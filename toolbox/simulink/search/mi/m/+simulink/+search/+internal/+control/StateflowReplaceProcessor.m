

classdef StateflowReplaceProcessor<simulink.search.internal.control.DefaultReplaceProcessor
    properties(Access=protected)
        m_sfObj=[];
        m_isName=false;
        m_isSrcDest=false;
    end

    methods(Access=public)
        function obj=StateflowReplaceProcessor()
            obj@simulink.search.internal.control.DefaultReplaceProcessor();
            obj.m_sfObj=[];
            obj.m_isName=false;
            obj.m_isSrcDest=false;
        end

        function[errMsg,newValue]=doReplace(this,blockCache,replaceData)


            this.resetStateParams(blockCache,replaceData);
            try
                chartId=blockCache.handle;
                this.m_sfObj=sf('IdToHandle',chartId);
            catch ex
                errMsg=ex.message;
                return;
            end
            fieldName=replaceData.propertyname;
            this.m_isName=strcmp(fieldName,'name');
            this.m_isSrcDest=strcmp(fieldName,'source')||strcmp(fieldName,'destination');
            if this.m_isSrcDest
                this.m_replaceParam.currentValue='';
                if~isprop(this.m_sfObj,fieldName)...
                    ||isempty(this.m_sfObj.(fieldName))...
                    ||~isprop(this.m_sfObj.(fieldName),'Name')
                    errMsg=[fieldName,'is not set properly for ',this.m_sfObj.Path];
                    return;
                end
                this.m_sfObj=this.m_sfObj.(fieldName);
            end
            [errMsg,newValue]=doReplace@simulink.search.internal.control.DefaultReplaceProcessor(...
            this,blockCache,replaceData...
            );
        end
    end

    methods(Access=protected)
        function generatePropertyName(this)
            if this.m_isName
                if isprop(this.m_sfObj,'Name')
                    this.m_replaceParam.propName='Name';
                elseif isprop(this.m_sfObj,'PlainText')
                    this.m_replaceParam.propName='Text';
                else

                    this.m_replaceParam.propName='Name';
                end
                return;
            end
            if this.m_isSrcDest
                this.m_replaceParam.propName='Name';
                return;
            end
            generatePropertyName@simulink.search.internal.control.DefaultReplaceProcessor(...
this...
            );
        end

        function generateCurrentValue(this)
            try
                fieldName=this.m_replaceParam.propName;
                fieldValue=this.m_sfObj.(fieldName);


                if isnumeric(fieldValue)
                    fieldValue=num2str(fieldValue);
                end
                this.m_replaceParam.currentValue=fieldValue;
            catch ex

                this.m_replaceParam.errMsg=ex.message;
            end
        end

        function doReplaceAction(this)
            sf('BeginInternalUDDSets');
            try
                set(this.m_sfObj,this.m_replaceParam.propName,this.m_replaceParam.newValue);
            catch ME
                this.m_replaceParam.errMsg=ME.message;
            end
            sf('EndInternalUDDSets');
        end
    end
end
