classdef ParameterManager<handle





    properties(Access='public')
Model
ModelParameters
ConfigSetParameters




        RequestExternalCompile(1,1)logical=false
    end

    properties(Access='private')
BusLabelLocations
NormalRefModels
AllRefModels
AccelModels
UniqueNormalRefModels
NormalRefParentBlocks
eiAdapter
OrigDirty
OrigPreloaded
AccelPreloaded
OrigModelParams
OrigConfigSetParameters
OrigAutoSave
TunableParametersAdded
ModelCloseListener



OriginalModelState


NumSolverBlks
SolverConfigBlks
OldSolverBlksSetting
    end

    methods
        function setModelParameters(this,modelParams,configParams)




            if~this.RequestExternalCompile
                if~isempty(modelParams)
                    this.ModelParameters=modelParams;
                end
                if~isempty(configParams)
                    this.ConfigSetParameters=configParams;
                end
            end
        end
    end

    methods(Access='public')
        function obj=ParameterManager(model)

            obj.Model=model;
            obj.TunableParametersAdded=[];
            obj.OrigConfigSetParameters={};
        end


        function setSimscapeSolverBlocks(this,simscapeSolverOpts)




            if nargin<2
                simscapeSolverOpts=slcontrollib.internal.utils.getDefaultSimscapeProjectionOptions();
            end


            allNomalModeModels=getUniqueNormalModeModels(this);
            this.SolverConfigBlks={};
            for ctm=1:numel(allNomalModeModels)
                newConfigBlks=find_system(allNomalModeModels{ctm},...
                'LookUnderMasks','on',...
                'SubClassName','solver');
                this.SolverConfigBlks=union(this.SolverConfigBlks,...
                newConfigBlks);
            end
            this.NumSolverBlks=numel(this.SolverConfigBlks);
            if this.NumSolverBlks>0

                ssparams=fields(simscapeSolverOpts);
                for ctscb=1:this.NumSolverBlks
                    for ctp=numel(ssparams):-1:1
                        this.OldSolverBlksSetting(ctscb).(ssparams{ctp})=get_param(this.SolverConfigBlks{ctscb},ssparams{ctp});
                        set_param(this.SolverConfigBlks{ctscb},...
                        ssparams{ctp},...
                        simscapeSolverOpts.(ssparams{ctp}));
                    end
                end
            end
        end


        function restoreSimscapeSolverBlocks(this)



            if~isempty(this.OldSolverBlksSetting)
                ssparams=fields(this.OldSolverBlksSetting);
                for ctscb=1:this.NumSolverBlks
                    for ctp=1:numel(ssparams)
                        set_param(this.SolverConfigBlks{ctscb},...
                        ssparams{ctp},...
                        this.OldSolverBlksSetting(ctscb).(ssparams{ctp}));
                    end
                end
            end
            this.OldSolverBlksSetting={};
            this.SolverConfigBlks={};
            this.NumSolverBlks=[];
        end

        function prepareModels(obj)









            if~obj.RequestExternalCompile

                manageModelDirtyState(obj,'cache');


                obj.eiAdapter=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);


                obj.OrigAutoSave=slcontrollib.internal.utils.enableAutoSave('off');


                prepareParameters(obj)
            end
        end

        function restoreModels(obj)






            restoreSimscapeSolverBlocks(obj);


            restoreParameters(obj);


            obj.eiAdapter=[];

            manageModelDirtyState(obj,'restore');


            if~isempty(obj.OrigAutoSave)
                slcontrollib.internal.utils.enableAutoSave(obj.OrigAutoSave);
            end
        end

        function loadModels(obj)




            mdlCI=find_system('SearchDepth',0,'Name',obj.Model);
            if isempty(mdlCI)
                top_preloaded=0;


                ws(1)=warning('off','sl_utility:caseSensitiveBlockDiagramNames:NameError');
                try
                    load_system(obj.Model);
                    warning(ws);
                catch ex
                    warning(ws);
                    rethrow(ex);
                end
            else
                top_preloaded=1;
            end


            [MdlRefParents,MdlRefModels,ref_preloaded,allrefmdls]=...
            slcontrollib.internal.utils.getNormalModeBlocks(obj.Model);

            for ct=1:numel(MdlRefModels)
                if~ref_preloaded(ct)
                    load_system(MdlRefModels{ct});
                end
            end


            obj.NormalRefModels=MdlRefModels(:);
            obj.AllRefModels=allrefmdls;
            obj.UniqueNormalRefModels=unique(MdlRefModels(:));
            obj.NormalRefParentBlocks=MdlRefParents(:);
            obj.OrigPreloaded=[top_preloaded;ref_preloaded];



            if isempty(obj.ModelCloseListener)
                hMdl=get_param(obj.Model,'Object');
                Simulink.listener(hMdl,'CloseEvent',@(hSrc,hData)delete(obj));
            end
        end

        function loadAccelModels(obj)


            if~isempty(obj.AllRefModels)
                accelmdls=setdiff(obj.AllRefModels,obj.NormalRefModels);
                if~isempty(accelmdls)
                    n=numel(accelmdls);
                    ref_preloaded=false(n,1);
                    for i=1:n
                        accelmdl=accelmdls{i};
                        ref_preloaded(i)=bdIsLoaded(accelmdl);
                        if~ref_preloaded(i)
                            load_system(accelmdl);
                        end
                    end
                    obj.AccelModels=accelmdls;


                    if isempty(obj.AccelPreloaded)
                        obj.AccelPreloaded=ref_preloaded;
                    end
                end
            end
        end

        function closeModels(obj)


            models=vertcat({obj.Model},obj.NormalRefModels,obj.AccelModels);
            preloaded=[obj.OrigPreloaded;obj.AccelPreloaded];
            for ct=numel(preloaded):-1:1

                if~preloaded(ct)
                    bdclose(models{ct});
                end
            end

            if~obj.RequestExternalCompile&&~isempty(obj.eiAdapter)
                obj.eiAdapter=[];
            end
        end

        function manageModelDirtyState(obj,doWhat)



            models=obj.getUniqueNormalModeModels;
            switch doWhat
            case 'cache'

                isdirty=cell(size(models));
                for ct=numel(models):-1:1

                    isdirty{ct}=get_param(models{ct},'Dirty');
                end
                obj.OrigDirty=isdirty;
            case 'restore'

                for ct=numel(models):-1:1
                    set_param(models{ct},'Dirty',obj.OrigDirty{ct});
                end
            end
        end

        function nrefs=findNumberNormalModeInstances(obj,model)
            nrefs=sum(strcmp(model,obj.NormalRefModels));
        end

        function[mdls,mdlblks]=getSingleInstanceNormalModeModels(obj)
            mdls={};mdlblks={};
            uniquemdls=getUniqueNormalModeModels(obj);
            for ct=1:numel(uniquemdls)
                indref=strcmp(uniquemdls{ct},obj.NormalRefModels);
                if sum(indref)==1
                    mdls{end+1,1}=obj.NormalRefModels{indref};%#ok<AGROW>
                    mdlblks{end+1,1}=obj.NormalRefParentBlocks{indref};%#ok<AGROW>
                end
            end
        end

        function[mdls,mdlblks]=getCompiledNormalModeModelBlockPaths(obj)
            mdls=obj.NormalRefModels;mdlblks=obj.NormalRefParentBlocks;
            uniquemdlblks=unique(mdlblks);
            for ct=1:numel(uniquemdlblks)
                indref=find(strcmp(uniquemdlblks{ct},obj.NormalRefParentBlocks));
                mdl=bdroot(uniquemdlblks{ct});
                for ct2=2:numel(indref)
                    mdls{indref(ct2)}=sprintf('%s%d',mdl,ct2-2);
                    blkname=obj.NormalRefParentBlocks{indref(ct2)};
                    mdlblks{indref(ct2)}=sprintf('%s%d%s',blkname(1:numel(mdl)),...
                    ct2-2,blkname(numel(mdl)+1:end));
                end
            end
        end

        function val=isChildBlock(obj,blk,PotentialParents)
            val=false;
            while~strcmp(blk,obj.Model)&&(val==false)
                if any(strcmp(blk,PotentialParents))
                    val=true;
                else
                    blkmdl=bdroot(blk);
                    blk=get_param(blk,'Parent');
                    if strcmp(blkmdl,blk)&&~strcmp(blk,obj.Model)


                        [~,normalmdlblks]=obj.getCompiledNormalModeModelBlockPaths;
                        blk=normalmdlblks{strcmp(...
                        get_param(normalmdlblks,'NormalModeModelName'),...
                        blkmdl)};
                    end
                end
            end
        end

        function varargout=compile(obj,method)
            numberOfOutputArguments=max(nargout,1);

            varargout=cell(numberOfOutputArguments,1);

            [varargout{1:numberOfOutputArguments}]=feval(obj.Model,[],[],[],method);


            if obj.RequestExternalCompile

                try
                    obj.OriginalModelState=slcontrollib.internal.utils.getStateStruct(obj.Model,false);
                catch



                    obj.OriginalModelState=[];
                end
            end
        end

        function varargout=sim(obj,varargin)
            numberOfOutputArguments=max(nargout,1);

            varargout=cell(numberOfOutputArguments,1);

            [varargout{1:numberOfOutputArguments}]=sim(obj.Model,varargin{:});
        end

        function term(obj)
            feval(obj.Model,[],[],[],'term');
        end

        function mdls=getUniqueNormalModeModels(obj)


            mdls=vertcat({obj.Model},obj.UniqueNormalRefModels);
        end

        function mdls=getUniqueUnLoadedRefModels(obj)

            open_diagrams=find_system('type','block_diagram');
            mdls={};


            [allmdls,~]=find_mdlrefs(obj.Model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            for ct=1:numel(allmdls)
                if~any(strcmp(allmdls{ct},open_diagrams))
                    mdls{end+1}=allmdls{ct};%#ok<AGROW>
                end
            end
        end

        function restoreParameters(obj)



            models=obj.getUniqueNormalModeModels;

            for ct=numel(models):-1:1

                if~isempty(obj.OrigModelParams)
                    f=fieldnames(obj.OrigModelParams);
                    for k=1:length(f)
                        prop=f{k};
                        set_param(models{ct},prop,obj.OrigModelParams(ct).(prop));
                    end
                end


                activeConfig=getActiveConfigSet(models{ct});
                if isa(activeConfig,'Simulink.ConfigSetRef')
                    activeConfig=activeConfig.getRefConfigSet;
                end
                if~isempty(obj.OrigConfigSetParameters)
                    f=fieldnames(obj.OrigConfigSetParameters{ct});
                    for k=1:length(f)
                        prop=f{k};
                        set_param(activeConfig,prop,obj.OrigConfigSetParameters{ct}.(prop));
                    end
                end


                if~isempty(obj.TunableParametersAdded)
                    str=get_param(models{ct},'TunableVars');
                    ind=strfind(str,obj.TunableParametersAdded);
                    if ind~=1

                        str(ind-1:end)=[];
                    else

                        str='';
                    end
                    set_param(models{ct},'TunableVars',str);
                    str=get_param(models{ct},'TunableVarsStorageClass');
                    ind=strfind(str,'Auto,Auto');
                    if ind~=1

                        str(ind-1:end)=[];
                    else

                        str='';
                    end
                    set_param(models{ct},'TunableVarsStorageClass',str);
                    str=get_param(models{ct},'TunableVarsTypeQualifier');
                    ind=strfind(str,',');
                    if ind~=1

                        str(ind-1:end)=[];
                    else

                        str='';
                    end
                    set_param(models{ct},'TunableVarsTypeQualifier',str);
                end


                set_param(models{ct},'ModelReferenceNormalModeCallback',[]);

            end


            obj.OrigModelParams=[];
            obj.OrigConfigSetParameters={};
            obj.ModelParameters=[];
            obj.ConfigSetParameters=[];
        end

        function prepareForFrestimate(obj)

            manageModelDirtyState(obj,'cache');


            obj.eiAdapter=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);


            obj.OrigAutoSave=slcontrollib.internal.utils.enableAutoSave('off');

            prepareParametersForFrestimate(obj);
        end

        function prepareParametersForFrestimate(obj)




            normalrefmdls=obj.UniqueNormalRefModels;

            for ct=1:numel(normalrefmdls)
                activeConfig=getActiveConfigSet(normalrefmdls{ct});
                if isa(activeConfig,'Simulink.ConfigSetRef')
                    activeConfig=activeConfig.getRefConfigSet;
                end
                set_param(activeConfig,'ModelReferenceMultiInstanceNormalModeStructChecksumCheck','none')
            end


            obj.ConfigSetParameters=linearize.linutil.createDisableWarningParameters;


            models=obj.getUniqueNormalModeModels;
            for ct=1:numel(models)
                mdl=models{ct};
                prepareLocalModelParameters(obj,mdl,[]);



                if ct==1&&isfield(obj.ModelParameters,'LoadInitialState')
                    obj.ModelParameters.LoadInitialState='off';
                    obj.ModelParameters.InitialState='';
                end
            end

        end

        function restoreForFrestimate(obj)

            normalrefmdls=obj.UniqueNormalRefModels;

            for ct=1:numel(normalrefmdls)
                activeConfig=getActiveConfigSet(normalrefmdls{ct});
                if isa(activeConfig,'Simulink.ConfigSetRef')
                    activeConfig=activeConfig.getRefConfigSet;
                end
                set_param(activeConfig,'ModelReferenceMultiInstanceNormalModeStructChecksumCheck','error')
            end

            restoreModels(obj);
            closeModels(obj);
        end

        function validateModelInEditMode(obj)


            if~strcmp(get_param(obj.Model,'SimulationStatus'),'stopped')
                error(message('Slcontrol:lintool:ModelIsCompiled',obj.Model));
            end
        end

        function checkModelRefForFrestimate(obj,io)




            normalrefmdls=obj.NormalRefModels;
            for ct_outer=1:numel(normalrefmdls)
                normal_instances_count=numel(find(strcmp(normalrefmdls{ct_outer},normalrefmdls)));
                normal_and_accel_instances_count=numel(find(strcmp(normalrefmdls{ct_outer},obj.AllRefModels)));
                if normal_instances_count~=normal_and_accel_instances_count


                    closeModels(obj);
                    ctrlMsgUtils.error('SLControllib:slcontrol:ModelRefFRESTIMATENormalAndAccelTogetherError',...
                    normalrefmdls{ct_outer});
                elseif normal_instances_count>1


                    if LocalIsAnyIOInRefModel(normalrefmdls{ct_outer},io)

                        closeModels(obj);
                        ctrlMsgUtils.error('SLControllib:slcontrol:ModelRefFRESTIMATEMultiInstanceNormalModeError',...
                        normalrefmdls{ct_outer});
                    end
                end
            end

        end

        function out=getInsertionInfo(obj,injdata)
            models=obj.getUniqueNormalModeModels;
            injdataDistModels=cell(length(models),1);
            for ct=1:length(injdata)
                modelname=get(slcontrollib.internal.utils.getModelHandleFromBlock(get_param(injdata(ct),'Parent')),'Name');

                injdataDistModels{strcmp(modelname,models)}(end+1)=injdata(ct);
            end

            for ct=1:length(injdataDistModels)
                set_param(models{ct},'InjectionData',injdataDistModels{ct});
            end

            insertioninfo={};
            for ct=1:length(models)
                hMdl=slcontrollib.internal.utils.getModelHandle(models{ct});
                try
                    insertioninfo{end+1}=getInjectionDataForSignalBasedLinearization(hMdl);
                catch Me


                    model=obj.Model;
                    obj.restoreForFrestimate;
                    [errids,~]=slprivate('getAllErrorIdsAndMsgs',Me);
                    if any(strcmp(errids,'Simulink:SampleTime:InvPortBasedSFcnBlkInTrigSubsys'))
                        ctrlMsgUtils.error('Slcontrol:frest:IOInAsyncSubsystem',model);
                    elseif any(strcmp(errids,'Simulink:Engine:SignalBasedLinearizationIOOnABus'))
                        ctrlMsgUtils.error('Slcontrol:frest:NoBusIOAllowed');
                    end
                    rethrow(Me);
                end
                set_param(models{ct},'InjectionData',[]);
            end


            lens=cellfun(@length,insertioninfo);
            out=insertioninfo{1};
            for ct=2:length(insertioninfo)
                out(end+1:end+lens(ct))=insertioninfo{ct};
            end
        end

        function prepareTunableParameters(obj,variablelist)

            models=obj.getUniqueNormalModeModels;
            obj.TunableParametersAdded=variablelist;

            for model_ct=1:numel(models)
                origTunPars=get_param(models{model_ct},'TunableVars');
                origTunStorage=get_param(models{model_ct},'TunableVarsStorageClass');
                origTunQual=get_param(models{model_ct},'TunableVarsTypeQualifier');

                if~isempty(origTunPars)
                    set_param(models{model_ct},'TunableVars',strcat(origTunPars,',',variablelist));
                else
                    set_param(models{model_ct},'TunableVars',variablelist);
                end
                if~isempty(origTunStorage)
                    set_param(models{model_ct},'TunableVarsStorageClass',strcat(origTunStorage,',Auto,Auto'));
                else
                    set_param(models{model_ct},'TunableVarsStorageClass','Auto,Auto');
                end
                if~isempty(origTunQual)
                    set_param(models{model_ct},'TunableVarsTypeQualifier',strcat(origTunQual,',,'));
                else


                    numcommas=numel(findstr(get_param(models{model_ct},'TunableVars'),','));
                    for ct=numcommas:-1:1
                        str(ct)=',';
                    end
                    set_param(models{model_ct},'TunableVarsTypeQualifier',str);
                end
            end

        end

        function distributeInjectionData(obj,injdata)
            models=obj.getUniqueNormalModeModels;
            injdataDistModels=cell(length(models),1);
            for ct=1:length(injdata)
                modelname=get(slcontrollib.internal.utils.getModelHandleFromBlock(get_param(injdata(ct).PortHandle,'Parent')),'Name');

                injdataDistModels{strcmp(modelname,models)}(end+1)=ct;
            end


            for ct=1:length(injdataDistModels)
                if~isempty(injdataDistModels{ct})
                    set_param(models{ct},'InjectionData',injdata(injdataDistModels{ct}));
                else
                    set_param(models{ct},'InjectionData',[]);
                end
            end
        end

        function name=findVariableNames(obj,candidate)
            list=evalin('base','who');

            models=obj.getUniqueNormalModeModels;

            for ct=1:numel(models)
                hws=get_param(models{ct},'ModelWorkspace');
                modelvars=hws.whos;modelvars={modelvars.name};
                list=[list(:);modelvars(:)];
            end
            name=cell(1,numel(candidate));
            for ct=1:numel(candidate)
                name{ct}=genvarname(candidate{ct},list);

                list{end+1}=name{ct};
            end
        end

        function restoreModelState(obj)


            if obj.RequestExternalCompile&&isCompiled(obj)


                if~isempty(obj.OriginalModelState)


                    sys=feval(obj.Model,[],[],[],'sizes');
                    nu=sys(4);
                    u=zeros(nu,1);

                    slcontrollib.internal.utils.pushTXU(obj.Model,0,obj.OriginalModelState,u);
                end
            end
        end

        function cleanupWithoutClose(obj,ismodelcompiled,varargin)

            if nargin>2
                autommd_orig=varargin{1};
                spparms('autommd',autommd_orig);
            end
            if nargin<2
                ismodelcompiled=isCompiled(obj);
            end

            if obj.RequestExternalCompile


                restoreModelState(obj);
            else
                if ismodelcompiled
                    obj.term();
                end

                obj.restoreModels();
            end
        end

        function cleanup(obj,ismodelcompiled,varargin)
            cleanupWithoutClose(obj,ismodelcompiled,varargin{:});
            obj.closeModels();
        end

        function val=isCompiled(this)
            val=strcmp(get_param(this.Model,'SimulationStatus'),'paused');
        end

    end

    methods(Access='public',Hidden=true)
        function prepareLocalModelParameters(obj,model,blockpath)





            DesiredParam=obj.ModelParameters;
            if numel(DesiredParam)
                f=fieldnames(DesiredParam);
                for k=1:length(f)
                    prop=f{k};
                    if strcmp(prop,'SCDLinearizationBlocksToRemove')
                        want_val=DesiredParam.(prop);
                        blkroot=bdroot(want_val);





                        if isempty(blockpath)
                            ind=strcmp(blkroot,model);
                            want_val=want_val(ind);
                        else
                            mdlblkpath=convertToCell(blockpath);



                            graphicalMdl=get_param(mdlblkpath{end},'ModelName');
                            ind=strcmp(blkroot,graphicalMdl);
                            want_val=want_val(ind);
                            for i=1:numel(want_val)


                                wv=want_val{i};
                                [~,eIdx]=regexp(wv,graphicalMdl);
                                stem=wv(eIdx+1:end);
                                want_val{i}=[model,stem];
                            end
                        end
                    elseif strcmp(prop,'SCDPotentialLinearizationIOs')

                        want_val=obj.findIOStructInModel(DesiredParam.(prop),model,blockpath);
                    else
                        want_val=DesiredParam.(prop);
                    end


                    have_val=get_param(model,prop);
                    origModelParams.(prop)=have_val;

                    set_param(model,prop,want_val);
                end
                obj.OrigModelParams=vertcat(obj.OrigModelParams,origModelParams);
            end


            activeConfig=getActiveConfigSet(model);
            if isa(activeConfig,'Simulink.ConfigSetRef')
                activeConfig=activeConfig.getRefConfigSet;
            end
            allparameterfields=activeConfig.getProp;
            configSetParameters=obj.ConfigSetParameters;
            if~isempty(configSetParameters)
                f=fieldnames(configSetParameters);
                origConfigSetParameters=[];
                for ct=1:numel(f)
                    prop=f{ct};


                    if any(contains(allparameterfields,prop))
                        try

                            have_val=get_param(activeConfig,prop);
                            origConfigSetParameters.(prop)=have_val;

                            want_val=configSetParameters.(prop);
                            set_param(activeConfig,prop,want_val);



                            if strcmp(prop,'StartTime')
                                starttime=str2double(want_val);
                                have_val=get_param(activeConfig,'StopTime');
                                origConfigSetParameters.StopTime=have_val;
                                stoptime=slResolve(get_param(model,'StopTime'),model);
                                if stoptime<=starttime
                                    set_param(activeConfig,'StopTime',sprintf('%.17g',starttime+1));
                                end
                            end
                        catch Ex
                            if strcmp(prop,'BufferReuse')
                                targetfile=get_param(activeConfig,'SystemTargetFile');
                                error(message('SLControllib:slcontrol:UnableToSetBufferReuse',prop,want_val,model,targetfile));
                            end
                            filterList={'OutputOption',...
                            'SimMechanicsOpenEditorOnUpdate',...
                            'SimscapeLogType',...
                            'SimscapeLogOpenViewer'};
                            if~ismember(prop,filterList)
                                rethrow(Ex)
                            end
                        end
                    end
                    if strcmp(prop,'StrictBusMsg')
                        obj.busLabelSetup(obj.BusLabelLocations,model,blockpath);
                    end
                end
                obj.OrigConfigSetParameters=vertcat(obj.OrigConfigSetParameters,origConfigSetParameters);
            end
        end
        function setBusLabelLocations(obj,io)
            obj.BusLabelLocations=io;
        end
    end

    methods(Access='private')

        function prepareParameters(obj)





            callback=slcontrollib.internal.mdlcfg.ParameterManagerModelRefCallback;
            callback.setParameterManager(obj);


            models=obj.getUniqueNormalModeModels;








            mdl=obj.Model;
            activeConfig=getActiveConfigSet(mdl);
            if isa(activeConfig,'Simulink.ConfigSetRef')
                activeConfig=activeConfig.getRefConfigSet;
            end
            if isfield(obj.ConfigSetParameters,'SaveFormat')&&...
                strcmp(get_param(activeConfig,'SaveState'),'on')
                wants=obj.ConfigSetParameters.SaveFormat;
                accelModels=unique(setdiff(obj.AllRefModels,obj.NormalRefModels));
                for i=1:numel(accelModels)



                    accelmdl=accelModels{i};
                    wasloaded=bdIsLoaded(accelmdl);
                    if~wasloaded
                        load_system(accelmdl);
                    end
                    has=get_param(accelmdl,'SaveFormat');
                    if~wasloaded
                        bdclose(accelmdl);
                    end
                    if strcmp(has,'Dataset')&&~strcmp(wants,has)
                        error(message('SLControllib:slcontrol:AcceleratedModelRefSaveFormatMismatch',...
                        has,accelmdl,wants));
                    end
                end
            end

            for ct=1:numel(models)
                prepareLocalModelParameters(obj,models{ct},[]);


                if~isempty(callback)
                    set_param(models{ct},'ModelReferenceNormalModeCallback',callback)
                end

            end
        end


        function busLabelSetup(obj,io,model,blockpath)
            if~isempty(io)


                if~any(strcmp(obj.getUniqueNormalModeModels,model))
                    unboundmodel=model;
                    mdlblock=blockpath.getBlock(blockpath.getLength);
                    model=get_param(mdlblock,'ModelName');
                    isUnBoundRef=true;
                else
                    isUnBoundRef=false;
                end
                for ct=1:length(io)

                    mdl=get(slcontrollib.internal.utils.getModelHandleFromBlock(io(ct).Block),'Name');
                    if isUnBoundRef
                        block=regexprep(io(ct).Block,model,unboundmodel);
                    else
                        block=io(ct).Block;
                    end
                    if strcmp(mdl,model)
                        ph=get_param(block,'PortHandles');
                        h=ph.Outport(io(ct).PortNumber);
                        blkh=slcontrollib.internal.utils.getBlockHandle(block);

                        if~slcontrollib.internal.utils.isRootInport(blkh)&&(isa(blkh,'Simulink.Inport')||isa(blkh,'Simulink.BusCreator'))
                            set_param(h,'CacheCompiledBusStruct','on');
                        elseif isa(blkh,'Simulink.SubSystem')

                            outport=find_system(block,'SearchDepth',1,...
                            'FollowLinks','on',...
                            'LookUnderMasks','all',...
                            'BlockType','Outport',...
                            'Port',num2str(io(ct).PortNumber));
                            ph=get_param(outport{1},'PortHandles');
                            set_param(ph.Inport,'CacheCompiledBusStruct','on');
                        end
                    end
                end
            else
                blocks=find_system(obj.Model,'SearchDepth',1,'BlockType','Outport');
                for ct=1:length(blocks)
                    ph=get_param(blocks{ct},'PortHandles');

                    set_param(ph.Inport,'CacheCompiledBusStruct','on');
                end
            end
        end

        function iostructobjModel=findIOStructInModel(obj,iostruct,model,blockpath)



            if~any(strcmp(obj.getUniqueNormalModeModels,model))
                unboundmodel=model;
                mdlblock=blockpath.getBlock(blockpath.getLength);
                model=get_param(mdlblock,'ModelName');
                isUnBoundRef=true;
            else
                isUnBoundRef=false;
            end

            iostructobjModel=[];
            for ct=1:numel(iostruct)

                mdl=get(slcontrollib.internal.utils.getModelHandleFromBlock(iostruct(ct).Block),'Name');
                if strcmp(mdl,model)
                    if isUnBoundRef
                        block=regexprep(iostruct(ct).Block,model,unboundmodel);
                    else
                        block=iostruct(ct).Block;
                    end
                    iostructobjModel(end+1).Block=block;%#ok<AGROW>
                    iostructobjModel(end).Port=iostruct(ct).Port;
                end
            end
        end
    end
end

function mdllist=LocalCreateMixedMdlRefErrorMsg(obj)

    mdls=LocalFindMixedModeModels(obj.Model);
    mdllist='(';
    for ct=1:numel(mdls)
        mdllist=sprintf('%s%s',mdllist,mdls{ct});
        if ct<numel(mdls)
            mdllist=sprintf('%s, ',mdllist);
        end
    end
    mdllist=sprintf('%s)',mdllist);
end

function mixedblks=LocalFindMixedModeModels(mdl)


    if Simulink.internal.useFindSystemVariantsMatchFilter()
        refmdls=find_mdlrefs(mdl,'MatchFilter',@Simulink.match.activeVariants);
    else
        refmdls=find_mdlrefs(mdl,'Variants','ActiveVariants');
    end


    refmdls(strcmp(refmdls,mdl))=[];




    modelmodes=false(numel(refmdls),2);
    recursemodel(mdl,true);


    function recursemodel(mdl,isnormal)
        if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',mdl))
            mdl_preloaded=false;
            load_system(mdl);
        else
            mdl_preloaded=true;
        end
        blks=find_system(mdl,'LookUnderMasks','all','FollowLinks',...
        'on','BlockType','ModelReference');

        mdls=get_param(blks,'ModelName');
        for ct=1:numel(mdls)
            ind=find(strcmp(mdls{ct},refmdls));
            if strcmp(get_param(blks{ct},'SimulationMode'),'Normal')&&isnormal
                modelmodes(ind,1)=true;
                isnextnormal=true;
            else
                modelmodes(ind,2)=true;
                isnextnormal=false;
            end
            recursemodel(mdls{ct},isnextnormal);
        end
        if~mdl_preloaded
            bdclose(mdl);
        end
    end

    mixedblks=refmdls(and(modelmodes(:,1),modelmodes(:,2)));
end

function out=LocalIsAnyIOInRefModel(model,io)
    out=false;
    for ct=1:numel(io)
        if strcmp(bdroot(io(ct).Block),model)
            out=true;
            return;
        end
    end
end







