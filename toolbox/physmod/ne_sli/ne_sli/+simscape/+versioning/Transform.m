classdef Transform<matlab.mixin.CustomDisplay



    properties
        SimscapePath{simscape.versioning.internal.mustBeSimscapePath}=''
        Version(1,1)simscape.versioning.version
Modify
        LegacySimscapePath{simscape.versioning.internal.mustBeSimscapePath}=''
    end

    methods(Hidden=true)
        function validate(obj)
            props=["SimscapePath"
            ]';
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
                propList=struct(...
                'SimscapePath',obj.SimscapePath,...
                'Version',sprintf('%s',obj.Version),...
                'Modify',obj.Modify,...
                'LegacySimscapePath',obj.LegacySimscapePath);
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end
end