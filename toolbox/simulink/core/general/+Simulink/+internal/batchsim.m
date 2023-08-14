function job=batchsim(simInputs,varargin)





    try

        modelName=simInputs.validateModelNames();

        if~bdIsLoaded(modelName)
            load_system(modelName);
            oc=onCleanup(@()bdclose(modelName));
        end

        p=inputParser;
        p.KeepUnmatched=true;
        defaultOptions=Simulink.SimulationManager.DefaultOptions;
        f=fieldnames(defaultOptions);
        for i=1:numel(f)
            addParameter(p,f{i},defaultOptions.(f{i}));
        end
        addParameter(p,'AllowParallelSimulations',true);

        parse(p,varargin{:});


        filesForAnalysis=cell.empty;
        setupFcn=p.Results.SetupFcn;
        if~isempty(setupFcn)
            fhinfo=functions(obj.SetupFcn);
            if~isempty(fhinfo.file)
                filesForAnalysis{end+1}=fhinfo.file;
            end
        end

        cleanupFcn=p.Results.CleanupFcn;
        if~isempty(cleanupFcn)
            fhinfo=functions(obj.CleanupFcn);
            if~isempty(fhinfo.file)
                filesForAnalysis{end+1}=fhinfo.file;
            end
        end

        filesToAttach=matlab.codetools.requiredFilesAndProducts(filesForAnalysis);


        [preSimDeps,ia,~]=unique(cellfun(@char,{simInputs.PreSimFcn},'UniformOutput',false));
        for i=1:numel(preSimDeps)
            if~isempty(preSimDeps{i})
                fhinfo=functions(simInputs(ia(i)).PreSimFcn);
                if~isempty(fhinfo.file)
                    files=matlab.codetools.requiredFilesAndProducts(fhinfo.file);
                    filesToAttach=[filesToAttach,files];
                end
            end
        end


        [postSimDeps,ia,~]=unique(cellfun(@char,{simInputs.PostSimFcn},'UniformOutput',false));
        for i=1:numel(postSimDeps)
            if~isempty(postSimDeps{i})
                fhinfo=functions(simInputs(ia(i)).PostSimFcn);
                if~isempty(fhinfo.file)
                    files=matlab.codetools.requiredFilesAndProducts(fhinfo.file);
                    filesToAttach=[filesToAttach,files];
                end
            end
        end


        [files,missing]=dependencies.fileDependencyAnalysis(simInputs(1).ModelName);
        if~isempty(missing)
            if iscellstr(missing)
                missing=strjoin(missing,'\n');
            end
            ME=MException(message('Simulink:Commands:SimInputMissingFiles',missing));
            MultiSim.internal.reportAsWarning(modelName,ME);
        end



        if ischar(files)
            files={files};
        end

        filesToAttach=[filesToAttach,files'];



        additionalFiles=p.Results.AttachedFiles;
        if~isrow(additionalFiles)
            additionalFiles=additionalFiles';
        end
        filesToAttach=[filesToAttach,additionalFiles];


        batchArgs=p.Unmatched;
        batchArgs.AttachedFiles=filesToAttach;
        f=fieldnames(batchArgs);
        batchParams=cell(1,2*numel(f));
        for i=1:numel(f)
            batchParams{2*i-1}=f{i};
            batchParams{2*i}=batchArgs.(f{i});
        end


        parsimArgs=p.Results;
        if isfield(parsimArgs,'AttachedFiles')
            parsimArgs=rmfield(parsimArgs,'AttachedFiles');
        end
        f=fieldnames(parsimArgs);
        parsimParams=cell(1,2*numel(f));
        for i=1:numel(f)
            parsimParams{2*i-1}=f{i};
            parsimParams{2*i}=parsimArgs.(f{i});
        end

        job=batch(@parsim,1,{simInputs,parsimParams{:}},batchParams{:});
    catch ME
        throwAsCaller(ME);
    end
end
