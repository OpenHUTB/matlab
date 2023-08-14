classdef MatlabEditorProvider<matlab.internal.project.unsavedchanges.LoadedFileProvider




    methods(Access=public)
        function loadedFiles=getLoadedFiles(~)
            docs=matlab.desktop.editor.getAll;

            loadedFiles=arrayfun(@i_makeLoadedFile,docs);
            if isempty(loadedFiles)
                loadedFiles=matlab.internal.project.unsavedchanges.LoadedFile.empty(1,0);
            end
        end

        function save(~,file)
            matchingDocument=matlab.desktop.editor.findOpenDocument(file);
            if~isempty(matchingDocument)
                matchingDocument.save;
            end
        end

        function open(~,file)
            matlab.desktop.editor.openDocument(file);
        end

        function discard(~,file)
            matchingDocument=matlab.desktop.editor.findOpenDocument(file);
            if~isempty(matchingDocument)
                matchingDocument.closeNoPrompt;
            end
        end

        function autoClose=isAutoCloseEnabled(~)
            autoClose=false;
        end
    end
end

function file=i_makeLoadedFile(doc)
    if(doc.Modified)
        props=matlab.internal.project.unsavedchanges.Property.Unsaved;
    else
        props=matlab.internal.project.unsavedchanges.Property.empty;
    end

    file=matlab.internal.project.unsavedchanges.LoadedFile(doc.Filename,props);
end
