

classdef DocumentListener<handle

    methods(Access=public)
        function obj=DocumentListener()
            import simulink.search.internal.finderModel.SelectionListener;
            obj.openListener='';
            obj.selectionListener=SelectionListener.empty;
        end

        function reset(this)

            selectionListeners=this.selectionListener;
            if~isempty(selectionListeners)
                for i=1:length(selectionListeners)
                    doc=selectionListeners(i).document;
                    if doc.isvalid
                        listener=selectionListeners(i).listener;
                        doc.removeDocumentSelectionChangedListener(listener);
                    end
                end
            end


            if~isempty(this.openListener)
                GLUE2.Document.removeDocumentOpenedListener(this.openListener);
            end


            this.openListener='';
            this.selectionListener=SelectionListener.empty;
        end

        function removeInvalidDocument(this)
            selectionListeners=this.selectionListener;
            if~isempty(selectionListeners)
                invalidIdx=[];
                for i=1:length(selectionListeners)
                    doc=selectionListeners(i).document;
                    if~doc.isvalid
                        invalidIdx=[invalidIdx,i];
                    end
                end
                selectionListeners(invalidIdx)=[];
            end
            this.selectionListener=selectionListeners;
        end
    end

    properties(Access=public)
        openListener='';
        selectionListener=simulink.search.internal.finderModel.SelectionListener.empty;
    end
end
