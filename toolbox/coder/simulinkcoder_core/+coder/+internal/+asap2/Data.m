classdef Data<handle










    properties(Hidden,Access=public)
        ModelName;
        ParametersMap;
        SignalsMap;
        CompuMethodsMap;
        CompuVtabsMap;
        RecordLayoutsMap;
        GroupsMap;
        SubGroupsMap;
        CommonAxesMap;
        LookUpTableRecordLayoutMap;
        ArrayLayout;
        HWDeviceType;
        Endianess;
        IsCppInterface;
        IsAutosarCompliant;
        AdditionalCalibrationAttributesMap;
        LUTInfoMap;
        CompuMethodValidationMap;



        ObjectsWithInvalDataTypeForBitmask;

        LutWithParamObj;
        AxisNameToAliasAxisNameMap;




        CategoryToObjectsMap;


        CustomizeGroupsByType;
        ObjectsWithInvalidDataType;
        DataTypeToCompuMethodFormatMap;

        AdditionalCalibrationAttributesValues;


        RecordLayoutsofDataTypeMap;

        Support64bitIntegers;
        SupportStructureElements;
        CalibrationValuesCache;

        MeasurementValuesCache;

        IsAdaptiveAutosarSTF;
        IsAutosarSTF;
        IncludeAUTOSARElements;
        FunctionMap;

        PeriodicEventList;
        IncludeDefaultEventList;
        IncludeAllRecordLayouts;
        IncludeComments;
        IncludeUserCustomizationObj;
        EcuAddressExtension;
        ToggleArrayLayout;
        MapFile;
        Folder;
        FileName;
        ModelClassInstanceName;
        GenerateXCPInfo;
        Version;
        IndentFile;
        UseSavedSettings;

    end

    methods(Access=public,Hidden=true)



        function this=Data(modelName)
            this.CompuMethodsMap=containers.Map;
            this.ParametersMap=containers.Map;
            this.SignalsMap=containers.Map;
            this.CompuVtabsMap=containers.Map;
            this.RecordLayoutsMap=containers.Map;
            this.GroupsMap=containers.Map;
            this.SubGroupsMap=containers.Map;
            this.CommonAxesMap=containers.Map;
            this.LookUpTableRecordLayoutMap=containers.Map;
            this.DataTypeToCompuMethodFormatMap=containers.Map;
            this.AdditionalCalibrationAttributesValues=struct('export',1,'calibrationAccess',[],'compuMethodName',[],...
            'displayIdentifier',[],'format',[],'export2DArrayAsFixAxis',[],'xAxisLabels',[],'yAxisLabels',[],'bitMask',[]);
            this.RecordLayoutsofDataTypeMap=containers.Map;
            this.ModelName=modelName;
            this.IsCppInterface=Simulink.CodeMapping.isCppClassInterface(modelName);
            this.IsAutosarCompliant=Simulink.CodeMapping.isAutosarCompliant(modelName);
            this.AdditionalCalibrationAttributesMap=containers.Map;
            this.LUTInfoMap=containers.Map;
            this.CompuMethodValidationMap=containers.Map;
            this.ObjectsWithInvalDataTypeForBitmask='';
            this.LutWithParamObj='';
            this.AxisNameToAliasAxisNameMap=containers.Map;
            this.CategoryToObjectsMap=containers.Map;
            this.CustomizeGroupsByType='';
            this.ObjectsWithInvalidDataType='';
            this.Support64bitIntegers=true;
            this.SupportStructureElements=true;
            this.CalibrationValuesCache=containers.Map;
            this.MeasurementValuesCache=containers.Map;
            this.IsAdaptiveAutosarSTF=Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName);
            this.IsAutosarSTF=Simulink.CodeMapping.isAutosarSTF(modelName);
            this.IncludeAUTOSARElements=false;
            this.FunctionMap=containers.Map;
            this.IncludeDefaultEventList=true;
            this.IncludeAllRecordLayouts=false;
            this.IncludeComments=true;
            this.IncludeUserCustomizationObj='';
            this.EcuAddressExtension=32768;
            this.ToggleArrayLayout=false;
            this.MapFile='';
            this.Folder='';
            this.ModelClassInstanceName='';
            this.GenerateXCPInfo=true;
            this.Version='';
            this.IndentFile=false;
            this.UseSavedSettings=false;
            this.FileName='';
        end
    end


end


