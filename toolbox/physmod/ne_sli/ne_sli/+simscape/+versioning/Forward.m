classdef Forward<matlab.mixin.CustomDisplay



    properties
        OldSimscapePath{simscape.versioning.internal.mustBeSimscapePath}=''
        NewSimscapePath{simscape.versioning.internal.mustBeSimscapePath}=''

        OldSimulinkPath{simscape.versioning.internal.mustBeSimulinkPath}=''
        NewSimulinkPath{simscape.versioning.internal.mustBeSimulinkPath}=''

        Version(1,1)simscape.versioning.version=simscape.versioning.version
        NewVersion simscape.versioning.version=simscape.versioning.version.empty
    end

    methods(Hidden=true)
        function validate(obj)
            props=["OldSimscapePath"
"NewSimscapePath"
"OldSimulinkPath"
            "NewSimulinkPath"]';
            for prop=props
                if isempty(obj.(prop))
                    pm_error('physmod:ne_sli:versioning:EmptyProperty',prop);
                end
            end
        end
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(obj)
            if~isscalar(obj)
                propgrp=getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                verfcn=@(ver)strjoin(...
                arrayfun(@(x)char(x),ver,...
                'UniformOutput',false),...
                '    ');
                propList=struct(...
                'Version',verfcn(obj.Version),...
                'OldSimscapePath',obj.OldSimscapePath,...
                'OldSimulinkPath',obj.OldSimulinkPath,...
                'NewSimscapePath',obj.NewSimscapePath,...
                'NewSimulinkPath',obj.NewSimulinkPath,...
                'NewVersion',verfcn(obj.NewVersion));
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end
end