




classdef MessageBeautifier<handle
    methods(Access=public)
        function results=emitExceptionHTML(this,me)
            results='';
            if~isempty(me)
                numberOfCauses=length(me.cause);
                if numberOfCauses>0
                    listData=Advisor.List;
                    listData.setCollapsibleMode('all');
                    for causeIdx=1:numberOfCauses
                        ex=me.cause{causeIdx};
                        listData.addItem(this.emitExceptionHTML(ex));
                    end
                    results=[me.message,listData.emitHTML];
                else
                    results=me.message;
                end
            end
        end
    end


    methods(Static,Access=public)
        function results=getHTMLTextFromMessages(messages)
            results='';
            if~isempty(messages)
                listData=Advisor.List;
                listData.setCollapsibleMode('all')
                cellfun(@(msg)listData.addItem(MSLDiagnostic(msg).message),messages);
                results=listData.emitHTML;
            end
        end

        function blockName=beautifyBlockName(blockName,blkH)
            blockName=Simulink.ModelReference.Conversion.MessageBeautifier.createHyperlinkString(...
            blockName,sprintf('matlab: hilite_system(Simulink.ID.getHandle(''%s''))',Simulink.ID.getSID(blkH)));
        end

        function modelName=beautifyModelName(modelName)
            modelName=Simulink.ModelReference.Conversion.MessageBeautifier.createHyperlinkString(...
            getfullname(modelName),sprintf('matlab: open_system(Simulink.ID.getHandle(''%s''))',Simulink.ID.getSID(modelName)));
        end

        function newString=createSDIHyperlink(orgString,baselineRun,currentRun)
            commandString=sprintf('matlab: Simulink.SDIInterface.compare(%d, %d)',baselineRun,currentRun);
            newString=Simulink.ModelReference.Conversion.MessageBeautifier.createHyperlinkString(orgString,commandString);
        end

        function newString=createRestoreHyperLink(orgString)
            commandString='matlab: Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.restore';
            newString=Simulink.ModelReference.Conversion.MessageBeautifier.createHyperlinkString(orgString,commandString);
        end

        function results=createHyperlinkString(strbuf,hyperlinkStr)
            results=sprintf('<a href="%s">%s</a>',hyperlinkStr,strbuf);
        end
    end
end
