classdef Signal<matlab.mixin.Copyable




    properties(Access='public')

        Name='Signal 1';
        Unit='inherit';
        SampleTime='0';
        OutputAfterFinalValue='Setting to zero';
        Interpolate='off';
        ZeroCross='off';
        IsBus='off';
        BusObject='Bus: BusObject';
    end

    methods(Access=protected)
        function cp=copyElement(obj)

            cp=copyElement@matlab.mixin.Copyable(obj);
            prop=properties(obj);
            for id=1:length(prop)
                cp.(prop{id})=obj.(prop{id});
            end
        end
    end

    methods(Access=public)
        function bool=areSignalPropertiesEqual(obj,Signal)
            bool=true;
            signalProperties=properties(Signal);
            for id=1:length(signalProperties)
                if strcmp(signalProperties{id},...
                    'Name')
                    continue;
                else

                    if~strcmp(Signal.(signalProperties{id}),...
                        obj.(signalProperties{id}))
                        bool=false;
                        break;
                    end
                end
            end
        end
    end

    methods(Static)
        function Signal=createSignalFromBlockHandle(blockH)
            Signal=Simulink.signaleditorblock.model.Signal;
            Signal.Name=get_param(blockH,'ActiveSignal');
            Signal.Unit=get_param(blockH,'Unit');
            Signal.SampleTime=get_param(blockH,'SampleTime');
            Signal.OutputAfterFinalValue=get_param(blockH,'OutputAfterFinalValue');
            Signal.Interpolate=get_param(blockH,'Interpolate');
            Signal.ZeroCross=get_param(blockH,'ZeroCross');
            Signal.IsBus=get_param(blockH,'IsBus');
            Signal.BusObject=get_param(blockH,'OutputBusObjectStr');
        end
    end
end