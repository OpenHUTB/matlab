function[pValue,propName]=getPropValue(psFP,objList,propName)






    [objs,nObjs]=rptgen_sl.getSimulinkObjects(objList);

    pValue=cell(1,nObjs);
    for i=1:nObjs
        obj=objs(i);
        modelName=bdroot(obj.getFullName());
        fpAppData=SimulinkFixedPoint.getApplicationData(modelName);
        dataTypeObj=locGetDataTypeObj(psFP,obj);

        if~isa(dataTypeObj,'Simulink.NumericType')
            [pValue{i},propName]=locGetSimulinkBlkPropVal(obj,propName);
            continue
        end

        switch propName
        case{'OutDataType','OutputDataTypeScaling','OutScaling'
            'MantBits','TimeOfMin','TimeOfMax'}
            pValue{i}='deprecated';

        case 'Scaling'
            pValue{i}=locGetScalingString(dataTypeObj);

        case 'Block'
            pValue{i}=obj.getFullName();

        case{'OutDataTypeStr','CompiledPortDataType'}
            pValue{i}=locGetCompiledPortDataType(obj);

        case 'WordLength'
            pValue{i}=dataTypeObj.WordLength;

        case 'FractionLength'
            pValue{i}=dataTypeObj.FractionLength;

        case{'FixExp','FixedExponent'}
            pValue{i}=dataTypeObj.FixedExponent;
            propName='FixedExponent';

        case 'Slope'
            pValue{i}=dataTypeObj.Slope;

        case{'Precision','Resolution'}
            if strncmpi(dataTypeObj.DataTypeMode,'fixed',5)
                pValue{i}=dataTypeObj.Slope;
            else
                pValue{i}='N/A';
            end

        case 'SlopeAdjustmentFactor'
            pValue{i}=dataTypeObj.SlopeAdjustmentFactor;

        case 'Bias'
            pValue{i}=dataTypeObj.Bias;

        case 'TotalBits'
            pValue{i}=dataTypeObj.WordLength;

        case 'Signed'
            pValue{i}=dataTypeObj.Signed;

        case{'DataTypeOverride','DataTypeOverride_Compiled'}
            pValue{i}=locGetSimulinkBlkPropVal(...
            obj,...
            'DataTypeOverride_Compiled');
            propName='DataTypeOverride';

        case{'SimMin','MinValue'}
            pValue{i}=locGetResults(fpAppData,obj,'SimMin');
            propName='SimMin';

        case{'SimMax','MaxValue'}
            pValue{i}=locGetResults(fpAppData,obj,'SimMax');
            propName='SimMax';

        case{'MinLim','RepresentableMinimum'}
            pValue{i}=SimulinkFixedPoint.DataType.getFixedPointRepMinMaxRwvInDouble(dataTypeObj);

        case{'MaxLim','RepresentableMaximum'}
            [~,pValue{i}]=SimulinkFixedPoint.DataType.getFixedPointRepMinMaxRwvInDouble(dataTypeObj);

        case 'OverflowOccurred'
            pValue{i}=locGetResults(fpAppData,obj,'OvfWrap');

        case 'SaturationOccurred'
            pValue{i}=locGetResults(fpAppData,obj,'OvfSat');

        case 'ParameterSaturationOccurred'
            pValue{i}=locGetResults(fpAppData,obj,'ParamSat');

        case 'DivisionByZeroOccurred'
            pValue{i}=locGetResults(fpAppData,obj,'DivByZero');

        case 'OutputMinimum'
            pValue{i}=locGetSimulinkBlkPropVal(obj,'OutMin');

        case 'OutputMaximum'
            pValue{i}=locGetSimulinkBlkPropVal(obj,'OutMax');

        case 'IntegerRoundingMode'
            pValue{i}=locGetSimulinkBlkPropVal(obj,'RndMeth');

        otherwise
            [pValue{i},propName]=locGetSimulinkBlkPropVal(obj,propName);
        end
    end


    function dataTypeObj=locGetDataTypeObj(psFP,obj)

        try
            outDataTypeStr=obj.OutDataTypeStr;
        catch ME %#ok
            outDataTypeStr=[];
        end

        if(isempty(outDataTypeStr)...
            ||strncmpi(outDataTypeStr,'Inherit',7)...
            ||~isempty(strfind(outDataTypeStr,'InternalDataType')))
            outDataType=locGetCompiledPortDataType(obj);
            if(~isempty(outDataType)&&iscell(outDataType))
                outDataType=outDataType{1};
            end
        else
            outDataType=outDataTypeStr;
        end

        if(isempty(outDataType)||strcmpi(outDataType,'N/A'))
            dataTypeObj=outDataType;
        else
            try
                dataTypeObj=fixdt(outDataType);
            catch ME %#ok
                try
                    dataTypeObj=evalin('base',outDataType);
                catch ME2 %#ok
                    dataTypeObj=[];
                end
            end
        end


        function scalingString=locGetScalingString(dataTypeObj)

            slopeValue=dataTypeObj.Slope;
            slopeString=dataTypeObj.SlopeString;
            biasValue=dataTypeObj.Bias;

            if(slopeValue==1)
                slopeString='';
            else
                slopeString=['*',slopeString];
            end

            if(biasValue==0)
                biasString='';
            elseif(biasValue>0)
                biasString=[' + ',num2str(biasValue)];
            else
                biasString=[' - ',num2str(abs(biasValue))];
            end
            scalingString=sprintf('V = Q%s%s',slopeString,biasString);


            function compiledPortDataType=locGetCompiledPortDataType(obj)

                compiledPortDataTypes=locGetSimulinkBlkPropVal(obj,'CompiledPortDataTypes');
                if(~isempty(compiledPortDataTypes)...
                    &&(isfield(compiledPortDataTypes,'Outport')...
                    &&~isempty(compiledPortDataTypes.Outport)))
                    outports=compiledPortDataTypes.Outport;
                    outports=outports{1};
                else
                    outports=[];
                end

                if length(outports)==1
                    compiledPortDataType=outports{1};
                elseif isempty(outports)
                    compiledPortDataType='N/A';
                else
                    compiledPortDataType=outports;
                end


                function propVal=locGetResults(fpAppData,obj,propName)

                    if~isempty(fpAppData)
                        runObj=fpAppData.dataset.getRun(fpAppData.ScaleUsing);


                        result=runObj.getResult(obj,'Output');
                        if isempty(result)
                            result=runObj.getResult(obj,'1');
                        end
                        if isempty(result)
                            results=runObj.getResults;
                            result=results(1);
                        end
                        propVal=result.getPropValue(propName);

                    else
                        propVal='';
                    end


                    function[propVal,propName]=locGetSimulinkBlkPropVal(obj,propName)

                        psSL=rptgen_sl.propsrc_sl_blk;

                        [propVal,propName]=psSL.getPropValue(...
                        {obj.getFullName()},...
                        propName);

                        if(length(propVal)==1)
                            propVal=propVal{1};
                        end
