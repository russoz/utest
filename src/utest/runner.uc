import { find_files } from 'utest.runner.discovery';
import { execute_suites } from 'utest.runner.executor';
import { create_reporter } from 'utest.runner.reporter';
import * as MockManager from 'utest.mock.manager';

export function run(options) {
	let jobs = int(options.jobs || 1);
	let color = !!options.color;
	let test_filter = options.filter;
	let reporter_type = options.reporter;

	// 1. Test Discovery
	let all_files = [];
	let bundle_work = [];

	for (let i = 0; i < length(options.bundles); i++) {
		let b = options.bundles[i];
		let files = find_files(b.pattern);
		if (length(files) > 0) {
			push(bundle_work, { name: b.name, files: files });
			for (let f in files) push(all_files, f);
		} else {
			warn(sprintf("[utest] warning: bundle '%s' matched no files for pattern '%s'\n",
				b.name, b.pattern));
		}
	}

	if (!length(bundle_work)) {
		die("No test files found for provided bundles.\n");
	}

	// find_real_module()/generate_standard_shim() resolve modules against THIS
	// process's REQUIRE_SEARCH_PATH, but lib_paths only ever reached the workers
	// (build_l_flags). Without this, a mocked module living outside ucode's
	// default path is invisible to the shim generator: no shim is created and
	// the mock silently has no effect. Appended, not unshifted, so user paths
	// never shadow framework modules — the same ordering build_l_flags() uses.
	for (let p in (options.lib_paths || [])) {
		push(REQUIRE_SEARCH_PATH, p + "/*.uc");
		push(REQUIRE_SEARCH_PATH, p + "/*.so");
	}

	// Set up shims for modules listed in config.mocks.
	options = MockManager.setup(options);

	let reporter = create_reporter(reporter_type, color, all_files, options.seed);

	// Run-wide context threaded to the executor. Defaults are applied once here so
	// the executor layers can read the fields directly without re-defaulting.
	let run_ctx = {
		reporter:   reporter,
		jobs:       jobs,
		filter:     test_filter,
		run_dir:    options.run_dir,
		src_dir:    options.src_dir,
		shim_paths: options.shim_paths || [],
		seed:       options.seed,
		timeout:    options.timeout || 60,
		lib_paths:  options.lib_paths || [],
		mocks:      keys(options.mocks || {}),
		prop_seed:  options.prop_seed
	};

	// 2. Execution Loop
	for (let i = 0; i < length(bundle_work); i++) {
		let b = bundle_work[i];
		reporter.bundle_start(b.name);
		let interrupted = execute_suites({ ...run_ctx, files: b.files, bundle: b.name });
		reporter.bundle_end(b.name);
		// A ^C during a -jN bundle only cancels that bundle's uloop; without this
		// break the next bundle would start a fresh worker fleet, so the user would
		// have to interrupt once per remaining bundle. Stop the run instead.
		if (interrupted) break;
	}

	reporter.summary();

	return (reporter.stats.failed === 0 && reporter.stats.errors === 0 && reporter.stats.fatals === 0);
};
