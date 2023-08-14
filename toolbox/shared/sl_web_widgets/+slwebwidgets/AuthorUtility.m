classdef AuthorUtility







    methods(Static)


        function dataTypeProposal=proposeDataType(inData,dataTypeObj)










            if~isnumeric(inData)
                DAStudio.error('sl_web_widgets:authorinsert:nonNumericData');
            end

            if~isa(dataTypeObj,'Simulink.NumericType')&&...
                ~isa(dataTypeObj,'embedded.numerictype')
                DAStudio.error('sl_web_widgets:authorinsert:nonNumericType');
            end

            dataTypeProposal=[];

            fiDataTypeSelector=fixed.DataTypeSelector;

            try
                suspectDataType=fiDataTypeSelector.propose(inData,dataTypeObj);

            catch ME

                throwAsCaller(ME);
            end

            if isa(dataTypeObj,'embedded.numerictype')
                suspectDataType=numerictype(suspectDataType);
            end

            if~isequal(suspectDataType,dataTypeObj)
                dataTypeProposal=suspectDataType.tostring;
            end

        end


        function[dataTypeProposal,binaryScalingProposal,slopeNBiasScalingProposal]=proposeDataTypeAllScaling(inData,dataTypeObj)



















            binaryScalingProposal=[];%#ok<NASGU>
            slopeNBiasScalingProposal=[];%#ok<NASGU>

            try


                dataTypeProposal=slwebwidgets.AuthorUtility.proposeDataType(inData,dataTypeObj);
            catch ME
                throwAsCaller(ME);
            end

            if isempty(dataTypeProposal)


                theTypeProposal=dataTypeObj;
                assignedProposed=theTypeProposal.tostring;
            else

                theTypeProposal=eval(dataTypeProposal);
                assignedProposed=dataTypeProposal;
            end


            if theTypeProposal.isscalingbinarypoint


                binaryScalingProposal=assignedProposed;

                xDoubleData=double(inData);



                slopeNBiasScalingProposal=slwebwidgets.AuthorUtility.proposeDataType(xDoubleData,fixdt(theTypeProposal.IsSigned,theTypeProposal.WordLength,1,1));

            else


                slopeNBiasScalingProposal=assignedProposed;

                xDoubleData=double(inData);




                binaryScalingProposal=slwebwidgets.AuthorUtility.proposeDataType(xDoubleData,fixdt(theTypeProposal.IsSigned,theTypeProposal.WordLength));

            end
        end


        function timeValOut=formatTimeValues(timeValIn)


            [M,N]=size(timeValIn);


            if(M==1&&N>=1)

                timeValOut=timeValIn';
            else
                timeValOut=timeValIn;
            end
        end


        function dataVals=formatDataValues(dataVals)

            VAR_SIZE=size(dataVals);



            IS_1x1xM=VAR_SIZE(end)>1&&all(VAR_SIZE(1:end-1)==1);

            if isrow(dataVals)
                if isreal(dataVals)||isstring(dataVals)||isenum(dataVals)
                    dataVals=dataVals';
                else
                    dataVals=dataVals.';
                end
            elseif IS_1x1xM
                dataVals=squeeze(dataVals);
            end
        end


        function errorData=qualifyDataValue(dataVal)
            MAX_SL_STR_LENGTH=32766;

            errorData=[];

            if~isnumeric(dataVal)&&~isenum(dataVal)&&~isSLString(dataVal)&&~islogical(dataVal)||isempty(dataVal)

                errorData=DAStudio.message('sl_web_widgets:authorinsert:qualifyDataNonSimulinkSupport');
            end

            if isSLString(dataVal)
                resShapeSLString=reshape(dataVal,numel(dataVal),1);
                if any(resShapeSLString.strlength>MAX_SL_STR_LENGTH)
                    errorData=DAStudio.message('sl_sta_general:common:slStringLimtation');
                end
            end
        end


        function errorTime=qualifyTimeValue(timeVal)

            errorTime=[];

            if isempty(timeVal)
                errorTime=DAStudio.message('sl_web_widgets:authorinsert:qualifyTimeNonDoubleScalar');
                return;
            end

            IS_TIME_VECTOR=isvector(timeVal);

            if~IS_TIME_VECTOR
                errorTime=DAStudio.message('sl_web_widgets:authorinsert:qualifyTimeNonDoubleScalar');
                return;
            end


            if~isa(timeVal,'double')||any(isinf(timeVal))
                errorTime=DAStudio.message('sl_web_widgets:authorinsert:qualifyTimeNonDoubleScalar');
                return;
            end

            timeVal=slwebwidgets.AuthorUtility.formatTimeValues(timeVal);
            [~,~]=size(timeVal);

            if~isempty(find(diff(timeVal)<0))%#ok<EFIND>
                errorTime=DAStudio.message('sl_web_widgets:authorinsert:qualifyTimeNonIncreasing');
                return;
            end
        end


        function errorTime=qualifyTimeTableTimeValue(timeVal)

            errorTime=[];

            if isempty(timeVal)
                errorTime=DAStudio.message('sl_web_widgets:authorinsert:timeTableTimeError');
                return;
            end


            if~isa(timeVal,'duration')||any(isinf(timeVal))
                errorTime=DAStudio.message('sl_web_widgets:authorinsert:timeTableTimeError');
                return;
            end

            IS_TIME_VECTOR=isvector(timeVal);

            if~IS_TIME_VECTOR
                errorTime=DAStudio.message('sl_web_widgets:authorinsert:timeTableTimeError');
                return;
            end
        end


        function[signalProperties,errMsgStruct]=qualifyAuthoredTimeseries(dataVal,timeVal,errMsgStruct)

            signalProperties.numSamples=[];
            signalProperties.dataType=[];
            signalProperties.dimensions='';
            signalProperties.signalType='';
            signalProperties.proposedDataType='';
            signalProperties.IS_1D=true;
            signalProperties.IS_SCALAR=true;

            if isempty(errMsgStruct.errorTime)&&isempty(errMsgStruct.errorData)
                try

                    signalProperties.numSamples=num2str(length(timeVal));
                    signalProperties.dataType=slwebwidgets.AuthorUtility.qualifyDataType(dataVal);

                    if isstring(dataVal)&&length(dataVal)==1
                        varIn=timeseries();
                        varIn.Time=timeVal;
                        varIn.Data=dataVal;
                    else
                        varIn=timeseries(dataVal,timeVal);

                    end

                    IS_SUPPORTED=isSimulinkSignalFormat(varIn);

                    if~IS_SUPPORTED

                        if isfi(varIn.Data)&&~isSimulinkFi(varIn.Data)
                            errMsgStruct.errorData=DAStudio.message('sl_web_widgets:authorinsert:slFiWordLengthViolation');
                            return;
                        end

                    end


                    [signalProperties.comparedim,signalProperties.dimensions]=...
                    slwebwidgets.AuthorUtility.getDimensionsAndCompareDims(varIn);

                    varSize=size(varIn.Data);
                    signalProperties.IS_1D=isvector(varIn.Data)&&...
                    varSize(2)==1&&...
                    varSize(1)==str2num(signalProperties.numSamples);%#ok<ST2NM>

                    signalProperties.IS_SCALAR=isscalar(varIn.Data);




                    if isreal(dataVal)||isa(dataVal,'string')
                        signalProperties.signalType=getString(message('sl_sta_general:common:Real'));
                    else
                        signalProperties.signalType=getString(message('sl_sta_general:common:Complex'));
                    end

                catch ME_TS_FAIL

                    errMsgStruct.errorConsistency=ME_TS_FAIL.message;
                    return;
                end
            end
        end


        function[signalProperties,errMsgStruct]=qualifyAuthoredDataArray(dataVal,timeVal,errMsgStruct)

            signalProperties.numSamples=[];
            signalProperties.dataType=[];
            signalProperties.dimensions=[];
            signalProperties.proposedDataType='';
            signalProperties.signalType='';
            signalProperties.IS_1D=true;
            signalProperties.IS_SCALAR=true;
            if isempty(errMsgStruct.errorTime)&&isempty(errMsgStruct.errorData)

                try
                    if~isa(dataVal,'double')
                        errMsgStruct.errorData=DAStudio.message('sl_web_widgets:authorinsert:timeDataArrayDataError');
                        return;
                    end

                    if~isa(timeVal,'double')
                        errMsgStruct.errorTime=DAStudio.message('sl_web_widgets:authorinsert:timeDataArrayTimeError');
                        return;
                    end

                    dArray=[timeVal,dataVal];

                    if~isreal(dArray)
                        errMsgStruct.errorConsistency=DAStudio.message('sl_web_widgets:authorinsert:timeDataArrayComplexityError');
                        return;
                    end

                    signalProperties.numSamples=num2str(length(timeVal));
                    signalProperties.dataType=class(dataVal);
                    dArrayDims=size(dArray);
                    signalProperties.dimensions=num2str((dArrayDims(2)-1));
                    signalProperties.comparedim=signalProperties.dimensions;
                    signalProperties.signalType=getString(message('sl_sta_general:common:Real'));


                    signalProperties.IS_1D=strcmpi(signalProperties.dimensions,'1');
                    signalProperties.IS_SCALAR=isscalar(dataVal);
                catch ME_TS_FAIL

                    errMsgStruct.errorConsistency=ME_TS_FAIL.message;
                    return;
                end
            end
        end


        function[signalProperties,errMsgStruct]=qualifyAuthoredTimeTable(dataVal,timeVal,errMsgStruct)
            if isempty(errMsgStruct.errorTime)&&isempty(errMsgStruct.errorData)

                signalProperties.numSamples=[];
                signalProperties.dataType=[];
                signalProperties.dimensions='';
                signalProperties.proposedDataType='';
                signalProperties.signalType='';
                signalProperties.IS_1D=true;
                try

                    if~isa(timeVal,'duration')
                        errMsgStruct.errorTime=DAStudio.message('sl_web_widgets:authorinsert:timeTableTimeError');
                        return;
                    end

                    tmpTimeTable=timetable(timeVal,dataVal);

                    signalProperties.numSamples=num2str(length(timeVal));
                    signalProperties.dataType=slwebwidgets.AuthorUtility.qualifyDataType(dataVal);

                    IS_SUPPORTED=isSimulinkSignalFormat(tmpTimeTable);

                    if~IS_SUPPORTED
                        if isfi(tmpTimeTable.(tmpTimeTable.Properties.VariableNames{1}))&&...
                            ~isSimulinkFi(tmpTimeTable.(tmpTimeTable.Properties.VariableNames{1}))
                            errMsgStruct.errorData=DAStudio.message('sl_web_widgets:authorinsert:slFiWordLengthViolation');
                            return;
                        end
                    end

                    tssize=size(dataVal);
                    dataDim=tssize(2:end);

                    signalProperties.comparedim=mat2str(dataDim);

                    if length(signalProperties.comparedim)>1
                        dimsInXxXForm=signalProperties.comparedim(2:end-1);
                        signalProperties.dimensions=strrep(dimsInXxXForm,' ','x');

                    else
                        signalProperties.dimensions=signalProperties.comparedim;
                    end

                    varSize=size(tmpTimeTable.(tmpTimeTable.Properties.VariableNames{1}));
                    signalProperties.IS_1D=isvector(tmpTimeTable.(tmpTimeTable.Properties.VariableNames{1}))&&...
                    varSize(2)==1&&...
                    varSize(1)==str2num(signalProperties.numSamples);%#ok<ST2NM>

                    signalProperties.IS_SCALAR=isscalar(tmpTimeTable.(tmpTimeTable.Properties.VariableNames{1}));
                    if isreal(dataVal)||isa(dataVal,'string')
                        signalProperties.signalType=getString(message('sl_sta_general:common:Real'));
                    else
                        signalProperties.signalType=getString(message('sl_sta_general:common:Complex'));
                    end
                catch ME_TS_FAIL

                    errMsgStruct.errorConsistency=ME_TS_FAIL.message;
                    return;
                end
            end
        end


        function fiValueMetaData=quantizeRWValues(realWorldValues,dataType,varargin)






            if isfi(dataType)

                if~isempty(varargin)

                    IS_OVERFLOW_CONSISTENT=strcmpi(dataType.OverflowMode,varargin{1});
                    IS_ROUND_CONSISTENT=strcmpi(dataType.RoundMode,varargin{2});

                    if~IS_OVERFLOW_CONSISTENT||~IS_ROUND_CONSISTENT


                        DAStudio.error('sl_web_widgets:authorinsert:fiInconsistentValues');
                    end
                end

                dataTypeContainer=dataType;
            else

                if~isempty(varargin)
                    overflowMode=varargin{1};
                    roundMode=varargin{2};
                else


                    optargs={'Wrap','Floor'};
                    optargs(1:numel(varargin))=varargin;
                    [overflowMode,roundMode]=optargs{:};
                end

                dataTypeContainer=fi(realWorldValues,dataType,...
                'OverflowMode',overflowMode,...
                'RoundMode',roundMode);
            end

            [numOverflows,numUnderflows,fiObject]=fixed.internal.numOverAndUnderflows(realWorldValues,dataTypeContainer);

            IS_COMPLEX=false;
            if~isreal(realWorldValues)
                IS_COMPLEX=true;
                [numOverflowsReal,numUnderflowsReal,~]=fixed.internal.numOverAndUnderflows(real(realWorldValues),dataTypeContainer);
                [numOverflowsImag,numUnderflowsImag,~]=fixed.internal.numOverAndUnderflows(imag(realWorldValues),dataTypeContainer);
            end




            quantizedValues=double(fiObject);


            errorVal=double(realWorldValues)-quantizedValues;
            absError=abs(errorVal);


            relError=absError./abs(double(realWorldValues));















            fiValueMetaData.fiValue=fiObject;
            fiValueMetaData.numOverflows=numOverflows;
            fiValueMetaData.numUnderflows=numUnderflows;
            fiValueMetaData.error=errorVal;
            fiValueMetaData.absError=absError;
            fiValueMetaData.relError=relError;

            if IS_COMPLEX

                fiValueMetaData.realOverflow=numOverflowsReal;
                fiValueMetaData.imagOverflow=numOverflowsImag;

                fiValueMetaData.realUnderflow=numUnderflowsReal;
                fiValueMetaData.imagUnderflow=numUnderflowsImag;

            end

        end


        function dataType=qualifyDataType(dataVal)

            if isfi(dataVal)
                dataType=fixdt(dataVal.numerictype);
            elseif islogical(dataVal)
                dataType='boolean';
            else
                dataType=class(dataVal);
            end
        end


        function outBool=isDataTypeNumericType(dataTypeString)

            outBool=starepository.DataTypeHelper.isDataTypeNumericType(dataTypeString);

        end


        function[IS_VALID,ISA_META_STRUCT]=isSignalDataTypeStringValid(dataTypeString)

            [IS_VALID,ISA_META_STRUCT]=starepository.DataTypeHelper.isSignalDataTypeStringValid(dataTypeString);

        end


        function outEnumDataType=parseDataTypeStringForEnumeration(dataTypeString)

            outEnumDataType=starepository.DataTypeHelper.parseDataTypeStringForEnumeration(dataTypeString);
        end


        function[comparedims,dimensionsNxNForm]=getDimensionsAndCompareDims(varIn)


            theDims=getTSDimension(varIn);
            comparedims=mat2str(theDims);

            if length(comparedims)>1
                dimsInXxXForm=comparedims(2:end-1);
                dimensionsNxNForm=strrep(dimsInXxXForm,' ','x');

            else
                dimensionsNxNForm=comparedims;
            end


        end


        function[histogramStruct,errMsgStruct]=getHistogramData(authoredProperties)

            histogramStruct=[];
            if~fxptui.checkInstall
                errMsgStruct.errorData=DAStudio.message('sl_web_widgets:authorinsert:fixedPointLicenseRequired');
                return;
            end

            errMsgStruct=[];
            try
                dataValb4_Cast=eval(authoredProperties.dataToUse);
            catch ME_DATA %#ok<NASGU>
                try
                    dataValb4_Cast=evalin('base',authoredProperties.dataToUse);
                catch ME_EVAL_DATA %#ok<NASGU>

                    errMsgStruct.errorData=DAStudio.message('sl_web_widgets:authorinsert:qualifyDataNonSimulinkSupport');

                    return;
                end
            end


            histogramStruct=slwebwidgets.AuthorUtility.calculateHistogram(dataValb4_Cast,authoredProperties.dataTypeToUse);
        end


        function histogramStruct=calculateHistogram(dataValb4_Cast,specifiedDT)

            if~fxptui.checkInstall
                DAStudio.error('sl_web_widgets:authorinsert:fixedPointLicenseRequired');
            end


            [~,~,~]=...
            slwebwidgets.AuthorUtility.proposeDataTypeAllScaling(dataValb4_Cast,eval(specifiedDT));

            if ismatrix(dataValb4_Cast)
                dataValb4_Cast=reshape(dataValb4_Cast,1,numel(dataValb4_Cast));
            end

            signalData=dataValb4_Cast;



            result.HistogramData=fxpHistogram.HistogramUtil.getRangeHistogramData(signalData);
            result.getProposedDT=specifiedDT;
            result.getSpecifiedDT=specifiedDT;
            result.getCompiledDT=specifiedDT;
            result.PrecisionHistogramData=[];
            result.DesignMin=[];
            result.DesignMax=[];
            result.DerivedMin=[];
            result.DerivedMax=[];

            dataVal=double(dataValb4_Cast);

            result.SimMin=double(min(dataVal));
            result.SimMax=double(max(dataVal));
            result.OverflowWrap=[];
            result.OverflowSaturation=[];
            result.DivideByZero=[];
            result.IsScaledDouble=false;



            histogramStruct=slwebwidgets.AuthorUtility.computeHistogramData(result);



        end


        function histogramStruct=computeHistogramData(result)

            if~fxptui.checkInstall
                DAStudio.error('sl_web_widgets:authorinsert:fixedPointLicenseRequired');
            end

            histogramController=fxpHistogram.Web.HistogramController;
            histogramStruct=histogramController.computeHistogramData(result);
        end
    end
end


