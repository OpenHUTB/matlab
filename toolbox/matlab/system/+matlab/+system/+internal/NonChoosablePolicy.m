classdef NonChoosablePolicy<matlab.system.internal.PolicyBase


%#codegen   



    properties(SetAccess=protected,Hidden)
        IsControlPropertyActive=false
    end

    methods
        function obj=NonChoosablePolicy(aName,aClient,aCPN,aIsTargetActive,aIsControlActive)
            coder.allowpcode('plain');
            obj@matlab.system.internal.PolicyBase(aName,aClient,aCPN,aIsTargetActive);

            obj.IsControlPropertyActive=aIsControlActive;
        end

        function flag=isTargetPropertyActive(obj,~,~)
            flag=obj.IsTargetPropertyActive;
        end

        function flag=isControlPropertyActive(obj,~)
            flag=obj.IsControlPropertyActive;
        end

        function flag=useProperty(~,~,~)
            flag=true;
        end
    end

    methods(Static)
        function props=matlabCodegenNontunableProperties(~)
            props={'IsControlPropertyActive'};
        end
    end
end
