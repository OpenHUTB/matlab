classdef CapabilityManager<handle






    properties
        constructCache={};
    end

    methods

        function constructOfInterest=getUnsupportedConstruct(this,aScope)
            constructOfInterest={};
            uniqueBlockNameList={};


            compileModelHandler=fixed.internal.modelcompilehandler.ModelCompileHandler(aScope.TopModel);
            try
                compileModelHandler.start();
            catch FailToCompile
                rethrow(FailToCompile);
            end






            for sysIndex=1:numel(aScope.SelectedSystemsToScale)
                sysBlockName=aScope.SelectedSystemsToScale{sysIndex};
                sysObj=get_param(sysBlockName,'Object');


                if~DataTypeWorkflow.Advisor.Utils.isUnderReadOnlySystem(sysObj)...
                    &&~DataTypeWorkflow.Advisor.Utils.isSystemLinked(sysObj)
                    [activeBlks,~]=SimulinkFixedPoint.AutoscalerUtils.getAllBlockList(sysObj);

                    asExtension=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
                    for j=1:numel(activeBlks)

                        blkObj=activeBlks(j);

                        if~DataTypeWorkflow.Advisor.CapabilityManager.isEntityFixedPointCompatible(blkObj,asExtension)...
                            &&~DataTypeWorkflow.Advisor.Utils.isUnderReadOnlySystem(blkObj)

                            if DataTypeWorkflow.Advisor.Utils.getEntryModifiable(aScope.SelectedSystem,blkObj)
                                objectSelectedToModify=blkObj;
                            else



                                objectSelectedToModify=DataTypeWorkflow.Advisor.Utils.getTopLibraryEntry(blkObj);
                            end

                            blockToModify=objectSelectedToModify.getFullName;
                            if isempty(uniqueBlockNameList)||~any(strcmp(uniqueBlockNameList,blockToModify))

                                info.object=objectSelectedToModify;
                                info.constructName=blockToModify;

                                constructOfInterest{end+1}=info;%#ok<AGROW>
                                uniqueBlockNameList{end+1}=blockToModify;%#ok<AGROW>
                            end
                        end
                    end
                end
            end

            compileModelHandler.stop();

            this.constructCache=constructOfInterest;
        end

        function completeDecouple=decoupleUnsupportedConstruct(this)
            completeDecouple={};
            constructOfInterest=this.constructCache;
            for index=1:numel(constructOfInterest)
                obj=constructOfInterest{index};

                completeDecouple{end+1}=DataTypeWorkflow.Advisor.Utils.decoupleDTCSubsystem(obj.object);%#ok<AGROW>
            end
        end

    end
    methods(Static)

        function isFixedPointCompatible=isEntityFixedPointCompatible(blockObject,extension)



            isTypeAgnosticConstruct=DataTypeWorkflow.Advisor.CapabilityManager.knownBlockTypeAgnostic(blockObject);


            try
                blockCapabilityObject=blockObject.Capabilities;
                isFixedPointSupported=strcmp(blockCapabilityObject.supports('fixedpt',blockCapabilityObject.CurrentMode),'Yes');
                isIntegerSupported=strcmp(blockCapabilityObject.supports('integer',blockCapabilityObject.CurrentMode),'Yes');
            catch meCapability %#ok<NASGU>

                isFixedPointSupported=false;
                isIntegerSupported=false;
            end


            replacerObject=DataTypeWorkflow.Advisor.internal.unsupportedBlockRegisterTable(blockObject);
            [~,isCordicValue]=replacerObject.supportCordic;

            isFixedPointCapable=isFixedPointSupported||isIntegerSupported||isTypeAgnosticConstruct||isCordicValue;


            blkAutoscaler=extension.getAutoscaler(blockObject);
            [hasDTConstraints,curDTConstraintsSet]=blkAutoscaler.gatherDTConstraints(blockObject);

            isFloatingPointOnly=false;

            if hasDTConstraints

                for idx=1:numel(curDTConstraintsSet)
                    isFloatingPointOnly=~curDTConstraintsSet{idx}{2}.allowsFixedPointProposals;
                    if isFloatingPointOnly
                        break;
                    end
                end
            end

            isFixedPointCompatible=~isFloatingPointOnly&&isFixedPointCapable;
        end

        function isTypeAgnosticConstruct=knownBlockTypeAgnostic(blockObject)



            isTypeAgnosticBlocks=isa(blockObject,'Simulink.ForIterator')||...
            isa(blockObject,'Simulink.ForEach')||...
            isa(blockObject,'Simulink.WhileIterator')||...
            isa(blockObject,'Simulink.StateControl')||...
            isa(blockObject,'Simulink.DataflowConfiguration');
            if isa(blockObject,'Simulink.MATLABSystem')
                maskTypeInformation=blockObject.MaskType;
                isSystemBlockConstruct=strcmp(maskTypeInformation,'hdl.RAM')||...
                strcmp(maskTypeInformation,'fixed.system.internal.modbyconstant_hdl')||...
                strcmp(maskTypeInformation,'fixed.system.DivideByConstantAndRound')||...
                strcmp(maskTypeInformation,'fixed.system.ModByConstant')||...
                strcmp(maskTypeInformation,'fixed.system.RoundToMultiple')||...
                strcmp(maskTypeInformation,'FFT HDL Optimized')||...
                strcmp(maskTypeInformation,'FFT');
            else
                isSystemBlockConstruct=false;
            end
            isTypeAgnosticConstruct=isTypeAgnosticBlocks||isSystemBlockConstruct;
        end
    end
end


