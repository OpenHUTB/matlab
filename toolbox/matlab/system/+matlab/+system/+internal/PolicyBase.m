classdef PolicyBase


%#codegen 



    properties(SetAccess=protected,Hidden)
        Name=''
        Client=''
        ControlPropertyName=''
        IsTargetPropertyActive=false
    end

    methods
        function obj=PolicyBase(aName,aClient,aCPN,aIsTargetActive)
            coder.allowpcode('plain');
            obj.Name=char(aName);
            obj.Client=char(aClient);
            obj.ControlPropertyName=char(aCPN);
            obj.IsTargetPropertyActive=aIsTargetActive;
        end
    end

    methods(Abstract)
        flag=isTargetPropertyActive(obj,sysObj,propName)
        flag=isControlPropertyActive(obj,sysObj)
        flag=useProperty(obj,sysObj,propName)
    end

    methods(Static)
        function props=matlabCodegenNontunableProperties(~)
            props={'Client','ControlPropertyName','IsTargetPropertyActive'};
        end
    end
end
