classdef DirectLUDataToModel<FunctionApproximation.internal.datatomodeladapter.BlockDataToModel





    methods(Hidden)
        function modelInfo=initializeModelInfo(~)

            modelInfo=FunctionApproximation.internal.datatomodeladapter.DirectLUModelInfo();
        end

        function copyOriginalBlock(~,modelInfo,blockData)

            directLUBlockPath=getBlockPath(modelInfo);
            add_block(modelInfo.DirectLUBlockLibraryPath,directLUBlockPath);
            set_param(directLUBlockPath,'NumberOfTableDimensions',int2str(blockData.NumberOfDimensions));
            set_param(directLUBlockPath,'LockScale','on');
            set_param(directLUBlockPath,'Table',modelInfo.ParameterObjectName);
            set_param(directLUBlockPath,'InputsSelectThisObjectFromTable','Element');
            set_param(directLUBlockPath,'DiagnosticForOutOfRangeInput','Error');
            set_param(directLUBlockPath,'TableDataTypeStr','Inherit: Inherit from ''Table data''');
            set_param(modelInfo.ModelName,'AlgebraicLoopMsg','error');
            set_param(modelInfo.ModelName,'DefaultParameterBehavior','Inlined');
            set_param(modelInfo.ModelName,'BlockReduction','off');
            set_param(modelInfo.ModelName,'ConditionallyExecuteInputs','off');
            set_param(modelInfo.ModelName,'ProdHWDeviceType','ASIC/FPGA');
        end

        function addInputBoundary(~,modelInfo,blockData)

            assignin(modelInfo.ModelWorkspace,modelInfo.InputValuesVariableName,zeros(1,blockData.NumberOfDimensions));


            modelName=modelInfo.ModelName;
            blockObject=get_param(getBlockPath(modelInfo),'Object');
            blockPosition=blockObject.Position;
            blockHeight=blockPosition(4)-blockPosition(2);
            blockWidth=blockPosition(3)-blockPosition(1);



            nDimensions=numel(blockObject.PortHandles.Inport);
            for ii=1:nDimensions
                yCoordinate=-(blockHeight+4*modelInfo.InputBlockSpacing)*(ii-(nDimensions+1)/2);


                inputPath=getInputPath(modelInfo,ii);
                xCoordinateCorrection=2*any(blockData.NeedsLowerBoundCorrection)...
                +any(blockData.NeedsTypeCorrectionForInput)...
                +any(blockData.NeedsInputTypeConversion)...
                +modelInfo.ProtectInputWithDTC;
                xCoordinate=modelInfo.InputBlockWidth*(3+xCoordinateCorrection)...
                +modelInfo.InputBlockSpacing*(1+xCoordinateCorrection);
                add_block(modelInfo.ConstantBlockLibraryPath,inputPath,...
                'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate,yCoordinate]);
                inputBlockObject=get_param(inputPath,'Object');
                inputBlockObject.SampleTime='-1';

                if modelInfo.ProtectInputWithDTC

                    dtcPath=[getDataTypeConversionPath(modelInfo,ii),'_TypeMismatchProtect'];
                    xCoordinate=xCoordinate-(modelInfo.InputBlockWidth+modelInfo.InputBlockSpacing);
                    add_block(modelInfo.DataTypeConversionBlockPath,dtcPath,...
                    'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate,yCoordinate]);
                    dtcInputProtectionBlockObject=get_param(dtcPath,'Object');
                    dtcInputProtectionBlockObject.RndMeth='Nearest';
                end


                sigSpecPath=getSignalSpecificationPath(modelInfo,ii);
                xCoordinate=xCoordinate-(modelInfo.InputBlockWidth+modelInfo.InputBlockSpacing)+60;
                add_block(modelInfo.SignalSpecificationBlockPath,sigSpecPath,...
                'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate-60,yCoordinate]);
                sigSpecBlockObject=get_param(sigSpecPath,'Object');

                if blockData.NeedsInputTypeConversion(ii)

                    intermediateInputDTCPath=getDTCInputIntermediateTypePath(modelInfo,ii);
                    xCoordinate=xCoordinate-(modelInfo.InputBlockWidth+modelInfo.InputBlockSpacing)+40;
                    add_block(modelInfo.DataTypeConversionBlockPath,intermediateInputDTCPath,...
                    'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate-40,yCoordinate]);
                    intermediateInputDTCBlockObject=get_param(intermediateInputDTCPath,'Object');
                end

                if blockData.NeedsLowerBoundCorrection(ii)

                    lbCorrectionBlockPath=getLowerBoundCorrectionBlockPath(modelInfo,ii);
                    xCoordinate=xCoordinate-(modelInfo.InputBlockWidth+modelInfo.InputBlockSpacing);
                    add_block(modelInfo.ConstantBlockLibraryPath,lbCorrectionBlockPath,...
                    'Position',blockPosition-[xCoordinate+blockWidth*4/5,yCoordinate-blockHeight*2/3,xCoordinate+blockWidth*7/5,yCoordinate-blockHeight*1/3]);
                    lbCorrectionBlockObject=get_param(lbCorrectionBlockPath,'Object');
                    lbCorrectionBlockObject.SampleTime='-1';


                    subtractBlockPath=getSubtractBlockPath(modelInfo,ii);

                    add_block(modelInfo.SubtractLibraryPath,subtractBlockPath,...
                    'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate,yCoordinate]);
                    subtractBlockObject=get_param(subtractBlockPath,'Object');
                end


                dtcPath=getDataTypeConversionPath(modelInfo,ii);
                xCoordinate=xCoordinate-(modelInfo.InputBlockWidth+modelInfo.InputBlockSpacing);
                add_block(modelInfo.DataTypeConversionBlockPath,dtcPath,...
                'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate,yCoordinate]);
                dtcBlockObject=get_param(dtcPath,'Object');
                dtcBlockObject.RndMeth='Nearest';

                if blockData.NeedsTypeCorrectionForInput(ii)

                    dtcPathSI=getDataTypeConversionSIPath(modelInfo,ii);
                    xCoordinate=xCoordinate-(modelInfo.InputBlockWidth+modelInfo.InputBlockSpacing);
                    add_block(modelInfo.DataTypeConversionBlockPath,dtcPathSI,...
                    'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate,yCoordinate]);
                    dtcSIBlockObject=get_param(dtcPathSI,'Object');
                    dtcSIBlockObject.RndMeth='Nearest';
                end

                if any(blockData.NeedsLowerBoundCorrection)

                    delayInPath=getInputDelayPath(modelInfo,ii);
                    xCoordinate=xCoordinate-(modelInfo.InputBlockWidth+modelInfo.InputBlockSpacing);
                    add_block(modelInfo.DelayLibraryPath,delayInPath,...
                    'Position',blockPosition-[xCoordinate,yCoordinate,xCoordinate,yCoordinate]);
                    delayInObject=get_param(delayInPath,'Object');
                    delayInObject.SampleTime='-1';
                    delayInObject.DelayLength='0';
                    delayInObject.ShowEnablePort='off';
                    delayInObject.ExternalReset='None';
                end

                previousObject=inputBlockObject;

                if modelInfo.ProtectInputWithDTC

                    add_line(modelName,...
                    previousObject.PortHandles.Outport(1),...
                    dtcInputProtectionBlockObject.PortHandles.Inport(1));

                    previousObject=dtcInputProtectionBlockObject;
                end


                add_line(modelName,...
                previousObject.PortHandles.Outport(1),...
                sigSpecBlockObject.PortHandles.Inport(1));
                previousObject=sigSpecBlockObject;

                if blockData.NeedsInputTypeConversion(ii)

                    add_line(modelName,...
                    previousObject.PortHandles.Outport(1),...
                    intermediateInputDTCBlockObject.PortHandles.Inport(1));
                    previousObject=intermediateInputDTCBlockObject;
                end

                if blockData.NeedsLowerBoundCorrection(ii)


                    add_line(modelName,...
                    previousObject.PortHandles.Outport(1),...
                    subtractBlockObject.PortHandles.Inport(1));

                    add_line(modelName,...
                    lbCorrectionBlockObject.PortHandles.Outport(1),...
                    subtractBlockObject.PortHandles.Inport(2));

                    previousObject=subtractBlockObject;
                end

                add_line(modelName,...
                previousObject.PortHandles.Outport(1),...
                dtcBlockObject.PortHandles.Inport(1));
                previousObject=dtcBlockObject;

                if blockData.NeedsTypeCorrectionForInput(ii)
                    add_line(modelName,...
                    previousObject.PortHandles.Outport(1),...
                    dtcSIBlockObject.PortHandles.Inport(1));
                    previousObject=dtcSIBlockObject;
                end

                if any(blockData.NeedsLowerBoundCorrection)
                    add_line(modelName,...
                    previousObject.PortHandles.Outport(1),...
                    delayInObject.PortHandles.Inport(1));
                    previousObject=delayInObject;
                end

                add_line(modelName,...
                previousObject.PortHandles.Outport(1),...
                blockObject.PortHandles.Inport(ii));



                inputBlockObject.Value=[modelInfo.InputValuesVariableName,'(:,',int2str(ii),')'];



                inputBlockObject.OutDataTypeStr='Inherit: Inherit via back propagation';
                if blockData.NeedsInputTypeConversion(ii)
                    str=FunctionApproximation.internal.getDTOOffString(blockData.IntermediateTypes(ii));
                    intermediateInputDTCBlockObject.OutDataTypeStr=str;
                end
                dt=fixdt(0,blockData.InputTypes(ii).WordLength,0,'DataTypeOverride','off');
                dtcBlockObject.OutDataTypeStr=tostring(dt);
                dtcBlockObject.ConvertRealWorld='Stored Integer (SI)';
                if blockData.NeedsTypeCorrectionForInput(ii)
                    wl=blockData.InputWLCorrection(ii);
                    dt=fixdt(0,wl,0,'DataTypeOverride','off');
                    dtcSIBlockObject.OutDataTypeStr=tostring(dt);
                    dtcSIBlockObject.ConvertRealWorld='Real World Value (RWV)';
                end
                if blockData.NeedsLowerBoundCorrection(ii)
                    str=FunctionApproximation.internal.getDTOOffString(blockData.IntermediateTypes(ii));
                    subtractBlockObject.OutDataTypeStr=str;
                    subtractBlockObject.RndMeth='Ceiling';
                    str=FunctionApproximation.internal.getDTOOffString(blockData.InputTypes(ii));
                    lbCorrectionBlockObject.OutDataTypeStr=str;
                    lbCorrectionBlockObject.Value=[modelInfo.LowerBoundVarName,'(',int2str(ii),')'];
                end
            end
        end

        function addOutputBoundary(~,modelInfo,blockData)


            modelName=modelInfo.ModelName;
            blockObject=get_param(getBlockPath(modelInfo),'Object');
            blockPosition=blockObject.Position;
            xCoordinate=modelInfo.InputBlockWidth;


            delayOutPath=getOutputDelayPath(modelInfo);
            add_block(modelInfo.DelayLibraryPath,delayOutPath,...
            'Position',blockPosition+[xCoordinate,0,xCoordinate,0]);
            delayOutObject=get_param(delayOutPath,'Object');
            delayOutObject.SampleTime='-1';
            delayOutObject.DelayLength='0';
            delayOutObject.ShowEnablePort='off';
            delayOutObject.ExternalReset='None';
            blockPosition=delayOutObject.Position;

            if blockData.NeedsOutputTypeConversion

                intermediateInputDTCPath=getDTCOutputIntermediateTypePath(modelInfo);
                add_block(modelInfo.DataTypeConversionBlockPath,intermediateInputDTCPath,...
                'Position',blockPosition+[xCoordinate,0,xCoordinate,0]);
                outputCastDTCObject=get_param(intermediateInputDTCPath,'Object');
                blockPosition=outputCastDTCObject.Position;
            end

            outportBlockPath=getOutputBlockPath(modelInfo);
            add_block(modelInfo.OutportBlockLibraryPath,outportBlockPath,...
            'Position',blockPosition+[xCoordinate,0,xCoordinate,0])
            outportBlockObject=get_param(outportBlockPath,'Object');

            previousObject=blockObject;
            add_line(modelName,...
            previousObject.PortHandles.Outport(1),...
            delayOutObject.PortHandles.Inport(1));
            previousObject=delayOutObject;

            if blockData.NeedsOutputTypeConversion
                add_line(modelName,...
                previousObject.PortHandles.Outport(1),...
                outputCastDTCObject.PortHandles.Inport(1));
                previousObject=outputCastDTCObject;
            end

            add_line(modelName,...
            previousObject.PortHandles.Outport(1),...
            outportBlockObject.PortHandles.Inport(1));

            if blockData.NeedsOutputTypeConversion
                outputCastDTCObject.OutDataTypeStr=blockData.OutputType.tostring();

            end
        end
    end
end
