


classdef AnnotationsReadOnlyChecker<simulink.search.internal.model.ReadOnlyChecker
    methods(Access=public)
        function obj=AnnotationsReadOnlyChecker()
        end

        function checkerName=getName(this)
            checkerName='AnnotationsReadOnlyChecker';
        end

        function dependsOnProp=dependsOnPropertyName(this)
            dependsOnProp=true;
        end

        function isReadOnly=check(this,objectUri,propertyname)

            import simulink.search.internal.model.AnnotationsReadOnlyChecker;
            isReadOnly=false;

            try
                objectType=get_param(objectUri,'Type');
                if strcmp(objectType,'annotation')&&strcmp(propertyname,'Name')
                    isReadOnly=strcmp(get_param(objectUri,'Interpreter'),'rich');
                end
            catch ex

                annoObj=sf('IdToHandle',objectUri);
                if isa(annoObj,'Stateflow.Annotation')
                    isReadOnly=strcmp(annoObj.Interpretation,'RICH');
                end
            end
        end

        function msg=getMessage(this,blockUri,propertyname)
            msg=message(...
            'simulink_ui:search:resources:AnnotationRichTextMessage').getString();
        end
    end
end
