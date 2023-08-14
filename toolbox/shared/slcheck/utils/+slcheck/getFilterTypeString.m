function stringType=getFilterTypeString(enumType)
    switch enumType
    case advisor.filter.FilterType.Block
        stringType='Block';
    case advisor.filter.FilterType.BlockParameters
        stringType='BlockParameters';
    case advisor.filter.FilterType.BlockType
        stringType='BlockType';
    case advisor.filter.FilterType.Library
        stringType='Library';
    case advisor.filter.FilterType.MaskType
        stringType='MaskType';
    case advisor.filter.FilterType.Stateflow
        stringType='Stateflow';
    case advisor.filter.FilterType.StringTypeFilter
        stringType='StringTypeFilter';
    case advisor.filter.FilterType.Subsystem
        stringType='Subsystem';
    case advisor.filter.FilterType.MATLABLOCFilter
        stringType='MATLABLOCFilter';
    case advisor.filter.FilterType.State
        stringType='State';
    case advisor.filter.FilterType.Transition
        stringType='Transition';
    case advisor.filter.FilterType.Event
        stringType='Event';
    case advisor.filter.FilterType.Junction
        stringType='Junction';
    case advisor.filter.FilterType.GraphicalFunction
        stringType='GraphicalFunction';
    case advisor.filter.FilterType.TruthTable
        stringType='TruthTable';
    case advisor.filter.FilterType.SimulinkFunction
        stringType='SimulinkFunction';
    case advisor.filter.FilterType.MATLABFunction
        stringType='MATLABFunction';
    case advisor.filter.FilterType.SimulinkBasedState
        stringType='SimulinkBasedState';
    case advisor.filter.FilterType.Chart
        stringType='Chart';
    case advisor.filter.FilterType.Subchart
        stringType='Subchart';
    otherwise
        stringType='';

    end
end
