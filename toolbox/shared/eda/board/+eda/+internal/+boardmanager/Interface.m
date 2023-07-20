


classdef Interface<matlab.mixin.Copyable

    properties(Abstract,Constant)
        Name;
    end
    properties(SetAccess=private,GetAccess=protected)
        ParameterList;
    end
    properties(SetAccess=private,GetAccess=protected)
        SignalList;
    end
    methods
        function obj=Interface
            obj.SignalList=containers.Map;
            obj.ParameterList=containers.Map;
        end

        function r=getFormInstruction(obj)%#ok<MANU>
            r='';
        end
        function r=getSignalNames(obj)
            keys=obj.SignalList.keys;
            r=cell(1,numel(keys));
            for m=1:numel(keys)
                signal=obj.SignalList(keys{m});
                r{m}=signal.SignalName;
            end
        end

        function r=getOutputSignalNames(obj)
            all=obj.SignalList.keys;
            r=cell(0,1);
            for m=1:numel(all)
                signal=obj.SignalList(all{m});
                if strcmpi(signal.Direction,'out')||strcmpi(signal.Direction,'inout')
                    r{end+1}=signal.SignalName;%#ok<AGROW>
                end
            end
        end

        function validate(obj)
            keys=obj.SignalList.keys;
            for m=1:numel(keys)
                signal=obj.SignalList(keys{m});
                signal.validate;
            end
        end

        function r=getDescription(obj,Name)
            signal=getSignal(obj,Name);
            r=signal.Description;
        end
        function r=getDirection(obj,Name)
            signal=getSignal(obj,Name);
            r=signal.Direction;
        end
        function r=getBitWidth(obj,Name)
            signal=getSignal(obj,Name);
            r=num2str(signal.BitWidth);
        end
        function r=getIOStandard(obj,Name)
            signal=getSignal(obj,Name);
            r=signal.IOStandard;
        end
        function r=getFPGAPin(obj,Name)
            signal=getSignal(obj,Name);
            r=signal.FPGAPin;
        end
        function r=getSignal(obj,Name)
            Name=upper(Name);
            if~obj.SignalList.isKey(Name)
                error(message('EDALink:boardmanager:SignalNotExist',obj.Name,Name));
            end
            r=obj.SignalList(Name);
        end
        function signal=addSignal(obj,Name)
            Key=upper(Name);
            if obj.SignalList.isKey(Key)
                error(message('EDALink:boardmanager:SignalAlreadyExists',Name));
            end
            signal=eda.internal.boardmanager.Signal(Name);
            obj.SignalList(Key)=signal;
        end






        function Value=getParam(obj,Name)
            Value=obj.ParameterList(Name);
            if isempty(Value)
                Value='';
            end
        end
        function r=getParamNames(obj)
            r=obj.ParameterList.keys;
        end
        function setParam(obj,Name,Value)
            if~obj.ParameterList.isKey(Name)
                error(message('EDALink:boardmanager:InvalidParameterKey',Name,obj.Name));
            end
            obj.ParameterList(Name)=Value;
        end

        function setPin(obj,Name,FPGAPin,IOStandard)
            signal=getSignal(obj,Name);

            signal.FPGAPin=FPGAPin;
            if nargin==4
                signal.IOStandard=IOStandard;
            end
        end







    end


    methods(Access=protected)
        function signal=addSignalDefinition(obj,Name,Description,Direction,BitWidth,IOStandard)
            signal=addSignal(obj,Name);
            signal.Description=Description;
            signal.Direction=Direction;
            signal.BitWidth=BitWidth;
            if nargin>5
                signal.IOStandard=IOStandard;
            end
        end
        function addParameterDefinition(obj,Name,Default)
            obj.ParameterList(Name)=Default;
        end


        function cpObj=copyElement(obj)

            cpObj=copyElement@matlab.mixin.Copyable(obj);

            cpObj.ParameterList=eda.internal.boardmanager.copyContainersMap(obj.ParameterList);
            cpObj.SignalList=eda.internal.boardmanager.copyContainersMap(obj.SignalList);
        end
    end
end


