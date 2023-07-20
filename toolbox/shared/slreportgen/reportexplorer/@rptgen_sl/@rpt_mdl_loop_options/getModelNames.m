function mdlNames=getModelNames(this)







    if~this.Active
        mdlNames={};
        return
    end

    switch(this.MdlName)
    case '$current'
        currentModel=locGetCurrentModel();
        mdlNames={currentModel};
        this.RuntimeMdlName=currentModel;

    case '$all'
        mdlNames=locFindAllModels('BlockDiagramType','model');
        this.RuntimeMdlName='DEFAULT';

    case '$alllib'
        mdlNames=locFindAllModels('BlockDiagramType','library');
        this.RuntimeMdlName='DEFAULT';

    case '$pwd'
        mdlNames=locGetAllModelsInCurrentDirectory();
        this.RuntimeMdlName='DEFAULT';

    otherwise

        mdlNames=locGetCustomModels(rptgen.parseExpressionText(this.MdlName));

        if(length(mdlNames)>1)
            this.RuntimeMdlName=mdlNames{1};
        else
            this.RuntimeMdlName='DEFAULT';
        end
    end

    modelRefs=locGetModelReferences(this,mdlNames);
    mdlNames=[mdlNames(:);modelRefs(:)];

    if(length(mdlNames)==1&&isempty(mdlNames{1}))
        mdlNames={};
    end


    function models=locGetCustomModels(parsedMdlName)

        if strcmp(parsedMdlName,'{}')||strcmp(parsedMdlName,'[]')||isempty(parsedMdlName)
            modelList={};
            modelCount=0;
        else
            modelList=textscan(parsedMdlName,'%s','delimiter','\n');
            modelList=modelList{1};
            modelCount=length(modelList);
        end

        if~isempty(modelList)&&strcmp(modelList{1},'$custom')
            rptgen.displayMessage(getString(message('RptgenSL:rsl_csl_mdl_loop:customModelNotSpecified')),4);
            modelList={};
            modelCount=0;
        end

        for i=1:modelCount

            fileStatus=exist(modelList{i},'file');
            if(fileStatus==4)

                [~,modelList{i}]=fileparts(modelList{i});%#ok, not increasing
            elseif(fileStatus==2)

                [mdlpath,modelList{i}]=fileparts(modelList{i});%#ok, not increasing
                if(exist(mdlpath,'dir')==7)
                    addpath(mdlpath);
                end
            end
        end
        models=modelList;


        function models=locGetAllModelsInCurrentDirectory()

            dirModels=[dir(fullfile(pwd,'*.mdl'));dir(fullfile(pwd,'*.slx'))];
            modelCount=length(dirModels);
            models=cell(modelCount,1);
            for i=1:modelCount
                models{i}=dirModels(i).name(1:end-4);
            end


            function currentModel=locGetCurrentModel()

                currentModel='';
                possibleCurrentModel=bdroot(gcs);

                if~isempty(possibleCurrentModel)
                    if locIsRptgenTempModel(possibleCurrentModel)


                        allModels=locFindAllModels();
                        if~isempty(allModels)
                            currentModel=allModels{1};
                        else

                            currentModel='';
                        end

                    else
                        currentModel=possibleCurrentModel;
                    end
                end


                function tf=locIsRptgenTempModel(model)

                    tf=strcmp(model,'temp_rptgen_model');


                    function allModels=locFindAllModels(varargin)

                        allModels=find_system(...
                        'SearchDepth',0,...
                        'type','block_diagram',...
                        varargin{:});


                        rptgenTempModel=cellfun(@locIsRptgenTempModel,allModels);
                        allModels(rptgenTempModel)=[];


                        function modelReferences=locGetModelReferences(this,models)

                            depth=rptgen.parseExpressionText(this.ModelReferenceDepth);
                            depth=str2double(depth);
                            currentLevelSystemQueue={};
                            nextLevelSystemQueue={};
                            modelsInSystemQueue={};
                            modelReferences={};
                            currentModel='';

                            locTemporarilyLoadModel('init');

                            if(depth>0)

                                nModels=length(models);
                                for i=1:nModels
                                    model=models{i};
                                    locTemporarilyLoadModel('load',model);

                                    currentLevelSystemQueue=[currentLevelSystemQueue;...
                                    this.getReportedSystems(model)];%#ok                       
                                end

                                modelsInSystemQueue=unique(bdroot(currentLevelSystemQueue));




                                locTemporarilyLoadModel('unload');

                            end

                            while~isempty(currentLevelSystemQueue)

                                system=currentLevelSystemQueue{1};
                                currentLevelSystemQueue(1)=[];



                                idx=strfind(system,'/');
                                if~isempty(idx)
                                    model=system(1:idx-1);
                                else
                                    model=system;
                                end



                                if~strcmp(model,currentModel)

                                    if~isempty(currentModel)
                                        locTemporarilyLoadModel('unload');
                                    end
                                    currentModel=model;
                                end

                                if~locIsModelLoaded(model)
                                    locTemporarilyLoadModel('load',model);
                                end


                                modelRefs={};

                                if this.IncludeAllVariants


                                    modelRefBlocks=find_system(system,...
                                    'SearchDepth',1,...
                                    'MatchFilter',@Simulink.match.allVariants,...
                                    'BlockType','ModelReference',...
                                    'ProtectedModel','off');
                                    isSystemVariant=~strcmp(get_param(system,'Type'),'block_diagram')&&...
                                    strcmp(get_param(system,'Variant'),'on');
                                    nBlks=length(modelRefBlocks);
                                    for iBlk=1:nBlks
                                        blk=modelRefBlocks{iBlk};
                                        if strcmp(get_param(blk,'Variant'),'on')
                                            variants=get_param(blk,'Variants');
                                            nVar=length(variants);
                                            for iVar=1:nVar
                                                varName=variants(iVar).ModelName;
                                                if(exist(varName,'file')==4)
                                                    modelRefs=[modelRefs,{varName}];%#ok<AGROW>
                                                else

                                                    msgId='RptgenSL:rsl_rpt_mdl_loop_options:nonexistentVariantModelReference';
                                                    msg=getString(message(msgId,varName));
                                                    rptgen.displayMessage(msg,2);
                                                end
                                            end



                                        elseif isSystemVariant
                                            varName=get_param(blk,'ModelName');
                                            if(exist(varName,'file')==4)
                                                modelRefs=[modelRefs,{varName}];%#ok<AGROW>
                                            else

                                                msgId='RptgenSL:rsl_rpt_mdl_loop_options:nonexistentVariantModelReference';
                                                msg=getString(message(msgId,varName));
                                                rptgen.displayMessage(msg,2);

                                            end
                                        else
                                            modelRefs=[modelRefs,get_param(blk,'ModelName')];%#ok<AGROW>
                                        end
                                    end
                                else


                                    if Simulink.internal.useFindSystemVariantsMatchFilter()
                                        modelRefBlocks=find_system(system,...
                                        'SearchDepth',1,...
                                        'MatchFilter',@Simulink.match.activeVariants,...
                                        'BlockType','ModelReference',...
                                        'ProtectedModel','off');
                                    else
                                        modelRefBlocks=find_system(system,...
                                        'SearchDepth',1,...
                                        'Variants','ActiveVariants',...
                                        'BlockType','ModelReference',...
                                        'ProtectedModel','off');
                                    end
                                    modelRefs=get_param(modelRefBlocks,'ModelName');
                                end


                                modelRefs=regexprep(modelRefs,'\.mdl$|\.slx$','');


                                modelRefs=unique(modelRefs);


                                modelRefs(ismember(modelRefs,modelsInSystemQueue))=[];


                                modelsInSystemQueue=[modelsInSystemQueue;modelRefs(:)];%#ok


                                if(depth>1)
                                    for i=1:length(modelRefs)
                                        modelRef=modelRefs{i};
                                        locTemporarilyLoadModel('load',modelRef);
                                        nextLevelSystemQueue=[nextLevelSystemQueue;...
                                        this.getReportedSystems(modelRef,...
                                        modelRef,...
modelRef...
                                        )];%#ok

                                        locTemporarilyLoadModel('unload');
                                    end
                                end


                                modelReferences=[modelReferences;modelRefs(:)];%#ok

                                if isempty(currentLevelSystemQueue)

                                    depth=depth-1;
                                    currentLevelSystemQueue=nextLevelSystemQueue;
                                    nextLevelSystemQueue={};
                                end
                            end

                            locTemporarilyLoadModel('unload');


                            function locTemporarilyLoadModel(method,model)

                                persistent temporarilyLoadedModel initialCurrentSystem

                                if~exist('temporarilyLoadedModel','var')
                                    temporarilyLoadedModel={};
                                    initialCurrentSystem=[];
                                end

                                switch method
                                case 'init'
                                    temporarilyLoadedModel={};
                                    initialCurrentSystem=gcs;
                                case 'load'
                                    if~locIsModelLoaded(model)
                                        load_system(model);
                                        temporarilyLoadedModel=[temporarilyLoadedModel;model];
                                    end
                                case 'unload'
                                    for i=1:length(temporarilyLoadedModel)
                                        model=temporarilyLoadedModel{i};
                                        close_system(model,0);
                                    end
                                    temporarilyLoadedModel={};
                                    if~isempty(initialCurrentSystem)
                                        set_param(0,'CurrentSystem',initialCurrentSystem);
                                    end
                                end


                                function tf=locIsModelLoaded(model)

                                    tf=~isempty(find_system(0,'SearchDepth',0,'type','block_diagram','Name',model));


