function validateExternalInputs(modelName)






    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(modelName);
    isModelReference=(~isempty(modelCodegenMgr)&&...
    (~strcmp(modelCodegenMgr.MdlRefBuildArgs.ModelReferenceTargetType,'NONE')||...
    modelCodegenMgr.MdlRefBuildArgs.hasModelBlocks));
    if isModelReference
        return












    end

    warning('off','Simulink:Engine:UnableToLoadExtInputsFromWkspForCodeGen');


    expectedErr={{'MATLAB:MException:MultipleErrors',''},...
    {'Simulink:SimInput:',''},...
    {'Simulink:Logging:ExtInp',''},...
    {'Simulink:ConfigSet:ConfigSetEvalErr','ExternalInput'}};

    prevEIState=feature('EngineInterface');
    slfeature('EngineInterface',1001);
    try

        modelObj=get_param(modelName,'Object');
        modelObj.init('Command_line');
        modelObj.term();

    catch ME
        slfeature('EngineInterface',prevEIState);


        errList=locParseEngineErrorMessages(ME,expectedErr);
        if length(errList)==1
            throw(errList{1});
        else
            if length(errList)>1
                err=MException('MATLAB:MException:MultipleErrors','Error due to multiple causes.');
                for i=1:length(errList)
                    err=err.addCause(errList{i});
                end
                throw(err);
            end
        end

    end
    slfeature('EngineInterface',prevEIState);














    function errout=locParseEngineErrorMessages(errin,expectedErr)

        errout={};

        if~isempty(errin)
            errFound=false;


            for i=1:length(expectedErr)
                if contains(errin.identifier,expectedErr{i}{1})&&contains(errin.message,expectedErr{i}{2})
                    errFound=true;
                    break;
                end
            end

            if errFound
                if isempty(errin.cause)
                    errout{1}=MException(errin.identifier,errin.message);
                else

                    for i=1:length(errin.cause)
                        errout=[locParseEngineErrorMessages(errin.cause{i},expectedErr),errout];%#ok<AGROW>
                    end
                end
            end
        end
