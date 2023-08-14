classdef SimulinkProvider<matlab.internal.project.unsavedchanges.LoadedFileProvider




    methods(Access=public)
        function loadedFiles=getLoadedFiles(~)
            import matlab.internal.project.unsavedchanges.LoadedFile;
            import matlab.internal.project.unsavedchanges.Property;

            loadedFiles=LoadedFile.empty(1,0);
            if~isSimulinkStarted
                return;
            end

            bds=Simulink.allBlockDiagrams;
            if isempty(bds)
                return;
            end

            filePaths=string(get_param(bds,"FileName"));
            neverSaved=strlength(filePaths)==0;
            filePaths(neverSaved)=string(get_param(bds(neverSaved),"Name"));

            modelMap=containers.Map;

            for n=1:length(bds)
                filePath=filePaths(n);
                if~modelMap.isKey(filePath)
                    modelMap(filePath)=Property.empty;
                end

                if get_param(bds(n),"Dirty")=="on"
                    modelMap(filePath)=unique([modelMap(filePath),Property.Unsaved]);
                end
                if get_param(bds(n),"SimulationStatus")~="stopped"
                    modelMap(filePath)=unique([modelMap(filePath),Property.Simulating]);
                end
            end



            [cnt,file]=groupcounts(filePaths);
            for n=1:length(cnt)
                if cnt(n)>1
                    modelMap(file{n})=[modelMap(file{n}),Property.InternalTestHarnessOpen];
                end
            end

            for k=keys(modelMap)
                loadedFiles(end+1)=LoadedFile(k{1},modelMap(k{1}));%#ok<AGROW>
            end
        end

        function save(~,file)
            save_system(file,SaveDirtyReferencedModels=true);
        end

        function open(~,file)
            open_system(file);
        end

        function discard(~,file)
            close_system(file,0);
        end

        function autoClose=isAutoCloseEnabled(~)
            autoClose=true;
        end
    end
end
