

classdef DefaultReplaceProcessor<simulink.search.internal.control.ReplaceProcessor
    properties(Access=protected)
    end

    methods(Access=public)
        function obj=DefaultReplaceProcessor()
            obj@simulink.search.internal.control.ReplaceProcessor();
        end

        function resetStateParams(this,blockCache,replaceData)
            this.m_blockCache=blockCache;
            this.m_replaceData=replaceData;
            import simulink.search.internal.model.DoReplaceParam;
            this.m_replaceParam=DoReplaceParam();
        end

        function[errMsg,newValue]=doReplace(this,blockCache,replaceData)
            errMsg='';
            newValue='';
            this.resetStateParams(blockCache,replaceData);


            this.m_replaceParam.blkUri=this.m_blockCache.handle;
            this.m_replaceParam.originalValue=this.m_replaceData.highlighting.originalvalue;
            this.generatePropertyName();
            this.generateCurrentValue();
            if~isempty(this.m_replaceParam.errMsg)
                errMsg=this.m_replaceParam.errMsg;
                return;
            end


            this.generateNewValue();
            if this.hasValueChanged()
                errMsg=this.m_replaceParam.errMsg;
                return;
            end
            if~isempty(this.m_replaceParam.errMsg)
                errMsg=this.m_replaceParam.errMsg;
                return;
            end

            this.doReplaceAction();


            this.generateCurrentValue();
            newValue=this.m_replaceParam.currentValue;
            errMsg=this.m_replaceParam.errMsg;
            if isempty(errMsg)&&~strcmp(this.m_replaceParam.currentValue,this.m_replaceParam.newValue)
                errMsg=DAStudio.message('dastudio:finder:UnexpectedPropertyValueAfterReplace',this.m_replaceParam.currentValue);
                this.m_replaceParam.errMsg=errMsg;
            end
        end
    end

    methods(Access=protected)

        function generatePropertyName(this)
            if~isempty(this.m_replaceData.getRealPropertyName())
                this.m_replaceParam.propName=this.m_replaceData.getRealPropertyName();
            else
                this.m_replaceParam.propName=this.m_replaceData.propertyname;
            end
        end

        function generateCurrentValue(this)
            try
                this.m_replaceParam.currentValue=get_param(...
                this.m_replaceParam.blkUri,this.m_replaceParam.propName...
                );
            catch ex

                if strcmp(ex.identifier,'Simulink:Commands:InvSimulinkObjHandle')
                    this.m_replaceParam.errMsg=DAStudio.message('dastudio:finder:ObjectDoesNotExist');
                else
                    this.m_replaceParam.errMsg=ex.message;
                end
            end
        end

        function generateNewValue(this)
            this.m_replaceParam.newValue=this.m_replaceData.getReplacePreview();
        end

        function valueChanged=hasValueChanged(this)
            valueChanged=~strcmp(...
            this.m_replaceParam.currentValue,this.m_replaceParam.originalValue...
            );
            if valueChanged

                valueChanged=~strcmp(...
                this.m_replaceParam.currentValue,this.m_replaceParam.newValue...
                );
                if valueChanged
                    this.m_replaceParam.errMsg=message('simulink_ui:search:resources:ReplaceErrorDiffValue',...
                    this.m_replaceParam.currentValue,...
                    this.m_replaceParam.originalValue...
                    ).getString();
                end
            end
        end

        function doReplaceAction(this)
            try
                set_param(...
                this.m_replaceParam.blkUri,...
                this.m_replaceParam.propName,...
                this.m_replaceParam.newValue...
                );


                try
                    ownerSys=get_param(this.m_replaceParam.blkUri,'Parent');
                    editors=GLUE2.Util.findAllEditors(ownerSys);
                    if~isempty(editors)

                        numEditors=length(editors);
                        for i=1:numEditors
                            editor=editors(i);
                            if editor.isVisible
                                simulink.search.internal.Util.clearUndoRedoForEditor(editor);
                                break;
                            end
                        end
                    end
                catch
                end

            catch ex

                this.m_replaceParam.errMsg=ex.message;
            end
        end
    end
end
