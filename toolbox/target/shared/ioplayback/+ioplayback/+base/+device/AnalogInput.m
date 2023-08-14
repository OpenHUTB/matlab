classdef AnalogInput<handle





%#codegen

    properties(Abstract)
AvailableAnalogPins
AvailableAnalogPinsName
AnalogExternalTriggerType
AnalogEventsID
    end

    methods
        function obj=AnalogInput()
            coder.allowpcode('plain');


        end

        function ret=getAnalogPinName(obj,pinNumber)
            if nargin<2
                ret=obj.AvailableAnalogPinsName;
            else
                if isValidAnalogPin(obj,pinNumber)
                    ret=obj.AvailableAnalogPinsName{ismember(obj.AvailableAnalogPins,pinNumber)};
                else
                    ret='';
                end
            end
        end

        function[ret,varargout]=isValidAnalogPin(obj,pin)
            if isnumeric(pin)
                [ret,PinIdx]=ismember(pin,obj.AvailableAnalogPins);
            else
                [ret,PinIdx]=ismember(pin,obj.AvailableAnalogPinsName);
            end

            if nargout>1
                varargout{1}=PinIdx;
            end
        end

        function ret=getAnalogPinNumber(obj,pinName)
            if nargin<2
                ret=obj.AvailableAnalogPins;
            else
                if isValidAnalogPin(obj,pinName)
                    for i=coder.unroll(1:numel(obj.AvailableAnalogPinsName))
                        if isequal(obj.AvailableAnalogPinsName{i},pinName)
                            ret=obj.AvailableAnalogPins(i);
                            return;
                        end
                    end
                else
                    ret=[];
                end
            end
        end

        function ret=isValidAnalogExternalTriggerType(obj,Pin,SelectedExternalTriggerType)%#ok<INUSD>
            ret=true;
        end

        function ret=isValidAnalogEventsID(obj,Pin,SelectedAnalogEventID)%#ok<INUSD>
            ret=true;
        end
    end
end

