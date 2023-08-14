




function[codeAnalyzer,warningMessages]=createFromModel(modelName,varargin)

    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addOptional(argParser,'SimulationMode','SIL');
        addOptional(argParser,'CompiledMode',false);
        addOptional(argParser,'IsATS',false);
        addOptional(argParser,'HarnessInfo',[]);
    end

    parse(argParser,varargin{:});


    warningMessages=struct('Handle',{},...
    'Id',{},...
    'Message',{});

    codeAnalyzer=sldv.code.xil.CodeAnalyzer();


    if ischar(modelName)||(isstring(modelName)&&isscalar(modelName))
        modelName=char(modelName);
        if~bdIsLoaded(modelName)
            load_system(modelName);
            modelCleaner=onCleanup(@()bdclose(modelName));
        end
    elseif is_simulink_handle(modelName)
        modelName=get_param(modelName,'Name');
    else
        return
    end

    isATS=argParser.Results.IsATS;
    atsHarnessInfo=argParser.Results.HarnessInfo;
    if~isATS||isempty(atsHarnessInfo)
        [~,atsHarnessInfo]=sldv.code.xil.CodeAnalyzer.isATSHarnessModel(modelName);
    end
    if isempty(atsHarnessInfo)
        codeAnalyzer.ModelName=modelName;
    else
        codeAnalyzer.AtsHarnessInfo=atsHarnessInfo;
        codeAnalyzer.ModelName=atsHarnessInfo.model;
    end

    codeAnalyzer.SimulationMode=argParser.Results.SimulationMode;
    cleanerObjs=setup(modelName,argParser.Results.CompiledMode);

    codeDesc=codeAnalyzer.getCodeDescriptor();
    if isempty(codeDesc)||isempty(codeDesc.codeInfo)
        return
    end

    instInfo=sldv.code.xil.CodeInstanceInfo();
    instInfo.setInstanceIdFromHandle(codeAnalyzer.ModelName);
    instInfo.setFromCodeDescriptor(codeDesc);
    if~isempty(atsHarnessInfo)
        codeDbEntryName=atsHarnessInfo.ownerFullPath;
    else
        codeDbEntryName=codeAnalyzer.ModelName;
    end
    codeAnalyzer.addInstance(codeDbEntryName,instInfo);

    delete(cleanerObjs);


    function cleanerObjs=setup(modelName,compiledMode)

        cleanerObjs=[];
        if compiledMode

            systemsBefore=find_system('type','block_diagram');


            warnStruct=warning;
            restoreWarnings=onCleanup(@()warning(warnStruct));
            warning('off');



            oldFeatureValue=slfeature('EngineInterface',1001);
            cleanerObjs=onCleanup(@()slfeature('EngineInterface',oldFeatureValue));
            if~strcmpi(get_param(modelName,'SimulationStatus'),'initializing')

                evalc('feval(modelName, [],[], [], ''compile'')');
                cleanerObjs(end+1)=onCleanup(@()termCompile(modelName));
            end
            cleanerObjs=[cleanerObjs,onCleanup(@()doCleanup(systemsBefore))];
        end


        function termCompile(modelName)
            warnStruct=warning;
            restoreWarnings=onCleanup(@()warning(warnStruct));

            warning('off');
            cmd=sprintf('feval(''%s'', [],[], [], ''term'')',modelName);
            evalc(cmd);


            function doCleanup(systemsBefore)

                systemsAfter=find_system('type','block_diagram');
                systemsToClose=setdiff(systemsAfter,systemsBefore);
                if~isempty(systemsToClose)
                    for sysCount=1:numel(systemsToClose)
                        try


                            set_param(systemsToClose{sysCount},'CloseFcn','');
                        catch
                        end
                    end
                    close_system(systemsToClose,0);
                end
