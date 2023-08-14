function enumType=getFilterTypeEnum(stringType)
    stringType=lower(stringType);
    switch stringType
    case 'block'
        enumType=advisor.filter.FilterType.Block;
    case 'blockparameters'
        enumType=advisor.filter.FilterType.BlockParameters;
    case 'blocktype'
        enumType=advisor.filter.FilterType.BlockType;
    case 'library'
        enumType=advisor.filter.FilterType.Library;
    case 'masktype'
        enumType=advisor.filter.FilterType.MaskType;
    case 'stateflow'
        enumType=advisor.filter.FilterType.Stateflow;
    case 'stringtypefilter'
        enumType=advisor.filter.FilterType.StringTypeFilter;
    case 'subsystem'
        enumType=advisor.filter.FilterType.Subsystem;
    case 'matlablocfilter'
        enumType=advisor.filter.FilterType.MATLABLOCFilter;
    case 'state'
        enumType=advisor.filter.FilterType.State;
    case 'transition'
        enumType=advisor.filter.FilterType.Transition;
    case 'event'
        enumType=advisor.filter.FilterType.Event;
    case 'junction'
        enumType=advisor.filter.FilterType.Junction;
    case 'graphicalfunction'
        enumType=advisor.filter.FilterType.GraphicalFunction;
    case 'truthtable'
        enumType=advisor.filter.FilterType.TruthTable;
    case 'simulinkfunction'
        enumType=advisor.filter.FilterType.SimulinkFunction;
    case 'matlabfunction'
        enumType=advisor.filter.FilterType.MATLABFunction;
    case 'simulinkbasedstate'
        enumType=advisor.filter.FilterType.SimulinkBasedState;
    case 'chart'
        enumType=advisor.filter.FilterType.Chart;
    case 'subchart'
        enumType=advisor.filter.FilterType.Subchart;
    otherwise
        enumType=advisor.filter.FilterType.FILTER_TYPE_NONE;

    end
end
