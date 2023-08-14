function res=getBlockMaskTypeAttributes(h,blkObj,pathItem)%#ok












    if isequal(pathItem,'1')||isequal(pathItem,'Output')
        dataName='Output1';
    else
        dataName=pathItem;
    end

    res.IsSettableInSomeSituations=false;

    try
        blockType=blkObj.BlockType;
    catch
        return
    end

    switch blockType

    case{'Inport'
'Outport'
        }
        if any(contains({blkObj.UseBusObject,blkObj.IsBusElementPort},'on'))
            res.DisplayDataTypeStr=blkObj.OutDataTypeStr;
            return;
        else
            if strcmp('Output1',dataName)


                res.IsSettableInSomeSituations=true;
                res.DataTypeEditField_ParamName='OutDataTypeStr';
                res.LockScaling_ParamName='LockScale';
            end
        end

    case{'SignalSpecification'
'DataStoreMemory'
'Constant'
'Relay'
        }

        if strcmp('Output1',dataName)


            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='OutDataTypeStr';
            res.LockScaling_ParamName='LockScale';
        end

    case{'DiscreteIntegrator'
'Saturate'
'Switch'
'Lookup'
'Lookup2D'
'Abs'
'MinMax'
'MultiPortSwitch'
'DotProduct'
'Sqrt'
        }

        if strcmp('Output1',dataName)


            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='OutDataTypeStr';
            res.LockScaling_ParamName='LockScale';
        end
    case{'DataTypeConversion'
        }


        if strcmp(blkObj.ConvertRealWorld,'Stored Integer (SI)')
            res.IsSettableInSomeSituations=false;
            res.DataTypeEditField_ParamName='OutDataTypeStr';
            res.LockScaling_ParamName='LockScale';
        else
            if strcmp('Output1',dataName)


                res.IsSettableInSomeSituations=true;
                res.DataTypeEditField_ParamName='OutDataTypeStr';
                res.LockScaling_ParamName='LockScale';
            end
        end


    case{'Sum'
        }

        switch dataName
        case 'Output1'
            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='OutDataTypeStr';
            res.LockScaling_ParamName='LockScale';
        case 'Accumulator'
            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='AccumDataTypeStr';
            res.LockScaling_ParamName='LockScale';
        end

    case{'Math'
        }


        if strcmp('Output1',dataName)
            switch blkObj.Operator
            case{'magnitude^2','square','reciprocal','sqrt','1/sqrt'}
                res.IsSettableInSomeSituations=true;
                res.DataTypeEditField_ParamName='OutDataTypeStr';
                res.LockScaling_ParamName='LockScale';
            otherwise
                res.IsSettableInSomeSituations=false;
            end
        end

    case{'Width'
        }

        res.IsSettableInSomeSituations=false;
        res.DataTypeEditField_ParamName='OutputDataTypeScalingMode';

    case{'Logic'
'RelationalOperator'
        }

        res.IsSettableInSomeSituations=false;
        res.DataTypeEditField_ParamName='OutDataTypeStr';


    case{'Gain'
        }

        switch dataName
        case 'Output1'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='OutDataTypeStr';
            res.LockScaling_ParamName='LockScale';

        case 'Gain'

            res.IsSettableInSomeSituations=true;
            res.InitValue_ParamName='Gain';
            res.DataTypeEditField_ParamName='ParamDataTypeStr';
            res.LockScaling_ParamName='LockScale';

        end

    case{'DiscreteFir'
'AllpoleFilter'
        }

        switch dataName

        case 'Output1'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='OutDataTypeStr';
            res.LockScaling_ParamName='LockScale';

        case 'Accumulator'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='AccumDataTypeStr';
            res.LockScaling_ParamName='LockScale';

        case 'Product output'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='ProductDataTypeStr';
            res.LockScaling_ParamName='LockScale';
        case 'TapSum'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='TapSumDataTypeStr';
            res.LockScaling_ParamName='LockScale';
        case 'States'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='StateDataTypeStr';
            res.LockScaling_ParamName='LockScale';






        end
    case{'DiscreteFilter'
'DiscreteTransferFcn'
        }

        switch dataName

        case 'Output1'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='OutDataTypeStr';
            res.LockScaling_ParamName='LockScale';

        case 'Numerator accumulator'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='NumAccumDataTypeStr';
            res.LockScaling_ParamName='LockScale';

        case 'Denominator accumulator'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='DenAccumDataTypeStr';
            res.LockScaling_ParamName='LockScale';

        case 'Numerator product output'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='NumProductDataTypeStr';
            res.LockScaling_ParamName='LockScale';

        case 'Denominator product output'

            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='DenProductDataTypeStr';
            res.LockScaling_ParamName='LockScale';

        case 'States'
            if strcmp(blkObj.InitialStatesSource,'Dialog')
                res.IsSettableInSomeSituations=true;
                res.DataTypeEditField_ParamName='StateDataTypeStr';
                res.LockScaling_ParamName='LockScale';
            end

        case 'Multiplicand'
            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='MultiplicandDataTypeStr';
            res.LockScaling_ParamName='LockScale';












        end

    case 'Probe'
        switch dataName
        case 'Width'
            res.IsSettableInSomeSituations=false;
            res.DataTypeEditField_ParamName='ProbeWidthDataType';
        case 'SampleTime'
            res.IsSettableInSomeSituations=false;
            res.DataTypeEditField_ParamName='ProbeSampleTimeDataType';
        case 'SignalComplex'
            res.IsSettableInSomeSituations=false;
            res.DataTypeEditField_ParamName='ProbeComplexityDataType';
        case 'SignalDimension'
            res.IsSettableInSomeSituations=false;
            res.DataTypeEditField_ParamName='ProbeDimensionsDataType';
        case 'SignalFrame'
            res.IsSettableInSomeSituations=false;
            res.DataTypeEditField_ParamName='ProbeFrameDataType';
        end

    case 'Find'
        res.IsSettableInSomeSituations=false;
        res.DataTypeEditField_ParamName='OutDataTypeStr';

    case 'S-Function'

        maskType=blkObj.MaskType;

        if~isempty(maskType)
            res=getSFunctionAttributes(maskType,dataName);
        end

    case 'SubSystem'








    end


    function res=getSFunctionAttributes(maskType,dataName)



        res.IsSettableInSomeSituations=false;

        switch maskType

        case{'Weighted Moving Average'
            }
            switch dataName
            case 'Output1'

                res.IsSettableInSomeSituations=true;
                res.DataTypeEditField_ParamName='OutDataTypeStr';
                res.LockScaling_ParamName='LockScale';

            case 'Gain'

                res.IsSettableInSomeSituations=true;
                res.InitValue_ParamName='mgainval';
                res.DataTypeEditField_ParamName='GainDataTypeStr';
                res.LockScaling_ParamName='LockScale';

            end

        case{'Lookup Table Dynamic'
            }

            if strcmp('Output1',dataName)

                res.IsSettableInSomeSituations=true;
                res.DataTypeEditField_ParamName='OutDataTypeStr';
                res.LockScaling_ParamName='LockScale';
            end

        otherwise

            res.IsSettableInSomeSituations=false;

        end



