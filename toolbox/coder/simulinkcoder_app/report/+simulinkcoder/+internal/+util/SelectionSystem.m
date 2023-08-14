classdef SelectionSystem<handle



    events
SelectedSidsChangedFromAnyStudio
    end

    methods(Static)
        function obj=instance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj=simulinkcoder.internal.util.SelectionSystem();
                uniqueInstance=obj;
            else
                obj=uniqueInstance;
            end
        end
    end

    methods(Access=private)
        function obj=SelectionSystem()
            GLUE2.Document.addDocumentOpenedListener...
            (@(doc)obj.onDocOpened(doc));
            docs=GLUE2.Document.getDocuments();
            for i=1:length(docs)
                obj.attachToDoc(docs{i});
            end
        end

        function attachToDoc(obj,doc)
            doc.addDocumentSelectionChangedListener(@(doc,old,new)...
            obj.onSelectionChanged(doc,old,new));
        end

        function onDocOpened(obj,doc)
            obj.attachToDoc(doc);
        end

        function onSelectionChanged(obj,doc,~,new)
            elements=new.getElements;
            data=simulinkcoder.internal.util.SelectionData(doc,elements);
            obj.notify('SelectedSidsChangedFromAnyStudio',data);
        end
    end
end

