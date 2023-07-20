classdef MessageHandler<matlabshared.asyncio.internal.MessageHandler




    methods(Access=public)
        function onError(~,data)
            try
                switch data.ID
                case "MATLAB:ble:ble:macBluetoothPoweredOff"

                    clear +matlabshared/+blelib/+internal/TransportFactory;

                    matlabshared.blelib.internal.localizedError(data.ID,data.Args{:});
                case "MATLAB:ble:ble:deviceProfileChanged"
                    if ispc





                        transport=matlabshared.blelib.internal.TransportFactory.getInstance.get;
                        transport.ServicesChangedErrorMap(data.Args{1})=true;
                    elseif ismac

                        matlabshared.blelib.internal.localizedError(data.ID,data.Args{:});
                    end
                otherwise


                    matlabshared.blelib.internal.localizedError(data.ID,data.Args{:});
                end
            catch e
                throwAsCaller(e);
            end
        end
    end
end