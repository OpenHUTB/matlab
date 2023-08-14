classdef DigitalIO<handle





%#codegen

    properties(Abstract)
AvailableDigitalPins
AvailableDigitalPinsName
    end

    methods
        function obj=DigitalIO()
            coder.allowpcode('plain');


        end

        function ret=getDigitalPinName(obj,pinNumber)
            if nargin<2
                ret=obj.AvailableDigitalPinsName;
            else
                if isValidDigitalPin(obj,pinNumber)
                    ret=obj.AvailableDigitalPinsName{ismember(obj.AvailableDigitalPins,pinNumber)};
                else
                    ret='';
                end
            end
        end

        function[ret,varargout]=isValidDigitalPin(obj,pin)
            if isnumeric(pin)
                [ret,PinIdx]=ismember(pin,obj.AvailableDigitalPins);
            else
                [ret,PinIdx]=ismember(pin,obj.AvailableDigitalPinsName);
            end

            if nargout>1
                varargout{1}=PinIdx;
            end
        end

        function ret=getDigitalPinNumber(obj,pinName)
            if nargin<2
                ret=obj.AvailableDigitalPins;
            else
                if isValidDigitalPin(obj,pinName)
                    for i=coder.unroll(1:numel(obj.AvailableDigitalPinsName))
                        if isequal(obj.AvailableDigitalPinsName{i},pinName)
                            ret=obj.AvailableDigitalPins(i);
                            return;
                        end
                    end
                else
                    ret=[];
                end
            end
        end
    end
end
