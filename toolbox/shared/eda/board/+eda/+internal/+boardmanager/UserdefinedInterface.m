


classdef UserdefinedInterface<eda.internal.boardmanager.Interface
    properties(SetAccess=private,GetAccess=private)
        SignalOrder;
    end

    properties(Constant)
        Name='User-defined I/O interface';
    end
    methods
        function obj=UserdefinedInterface
            obj=obj@eda.internal.boardmanager.Interface;
            obj.SignalOrder=containers.Map;
        end
    end

    methods

        function r=getFormInstruction(~)
            r=DAStudio.message('EDALink:boardmanagergui:UserIO_Table_Instruction');
        end

        function signal=addSignal(obj,Name)
            Key=upper(Name);
            if obj.SignalList.isKey(Key)
                error(message('EDALink:boardmanager:SignalExist',Name));
            end
            signal=eda.internal.boardmanager.Signal(Key);
            obj.SignalList(Key)=signal;
            obj.SignalOrder(Key)=obj.SignalList.length;
        end
        function indx=getSignalOrder(obj,Name)
            Key=upper(Name);
            indx=obj.SignalOrder(Key);
        end
        function validate(obj)
            if length(obj.SignalList.keys)<1
                error(message('EDALink:boardmanager:NoSignalDefined'));
            end
            signalNames=obj.SignalList.keys;
            for m=1:numel(signalNames)
                signal=obj.SignalList(signalNames{m});
                if strcmpi(signal.Direction,'out')||strcmpi(signal.Direction,'inout')
                    return;
                end
            end
            error(message('EDALink:boardmanager:NoOutputSignal'));
        end
    end
end


