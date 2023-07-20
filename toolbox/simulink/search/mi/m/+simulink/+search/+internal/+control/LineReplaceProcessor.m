

classdef LineReplaceProcessor<simulink.search.internal.control.DefaultReplaceProcessor
    properties(Access=protected)
    end

    methods(Access=public)
        function obj=LineReplaceProcessor()
            obj@simulink.search.internal.control.DefaultReplaceProcessor();
        end

        function[errMsg,newValue]=doReplace(this,blockCache,replaceData)
            errMsg='';
            newValue='';
            this.resetStateParams(blockCache,replaceData);
            portUri=this.m_blockCache.handle;
            this.m_replaceParam.originalValue=this.m_replaceData.highlighting.originalvalue;



            linePropName=this.generateLinePropertyName();
            if isempty(linePropName)
                this.m_replaceParam.blkUri=portUri;
                this.m_replaceParam.propName=this.m_replaceData.propertyname;
                try
                    this.m_replaceParam.currentValue=get_param(...
                    this.m_replaceParam.blkUri,...
                    this.m_replaceParam.propName...
                    );
                catch ex

                    this.m_replaceParam.errMsg=ex.message;
                end
            else
                try
                    lineUri=get_param(portUri,'line');
                    blockUri=get_param(lineUri,linePropName);
                    this.m_replaceParam.currentValue=get_param(blockUri,'Name');
                    if length(blockUri)>1
                        blockUri=blockUri(1);
                    end
                    this.m_replaceParam.blkUri=blockUri;
                    this.m_replaceParam.propName='Name';
                catch ex

                    this.m_replaceParam.errMsg=message(...
'simulink_ui:search:resources:ReplaceErrorNoLineInfo'...
                    ).getString();
                end
            end
            if~isempty(this.m_replaceParam.errMsg)
                errMsg=this.m_replaceParam.errMsg;
                return;
            end
            this.generateNewValue();


            if this.hasValueChanged()
                errMsg=this.m_replaceParam.errMsg;
                return;
            end

            this.doReplaceAction();


            if isempty(linePropName)
                try
                    newValue=get_param(...
                    this.m_replaceParam.blkUri,...
                    this.m_replaceParam.propName...
                    );
                catch ex
                    newValue=this.m_replaceParam.newValue;
                end
            else
                try
                    lineUri=get_param(portUri,'line');
                    blockUri=get_param(lineUri,linePropName);
                    newValue=get_param(blockUri,'Name');
                catch ex
                    newValue=this.m_replaceParam.newValue;
                end
            end
            errMsg=this.m_replaceParam.errMsg;
        end
    end

    methods(Access=protected)
        function linePropName=generateLinePropertyName(this)
            switch this.m_replaceData.propertyname
            case 'source'
                linePropName='SrcBlockHandle';
            case 'destination'
                linePropName='DstBlockHandle';
            otherwise
                linePropName='';
            end
        end
    end
end
