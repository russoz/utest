# utest

A modern, non-invasive testing framework for [ucode](https://ucode-lang.org/), OpenWrt's scripting language.

```js
import { describe, it, assert } from 'utest';

describe("add()", () => {
    it("returns the sum of two numbers", () => {
        assert.match(5, add(2, 3));
    });
});
```

```
[test/unit/add_test.uc] add_test.uc
  [PASS] returns the sum of two numbers
Summary:
  Suites: 1
  Total:  1
  Passed: 1
  Failed: 0
  Errors: 0
  Time:   4 ms
```

---

## Installation

**OpenWrt ≤ 24.10**:
```bash
opkg install ucode-utest
```

**OpenWrt ≥ 25.12**:
```bash
apk add ucode-utest
```

---

## Documentation

**[ucode-lang.org/utest](https://ucode-lang.org/utest/)**

| | |
| :--- | :--- |
| [Tutorials](https://ucode-lang.org/utest/tutorials/) | Start here — write your first test, mock, and assertion |
| [How-to Guides](https://ucode-lang.org/utest/how-to/) | Recipes for mocking, CI, filtering, custom proxies, and more |
| [Reference](https://ucode-lang.org/utest/reference/) | CLI flags, DSL, assertion and mock API |
| [Explanation](https://ucode-lang.org/utest/explanation/) | Design decisions and architecture |

---

## License

MIT — see [LICENSE](LICENSE).
