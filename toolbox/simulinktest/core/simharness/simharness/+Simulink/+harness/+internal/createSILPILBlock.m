function harnessSILPILBlock=createSILPILBlock(sut,harnessBD,verificationMode,existingBuildFolder)%#ok<INUSD>
    silpilTempModel=findNextUntitledModel();
    try
        if(verificationMode==1)
            mode='SIL';
        else
            mode='PIL';
        end

        if(~isempty(existingBuildFolder))
            model=bdroot(sut);
            cs=getActiveConfigSet(model);
            dataDict=get_param(model,'DataDictionary');


            if isfile(fullfile(existingBuildFolder,'rtwtypes.h'))
                try
                    if isempty(dataDict)
                        silpilBlock=crossReleaseImport(existingBuildFolder,cs,'SimulationMode',mode);
                    else
                        silpilBlock=crossReleaseImport(existingBuildFolder,cs,'SimulationMode',mode,'DataDictionary',dataDict);
                    end
                catch me
                    createError=MException(message('Simulink:Harness:CrossReleaseImportError'));
                    createError=addCause(createError,me);
                    throw(createError);
                end
            else
                infoStructLoader=coder.internal.xrel.buildartifacts.InfoStructLoader;
                infoStructLoader.load(existingBuildFolder);
                infoStruct=infoStructLoader.InfoStruct;
                relativePathToAnchor=infoStruct.relativePathToAnchor;
                sharedSourcesDir=infoStruct.sharedSourcesDir;



                sharedSourceDirParts=strsplit(sharedSourcesDir,'\');
                sharedSourcesDir=fullfile(sharedSourceDirParts{:});

                if(~isempty(sharedSourcesDir))
                    sharedUtilsPath=coder.internal.xrelexport.getCanonicalPath(fullfile(existingBuildFolder,relativePathToAnchor,sharedSourcesDir),pwd);
                    sharedCodeValue=get_param(cs,'ExistingSharedCode');
                    noRet=onCleanup(@()revertConfigSet(cs,sharedCodeValue));
                    [filepath,~,~]=fileparts(existingBuildFolder);
                    sharedCodeRepo=fullfile(filepath,'SharedCodeRepo');
                    if(~isfolder(sharedCodeRepo))
                        mkdir(sharedCodeRepo);
                    end
                    sharedCodeUpdate(sharedUtilsPath,sharedCodeRepo,'Interactive',false);
                    cs=getActiveConfigSet(model);
                    set_param(cs,'ExistingSharedCode',sharedCodeRepo);
                    try
                        if isempty(dataDict)
                            silpilBlock=crossReleaseImport(existingBuildFolder,cs,'SimulationMode',mode);
                        else
                            silpilBlock=crossReleaseImport(existingBuildFolder,cs,'SimulationMode',mode,'DataDictionary',dataDict);
                        end
                    catch me
                        createError=MException(message('Simulink:Harness:CrossReleaseImportError'));
                        createError=addCause(createError,me);
                        throw(createError);
                    end
                end
            end





            sutPorts=get_param(sut,'Ports');
            silPilBlockPorts=get_param(silpilBlock,'Ports');



            if(~isequal(sutPorts(1)+sutPorts(3)+sutPorts(4),silPilBlockPorts(1))||~isequal(sutPorts(2),silPilBlockPorts(2)))
                error=MException(message('Simulink:Harness:CrossReleaseImportInterfaceChange'));
                throw(error);
            end
        else
            silpilBlock=rtwbuild(sut);
        end

        if harnessBD<0
            harnessSILPILBlock=silpilBlock;
        else

            harnessSILPILBlock=add_block(getfullname(silpilBlock),[getfullname(harnessBD),'/',get_param(silpilBlock,'Name')],'MakeNameUnique','On');
        end
    catch ME
        if~isempty(find_system('type','block_diagram','Name',silpilTempModel))
            close_system(silpilTempModel,0);
        end
        rethrow(ME);
    end

    if harnessBD<0


    else

        bdclose(bdroot(silpilBlock));
    end
end

function modelName=findNextUntitledModel()
    modelPrefix='untitled';
    modelIndex=1;
    modelName='untitled';
    while~isempty(find_system('type','block_diagram','Name',modelName))
        modelName=[modelPrefix,int2str(modelIndex)];
        modeIndex=modelIndex+1;%#ok<NASGU>
    end
end

function revertConfigSet(cs,sharedCodeValue)
    set_param(cs,'ExistingSharedCode',sharedCodeValue);
end
