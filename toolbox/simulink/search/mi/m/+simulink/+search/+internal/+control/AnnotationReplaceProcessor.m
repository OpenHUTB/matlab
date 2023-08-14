

classdef AnnotationReplaceProcessor<simulink.search.internal.control.DefaultReplaceProcessor
    properties(Access=protected)
    end

    methods(Access=public)
        function obj=AnnotationReplaceProcessor()
            obj@simulink.search.internal.control.DefaultReplaceProcessor();
        end
    end

    methods(Access=protected)
        function generatePropertyName(this)
            this.m_replaceParam.propName=this.m_replaceData.propertyname;
        end

        function generateCurrentValue(this)
            if strcmp(this.m_replaceParam.propName,'name')
                annoUri=this.m_replaceParam.blkUri;
                currentName=get_param(annoUri,'name');
                if~strcmp(currentName,get_param(annoUri,'PlainText'))
                    this.m_replaceParam.replaceParam.errMsg=message(...
                    'simulink_ui:search:resources:ReplaceErrorPlainOnly',currentName...
                    ).getString();
                    return;
                end
            end
            generateCurrentValue@simulink.search.internal.control.DefaultReplaceProcessor(this);
        end
    end
end
