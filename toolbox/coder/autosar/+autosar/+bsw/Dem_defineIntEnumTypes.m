function Dem_defineIntEnumTypes(modelName)




    dataDictionary=get_param(modelName,'DataDictionary');
    enumBuilder=autosar.simulink.enum.createEnumBuilder(dataDictionary);

    enumBuilder.defineIntEnumType('Dem_EventStatusType',...
    {'DEM_EVENT_STATUS_PASSED','DEM_EVENT_STATUS_FAILED','DEM_EVENT_STATUS_PREPASSED','DEM_EVENT_STATUS_PREFAILED'},...
    [0,1,2,3],...
    'DefaultValue','DEM_EVENT_STATUS_PASSED',...
    'StorageType','uint8',...
    'HeaderFile','Rte_Type.h',...
    'AddClassNameToEnumNames',false);

    enumBuilder.defineIntEnumType('Dem_DTCFormatType',...
    {'DEM_DTC_FORMAT_OBD','DEM_DTC_FORMAT_UDS'},...
    [0,1],...
    'StorageType','uint8',...
    'DefaultValue','DEM_DTC_FORMAT_OBD',...
    'HeaderFile','Rte_Type.h',...
    'AddClassNameToEnumNames',false);

    enumBuilder.defineIntEnumType('Dem_OperationCycleStateType',...
    {'DEM_CYCLE_STATE_START','DEM_CYCLE_STATE_END'},...
    [0,1],...
    'StorageType','uint8',...
    'DefaultValue','DEM_CYCLE_STATE_START',...
    'HeaderFile','Rte_Type.h',...
    'AddClassNameToEnumNames',false);

    enumBuilder.defineIntEnumType('Dem_DebouncingStateType',...
    {'DEM_TEMPORARILY_DEFECTIVE','DEM_FINALLY_DETECTIVE',...
    'DEM_TEMPORARILY_HEALED','DEM_TEST_COMPLETE',...
    'DEM_DTR_UPDATE'},...
    [1,2,4,8,16],...
    'StorageType','uint8',...
    'DefaultValue','DEM_TEMPORARILY_DEFECTIVE',...
    'HeaderFile','Rte_Type.h',...
    'AddClassNameToEnumNames',false);

    enumBuilder.defineIntEnumType('Dem_IumprDenomCondStatusType',...
    {'DEM_IUMPR_DEN_STATUS_NOT_REACHED',...
    'DEM_IUMPR_DEN_STATUS_REACHED',...
    'DEM_IUMPR_DEN_STATUS_INHIBITED'},...
    [0,1,2],...
    'StorageType','uint8',...
    'DefaultValue','DEM_IUMPR_DEN_STATUS_NOT_REACHED',...
    'HeaderFile','Rte_Type.h',...
    'AddClassNameToEnumNames',false);

    enumBuilder.defineIntEnumType('Dem_DTRControlType',...
    {'DEM_DTR_CTL_NORMAL',...
    'DEM_DTR_CTL_NO_MAX',...
    'DEM_DTR_CTL_NO_MIN',...
    'DEM_DTR_CTL_RESET',...
    'DEM_DTR_CTL_INVISIBLE',},...
    [0,1,2,3,4],...
    'StorageType','uint8',...
    'DefaultValue','DEM_DTR_CTL_NORMAL',...
    'HeaderFile','Rte_Type.h',...
    'AddClassNameToEnumNames',false);

    enumBuilder.defineIntEnumType('Dem_IndicatorStatusType',...
    {'DEM_INDICATOR_OFF',...
    'DEM_INDICATOR_CONTINUOUS',...
    'DEM_INDICATOR_BLINKING',...
    'DEM_INDICATOR_BLINK_CONT',...
    'DEM_INDICATOR_SLOW_FLASH',...
    'DEM_INDICATOR_FAST_FLASH',...
    'DEM_INDICATOR_ON_DEMAND',...
    'DEM_INDICATOR_SHORT',...
    },...
    [0,1,2,3,4,5,6,7],...
    'StorageType','uint8',...
    'DefaultValue','DEM_INDICATOR_OFF',...
    'HeaderFile','Rte_Type.h',...
    'AddClassNameToEnumNames',false);



