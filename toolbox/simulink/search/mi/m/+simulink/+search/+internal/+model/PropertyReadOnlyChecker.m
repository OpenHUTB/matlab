


classdef PropertyReadOnlyChecker<simulink.search.internal.model.ReadOnlyChecker

    properties(Constant,Access=protected)
        READONLY_PROPERTIES=containers.Map(...
        {'CompiledActiveChoiceControl','CompiledActiveChoiceBlock'},...
        {...
        '',...
''...
        }...
        );
    end

    methods(Access=public)
        function obj=PropertyReadOnlyChecker()
        end

        function checkerName=getName(this)
            checkerName='PropertyReadOnlyChecker';
        end

        function dependsOnProp=dependsOnPropertyName(this)
            dependsOnProp=true;
        end

        function isReadOnly=check(this,blockUri,propertyname)
            import simulink.search.internal.model.PropertyReadOnlyChecker;
            isReadOnly=isKey(...
            PropertyReadOnlyChecker.READONLY_PROPERTIES,...
propertyname...
            );
        end

        function msg=getMessage(this,blockUri,propertyname)
            msg=message(...
            'simulink_ui:search:resources:ReadOnlyPropertyMessage',...
propertyname...
            ).getString();
        end
    end
end
