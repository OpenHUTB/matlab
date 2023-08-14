function tunables=getTunableProperties(blockType)





    switch(blockType)
    case 'Constant'
        tunables={'Value',};
    case 'DiscreteIntegrator'
        tunables={'gainval','InitialCondition','UpperSaturationLimit','LowerSaturationLimit',};
    case 'Gain'
        tunables={'Gain',};
    case 'Integrator'
        tunables={'InitialCondition','UpperSaturationLimit','LowerSaturationLimit','AbsoluteTolerance',};
    case 'Saturate'
        tunables={'UpperLimit','LowerLimit',};
    case 'Switch'
        tunables={'Threshold',};
    case 'UnitDelay'
        tunables={'InitialCondition',};
    case 'Derivative'
        tunables={'LinearizePole',};
    case 'StateSpace'
        tunables={'A','B','C','D','X0','AbsoluteTolerance',};
    case 'TransportDelay'
        tunables={'DelayTime','InitialOutput','BufferSize','PadeOrder',};
    case 'VariableTransportDelay'
        tunables={'MaximumDelay','InitialOutput','MaximumPoints','PadeOrder','AbsoluteTolerance',};
    case 'Backlash'
        tunables={'BacklashWidth','InitialOutput',};
    case 'DeadZone'
        tunables={'LowerValue','UpperValue',};
    case 'HitCross'
        tunables={'HitCrossingOffset',};
    case 'Quantizer'
        tunables={'QuantizationInterval',};
    case 'RateLimiter'
        tunables={'RisingSlewLimit','FallingSlewLimit','InitialCondition',};
    case 'Relay'
        tunables={'OnSwitchValue','OffSwitchValue','OnOutputValue','OffOutputValue',};
    case 'Memory'
        tunables={'X0',};
    case 'CombinatorialLogic'
        tunables={'TruthTable',};
    case 'Lookup2D'
        tunables={'RowIndex','ColumnIndex','OutputValues',};
    case 'Lookup'
        tunables={'InputValues','OutputValues',};
    case 'Bias'
        tunables={'Bias',};
    case 'MagnitudeAngleToComplex'
        tunables={'ConstantPart',};
    case 'PermuteDimensions'
        tunables={'Order',};
    case 'RealImagToComplex'
        tunables={'ConstantPart',};
    case 'Sin'
        tunables={'Amplitude','Bias','Frequency','Phase','Samples','Offset',};
    case 'InitialCondition'
        tunables={'Value',};
    case 'RateTransition'
        tunables={'X0',};
    otherwise
        tunables=[];
    end
