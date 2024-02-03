#[starknet::interface]
trait ICounter<T> {
    fn get_counter(self: @T) -> u32; //snapshot does not modify state
    fn increase_counter(ref self: T); // ref self due to modification of the state, (storage)
}



#[starknet::contract]
mod Counter {
    use super::ICounter;
    use kill_switch::{IKillSwitchDispatcher, IKillSwitchDispatcherTrait};
    use starknet::ContractAddress;
    
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CounterIncreased: CounterIncreased,
        }

    #[derive(Drop, starknet::Event)]
    struct CounterIncreased {
        counter: u32
    }

    #[storage]
    struct Storage {
        counter: u32,
        kill_switch: IKillSwitchDispatcher,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_counter_value: u32, kill_switch_address: ContractAddress) {
        self.counter.write(initial_counter_value);
        let dispatcher = IKillSwitchDispatcher { contract_address: kill_switch_address };
        self.kill_switch.write(dispatcher);
    }

    #[abi(embed_v0)]
    impl CounterImpl of ICounter<ContractState>{
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }

        fn increase_counter(ref self: ContractState) {
            let is_active = self.kill_switch.read().is_active();
            if is_active {
                let actual_value = self.counter.read();
                let new_counter = actual_value + 1;
                self.counter.write(new_counter);
                self.emit(CounterIncreased {counter: new_counter})

            }

        }
    }
    }
