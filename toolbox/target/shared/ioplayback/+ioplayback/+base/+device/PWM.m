classdef PWM<handle





%#codegen

    properties(Abstract)
AvailablePWMPins
AvailablePWMPinsName

PWMSyncs
    end

    methods
        function obj=PWM()
            coder.allowpcode('plain');


        end

        function ret=getPWMPinName(obj,pinNumber)
            if nargin<2
                ret=obj.AvailablePWMPinsName;
            else
                if isValidPWMPin(obj,pinNumber)
                    ret=obj.AvailablePWMPinsName{ismember(obj.AvailablePWMPins,pinNumber)};
                else
                    ret='';
                end
            end
        end

        function[ret,varargout]=isValidPWMPin(obj,pin)
            if isnumeric(pin)
                [ret,PinIdx]=ismember(pin,obj.AvailablePWMPins);
            else
                [ret,PinIdx]=ismember(pin,obj.AvailablePWMPinsName);
            end

            if nargout>1
                varargout{1}=PinIdx;
            end
        end

        function ret=getPWMPinNumber(obj,pinName)
            if nargin<2
                ret=obj.AvailablePWMPins;
            else
                if isValidPWMPin(obj,pinName)
                    for i=coder.unroll(1:numel(obj.AvailablePWMPinsName))
                        if isequal(obj.AvailablePWMPinsName{i},pinName)
                            ret=obj.AvailablePWMPins(i);
                            return;
                        end
                    end
                else
                    ret=[];
                end
            end
        end

        function ret=getMinimumPWMFrequency(~)
            ret=0;
        end
        function ret=getMaximumPWMFrequency(~)
            ret=1e9;
        end





































        function ret=isValidPWMSyncs(obj,Pin,SelectedPWMSync)%#ok<INUSD>
            ret=true;
        end
    end
end
