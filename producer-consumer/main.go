package main

import (
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"sync"
)

var bufferLock sync.Mutex
var bufferLockCond sync.Cond = *sync.NewCond(&bufferLock)
var bufferProducerLockCond sync.Cond = *sync.NewCond(&bufferLock)
var bufferConsumerLockCond sync.Cond = *sync.NewCond(&bufferLock)

func produce(index int, buffer *[]int, size int) {
	for {
		// time.Sleep(time.Second)
		value := rand.Intn(100)
		fmt.Printf("Producer[%d] Inserting value to queue: %d\n", index, value)
		bufferProducerLockCond.L.Lock()
		for len(*buffer) == size {
			bufferProducerLockCond.Wait()
		}
		*buffer = append(*buffer, value)
		fmt.Printf("Producer[%d]Buffer elements after inserting %d: %v\n", index, value, *buffer)
		bufferProducerLockCond.L.Unlock()
		bufferConsumerLockCond.Signal()
	}
}

func consume(index int, buffer *[]int, size int) {
	for {
		// time.Sleep(time.Second)
		bufferConsumerLockCond.L.Lock()
		for len(*buffer) == 0 {
			bufferConsumerLockCond.Wait()
		}
		value := (*buffer)[0]
		*buffer = (*buffer)[1:]
		fmt.Printf("Consumer[%d] Read value from buffer: %d\n", index, value)
		fmt.Printf("Consumer[%d] Buffer elements after reading %d: %v\n", index, value, *buffer)
		bufferConsumerLockCond.L.Unlock()
		bufferProducerLockCond.Signal()
	}
}

func main() {
	if len(os.Args) != 4 {
		fmt.Print("Provide proper parameters to mention the number of producers, consumers and buffers!")
		return
	}
	numProducers, err := strconv.Atoi(os.Args[1])
	if err != nil {
		fmt.Println("Please provide a valid value for number of producers")
		return
	}
	numConsumers, err := strconv.Atoi(os.Args[2])
	if err != nil {
		fmt.Println("Please provide a valid value for number of consumers")
		return
	}
	numBuffers, err := strconv.Atoi(os.Args[3])
	if err != nil {
		fmt.Println("Please provide a valid value for number of buffers")
		return
	}
	fmt.Printf("Number of producers, consumers and buffers: %d,%d,%d\n", numProducers, numConsumers, numBuffers)

	var buffer []int = make([]int, 0)

	wg := sync.WaitGroup{}
	for i := 0; i < numProducers; i++ {
		wg.Add(1)
		go produce(i, &buffer, numBuffers)
	}
	for i := 0; i < numConsumers; i++ {
		wg.Add(1)
		go consume(i, &buffer, numBuffers)
	}
	wg.Wait()
}
