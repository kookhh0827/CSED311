# CSED311 Computer Architecture

이 레포지토리는 CSED311 Computer Architecture (컴퓨터구조) 과목의 과제에 대한 모범 정답을 담고 있습니다.

모든 랩은 Verilog HDL 문법으로 작성되었으며, 다른 환경에서의 동작을 보장하지 않습니다.

문제가 있거나, 질문사항이 있는 경우 Issue에 남겨주시거나 연락 바랍니다.

## 목차
- [Lab 1: RTL Design](#lab-1-rtl-design)
- [Lab 2: Single Cycle CPU](#lab-2-single-cycle-cpu)
- [Lab 3: Multi-Cycle CPU](#lab-3-multi-cycle-cpu)
- [Lab 4-1: Pipelined CPU without Control](#lab-4-1-pipelined-cpu-without-control)
- [Lab 4-2: Full Pipelined CPU](#lab-4-2-full-pipelined-cpu)
- [Lab 5: Cache](#lab-5-cache)

## Lab 1: RTL Design
Verilog를 사용한 동기 회로 설계 및 구현에 초점을 맞추며, 자판기(Vending Machine)를 구현합니다. 

이 과제는 기본적인 RTL 설계 방법과 Verilog 사용법을 학습하는 데 목적이 있습니다.

## Lab 2: Single Cycle CPU
RISC-V ISA를 기반으로 한 Single Cycle CPU의 구현을 다룹니다. 

이 과제는 CPU의 Datapath와 Control Unit의 설계에 초점을 맞추며, 각종 명령어의 실행을 위한 구조를 설계합니다.

## Lab 3: Multi-Cycle CPU
하나의 명령어 처리를 여러 사이클에 걸쳐 수행하는 Multi-Cycle CPU 구현을 포함합니다. 

이는 자원 사용의 중복을 줄이고 효율성을 증가시키는 데 목표를 둡니다.

## Lab 4-1: Pipelined CPU without Control
Control flow 명령어를 제외하고 구현한 5단계 파이프라인 CPU에 대해 다룹니다. 

이 과제는 Control Bits, Stall, Data Forwarding 등의 구현에 대해 설명합니다.

## Lab 4-2: Full Pipelined CPU
Control Flow Instructions를 포함하는 Full Pipelined CPU 구현을 포함하며, Branch Prediction 기능과 여러 Branch Prediction 방법을 비교합니다.

## Lab 5: Cache
Data Cache 구현에 대해 다룹니다. 

Set-Associative Cache 디자인과 Write Policy(Write-allocate, Write-back)를 포함하며, Cache의 Read와 Write 동작, Asynchronous 및 Synchronous Logic 구현 방법을 상세히 설명합니다.
