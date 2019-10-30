# MemoryCache
Local in-memory cache for Nim.

# Todo
- [ ] Removing old keys in the background.

## Usage
```nim
import memory_cache
import times
import options

var cache: MemoryCache[string, string]

let value = cache.getOrCreate("key", proc (options: var CacheOptions): string = "Hello, world!")

echo value                  # Hello, world!
echo cache.get("key")       # Some("Hello, world!")
echo cache.get("wrong_key") # None[string]
```
