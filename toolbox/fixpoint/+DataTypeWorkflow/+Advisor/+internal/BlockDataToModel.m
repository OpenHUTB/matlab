classdef BlockDataToModel<handle






    methods(Hidden)
        function modelInfo=initializeModelInfo(~)

            modelInfo=DataTypeWorkflow.Advisor.internal.ModelInfo();
        end

        function initializeModel(~,modelInfo)

            [~,postFixModelName]=fileparts(tempname);
            modelInfo.ModelName=[modelInfo.ModelNamePrefix,datestr(now,'yyyymmddTHHMMSSFFF'),'_',postFixModelName(1:14)];



            modelHandle=new_system(modelInfo.ModelName);
            modelObject=get_param(modelHandle,'Object');
            modelInfo.ModelObject=modelObject;
        end

        function copyOriginalBlock(~,modelInfo,blockData)

            add_block(blockData.FullName,getBlockPath(modelInfo));
        end
    end

    methods
        function modelInfo=getModelInfo(this,blockData)


            modelInfo=initializeModelInfo(this);


            initializeModel(this,modelInfo);


            copyOriginalBlock(this,modelInfo,blockData);


            addBoundaries(this,modelInfo,blockData);


            createSubsystem(this,modelInfo);


            clearAutosaveFile(modelInfo);


            dirtyOff(modelInfo);
        end
    end

    methods(Hidden)

        function addBoundaries(this,modelInfo,blockData)




            if~isempty(blockData.InputTypes)
                addInputBoundary(this,modelInfo,blockData);
            end
            if~isempty(blockData.OutputType)
                addOutputBoundary(this,modelInfo,blockData);
            end
        end

        function createSubsystem(~,modelInfo)
            internalBlocks=getBlockHandlesForInternalBlocks(modelInfo);
            Simulink.BlockDiagram.createSubsystem(internalBlocks);
            subsysHandle=get_param(get_param(internalBlocks(1),'Parent'),'Handle');
            set_param(subsysHandle,'Name',getSubsystemName(modelInfo));
            set_param(subsysHandle,'Tag',DataTypeWorkflow.Advisor.internal.ReplacementSetUp.TagUsed);
            set_param(subsysHandle,'BackgroundColor',DataTypeWorkflow.Advisor.internal.ReplacementSetUp.ColorBackground);


            [inportHandleList,outportHandleList]=DataTypeWorkflow.Advisor.internal.getRootModelPorts(subsysHandle);
            for idxIn=1:numel(inportHandleList)
                set_param(inportHandleList(idxIn),'LockScale','On');
            end
            for idxOut=1:numel(outportHandleList)
                set_param(outportHandleList(idxOut),'LockScale','On');
            end

        end

        function addInputBoundary(~,modelInfo,blockData)


            modelName=modelInfo.ModelName;
            blockObject=get_param(getBlockPath(modelInfo),'Object');

            if~isempty(blockObject.PortHandles.Inport)
                blockPosition=blockObject.Position;
                blockHeight=blockPosition(4)-blockPosition(2);


                nDimensions=numel(blockObject.PortHandles.Inport);
                nTypeResolved=numel(blockData.InputTypes);

                for ii=1:nTypeResolved

                    if mod(nDimensions,2)

                        yCoordinate=-(blockHeight+modelInfo.InputBlockSpacing)*(ii-(nDimensions+1)/2);
                    else

                        yCoordinate=-(blockHeight+modelInfo.InputBlockSpacing)*(ii-(nDimensions)/2);
                    end


                    dtcPath=getInputDataTypeConversionPath(modelInfo,ii);
                    xCoordinate=modelInfo.InputBlockWidth*3+modelInfo.InputBlockSpacing*2;
                    add_block(modelInfo.DataTypeConversionBlockPath,dtcPath,...
                    'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate,yCoordinate]);
                    dtcBlockObject=get_param(dtcPath,'Object');
                    dtcBlockObject.RndMeth=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.DataTypeConversionRoundingMethod;



                    add_line(modelName,...
                    dtcBlockObject.PortHandles.Outport(1),...
                    blockObject.PortHandles.Inport(ii));


                    originalType=blockData.InputTypes(ii);
                    dtcBlockObject.OutDataTypeStr=originalType.tostring;
                    dtcBlockObject.LockScale='On';

                end
            end
        end

        function addOutputBoundary(~,modelInfo,blockData)


            modelName=modelInfo.ModelName;
            blockObject=get_param(getBlockPath(modelInfo),'Object');


            if~isempty(blockObject.PortHandles.Outport)
                blockPosition=blockObject.Position;
                blockHeight=blockPosition(4)-blockPosition(2);


                nDimensions=numel(blockObject.PortHandles.Outport);
                nTypeResolved=numel(blockData.OutputType);

                for dIndex=1:nTypeResolved

                    dtcPath=getOutputDataTypeConversionPath(modelInfo,dIndex);
                    xCoordinate=100+modelInfo.InputBlockSpacing;
                    yCoordinate=(blockHeight+modelInfo.InputBlockSpacing)*(dIndex-(nDimensions)/2);
                    add_block(modelInfo.DataTypeConversionBlockPath,dtcPath,...
                    'Position',blockPosition+[xCoordinate,yCoordinate,xCoordinate,yCoordinate])
                    dtcBlockObject=get_param(dtcPath,'Object');
                    add_line(modelName,...
                    blockObject.PortHandles.Outport(dIndex),...
                    dtcBlockObject.PortHandles.Inport(1));


                    if isempty(blockData.OutputType)
                        dtcBlockObject.OutDataTypeStr=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.DataTypeConversionOutInheritance;
                    else
                        originalType=blockData.OutputType(dIndex);
                        dtcBlockObject.OutDataTypeStr=originalType.tostring;
                    end
                end
            end

        end
    end
end

