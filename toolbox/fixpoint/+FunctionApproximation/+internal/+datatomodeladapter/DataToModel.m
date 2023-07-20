classdef(Abstract)DataToModel<handle







    methods
        function modelInfo=getModelInfo(this,blockData)


            modelInfo=initializeModelInfo(this);


            initializeModel(this,modelInfo);


            setModelConfigurationParameters(this,modelInfo);


            copyOriginalBlock(this,modelInfo,blockData);


            addBoundaries(this,modelInfo,blockData);


            update(modelInfo,blockData);


            clearAutosaveFile(modelInfo);


            dirtyOff(modelInfo);
        end
    end

    methods(Hidden)
        modelInfo=initializeModelInfo(this)
        initializeModel(this,modelInfo)
        copyOriginalBlock(~,modelInfo,blockData)

        function setModelConfigurationParameters(~,modelInfo)
            modelName=modelInfo.ModelName;


            set_param(modelName,'ParameterPrecisionLossMsg','none');
            set_param(modelName,'ParameterOverflowMsg','none')
            set_param(modelName,'IntegerSaturationMsg','none');
            set_param(modelName,'ParameterPrecisionLossMsg','none');
            set_param(modelName,'FixptConstPrecisionLossMsg','none');
            set_param(modelName,'IntegerOverflowMsg','none');



            set_param(modelName,'StopTime','0');




            set_param(modelName,'SolverType','Fixed-Step');
            set_param(modelName,'FixedStep','1');
        end

        function addBoundaries(this,modelInfo,blockData)

            addInputBoundary(this,modelInfo,blockData);
            addOutputBoundary(this,modelInfo,blockData);
        end

        function addInputBoundary(~,modelInfo,blockData)

            assignin(modelInfo.ModelWorkspace,modelInfo.InputValuesVariableName,zeros(1,blockData.NumberOfDimensions));


            modelName=modelInfo.ModelName;
            blockObject=get_param(getBlockPath(modelInfo),'Object');
            blockPosition=blockObject.Position;
            blockHeight=blockPosition(4)-blockPosition(2);



            nDimensions=numel(blockObject.PortHandles.Inport);
            for ii=1:nDimensions
                yCoordinate=-(blockHeight+modelInfo.InputBlockSpacing)*(ii-(nDimensions+1)/2);


                inputPath=getInputPath(modelInfo,ii);
                xCoordinate=modelInfo.InputBlockWidth*3+modelInfo.InputBlockSpacing*2;
                add_block(modelInfo.ConstantBlockLibraryPath,inputPath,...
                'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate,yCoordinate]);
                inputBlockObject=get_param(inputPath,'Object');


                dtcPath=getDataTypeConversionPath(modelInfo,ii);
                xCoordinate=xCoordinate-(modelInfo.InputBlockWidth+modelInfo.InputBlockSpacing);
                add_block(modelInfo.DataTypeConversionBlockPath,dtcPath,...
                'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate,yCoordinate]);
                dtcBlockObject=get_param(dtcPath,'Object');
                dtcBlockObject.RndMeth='Nearest';


                sigSpecPath=getSignalSpecificationPath(modelInfo,ii);
                xCoordinate=xCoordinate-(modelInfo.InputBlockWidth+modelInfo.InputBlockSpacing)+60;
                add_block(modelInfo.SignalSpecificationBlockPath,sigSpecPath,...
                'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate-60,yCoordinate]);
                sigSpecBlockObject=get_param(sigSpecPath,'Object');


                add_line(modelName,...
                inputBlockObject.PortHandles.Outport(1),...
                dtcBlockObject.PortHandles.Inport(1));

                add_line(modelName,...
                dtcBlockObject.PortHandles.Outport(1),...
                sigSpecBlockObject.PortHandles.Inport(1));

                add_line(modelName,...
                sigSpecBlockObject.PortHandles.Outport(1),...
                blockObject.PortHandles.Inport(ii));



                inputBlockObject.Value=[modelInfo.InputValuesVariableName,'(:,',int2str(ii),')'];



                inputBlockObject.OutDataTypeStr='Inherit: Inherit via back propagation';
                dtcBlockObject.OutDataTypeStr='Inherit: Inherit via back propagation';
            end
        end

        function addOutputBoundary(~,modelInfo,~)


            modelName=modelInfo.ModelName;
            blockObject=get_param(getBlockPath(modelInfo),'Object');
            blockPosition=blockObject.Position;
            outportBlockPath=getOutputBlockPath(modelInfo);
            xCoordinate=modelInfo.InputBlockWidth;
            add_block(modelInfo.OutportBlockLibraryPath,outportBlockPath,...
            'Position',blockPosition+[xCoordinate,0,xCoordinate,0])
            outportBlockObject=get_param(outportBlockPath,'Object');
            add_line(modelName,...
            blockObject.PortHandles.Outport(1),...
            outportBlockObject.PortHandles.Inport(1));
        end
    end
end
