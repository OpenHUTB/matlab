classdef TemporaryModelForVirtualBusCrossing<handle



    properties
ConversionParameters
        temporaryModelForVirtualBusExpansion_Handle=-1
        useNewTemporaryModel=false
portExpansionTable
    end
    methods(Access=public)
        function this=TemporaryModelForVirtualBusCrossing(conversionParameters)
            this.ConversionParameters=conversionParameters;
        end

        function[outModel,useNewTemporaryModel,portExpansionTable]=generateTemporaryModel(this,currentSubsystem,mdlHdl)
            createBusObjectsForAllBuses=this.ConversionParameters.CreateBusObjectsForAllBuses;
            ExpandVirtualBusPorts=this.ConversionParameters.ExpandVirtualBusPorts;
            ExportedFcn=this.ConversionParameters.ExportedFcn;
            isRightClickBuild=this.ConversionParameters.RightClickBuild;
            outModel=-1;
            isSampleTimeIndependent=Simulink.ModelReference.Conversion.SampleTimeUtils.isSampleTimeIndependent(bdroot(currentSubsystem),ExportedFcn);
            useNewTemporaryModel=false;
            portExpansionTable=containers.Map;
            if~createBusObjectsForAllBuses&&~ExpandVirtualBusPorts&&~ExportedFcn
                [usingWrapper,portExpansionTable]=this.containsPureVirtualBusCross(currentSubsystem);
                if usingWrapper
                    Simulink.ModelReference.Conversion.CopySubsystemToNewModel.copy(currentSubsystem,mdlHdl,createBusObjectsForAllBuses,portExpansionTable,isRightClickBuild,isSampleTimeIndependent);
                    Simulink.BlockDiagram.arrangeSystem(mdlHdl,'FullLayout','True');
                    useNewTemporaryModel=true;
                    this.temporaryModelForVirtualBusExpansion_Handle=mdlHdl;
                    this.useNewTemporaryModel=useNewTemporaryModel;
                    this.portExpansionTable=portExpansionTable;
                    outModel=mdlHdl;
                end
            end
        end
    end

    methods(Access=private)










        function[usingWrapper,expansionTable]=containsPureVirtualBusCross(~,currentSubsystem)
            currentSubsystemPortHandles=get_param(currentSubsystem,'PortHandles');
            inportNum=numel(currentSubsystemPortHandles.Inport);
            currentSubsystemPortHandles=[currentSubsystemPortHandles.Inport,currentSubsystemPortHandles.Outport];
            portCanBeExpanded=zeros(numel(currentSubsystemPortHandles),2);

            portType={'Inport','Outport'};

            for ii=1:numel(currentSubsystemPortHandles)
                portOnSubsystem=currentSubsystemPortHandles(ii);
                isPureVirtualBus=slInternal('isPureVirtualBus',portOnSubsystem);
                containsVarDim=(sum(get_param(portOnSubsystem,'CompiledPortDimensionsMode'))~=0);

                if~isPureVirtualBus||containsVarDim
                    portCanBeExpanded(ii,1)=0;
                else




                    portBlks=find_system(currentSubsystem,'SearchDepth','1','LookUnderMasks','on','FollowLinks','on','BlockType',portType{(ii>inportNum)+1});


                    if numel(portBlks)>1
                        portIdx=num2str(get_param(currentSubsystemPortHandles(ii),'PortNumber'));
                        portBlks=portBlks(strcmp(get_param(portBlks,'Port'),portIdx));
                    else
                        assert(strcmp(get_param(portBlks,'Port'),num2str(get_param(currentSubsystemPortHandles(ii),'PortNumber'))));
                    end




                    if any(startsWith(get_param(portBlks,'OutDataTypeStr'),'Bus:'))
                        portCanBeExpanded(ii,1)=0;
                    else
                        portCanBeExpanded(ii,1)=1;
                        try
                            portBlkObj=get_param(portBlks,'Object');
                            portCanBeExpanded(ii,2)=Simulink.ModelReference.Conversion.PortUtils.portConnectedWithRTB(portBlkObj);
                        catch MME %#ok
                            portCanBeExpanded(ii,2)=0;
                            if exist('sess','var')
                                delete(sess);
                            end
                        end
                    end
                end
            end

            usingWrapper=any(portCanBeExpanded(:,1)==1);
            if isempty(currentSubsystemPortHandles)
                assert(isempty(portCanBeExpanded))
                expansionTable=containers.Map;
            else
                assert(numel(currentSubsystemPortHandles)==numel(portCanBeExpanded(:,1)));
                expansionTable=containers.Map(currentSubsystemPortHandles,num2cell(portCanBeExpanded,2));
            end
        end
    end
end
