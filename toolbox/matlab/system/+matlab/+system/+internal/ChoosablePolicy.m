classdef ChoosablePolicy<matlab.system.internal.PolicyBase


%#codegen



    methods
        function obj=ChoosablePolicy(aName,aClient,aCPN,aIsTargetActive)
            coder.allowpcode('plain');
            obj@matlab.system.internal.PolicyBase(aName,aClient,aCPN,aIsTargetActive);
        end

        function flag=isTargetPropertyActive(obj,sysObj,~)
            if getControlValue(obj,sysObj)
                flag=false;
            else
                flag=obj.IsTargetPropertyActive;
            end
        end

        function flag=isControlPropertyActive(~,~)
            flag=true;
        end

        function flag=useProperty(obj,sysObj,~)
            flag=~getControlValue(obj,sysObj);
        end
    end

    methods(Access=private)
        function value=getControlValue(obj,sysObj)
            controlValue=sysObj.(obj.ControlPropertyName);
            if isempty(controlValue)||~controlValue
                value=false;
            else
                value=true;
            end
        end

    end
end
