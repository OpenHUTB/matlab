classdef(Sealed,Hidden)Environment<handle





    properties(Constant)
        ErrorsForNoLog={


'Simulink:Variants:OutputDirPublic'
'Simulink:VariantReducer:OutputDirInstall'
'Simulink:Variants:ReducerCWDUnderOutputDir'
'Simulink:Variants:SameSrcAndDstDirs'
'Simulink:Variants:ModelPathUnderOutputDir'
'Simulink:Variants:OutputDirNotWritable'
'Simulink:Variants:OutputDirUnclean'
        };

        IgnoredWarnings={

'backtrace'


'Simulink:IOManager:ViewerConnectionNotValid'
'Simulink:IOManager:SigGenConnectionNotValid'
'Simulink:Engine:OutputNotConnected'
'Simulink:Engine:InputNotConnected'
'Simulink:Engine:LineWithoutSrc'
'Simulink:Engine:LineWithoutDst'





'Simulink:Masking:Promote_Parameter_Unresolved'
'Simulink:Masking:Promote_Parameter_AllUnresolved'




'Simulink:Commands:SetParamLinkChangeWarn'
'Simulink:Engine:SaveWithParameterizedLinks_Warning'





'Simulink:modelReference:IOMismatchParamArgs'
'Simulink:modelReference:ErrDiagIOMismatchMsg'
'Simulink:modelReference:WarnDiagIOMismatchMsg'
'Simulink:modelReference:WarnNoSyncDiagIOMismatchMsg'
        };
    end

    properties(Transient,Access=private)

        PWD(1,:)char


        OrigMLPath(1,:)char


        WarnIDState(1,:)struct=Simulink.variant.reducer.Environment.initWarnIdStateStruct();


AutoSaveOptions



        BDsLoadedBeforeReduction={};

        OpenDataDictionaryFilesBeforeReduction={};


        DefaultConfigHandlerList(1,:)Simulink.variant.utils.DefaultConfigHandler;


        VCDOHandlerList(1,:)Simulink.variant.utils.VCDOHandler;


        ReducedBDNames={};
    end

    properties(Transient)

        CausedByError=true;

        DirtyDataDictionaryFilesBeforeReduction={};

        BDsDirtyBeforeReduction={};

        ModelTargetReplacer(1,1)Simulink.variant.utils.ModelReferenceTargetReplacer;
    end

    methods


        function obj=Environment()


            obj.PWD=pwd;


            obj.OrigMLPath=path;


            obj.ignoreWarnings();

            origAutoSaveOptions=get_param(0,'AutoSaveOptions');
            obj.AutoSaveOptions=origAutoSaveOptions;

            modAutoSaveOptions=origAutoSaveOptions;
            modAutoSaveOptions.SaveBackupOnVersionUpgrade=0;
            modAutoSaveOptions.SaveOnModelUpdate=0;
            set_param(0,'AutoSaveOptions',modAutoSaveOptions);

            [obj.BDsLoadedBeforeReduction,obj.BDsDirtyBeforeReduction]=Simulink.variant.utils.getOpenAndDirtyModels();

            [obj.OpenDataDictionaryFilesBeforeReduction,obj.DirtyDataDictionaryFilesBeforeReduction]=Simulink.variant.utils.getOpenAndDirtyDataDictionaryFiles();

            obj.ModelTargetReplacer=Simulink.variant.utils.ModelReferenceTargetReplacer();
        end


        function delete(obj)

            if isvalid(obj.ModelTargetReplacer)
                delete(obj.ModelTargetReplacer)
            end







            obj.resetDefaultConfigs();
            obj.resetAddedVCDOs();


            if~strcmp(pwd,obj.PWD)
                cd(obj.PWD);
            end


            path(obj.OrigMLPath);


            warning(obj.WarnIDState);


            set_param(0,'AutoSaveOptions',obj.AutoSaveOptions);

            [bDsLoadedAtEndOfReduction,bDsDirtyAtEndOfReduction]=Simulink.variant.utils.getOpenAndDirtyModels();

            modelsToBeCleaned=setdiff(bDsDirtyAtEndOfReduction,obj.BDsDirtyBeforeReduction);
            cellfun(@(X)(set_param(X,'Dirty','off')),modelsToBeCleaned);

            modelsToBeClosed=setdiff(bDsLoadedAtEndOfReduction,obj.BDsLoadedBeforeReduction);





            if(slfeature('VRedRearch')>0)







                origOpenedBDs=setdiff(modelsToBeClosed,obj.ReducedBDNames);
                skipCloseFcnCallback=false;
                Simulink.variant.reducer.utils.i_closeModel(origOpenedBDs,skipCloseFcnCallback);
                modelsToBeClosed=obj.ReducedBDNames;
            end
            skipCloseFcnCallback=true;
            Simulink.variant.reducer.utils.i_closeModel(modelsToBeClosed,skipCloseFcnCallback);

            [openDataDictionaryFiles,dirtyDataDictionaryFiles]=Simulink.variant.utils.getOpenAndDirtyDataDictionaryFiles();

            openDataDictionaryFilesByReducer=setdiff(openDataDictionaryFiles,obj.OpenDataDictionaryFilesBeforeReduction);
            for i=1:numel(openDataDictionaryFilesByReducer)
                [~,dataDictionaryName,dataDictionaryExt]=fileparts(openDataDictionaryFilesByReducer{i});
                Simulink.data.dictionary.closeAll([dataDictionaryName,dataDictionaryExt],'-discard');
            end

            dirtyDataDictionaryFilesByReducer=setdiff(dirtyDataDictionaryFiles,[obj.DirtyDataDictionaryFilesBeforeReduction;openDataDictionaryFilesByReducer]);

            for i=1:numel(dirtyDataDictionaryFilesByReducer)
                currDir=cd(fileparts(dirtyDataDictionaryFilesByReducer{i}));

                try
                    ddObj=Simulink.data.dictionary.open(dirtyDataDictionaryFilesByReducer{i});
                    ddObj.discardChanges();
                    cd(currDir);
                catch
                    cd(currDir);
                end
            end
        end


        function dir=getPWD(obj)

            dir=obj.PWD;

        end

        function addModelForDefaultConfigHandling(obj,model)
            obj.DefaultConfigHandlerList(end+1)=Simulink.variant.utils.DefaultConfigHandler(model);
        end

        function resetDefaultConfigs(obj)
            obj.DefaultConfigHandlerList.delete();
        end

        function addVCDOForModel(obj,modelName,vcdoName,vcdo,toDelete)
            obj.VCDOHandlerList(end+1)=Simulink.variant.utils.VCDOHandler(modelName,vcdoName,vcdo,toDelete);
        end

        function resetAddedVCDOs(obj)
            obj.VCDOHandlerList.delete();
        end

        function setReducedBDNames(obj,bdNames)
            obj.ReducedBDNames=bdNames;
        end
    end

    methods(Access=private)


        function ignoreWarnings(obj)
            nWarns=numel(obj.IgnoredWarnings);
            warnIDState=Simulink.variant.reducer.Environment.initWarnIdStateStruct(nWarns);
            for warnId=1:nWarns
                warnIDState(warnId)=warning('off',obj.IgnoredWarnings{warnId});
            end
            obj.WarnIDState=warnIDState;
        end

    end

    methods(Static,Access=private)
        function s=initWarnIdStateStruct(varargin)
            len=0;
            if nargin>0
                len=varargin{1};
            end
            s=struct('identifier',cell(1,len),'state',cell(1,len));
        end
    end

end


