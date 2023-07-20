




classdef IncrementalCodeGenDriver<matlab.mixin.SetGet


    properties(Constant,Hidden=true)
        CODEGENSTATUSFILENAME='hdlcodegenstatus.mat';
        ALWAYSNOREGEN=0;
        ALWAYSREGEN=1;
        SMART=2;

        NEVERDIAG_NONE=0;
        NEVERDIAG_WARNING=1;
        NEVERDIAG_ERROR=2;
    end

    properties(Access=protected)
        incrementalCodeGenStatus=[];
        preconditionRegen=true;
        neverDiagLevel=2;
    end

    methods(Access=public)

        function obj=IncrementalCodeGenDriver(codeGenDriver)
            obj.init(codeGenDriver);
        end

        function init(this,codeGenDriver)
            [this.neverDiagLevel,this.preconditionRegen]=this.resolvePreconditionRegen(codeGenDriver);

            allModelsNames={codeGenDriver.AllModels.modelName};
            this.incrementalCodeGenStatus=containers.Map('KeyType','char','ValueType','any');
            for i=1:length(allModelsNames)
                this.incrementalCodeGenStatus(allModelsNames{i})=this.getDefaultIncrementalCodeGenStatusStruct();
            end
        end

        function loadHDLCodeGenStatus(this,codeGenDriver,modelName)
            hdlCodeGenStatus=[];
            cgsFilePath=this.hdlCodeGenStatusFilePath(codeGenDriver);
            if(exist(cgsFilePath,'file')==2)
                try
                    hdlCodeGenStatus=load(cgsFilePath);
                catch %#ok<CTCH>
                    hdlCodeGenStatus=[];
                end
            end
            cgs=this.incrementalCodeGenStatus(modelName);
            cgs.hdlCodeGenStatus=hdlCodeGenStatus;
        end

        function saveHDLCodeGenerationStatus(this,codeGenDriver,p)
            if(this.preconditionRegen==this.ALWAYSNOREGEN)
                return;
            end

            if(this.incrementalCodeGenStatus(p.ModelName).regenModel||this.incrementalCodeGenStatus(p.ModelName).regenCode||(this.preconditionRegen==this.ALWAYSREGEN))
                cgsFilePath=this.hdlCodeGenStatusFilePath(codeGenDriver);
                genFileList=codeGenDriver.getEntityFileNames(p);
                currStatus=this.incrementalCodeGenStatus(p.ModelName);
                if(isfield(codeGenDriver.cgInfo,'DSPBALibSynthesisScriptsNeeded'))
                    currStatus.newHDLCodeGenStatus.DSPBALibSynthesisScriptsNeeded=codeGenDriver.cgInfo.DSPBALibSynthesisScriptsNeeded;
                end
                if(isfield(codeGenDriver.cgInfo,'DSPBAAdditionalFiles'))
                    currStatus.newHDLCodeGenStatus.DSPBAAdditionalFiles=codeGenDriver.cgInfo.DSPBAAdditionalFiles;
                end






                if codeGenDriver.getParameter('BuildToProtectModel')
                    targetdir=hdlGetCodegendir;
                    hdlparamFile=[targetdir,filesep,'hdlparams.m'];
                    hdlparams=hdlsaveparams(codeGenDriver.ModelName,hdlparamFile,'force_overwrite');
                    rowsToBeRemoved=[];
                    for ii=1:numel(hdlparams)
                        object=hdlparams(ii).object;


                        if~strcmp(object,codeGenDriver.ModelName)&&...
                            ~strcmp(object,codeGenDriver.OrigStartNodeName)
                            rowsToBeRemoved=[rowsToBeRemoved,ii];%#ok<AGROW>
                        end
                    end
                    hdlparams(rowsToBeRemoved)=[];
                    currStatus.newHDLCodeGenStatus.HDLParams=hdlparams;
                    delete(hdlparamFile);
                end

                currStatus.newHDLCodeGenStatus.GenFileList=genFileList;
                currStatus.newHDLCodeGenStatus.Latency=codeGenDriver.cgInfo.latency;
                currStatus.newHDLCodeGenStatus.PhaseCycles=codeGenDriver.cgInfo.phaseCycles;
                newHDLCodeGenStatus=currStatus.newHDLCodeGenStatus;
                if isfile(cgsFilePath)

                    s=load(cgsFilePath);
                    f=fieldnames(newHDLCodeGenStatus);
                    for i=1:numel(f)
                        s.(f{i})=newHDLCodeGenStatus.(f{i});
                    end
                    s=orderfields(s);
                    save(cgsFilePath,'-struct','s');
                else
                    newHDLCodeGenStatus=orderfields(newHDLCodeGenStatus);
                    save(cgsFilePath,'-struct','newHDLCodeGenStatus');
                end
            end
        end

        function[errorLevel,regen]=resolvePreconditionRegen(this,codeGenDriver)


            mdlrefRebuild=get_param(codeGenDriver.ModelName,'UpdateModelReferenceTargets');
            neverDiag=get_param(codeGenDriver.ModelName,'CheckModelReferenceTargetMessage');

            switch mdlrefRebuild
            case 'Force'
                regen=this.ALWAYSREGEN;
            case{'IfOutOfDateOrStructuralChange','IfOutOfDate'}
                regen=this.SMART;
            case 'AssumeUpToDate'
                regen=this.ALWAYSNOREGEN;
            otherwise
                assert(true);
            end

            switch lower(neverDiag)
            case 'none'
                errorLevel=this.NEVERDIAG_NONE;
            case 'warning'
                errorLevel=this.NEVERDIAG_WARNING;
            case 'error'
                errorLevel=this.NEVERDIAG_ERROR;
            otherwise
                assert(true);
            end

        end

        function forceRegenCode(this,codeGenDriver)
            numModels=numel(codeGenDriver.AllModels);
            for mdlIdx=1:numModels
                codeGenDriver.mdlIdx=mdlIdx;
                statusmatDir=codeGenDriver.hdlGetCodegendir;
                statusmatFile=fullfile(statusmatDir,this.CODEGENSTATUSFILENAME);

                if exist(statusmatFile,'file')
                    delete(statusmatFile);
                end
            end
        end

        function[regenFrontEnd,newFrontEndStatus]=frontEndPredicate(this,codeGenDriver,modelName,mHandle)
            [regenFrontEnd,newFrontEndStatus]=this.frontEndPredicatePrivate(codeGenDriver,modelName,mHandle);
        end

        function regen=modelGenerationPredicate(this,codeGenDriver,p)
            blkHandle=p.getTopNetwork.getFirstCRCInstanceSimulinkHandle();
            [regenFrontEnd,newFrontEndStatus]=this.frontEndPredicate(codeGenDriver,p.ModelName,blkHandle);
            [regenModel,newModelGenStatus]=this.modelGenerationPredicatePrivate(codeGenDriver,p,newFrontEndStatus);

            if(this.preconditionRegen==this.ALWAYSNOREGEN)
                if(regenModel)
                    this.reportNeverRebuildViolation(p.ModelName);
                end
                regen=false;
                return;
            end

            regen=regenFrontEnd|regenModel|(this.preconditionRegen==this.ALWAYSREGEN);
            cgs=this.incrementalCodeGenStatus(p.ModelName);
            cgs.regenModel=regen;

            cgs.newHDLCodeGenStatus.ModelGenStatus=newModelGenStatus;
        end

        function regen=codeGenerationPredicate(this,p)
            regenModel=this.incrementalCodeGenStatus(p.ModelName).regenModel;
            [regenCode,newCodeGenStatus]=this.codeGenerationPredicatePrivate(p);

            if(this.preconditionRegen==this.ALWAYSNOREGEN)
                if(~regenModel&&regenCode)
                    this.reportNeverRebuildViolation(p.ModelName);
                end
                regen=false;
                return;
            end


            regen=regenModel|regenCode|(this.preconditionRegen==this.ALWAYSREGEN);
            cgs=this.incrementalCodeGenStatus(p.ModelName);
            cgs.regenCode=regen;

            cgs.newHDLCodeGenStatus.CodeGenStatus=newCodeGenStatus;
        end


        function genFileList=getGenFileList(this,modelName)
            status=this.incrementalCodeGenStatus(modelName);
            genFileList=status.hdlCodeGenStatus.GenFileList;
        end
    end

    methods(Access=protected)
        function[regen,newFrontEndStatus]=frontEndPredicatePrivate(this,codeGenDriver,modelName,mHandle)
            regen=true;
            newFrontEndStatus=incrementalcodegen.IncrementalCodeGenDriver.getFrontEndStatusData(codeGenDriver,modelName,mHandle);

            hdlCodeGenStatus=this.incrementalCodeGenStatus(modelName).hdlCodeGenStatus;



            try
                if(isempty(newFrontEndStatus.ModelStructuralChecksum))
                    return;
                end

                if(isempty(newFrontEndStatus.ModelTopLevelHDLParams))
                    return;
                end

                if isempty(hdlCodeGenStatus)
                    return;
                end

                fieldnames={'Version';'ModelStructuralChecksum';'CLI';...
                'ModelTopLevelHDLParams';'TopModelNonStructuralData'};
                for ii=1:length(fieldnames)
                    hdlFrontEndStatus.(fieldnames{ii})=hdlCodeGenStatus.ModelGenStatus.(fieldnames{ii});
                end

                if~isequal(hdlFrontEndStatus,newFrontEndStatus)
                    return;
                end
            catch %#ok<CTCH>
                return;
            end

            regen=false;
        end
        function[regen,newModelGenStatus]=modelGenerationPredicatePrivate(this,codeGenDriver,p,newFrontEndStatus)
            regen=true;
            newModelGenStatus=incrementalcodegen.IncrementalCodeGenDriver.getModelStatusData(codeGenDriver,p,newFrontEndStatus);

            hdlCodeGenStatus=this.incrementalCodeGenStatus(p.ModelName).hdlCodeGenStatus;

            try

                if isempty(hdlCodeGenStatus)||...
                    ~isequal(hdlCodeGenStatus.ModelGenStatus,newModelGenStatus)
                    return;
                end
            catch %#ok<CTCH>
                return;
            end

            regen=false;
        end

        function[regen,newCodeGenStatus]=codeGenerationPredicatePrivate(this,p)
            regen=true;
            newCodeGenStatus.clockReportDatt=p.getClockReportData();
            hdlCodeGenStatus=this.incrementalCodeGenStatus(p.ModelName).hdlCodeGenStatus;

            try

                if isempty(hdlCodeGenStatus)||...
                    ~isequal(hdlCodeGenStatus.CodeGenStatus,newCodeGenStatus)
                    return;
                end
            catch %#ok<CTCH>
                return;
            end

            regen=false;
        end

        function s=getDefaultIncrementalCodeGenStatusStruct(~)
            s=incrementalcodegen.IncrementalCodeGenStatus();
        end

        function filePath=hdlCodeGenStatusFilePath(this,codeGenDriver)
            codeGenDir=codeGenDriver.hdlGetCodegendir;
            filePath=fullfile(codeGenDir,this.CODEGENSTATUSFILENAME);
        end

        function reportNeverRebuildViolation(this,modelName)
            switch this.neverDiagLevel
            case this.NEVERDIAG_NONE
                return;
            case this.NEVERDIAG_WARNING
                warn(message('hdlcoder:makehdl:modelrefOutOfDate',modelName));
            case this.NEVERDIAG_ERROR
                error(message('hdlcoder:makehdl:modelrefOutOfDate',modelName));
            otherwise
                assert(true);
            end
        end
    end

    methods(Static)



        function shallDo=topModelPredicate(modelName)
            p=pir;
            isTopModel=isequal(modelName,p.getTopPirCtx.ModelName);
            incrCodeGenForTop=hdlgetparameter('IncrementalCodeGenForTopModel');
            shallDo=~isTopModel||...
            (~isempty(incrCodeGenForTop)&&incrCodeGenForTop);
        end



        function checksum=hashEntireDesign(topModelName,dataRetrieveFunc)
            hdriver=hdlmodeldriver(topModelName);
            dbg=hdriver.getParameter('Debug');
            numModels=numel(hdriver.AllModels);
            itemChecksums={};
            for mdlIdx=1:numModels
                mdlName=hdriver.AllModels(mdlIdx).modelName;
                p=pir(mdlName);
                item.modelGenStatusData=dataRetrieveFunc(hdriver,p);
                item.modelName=mdlName;
                if(dbg>0)
                    itemChecksums{end+1}=item;%#ok<AGROW>
                else
                    str=hdlwfsmartbuild.serialize(item);
                    itemChecksums{end+1}=rptgen.hash(str);%#ok<AGROW>
                end
            end
            if(dbg>0)
                checksum=itemChecksums;
            else
                str=hdlwfsmartbuild.serialize(itemChecksums);
                checksum=rptgen.hash(str);
            end
        end

        function newHDLCodeGenStatus=getFrontEndStatusData(codeGenDriver,modelName,mHandle)

            newHDLCodeGenStatus.Version=ver('HDLCoder');
            modelInfo=codeGenDriver.getModelInfo(modelName);
            newHDLCodeGenStatus.ModelStructuralChecksum=modelInfo.slFrontEnd.ModelCheckSum;
            newHDLCodeGenStatus.CLI=codeGenDriver.getCPObj.CLI.dumpParamsStr(true);
            newHDLCodeGenStatus.ModelTopLevelHDLParams=incrementalcodegen.IncrementalCodeGenDriver.getModelTopLevelHDLParams(codeGenDriver,mHandle);
            newHDLCodeGenStatus.TopModelNonStructuralData=incrementalcodegen.IncrementalCodeGenDriver.getTopModelNonStructuralData(codeGenDriver.ModelName);
        end

        function newHDLCodeGenStatus=getModelStatusData(codeGenDriver,p,newHDLCodeGenStatus)

            newHDLCodeGenStatus.DelayData=codeGenDriver.retrieveModelDelayData(p);
            newHDLCodeGenStatus.TopNetworkPortInfo=incrementalcodegen.IncrementalCodeGenDriver.getModelTopLevelPorts(codeGenDriver,p);
        end

        function newHDLCodeGenStatus=getModelGenerationStatusData(codeGenDriver,p)
            blkHandle=p.getTopNetwork.getFirstCRCInstanceSimulinkHandle();
            newFrontEndStatus=incrementalcodegen.IncrementalCodeGenDriver.getFrontEndStatusData(codeGenDriver,p.ModelName,blkHandle);
            newHDLCodeGenStatus=incrementalcodegen.IncrementalCodeGenDriver.getModelStatusData(codeGenDriver,p,newFrontEndStatus);
        end

        function params=getModelTopLevelHDLParams(codeGenDriver,blkHandle)
            if(blkHandle)
                cm=codeGenDriver.getConfigManager(get_param(bdroot(blkHandle),'name'));
                [~,implInfo]=cm.getImplementationForBlock([get_param(blkHandle,'parent'),'/',get_param(blkHandle,'name')]);
            else
                cm=codeGenDriver.getConfigManager(codeGenDriver.OrigModelName);
                [~,implInfo]=cm.getImplementationForBlock(codeGenDriver.OrigStartNodeName);
            end
            try
                params=implInfo.Parameters;
            catch
                params=[];
            end
        end

        function nonStructuralData=getTopModelNonStructuralData(modelName)
            paramNames={'SimulationMode',...
            'StartTime',...
            'StopTime',...
            'SolverType',...
            'Solver',...
            };

            for i=1:length(paramNames)
                paraName=paramNames{i};
                nonStructuralData.(paraName)=get_param(modelName,paraName);
            end
        end

        function portInfo=getModelTopLevelPorts(codeGenDriver,p)
            tn=p.getTopNetwork;
            portInfo.inputPorts=struct('Name',[],...
            'Rate',[],...
            'Kind',[],...
            'PortIndex',[],...
            'IsComplex',[],...
            'Testpoint',[],...
            'TunableName',[],...
            'Latency',[]);

            for i=1:length(tn.PirInputPorts)
                port=tn.PirInputPorts(i);
                sig=port.Signal;
                portData.Rate=sig.SimulinkRate;
                portData.Name=port.Name;
                portData.Kind=port.Kind;
                portData.PortIndex=port.PortIndex;
                portData.IsComplex=sig.Type.isComplexType||...
                sig.Type.BaseType.isComplexType;
                portData.Testpoint=port.isTestpoint;
                portData.TunableName='';
                if~isempty(port.getTunableName)
                    portData.TunableName=port.getTunableName;
                end
                portData.Latency=-1;
                portInfo.inputPorts(i)=portData;
            end

            portInfo.outputPorts=struct('Name',[],...
            'Rate',[],...
            'Kind',[],...
            'PortIndex',[],...
            'IsComplex',[],...
            'Testpoint',[],...
            'TunableName',[],...
            'Latency',[]);
            for i=1:length(tn.PirOutputPorts)
                port=tn.PirOutputPorts(i);
                sig=port.Signal;
                portData.Rate=sig.SimulinkRate;
                portData.Name=port.Name;
                portData.Kind=port.Kind;
                portData.PortIndex=port.PortIndex;
                portData.IsComplex=sig.Type.isComplexType||...
                sig.Type.BaseType.isComplexType;
                portData.Testpoint=port.isTestpoint;
                portData.TunableName='';
                if~isempty(port.getTunableName)
                    portData.TunableName=port.getTunableName;
                end
                portData.Latency=-1;
                if codeGenDriver.getParameter('BuildToProtectModel')&&...
                    isequal(codeGenDriver.ModelName,p.ModelName)
                    portData.Latency=p.getDutExtraLatency(i-1);
                end
                portInfo.outputPorts(i)=portData;
            end
        end

        function fileName=hdlCodeGenStatusFileName()
            fileName=incrementalcodegen.IncrementalCodeGenDriver.CODEGENSTATUSFILENAME;
        end
    end

end



