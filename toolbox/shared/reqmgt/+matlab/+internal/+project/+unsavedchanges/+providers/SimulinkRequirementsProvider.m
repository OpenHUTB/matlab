classdef SimulinkRequirementsProvider<matlab.internal.project.unsavedchanges.LoadedFileProvider

    methods(Access=public)
        function loadedFiles=getLoadedFiles(~)
            import matlab.internal.project.unsavedchanges.LoadedFile;
            reqSets=slreq.data.ReqData.getInstance.getLoadedReqSets();
            linkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();

            loadedReqs=arrayfun(@i_makeLoadedFile,reqSets);
            loadedLinks=arrayfun(@i_makeLoadedFile,linkSets);
            loadedFiles=[loadedReqs,loadedLinks];
            if isempty(loadedFiles)
                loadedFiles=LoadedFile.empty(1,0);
            end
        end

        function discard(~,filePath)
            [~,fileName,~]=fileparts(filePath);
            slreq.utils.slproject.discardRequirementsFile(fileName,filePath);
        end

        function save(~,filePath)
            [~,fileName,~]=fileparts(filePath);
            slreq.utils.slproject.saveRequirementsFile(fileName,filePath);
        end

        function open(~,filePath)
            [~,fileName,~]=fileparts(filePath);
            slreq.utils.slproject.openRequirementsFile(fileName,filePath);
        end

        function autoClose=isAutoCloseEnabled(~)
            autoClose=true;
        end
    end
end

function file=i_makeLoadedFile(reqSet)
    import matlab.internal.project.unsavedchanges.Property;
    if(reqSet.dirty)
        props=Property.Unsaved;
    else
        props=Property.empty;
    end

    file=matlab.internal.project.unsavedchanges.LoadedFile(reqSet.filepath,props);
end
