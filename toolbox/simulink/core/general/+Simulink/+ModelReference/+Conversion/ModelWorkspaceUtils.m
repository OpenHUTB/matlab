




classdef ModelWorkspaceUtils<handle
    properties(SetAccess=private,GetAccess=private)
Model
ModelReferenceHandle
ModelWorkspace
ModelReferenceWorkspace

Logger
UseDataDictionary
        FHandles;
    end
    properties(SetAccess=private,GetAccess=protected)
        UsedVariables=[]
    end

    properties(Constant,Access=private)
        DataSources={'Model File','MATLAB Code','MAT-File','MATLAB File'};
    end


    methods(Access=public)
        function this=ModelWorkspaceUtils(srcModel,destModel,varargin)
            this.Model=srcModel;
            this.ModelReferenceHandle=destModel;


            if~isempty(varargin)
                this.UsedVariables=varargin{:};
            end
            this.UseDataDictionary=~isempty(get_param(this.Model,'DataDictionary'));
            this.FHandles={@this.copyModelFileWorkspace,@this.copyModelFileWorkspace,@this.copyModelFileWorkspace,@this.copyModelFileWorkspace};
        end


        function copy(this)
            this.ModelWorkspace=get_param(this.Model,'ModelWorkspace');
            this.ModelReferenceWorkspace=get_param(this.ModelReferenceHandle,'ModelWorkspace');




            if(~strcmp(this.ModelWorkspace.DataSource,'Model File'))
                this.ModelReferenceWorkspace.DataSource='Model File';
            end
            this.FHandles{strcmp(this.ModelWorkspace.DataSource,this.DataSources)}();
            usedVariables=this.ModelReferenceWorkspace.data;
            parameterArgumentsInOrigModel=strsplit(get_param(this.Model,'ParameterArgumentNames'),',');
            parameterArguments='';
            parameterArgumentInfos=[];
            for ii=1:length(usedVariables)
                for jj=1:length(parameterArgumentsInOrigModel)
                    if strcmp(parameterArgumentsInOrigModel{jj},usedVariables(ii).Name)
                        parameterArguments=[parameterArguments,',',parameterArgumentsInOrigModel{jj}];
                        parameterArgumentInfos=[parameterArgumentInfos;usedVariables(ii)];
                    end
                end
            end

            setParameterArgumentsFlag=false;
            if~isempty(parameterArguments)
                parameterArguments=parameterArguments(2:end);
                set_param(this.ModelReferenceHandle,'ParameterArgumentNames',parameterArguments);
                setParameterArgumentsFlag=true;
            end


            if setParameterArgumentsFlag
                for ii=1:length(parameterArgumentInfos)
                    variable=parameterArgumentInfos(ii);
                    if isa(variable.Value,'Simulink.Parameter')||isa(variable.Value,'Simulink.LookupTable')
                        variableInOrigMWS=getVariable(this.ModelWorkspace,variable.Name);
                        variableInNewMWS=getVariable(this.ModelReferenceWorkspace,variable.Name);
                        variableInNewMWS.StorageClass=variableInOrigMWS.StorageClass;
                    end
                end

            end
        end

        function setLogger(this,logger)
            this.Logger=logger;
        end
    end


    methods(Access=protected)
        function copyModelFileWorkspace(this)
            if isempty(this.UsedVariables)
                this.copyParameters;
            else
                this.copyParametersUsedBySubsystem;
            end
        end

        function copyParametersUsedBySubsystem(this)
            numberOfUsedVariables=length(this.UsedVariables);
            for idx=1:numberOfUsedVariables
                varName=this.UsedVariables(idx).Name;
                varValue=this.ModelWorkspace.getVariable(varName);
                this.createVariable(varName,varValue);
            end
        end
    end


    methods(Access=private)
        function copyParameters(this)
            srcData=this.ModelWorkspace.data;
            numberOfVariables=length(srcData);
            for idx=1:numberOfVariables
                varName=srcData(idx).Name;
                varValue=srcData(idx).Value;
                this.createVariable(varName,varValue);
            end
        end

        function copyMatlabCodeWorkspace(this)
            this.ModelReferenceWorkspace.MATLABCode=this.ModelWorkspace.MATLABCode;
            this.ModelReferenceWorkspace.reload;
        end


        function copyMatFileWorkspace(this)
            this.ModelReferenceWorkspace.FileName=this.ModelWorkspace.FileName;
            this.ModelReferenceWorkspace.reload;
        end


        function createVariable(this,varName,varValue)
            this.ModelReferenceWorkspace.assignin(varName,varValue);
            if~isempty(this.Logger)&&~this.UseDataDictionary
                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:CopiedParameter',varName,...
                Simulink.ModelReference.Conversion.MessageBeautifier.beautifyModelName(getfullname(this.ModelReferenceHandle))));
            end
        end
    end

    methods(Static,Access=public)
        function setupInstanceParameters(currentSubsystem,modelRefName,isCopyContent,useTempModelAndNotCreateBusObjects)
            mdlBlksInSubSys=find_mdlref_blocks(currentSubsystem);

            currentSubsystemName=get_param(currentSubsystem,'Name');



            currentSubsystemName=replace(currentSubsystemName,'/','//');
            curSubsysNameLength=length(currentSubsystemName);

            currentSubsystemParentName=get_param(currentSubsystem,'Parent');

            subsysParentPatternStringIdx=length(currentSubsystemParentName)+curSubsysNameLength+1;
            mdlBlksInNewMdl=find_mdlref_blocks(modelRefName);
            newMdlBlksInNewMdl=mdlBlksInNewMdl;
            for mdlBlkInNewMdlIdx=1:numel(mdlBlksInNewMdl)
                tmpStr=mdlBlksInNewMdl{mdlBlkInNewMdlIdx};
                if useTempModelAndNotCreateBusObjects
                    tmpStr=tmpStr(length(modelRefName)+2+...
                    (curSubsysNameLength+1):end);
                else
                    tmpStr=tmpStr(length(modelRefName)+2+...
                    (curSubsysNameLength+1)*(~isCopyContent):end);
                end
                newMdlBlksInNewMdl{mdlBlkInNewMdlIdx}=tmpStr;
            end

            for mdlBlkInSubSysIdx=1:numel(mdlBlksInSubSys)
                mdlBlkInSubsys=mdlBlksInSubSys{mdlBlkInSubSysIdx};
                mdlBlkInSubsys=mdlBlkInSubsys(subsysParentPatternStringIdx+2:end);
                mdlIdx=find(cellfun(@(s)strcmp(mdlBlkInSubsys,s)==true,newMdlBlksInNewMdl));
                assert(numel(mdlIdx)==1);
                instParamArgs=get_param(mdlBlksInSubSys{mdlBlkInSubSysIdx},'InstanceParameters');
                set_param(mdlBlksInNewMdl{mdlIdx},'InstanceParameters',instParamArgs);
            end
        end

        function setupInstanceParameterValuesOnModelBlocks(mdlRef,modelBlockName)


            allMdlRefBlks=find_mdlref_blocks(mdlRef);
            argStruct=[];
            for blkIdx=1:numel(allMdlRefBlks)
                tmpStruct=get_param(allMdlRefBlks{blkIdx},'InstanceParameters');
                for tmpIdx=1:numel(tmpStruct)
                    if tmpStruct(tmpIdx).Argument==true
                        tmpFullPath=convertToCell(tmpStruct(tmpIdx).Path);
                        tmpStruct(tmpIdx).Path=Simulink.BlockPath([allMdlRefBlks(blkIdx);tmpFullPath]);
                        tmpStruct(tmpIdx).Argument=false;
                        argStruct=[argStruct;tmpStruct(tmpIdx)];
                    end
                end
            end
            if~isempty(argStruct)
                set_param(modelBlockName,'InstanceParameters',argStruct);
            end


            argNames=get_param(modelBlockName,'InstanceParameters');
            if~isempty(argNames)
                for ii=1:length(argNames)
                    if(isempty(convertToCell(argNames(ii).Path)))
                        argNames(ii).Value=argNames(ii).Name;
                    end
                end
                set_param(modelBlockName,'InstanceParameters',argNames);
            end
        end
    end
end
