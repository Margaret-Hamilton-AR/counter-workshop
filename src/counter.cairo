#[starknet::interface]
trait ICounter<T> {
    fn get_counter(self: @T) -> u32; //snapshot does not modify state
    fn increase_counter(ref self: T); // ref self due to modification of the state, (storage)
}

#[starknet::contract]
mod Counter {
    use super::ICounter;

    #[storage]
    struct Storage {
        counter: u32,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_counter_value: u32) {
        self.counter.write(initial_counter_value);
    }

    #[abi(embed_v0)]
    impl CounterImpl of ICounter<ContractState>{
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }

        fn increase_counter(ref self: ContractState) {
            let actual_value = self.counter.read();
            self.counter.write(actual_value + 1);
        }
    }
    }