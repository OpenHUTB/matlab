classdef ExecuteCommands





    enumeration
        DISCOVER_PERIPHERALS_START("start_discover_peripherals")
        DISCOVER_PERIPHERALS_STOP("stop_discover_peripherals")
        CONNECT_PERIPHERAL("connect_peripheral")
        DISCONNECT_PERIPHERAL("disconnect_peripheral")
        GET_PERIPHERAL_STATE("get_peripheral_status")
        DISCOVER_SERVICES("discover_services")
        DISCOVER_CHARACTERISTICS("discover_characteristics")
        DISCOVER_DESCRIPTORS("discover_descriptors")
        READ_CHARACTERISTIC("read_characteristic")
        WRITE_CHARACTERISTIC("write_characteristic")
        SUBSCRIBE_CHARACTERISTIC("subscribe_characteristic")
        UNSUBSCRIBE_CHARACTERISTIC("unsubscribe_characteristic")
        GET_CHARACTERISTIC_STATUS("get_characteristic_status")
        READ_DESCRIPTOR("read_descriptor")
        WRITE_DESCRIPTOR("write_descriptor")


        REGISTER_CHARACTERISTIC_BUFFER("unused")
        UNREGISTER_CHARACTERISTIC_BUFFER("unused")
    end

    properties
String
    end

    methods
        function enum=ExecuteCommands(value)
            enum.String=value;
        end
    end
end