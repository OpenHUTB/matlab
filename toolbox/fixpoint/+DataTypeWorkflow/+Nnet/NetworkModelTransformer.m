classdef NetworkModelTransformer<handle






    properties
Report
    end

    properties(Access=private)
SimulinkData
NetworkData
ModelToPrep
ModelWorkspace
    end

    properties(Constant)
        PreparationErrID='NetworkModelTransformer:PreparationIncomplete'
        PreparationErrMsg=['Model preparation failed before completion. '...
        ,'Find details of the partial preparation changes in the Report property']
    end

    methods
        function this=NetworkModelTransformer(simulinkData,networkData)
            this.SimulinkData=simulinkData;
            this.NetworkData=networkData;
            this.ModelToPrep=simulinkData.SystemUnderDesign;
            this.ModelWorkspace=get_param(this.ModelToPrep,'ModelWorkspace');
            this.initReport();
        end

        function prepareModelForConversion(this)













            this.disableLibraryLinks();










            try
                this.isolateUnsupportedConstructs();
            catch err
                this.Report.Errors=this.Report.Errors.addCause(err);
            end












            if~isempty(this.Report.LibraryLinks)
                try
                    this.updateNetworkBlockInterface();
                catch err
                    this.Report.Errors=this.Report.Errors.addCause(err);
                end
            end





            try
                this.updateWeightBlocks();
            catch err
                this.Report.Errors=this.Report.Errors.addCause(err);
            end


            this.enforceLooseCoupling();


            if isempty(this.Report.Errors.cause)

                this.Report.ready=true;
                this.Report.Errors=[];
            else
                this.Report.Errors.throwAsCaller();
            end
        end
    end

    methods(Access=private)
        function disableLibraryLinks(this)
            libdata=this.SimulinkData.LibraryInfo;

            for i=1:length(libdata)
                if~strcmp(get_param(libdata(i).Block,'LinkStatus'),'inactive')
                    set_param(libdata(i).Block,'LinkStatus','inactive');
                    disabledLink=struct('Block',libdata(i).Block,'ReferenceBlock',libdata(i).ReferenceBlock);


                    this.Report.LibraryLinks{end+1}=disabledLink;
                end
            end
        end

        function isolateUnsupportedConstructs(this)

            report=DataTypeWorkflow.Advisor.runChecks(this.ModelToPrep,...
            this.SimulinkData.EnumWorkflow,this.SimulinkData.TopModel);


            for idx=1:length(report.UnsupportedConstruct)
                this.Report.UnsupportedConstructs{end+1}=report.UnsupportedConstruct{idx}.BeforeValue;
            end


        end

        function updateNetworkBlockInterface(this)
            xarr=this.NetworkData.TrainingInput;
            yarr=this.NetworkData.TrainingTarget;
            T=length(xarr.Time);

            interfaceConst=getNetworkInterfaceConstants();

            this.ModelWorkspace.assignin(interfaceConst.InputVarName,xarr);
            this.ModelWorkspace.assignin(interfaceConst.TargetVarName,yarr);
            set_param(this.ModelToPrep,'StopTime',num2str(T));



            xarrBlk=this.addBlock(interfaceConst.FromWorkspaceLibPath,[this.ModelToPrep,'/',interfaceConst.InputVarName],...
            'VariableName',interfaceConst.InputVarName);
            yarrBlk=this.addBlock(interfaceConst.FromWorkspaceLibPath,[this.ModelToPrep,'/',interfaceConst.TargetVarName],...
            'VariableName',interfaceConst.TargetVarName);
            dtc_fromBlk=this.addBlock(interfaceConst.DTCLibPath,[this.ModelToPrep,'/',interfaceConst.DTCFromBlockName]);
            dtc_toBlk=this.addBlock(interfaceConst.DTCLibPath,[this.ModelToPrep,'/',interfaceConst.DTCToBlockName]);
            diffBlk=this.addBlock(interfaceConst.DiffLibPath,[this.ModelToPrep,'/',interfaceConst.DiffBlockName]);


            opts=Simulink.FindOptions('SearchDepth',1);
            inputBlk=getfullname(Simulink.findBlocksOfType(this.ModelToPrep,'Constant',opts));
            sinkBlk=getfullname(Simulink.findBlocksOfType(this.ModelToPrep,'Scope',opts));
            inputPH=getPortHandles(inputBlk);
            sinkPH=getPortHandles(sinkBlk);
            netPH=getPortHandles(this.SimulinkData.NetworkBlock);
            xarrPH=getPortHandles(xarrBlk);
            yarrPH=getPortHandles(yarrBlk);
            dtcFromPH=getPortHandles(dtc_fromBlk);
            dtcToPH=getPortHandles(dtc_toBlk);
            diffPH=getPortHandles(diffBlk);


            this.deleteLine(this.ModelToPrep,inputPH.Outport(1),netPH.Inport(1));
            this.deleteLine(this.ModelToPrep,netPH.Outport(1),sinkPH.Inport(1));


            this.addAutoroutingLine(this.ModelToPrep,xarrPH.Outport(1),dtcFromPH.Inport(1));
            this.addAutoroutingLine(this.ModelToPrep,dtcFromPH.Outport(1),netPH.Inport(1));
            this.addAutoroutingLine(this.ModelToPrep,netPH.Outport(1),dtcToPH.Inport(1));
            this.addAutoroutingLine(this.ModelToPrep,dtcToPH.Outport(1),diffPH.Inport(1));
            this.addAutoroutingLine(this.ModelToPrep,yarrPH.Outport(1),diffPH.Inport(2));
            this.addAutoroutingLine(this.ModelToPrep,diffPH.Outport(1),sinkPH.Inport(1));


            this.deleteBlock(inputBlk);


            enableDataLogging(netPH.Outport(1));
            enableDataLogging(diffPH.Outport(1));
            enableDataLogging(yarrPH.Outport(1));

            tryArrangeSystem(this.ModelToPrep);
        end

        function updateWeightBlocks(this)
            numLayers=this.NetworkData.NumLayers;
            for layerNum=1:numLayers

                weights=this.NetworkData.getWeightInformation(layerNum);
                this.ModelWorkspace.assignin(weights.VarName,weights.Value);


                tempWtBlockHandler=DataTypeWorkflow.Nnet.TempWeightBlockHandler(weights.Value,layerNum);
                replacementBlockPath=tempWtBlockHandler.ReplacementSubsystemPath;
                originalBlockPath=this.getOriginalWeightBlockPath(layerNum,weights.BlockName);

                if~isempty(replacementBlockPath)

                    FunctionApproximation.internal.Utils.replaceBlockWithBlock(originalBlockPath,replacementBlockPath);


                    this.Report.WeightBlocks{end+1}=originalBlockPath;
                    tryArrangeSystem(originalBlockPath);
                else
                    error(message('FixedPointTool:fixedPointTool:WeightBlockUpdateFailed',originalBlockPath));
                end
            end
        end

        function enforceLooseCoupling(this)



            netObj=get_param(this.SimulinkData.NetworkBlock,'Object');
            allBlocks=SimulinkFixedPoint.AutoscalerUtils.getAllBlockList(netObj);
            hasPropertyActive=false(numel(allBlocks),1);
            for bIndex=1:numel(allBlocks)
                if isprop(allBlocks(bIndex),'InputSameDT')
                    hasPropertyActive(bIndex)=strcmp(allBlocks(bIndex).InputSameDT,'on');
                end
            end
            allBlocks(~hasPropertyActive)='';

            set(allBlocks,'InputSameDT','off');
        end

        function blockhandle=addBlock(this,source,destination,varargin)
            blockhandle=add_block(source,destination,varargin{:});

            this.Report.NetSubsystemInterface.BlocksAdded{end+1}=destination;
        end

        function deleteLine(this,system,oport,iport)
            delete_line(system,oport,iport);
            line.FromPort=oport;
            line.ToPort=iport;

            this.Report.NetSubsystemInterface.LinesDeleted{end+1}=line;
        end

        function addAutoroutingLine(this,system,oport,iport)
            add_line(system,oport,iport,'autorouting','on');
            line.FromPort=oport;
            line.ToPort=iport;

            this.Report.NetSubsystemInterface.LinesAdded{end+1}=line;
        end

        function deleteBlock(this,block)
            delete_block(block);

            this.Report.NetSubsystemInterface.BlocksDeleted{end+1}=block;
        end

        function originalPath=getOriginalWeightBlockPath(this,layerNum,weightBlockName)
            originalPath=[this.NetworkData.getLayerBlockPath(this.SimulinkData.NetworkBlock,layerNum)...
            ,'/',weightBlockName];
        end


        function initReport(this)








            interfaceChanges=struct('BlocksAdded',[],'LinesDeleted',[],...
            'LinesAdded',[],'BlocksDeleted',[]);
            preparationError=MException(DataTypeWorkflow.Nnet.NetworkModelTransformer.PreparationErrID,...
            DataTypeWorkflow.Nnet.NetworkModelTransformer.PreparationErrMsg);
            report=struct('LibraryLinks',[],'UnsupportedConstructs',[],...
            'WeightBlocks',[],'NetSubsystemInterface',interfaceChanges,...
            'Errors',preparationError,'ready',false);
            this.Report=report;
        end
    end
end


function portHandles=getPortHandles(block)
    portHandles=get_param(block,'PortHandles');
end

function enableDataLogging(port)
    set_param(port,'DataLogging','on');
end

function tryArrangeSystem(system)
    try

        Simulink.BlockDiagram.arrangeSystem(system);
    catch

    end
end

function interfaceConst=getNetworkInterfaceConstants()
    interfaceConst.FromWorkspaceLibPath=DataTypeWorkflow.Nnet.NetworkModelConstants.FromWorkspaceBlockLibraryPath;
    interfaceConst.DTCLibPath=DataTypeWorkflow.Nnet.NetworkModelConstants.DTCBlockLibraryPath;
    interfaceConst.DiffLibPath=DataTypeWorkflow.Nnet.NetworkModelConstants.DiffBlockLibraryPath;
    interfaceConst.InputVarName=DataTypeWorkflow.Nnet.NetworkModelConstants.TrainingInputVarName;
    interfaceConst.TargetVarName=DataTypeWorkflow.Nnet.NetworkModelConstants.TrainingTargetVarName;
    interfaceConst.DTCFromBlockName=DataTypeWorkflow.Nnet.NetworkModelConstants.DTCFromBlockName;
    interfaceConst.DTCToBlockName=DataTypeWorkflow.Nnet.NetworkModelConstants.DTCToBlockName;
    interfaceConst.DiffBlockName=DataTypeWorkflow.Nnet.NetworkModelConstants.DiffBlockName;
end


