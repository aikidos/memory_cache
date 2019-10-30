import tables
import times
import options

type
  MemoryCache*[A, B] = object
    ## Represents a local in-memory cache.
    table: Table[A, CacheEntry[B]]
  CacheOptions* = object
    ## Represents a set of eviction and expiration details for a specific cache entry.
    expiration*: Option[DateTime]
    ## Value that indicates whether a cache entry should be evicted at a specified point in time.
  CacheEntry[B] = object
    options: CacheOptions
    value: B

proc hasKey*[A, B](cache: MemoryCache[A, B], key: A): bool =
  ## Determines whether the `MemoryCache[A, B]` contains the specified key.
  if cache.table.hasKey(key):
    let expiration = cache.table[key].options.expiration
    expiration.isNone or expiration.get > now()
  else: false

proc get*[A, B](cache: MemoryCache[A, B], key: A): Option[B] =
  ## Gets the value associated with the specified key.
  if cache.hasKey(key): some(cache.table[key].value)
  else: none(B)

proc getOrCreate*[A, B](cache: var MemoryCache[A, B], key: A, factory: proc(options: var CacheOptions): B): B =
  ## Gets the value associated with the specified key, or if the key can not be found, creates and insert value using the `factory` function.
  let cachedValue = cache.get(key)
  if cachedValue.isSome: cachedValue.get
  else: 
    var options = CacheOptions(expiration: none(DateTime))
    let value = factory(options)
    cache.table[key] = CacheEntry[B](options: options, value: value)
    value

proc set*[A, B](cache: var MemoryCache[A, B], key: A, value: B, options: CacheOptions) =
  ## Inserts a cache entry into the cache by using a key and a value.
  cache.table[key] = CacheEntry[B](options: options, value: value)

proc set*[A, B](cache: var MemoryCache[A, B], key: A, value: B, expiration: DateTime) =
  ## Inserts a cache entry into the cache by using a key and a value.
  cache.set(key, value, CacheOptions(expiration: expiration))

proc set*[A, B](cache: var MemoryCache[A, B], key: A, value: B) =
  ## Inserts a cache entry into the cache by using a key and a value.
  cache.set(key, value, CacheOptions(expiration: none(DateTime)))

proc del*[A, B](cache: var MemoryCache[A, B], key: A) =
  ## Removes a cache entry from the cache.
  cache.table.del(key)