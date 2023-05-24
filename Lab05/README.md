# Lab5: Cache

## Introduction

이전 Lab 까지는 Memory R/W를 1cycle에 할 수 있는 마법과 같았다.
하지만, 이전 Lab에서는 실제와 유사한 Memory의 최적화를 위해
효율적으로 메모리를 사용하기 위해 Cache를 구현한다.
Memory에 Instruction Memory, Data Memory가 존재하듯
Cache에도 Instruction Cache와 Data Cache가 존재하는데,
이번 Lab에서는 Data Cache만 구현한다.

## Design

Cache의 Write Policy는 다음과 같다.

- Write-allocate
- Write-back

위 Write Policy에 따른 Cache의 작동 방식을 나타내보면 다음과 같다.

![Cache Mechanism](./image_resource/Cache_Mechanism)

Lab instruction에 따른면 Cache Size는 256Byte로 정해져있다.
이번 과제에서는 해당 Cache Size를 고정시키며,
    다음 3가지의 변수를 매개변수화하여 매개변수에 따라
    다양한 Cache를 구현할 수 있도록 한다.

- \# sets
- \# ways
- Line Size

### Replacement Policy: LRU

N-way Associative Cache의 구현을 위해서 어느 bank의 cache를 replace
할 지에 대한 기준이 필요하다.
여러 방법 중 LRU를 택했는데, 동일 index 중 가장 나중에 사용된 bank의
line을 evict하는 방법을 택했다.
사실 실행하는 Program에 따라 Optimal Replacmeent Policy가 다를텐데,
일반적으로 가장 이전에 사용한 Cache가 다음에 사용할 가능성이 가장 낮을 것이라고
판단하여 LRU를 사용하였다.

## Implementation

### Cache: Write - Synchronous, Read - Asynchronous

#### Parameter

- LINE\_SIZE
- NUM\_SETS
- NUM\_WAYS

#### Input

- [31:0] `addr`: Memory Address
- `mem\_read`: mem\_read control bit
- `mem\_write`: mem\_write control bit
- [31:0] `din`: data to write in memory

#### Output

- `is\_ready`: Indicates whether it's able to retrieve data immediately from memory
- `is\_output\_valid`: It's true if both `is\_ready` and `is\_hit` are true
- [31:0] `dout`: Data of memory with given address
- `is\_hit`: Indicates whether it is a cache hit

<!----
Need to Fill in Specific Mechanism
----->

### Hazard Detection: Modified

기존에 구현된 Hazard Detection 에서 다음 조건이 추가되었다.

``` verilog
if ((EX_MEM_mem_read || EX_MEM_mem_write) && !(MEM_is_hit && MEM_is_output_valid && MEM_is_ready)) begin
    is_stall = 1;
    cache_stall = 1;
end
else begin
    cache_stall = 0;
end
```
<!----
Why is is_stall 1?
----->

현재 Mem 단계에서 R/W 를 하고 있으나, is\_hit&&is\_ready&&is\_output\_valid == 1 이 아니라면
아직 메모리에서 데이터를 읽어오고 있거나 제대로 된 데이터가 아니므로 Stall 한다.

## Discussion

기존의 magic memory가 아닌 실제 memory와 같이 delay가 있는 상황에서
최적화를 위해 Cache를 구현해보면서 이론으로만 알던 Cache에 대해
깊에 알 수 있는 기회가 되었다.

## Conclusion

### Cycle 수 비교

|# Cycles|Directed Mapped Cache|2 way-associative Cache|
|:------:|:---:|:---:|
|Naive|91610|96778|
|OPT|97812|88982|

### Hit ratio 비교

<!----
Need to Fill in Hit Ratio
Cache hit ratio comparison
For each matmul, for each # of sets and # of ways
----->

<!----
Needs some comments
----->
