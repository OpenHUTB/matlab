


classdef CosimWizardPara<handle
    properties(SetAccess=private)
        Name='Name'
        FullName=''
        Module='Module'
        Path='Path'
defaultValue
Value
        overriddenFlag=false
        globalFlag=false
Type
    end
    methods
        function obj=CosimWizardPara(Name,FullName,Type,defaultValue)
            if(nargin~=3)
                sprintf('Internal Error: CosimWizardPara constructer requires three attributes');
            end
            obj.Name=Name;
            obj.FullName=FullName;
            obj.Type=Type;
            obj.defaultValue=defaultValue;
            obj.globalFlag=false;

        end
        function overridePara(obj,value)
            obj.overriddenFlag=true;
            obj.Value=value;
        end
        function setGlobal(obj)
            obj.globalFlag=true;
        end


        function obj=createGlobalPara(this)
            obj=CosimWizardPara(this.Name,'',this.defaultValue);
            obj.globalFlag=true;
        end
    end
end
