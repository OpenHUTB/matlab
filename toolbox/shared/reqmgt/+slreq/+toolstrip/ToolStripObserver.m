
classdef ToolStripObserver<handle

    properties






        context;



        appName;
    end

    methods

        function this=ToolStripObserver()
            this.appName='requirementsEditorApp';
        end

        function onReqSpreadSheetViewChanged(this,~,eventData)










            if isa(eventData,'slreq.gui.ReqSpreadSheetViewChanged')
                slreq.toolstrip.switchView(eventData.isReqsView,this.context);
            end
        end

        function onReqSpreadSheetSelectionChanged(this,x,eventData)

            if isa(this.context,'slreq.toolstrip.ReqEditorAppContext')




                if isa(eventData,'slreq.gui.ReqSpreadSheetSelectionChanged')
                    this.context.isReqSetSelected=eventData.isReqSetSelected();
                    newTypeChain=setdiff(this.context.TypeChain,{'disableTraceDiagramButton','enableTraceDiagramButton'},'stable');
                    if isempty(eventData.selection)||length(eventData.selection)>1
                        newTypeChain{end+1}='disableTraceDiagramButton';
                    else
                        newTypeChain{end+1}='enableTraceDiagramButton';
                    end

                    this.context.TypeChain=newTypeChain;
                end
            end
        end

        function onSpreadSheetToggled(this,~,eventData)
            if isa(this.context,'slreq.toolstrip.ReqEditorAppContext')
                if isa(eventData,'slreq.gui.ReqSpreadSheetToggled')
                    this.context.isReqBrowserVisible=eventData.state;
                end
            end
        end
    end

end