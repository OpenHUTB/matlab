




classdef ConversionData<handle
    properties(SetAccess=private,GetAccess=public)
ConversionParameters
Logger
ParameterMap
DataAccessor


        VariableNames={}
ModelActions
Graph

        ScratchModel=[];
        ReplaceSubsystem=false;
    end

    properties(Hidden,SetAccess=public,GetAccess=public)
        TopModelFixes={}
        ReferencedModelFixes={}
        SystemFixes={}
ModelBlocks



        SkipVirtualSubsystemCheck=false;
        FcnCallCrossBoundaryWithGotoFrom=false;
        MustCopySubsystem=false;

        DSMReferenceCopyInfo={};


        BlockPriority;
    end

    properties(Constant)
        ScratchModelName='ScratchModel'
    end

    methods(Access=public)
        function this=ConversionData(varargin)
            this.ConversionParameters=Simulink.ModelReference.Conversion.ConversionParameters.create(varargin{:});
            this.DataAccessor=Simulink.data.DataAccessor.createForExternalData(this.ConversionParameters.Model);
            this.Logger=Simulink.ModelReference.Conversion.ConversionLogger;


            this.ParameterMap=Simulink.ModelReference.Conversion.ParameterMap;
            this.ModelActions=Simulink.ModelActions(this.ConversionParameters.Model);
            if this.ConversionParameters.UseConversionAdvisor

                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:InputParameterInfo',...
                DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogSubsystemName'),...
                Simulink.ModelReference.Conversion.Utilities.cellstr2str(...
                Simulink.ModelReference.Conversion.Utilities.cellify(...
                getfullname(this.ConversionParameters.Systems)),'','')));

                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:InputParameterInfo',...
                DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogNewModelName'),...
                Simulink.ModelReference.Conversion.Utilities.cellstr2str(...
                this.ConversionParameters.ModelReferenceNames,'','')));

                if~isempty(this.ConversionParameters.DataFileName)
                    this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:InputParameterInfo',...
                    DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogDataFileName'),...
                    this.ConversionParameters.DataFileName));
                end


                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:InputParameterInfo',...
                [DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogReplaceSubsystem'),':'],...
                Simulink.ModelReference.Conversion.ConversionData.getBoolString(this.ConversionParameters.ReplaceSubsystem)));

                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:InputParameterInfo',...
                [DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogAutoFix'),':'],...
                Simulink.ModelReference.Conversion.ConversionData.getBoolString(this.ConversionParameters.UseAutoFix)));

                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:InputParameterInfo',...
                [DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogCheckSimulationResults'),':'],...
                Simulink.ModelReference.Conversion.ConversionData.getBoolString(this.ConversionParameters.CheckSimulationResults)));

                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:InputParameterInfo',...
                DAStudio.message('Simulink:modelReferenceAdvisor:AbsoluteTolerance'),...
                num2str(this.ConversionParameters.AbsoluteTolerance)));

                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:InputParameterInfo',...
                DAStudio.message('Simulink:modelReferenceAdvisor:RelativeTolerance'),...
                num2str(this.ConversionParameters.RelativeTolerance)));

                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:InputParameterInfo',...
                DAStudio.message('Simulink:modelReferenceAdvisor:SimulationMode'),...
                Simulink.ModelReference.Conversion.Utilities.cellstr2str(this.ConversionParameters.SimulationModes,'{','}')));
            end
            this.Graph=Simulink.ModelReference.SubsystemGraph.create(this.ConversionParameters.Systems);
            this.checkForNestedSystems;


            this.ReplaceSubsystem=this.ConversionParameters.ReplaceSubsystem;
            this.ModelBlocks=zeros(numel(this.ConversionParameters.Systems),1);
            this.MustCopySubsystem=this.ConversionParameters.CopySubsystem;
        end

        function delete(this)
            if this.ReplaceSubsystem
                N=numel(this.ScratchModel);
                for idx=1:N
                    aModel=this.ScratchModel(idx);
                    if ishandle(aModel)
                        close_system(aModel,0);
                    end
                end
            end
        end

        function saveData(this)
            if~isempty(this.VariableNames)
                savedFileList=this.saveAndGetExternalDataSources();
                for i=1:length(savedFileList)
                    this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:SaveDataMessage',savedFileList{i}));
                end
            end
        end

        function subsys=beautifySubsystemName(this,subsys)
            if this.ConversionParameters.UseConversionAdvisor

                ssName=this.ConversionParameters.getSystemName(subsys);
                ssSID=this.ConversionParameters.getSystemSIDs(subsys);
                subsys=Simulink.ModelReference.Conversion.MessageBeautifier.createHyperlinkString(...
                ssName,sprintf('matlab: hilite_system(Simulink.ID.getHandle(''%s''))',ssSID));
            else
                subsys=this.ConversionParameters.getSystemName(subsys);
            end
        end

        function checkForNestedSystems(this)
            g=this.Graph.Graph;
            subsys=this.ConversionParameters.Systems;
            vids=arrayfun(@(ss)this.Graph.VertexMap(ss),subsys);
            N=numel(vids);
            results={};
            for idx=1:N
                ss=subsys(idx);
                vid=this.Graph.VertexMap(ss);

                childVids=intersect(vids,setdiff(g.depthFirstTraverse(vid),vid));


                if~isempty(childVids)
                    results=horzcat(results,arrayfun(@(blkVid)...
                    message('Simulink:modelReferenceAdvisor:NestedSubsystems',...
                    this.beautifySubsystemName(ss),...
                    this.beautifySubsystemName(subsys(vids==blkVid))),...
                    childVids,'UniformOutput',false));%#ok
                end
            end


            if~isempty(results)
                subsysNames=arrayfun(@(ss)this.beautifySubsystemName(ss),subsys,'UniformOutput',false);
                nameString=Simulink.ModelReference.Conversion.Utilities.cellstr2str(subsysNames,'','');
                me=MException(message('Simulink:modelReferenceAdvisor:CannotConvertSubsystem',nameString));
                N=numel(results);
                for idx=1:N
                    me=me.addCause(MException(results{idx}));
                end
                throw(me);
            end
        end

        function addVariable(this,varName)
            this.VariableNames{end+1}=varName;
        end



        function addTopModelFixObj(this,fixObj)
            this.TopModelFixes{end+1}=fixObj;
        end

        function addSystemFixObj(this,fixObj)
            this.SystemFixes{end+1}=fixObj;
        end


        function addDSMReferenceCopyInfo(this,info)
            this.DSMReferenceCopyInfo{end+1}=info;
        end

        function clearDSMReferenceCopyInfo(this)
            this.DSMReferenceCopyInfo={};
        end


        function addNewModelFixObj(this,fixObj)
            this.ReferencedModelFixes{end+1}=fixObj;
        end

        function runTopModelFixes(this)
            fixObjs=this.TopModelFixes;
            this.TopModelFixes={};
            this.runFixes(fixObjs);
        end

        function runSystemFixes(this)
            fixObjs=this.SystemFixes;
            this.SystemFixes={};
            this.runFixes(fixObjs);
        end

        function runNewModelFixes(this)
            fixObjs=this.ReferencedModelFixes;
            this.ReferencedModelFixes={};
            this.runFixes(fixObjs);
        end

        function clearFixQueues(this)
            this.TopModelFixes={};
            this.SystemFixes={};
            this.ReferencedModelFixes={};
        end

        function createScratchModel(this)
            N=numel(this.ConversionParameters.Systems);
            for idx=1:N
                if this.ConversionParameters.RightClickBuild
                    baseName=this.ScratchModelName;
                else
                    baseName='untitled';
                end
                startIndex=0;
                aName=Simulink.ModelReference.Conversion.NameUtils.getValidModelNameForBase(...
                baseName,1000,this.DataAccessor,startIndex);
                this.ScratchModel(end+1)=new_system(aName,'model');



                if this.ConversionParameters.ReplaceSubsystem
                    load_system(this.ScratchModel);
                elseif this.ConversionParameters.RightClickBuild&&~strcmp(get_param(bdroot(this.ConversionParameters.Systems(idx)),'CreateSILPILBlock'),'None')
                    open_system(this.ScratchModel);
                else
                    this.open_system(this.ScratchModel);
                end
            end
        end

        function aHandle=getScratchModel(this,currentSystem)
            aHandle=this.ScratchModel(this.ConversionParameters.Systems==currentSystem);
        end

        function open_system(this,aModel)
            if strcmp(get_param(this.ConversionParameters.Model,'Shown'),'off')
                load_system(aModel);
            else
                open_system(aModel);
            end

        end
    end

    methods(Access=private)
        function runFixes(this,fixObjs)
            N=numel(fixObjs);
            for idx=1:N
                aFix=fixObjs{idx};
                aFix.fix;
                this.Logger.addFixResults(aFix.getActionDescription);
            end
        end
        function dataSourceList=saveAndGetExternalDataSources(this)
            dataSourceList={};
            dataFileName=this.ConversionParameters.DataFileName;
            allVarIds=[];
            for i=1:numel(this.VariableNames)
                varName=this.VariableNames{i};
                varId=this.DataAccessor.identifyByName(varName);
                allVarIds=[allVarIds,varId];%#ok
            end
            [nonPersistentVarIds,persistentWritableVarIds,~]=this.DataAccessor.classifyForPersistency(allVarIds);


            if~isempty(nonPersistentVarIds)
                if isempty(dataFileName)
                    DAStudio.error('SLDD:sldd:FileNameMissing');
                else
                    bwsVariableName={nonPersistentVarIds.Name};
                    strbuf=['save(','''',dataFileName,''', ',...
                    Simulink.ModelReference.Conversion.Utilities.cellstr2str(bwsVariableName,'',''),');'];
                    evalin('base',strbuf);
                    dataSourceList{end+1}=dataFileName;
                end
            end


            if~isempty(persistentWritableVarIds)
                this.DataAccessor.saveDataSourceOfVariables(persistentWritableVarIds);
            end


            [writableList,~]=this.DataAccessor.identifyPersistentStorageGateway(allVarIds);
            dataSourceList=[dataSourceList,writableList];
        end
    end

    methods(Static,Access=private)
        function strbuf=getBoolString(val)
            if(val)
                strbuf='yes';
            else
                strbuf='no';
            end
        end

    end
end


