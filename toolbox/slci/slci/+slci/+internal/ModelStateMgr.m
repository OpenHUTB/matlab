


classdef ModelStateMgr<handle
    properties(Access=private)
        fModelName='';
        fTopModelName='';
        fTopModelFile='';
        fNormalModeModelPrep=[];
        fOrigAutosave=[];
        fOrigDirty='';
        fTempdir='';
        fOrigLoaded=false;
        fOrigCompiled=false;
        fNumCompiles=0;
    end

    methods(Access=private)

        function clearCallBacks(aObj)
            mdl=aObj.fTopModelName;
            set_param(mdl,'PreLoadFcn','');
            set_param(mdl,'PostLoadFcn','');
            set_param(mdl,'InitFcn','');
            set_param(mdl,'StartFcn','');
            set_param(mdl,'PauseFcn','');
            set_param(mdl,'ContinueFcn','');
            set_param(mdl,'StopFcn','');
            set_param(mdl,'PreSaveFcn','');
            set_param(mdl,'PostSaveFcn','');
            set_param(mdl,'CloseFcn','');
        end

        function createTopModel(aObj)
            if isempty(aObj.fTopModelName)



                iter=0;
                while 1
                    tmpname=['top_',num2str(iter)];
                    if exist(tmpname)==4
                        iter=iter+1;
                    else
                        break;
                    end
                end
                aObj.fTopModelName=tmpname;
                modelFile=which(aObj.fModelName);
                [~,~,modelFileExt]=fileparts(modelFile);
                aObj.fTopModelFile=[aObj.fTempdir,filesep,tmpname,modelFileExt];
                copyfile(modelFile,aObj.fTopModelFile);
                load_system(tmpname);

                Simulink.ModelReference.internal.NormalModeConfiguration(tmpname);


                Simulink.BlockDiagram.deleteContents(tmpname);
                mdlBlk=[tmpname,'/Model'];
                add_block('built-in/ModelReference',mdlBlk);
                set_param(mdlBlk,'ModelName',aObj.fModelName);
                set_param(mdlBlk,'SimulationMode','Normal');


                paramArgs=get_param(mdlBlk,'ParameterArgumentNames');
                set_param(mdlBlk,'ParameterArgumentValues',paramArgs);


                aObj.clearCallBacks();

            end
        end

    end

    methods(Hidden)

        function delete(aObj)
            set_param(0,'AutoSaveOptions',aObj.fOrigAutosave);
            if~aObj.fOrigCompiled
                aObj.terminate();
            end
            if~aObj.fOrigLoaded
                aObj.closeModel();
            end
            if~isempty(aObj.fTopModelName)
                bdclose(aObj.fTopModelName);
                if exist(aObj.fTopModelFile)==4
                    delete(aObj.fTopModelFile);
                end
            end
            if exist(aObj.fTempdir)==7
                rmpath(aObj.fTempdir);
                rmdir(aObj.fTempdir,'s');
            end
        end

        function name=getTopModelName(aObj)
            name=aObj.fTopModelName;
        end

        function name=getTempdir(aObj)
            name=aObj.fTempdir;
        end

        function out=getNumCompiles(aObj)
            out=aObj.fNumCompiles;
        end

    end

    methods

        function obj=ModelStateMgr(aModelName)
            obj.fModelName=aModelName;
            obj.fTempdir=tempname;
            mkdir(obj.fTempdir);
            addpath(obj.fTempdir);
            obj.fOrigLoaded=obj.isLoaded();
            obj.fOrigCompiled=obj.isCompiled();


            obj.fOrigAutosave=get_param(0,'AutoSaveOptions');
            new_autosave_state=obj.fOrigAutosave;
            new_autosave_state.SaveOnModelUpdate=0;
            new_autosave_state.SaveBackupOnVersionUpgrade=0;
            set_param(0,'AutoSaveOptions',new_autosave_state);
        end

        function loadModel(aObj)

            if~aObj.isLoaded()
                load_system(aObj.fModelName);
            end
        end


        function closeModel(aObj)

            if aObj.isLoaded()

                if aObj.isCompiled()
                    aObj.terminate()
                end
                close_system(aObj.fModelName,0);
            end
        end

        function compileModelForTop(aObj)

            if~aObj.isLoaded()
                aObj.loadModel();

            elseif aObj.isCompiledForTop()
                return

            elseif aObj.isCompiledForRef()
                aObj.terminate()
            end
            mdlObj=get_param(aObj.fModelName,'Object');%#ok


            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            try
                evalc('mdlObj.init(''COMMAND_LINE'');');
            catch ME


                rethrow(ME)
            end
            aObj.fNumCompiles=aObj.fNumCompiles+1;
        end

        function compileModelForRef(aObj)

            if~aObj.isLoaded()
                aObj.loadModel();

            elseif aObj.isCompiledForRef()
                return

            elseif aObj.isCompiledForTop()
                aObj.terminate()
            end
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            try

                aObj.fNormalModeModelPrep=...
                Simulink.ModelReference.internal.NormalModeConfiguration(aObj.fModelName);

                mdlObj=get_param(aObj.fModelName,'Object');%#ok
                evalc('mdlObj.init(''MDLREF_NORMAL'');');
            catch ME


                aObj.fNormalModeModelPrep.cleanupModel;
                rethrow(ME)
            end
            aObj.fNumCompiles=aObj.fNumCompiles+1;
        end

        function terminate(aObj)

            if aObj.isLoaded()&&aObj.isCompiled()
                sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
                try
                    if aObj.isCompiledForTop()
                        aObj.terminateForTop();
                    else
                        aObj.terminateForRef();
                    end
                catch ME


                    rethrow(ME)
                end
            end
        end

        function terminateForTop(aObj)
            mdlObj=get_param(aObj.fModelName,'Object');
            mdlObj.term();
        end

        function terminateForRef(aObj)
            mdlObj=get_param(aObj.fModelName,'Object');
            mdlObj.term;
            aObj.fNormalModeModelPrep.cleanupModel;
        end

        function compiled=isCompiled(aObj)

            if aObj.isLoaded()
                simStatus=get_param(aObj.fModelName,'SimulationStatus');
                compiled=strcmpi(simStatus,'paused')||...
                strcmpi(simStatus,'initializing')||...
                strcmpi(simStatus,'running')||...
                strcmpi(simStatus,'updating');
            else
                compiled=false;
            end
        end

        function compiledForTop=isCompiledForTop(aObj)
            compiledForTop=aObj.isCompiled&&...
            strcmpi(get_param(aObj.fModelName,'ModelReferenceTargetType'),'NONE');
        end

        function compiledForRef=isCompiledForRef(aObj)
            compiledForRef=aObj.isCompiled()&&...
            strcmpi(get_param(aObj.fModelName,'ModelReferenceTargetType'),'SIM');
        end

        function loaded=isLoaded(aObj)
            loaded=~isempty(find_system('flat','Name',aObj.fModelName));
        end

    end
end


