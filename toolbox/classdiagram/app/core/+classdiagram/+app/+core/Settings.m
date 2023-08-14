classdef Settings
    properties
        ShowAssociations=0;
        IsDebug=0;
        ShowHidden=1;
        ShowHandle=0;
        ShowMixins=0;
        ShowIndirectInheritance=1;
        ShowDetails=0;
        MaxEntities=300;
        InitiallyCollapsed=1;
    end

    properties(Transient)
        ShowPackageNames=1;
    end

    methods(Static)
        function cmd=propNameToFuncName(cmd)
            cmd(1)=lower(cmd(1));
        end

        function value=getDefaultValue(setting)
            defaultSettings=classdiagram.app.core.Settings();
            value=defaultSettings.(setting);
        end

    end

    methods
        function obj=Settings
        end

        function self=set(self,key,val)
            self.(key)=val;
        end

        function val=get(self,key)
            val=self.(key);
        end
    end
end