function list=getPropList(this,filterName)






    switch filterName
    case 'main'
        list={
'Name'
'OutDataTypeStr'
'RepresentableMaximum'
'OutputMaximum'
'OutputMinimum'
'RepresentableMinimum'
'Precision'
        };

    case 'mask'
        list=getPropList(rptgen_sl.propsrc_sl_blk,'mask');

    case 'fixpoint-binary-point'
        list={
'Name'
'OutDataTypeStr'
'Signed'
'WordLength'
'FractionLength'
        };

    case 'fixpoint-slope-bias'
        list={
'Name'
'OutDataTypeStr'
'Signed'
'WordLength'
'Slope'
'Bias'
        };

    case 'fixpoint-sim'
        listMinMax={
'Name'
'SimMin'
'SimMax'
        };
        list=[listMinMax;setdiff(this.getPropList('errors'),listMinMax)];

    case 'fixpoint-misc'
        list={
'Name'
'Scaling'
'TotalBits'
'FixedExponent'
'SlopeAdjustmentFactor'
'LockScale'
'ConvertRealWorld'
'IntegerRoundingMode'
'SaturateOnIntegerOverflow'
'DataTypeOverride'
        };
        list=sort(list);

    case 'errors'
        list={
'Name'
'OverflowOccurred'
'SaturationOccurred'
'ParameterSaturationOccurred'
'DivisionByZeroOccurred'
        };

    case 'all'
        list=[this.getPropList('main');...
        this.getPropList('fixpoint-binary-point');...
        this.getPropList('fixpoint-slope-bias');...
        this.getPropList('fixpoint-sim');...
        this.getPropList('fixpoint-misc');...
        ];
        list=unique(list);

    case 'blkall'
        list=getPropList(rptgen_sl.propsrc_sl_blk,'all');

    case 'slmain'
        list=getPropList(rptgen_sl.propsrc_sl_blk,'main');

    otherwise
        list={};
    end
