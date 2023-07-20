function pathItems=getPathItems(h,blkObj)%#ok








    clz=class(blkObj);

    switch clz

    case{'Simulink.Inport'
'Simulink.Outport'
'Simulink.DataStoreMemory'
'Simulink.Relay'
'Simulink.Logic'
'Simulink.RelationalOperator'
'Simulink.DataTypeConversion'
'Simulink.DiscreteIntegrator'
'Simulink.Saturate'
'Simulink.Switch'
'Simulink.Abs'
'Simulink.MinMax'
'Simulink.MultiPortSwitch'
'Simulink.Math'
'Simulink.Sqrt'
        }
        pathItems={'1'};

    case 'Simulink.Sum'
        pathItems={'Output','Accumulator'};

    case{'Simulink.Gain'}
        pathItems={'1','Gain'};

    case{'Simulink.DiscreteFilter'
'Simulink.DiscreteTransferFcn'
        }
        switch blkObj.FilterStructure
        case{'Direct form II',...
'Direct form II transposed'
            }
            pathItems={'Numerator accumulator','Denominator accumulator',...
            'Numerator product output','Denominator product output',...
            'States','Output'};

        case 'Direct form I'
            pathItems={'Numerator accumulator','Denominator accumulator',...
            'Numerator product output','Denominator product output',...
            'Output'};

        case 'Direct form I transposed'
            pathItems={'Numerator accumulator','Denominator accumulator',...
            'Numerator product output','Denominator product output',...
            'States','Multiplicand','Output'};
        otherwise
            pathItems={'1'};
        end

    case 'Simulink.DiscreteFir'

        switch blkObj.FirFiltStruct
        case{'Direct form',...
'Direct form transposed'
            }
            pathItems={'Accumulator','Output','Product output'};



        case{'Direct form symmetric',...
'Direct form antisymmetric'
            }
            pathItems={'Accumulator','Output','Product output','TapSum'};

        case 'Lattice MA'
            pathItems={'Accumulator','Output','Product output','States'};

        otherwise
            pathItems={'1'};
        end

    case 'Simulink.AllpoleFilter'

        switch blkObj.FirFiltStruct
        case 'Direct form'
            pathItems={'Accumulator','Output','Product output'};

        case{'Lattice AR',...
'Direct form transposed'
            }
            pathItems={'Accumulator','Output','Product output','States'};

        otherwise
            pathItems={'1'};
        end

    case 'Simulink.Probe'
        pathItems={};
        if strcmp(blkObj.ProbeWidth,'on')
            pathItems{end+1}='Width';
        end
        if strcmp(blkObj.ProbeSampleTime,'on')
            pathItems{end+1}='SampleTime';
        end
        if strcmp(blkObj.ProbeComplexSignal,'on')
            pathItems{end+1}='SignalComplex';
        end
        if strcmp(blkObj.ProbeSignalDimensions,'on')
            pathItems{end+1}='SignalDimension';
        end
        if strcmp(blkObj.ProbeFramedSignal,'on')
            pathItems{end+1}='SignalFrame';
        end

    case 'Simulink.SFunction'

        pathItems=getSFunctionAttributes(blkObj);

    otherwise
        pathItems={'1'};
    end

    function pathItems=getSFunctionAttributes(blk)


        switch blk.MaskType
        case{'Weighted Moving Average'
            }
            pathItems={'1','Gain'};

        otherwise

            pathItems={'1'};


        end




