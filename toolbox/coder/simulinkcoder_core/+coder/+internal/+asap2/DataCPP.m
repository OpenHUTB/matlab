classdef DataCPP<handle










    properties(Hidden,Access=public)
        ModelName;
        ParametersMap;
        SignalsMap;
        FunctionMap;
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
        CompuMethodValidationMap;



        ObjectsWithInvalDataTypeForBitmask;


        CategoryToObjectsMap;


        CustomizeGroupsByType;
        ObjectsWithInvalidDataType;
        AdditionalCalibrationAttributesValues;



        Support64bitIntegers;
        SupportStructureElements;
        PeriodicEventList;
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
        IncludeAUTOSARElements;
        IncludeDefaultEventList;
    end

    methods(Access=public)
        function this=DataCPP(DataStructFromBuild)
            this.CompuMethodsMap=DataStructFromBuild.CompuMethodsMap;
            this.ParametersMap=DataStructFromBuild.ParametersMap;
            this.FunctionMap=DataStructFromBuild.FunctionMap;
            this.SignalsMap=DataStructFromBuild.SignalsMap;
            this.CompuVtabsMap=DataStructFromBuild.CompuVtabsMap;
            this.RecordLayoutsMap=DataStructFromBuild.RecordLayoutsMap;
            this.GroupsMap=DataStructFromBuild.GroupsMap;
            this.SubGroupsMap=DataStructFromBuild.SubGroupsMap;
            this.CommonAxesMap=DataStructFromBuild.CommonAxesMap;
            this.LookUpTableRecordLayoutMap=DataStructFromBuild.LookUpTableRecordLayoutMap;
            this.ModelName=DataStructFromBuild.ModelName;
            this.IsCppInterface=Simulink.CodeMapping.isCppClassInterface(DataStructFromBuild.ModelName);
            this.IsAutosarCompliant=Simulink.CodeMapping.isAutosarCompliant(DataStructFromBuild.ModelName);
            this.ObjectsWithInvalDataTypeForBitmask='';
            this.CompuMethodValidationMap=DataStructFromBuild.CompuMethodValidationMap;
            this.ObjectsWithInvalDataTypeForBitmask=DataStructFromBuild.ObjectsWithInvalDataTypeForBitmask;
            this.CategoryToObjectsMap=DataStructFromBuild.CategoryToObjectsMap;
            this.CustomizeGroupsByType=DataStructFromBuild.CustomizeGroupsByType;
            this.ObjectsWithInvalidDataType=DataStructFromBuild.ObjectsWithInvalidDataType;
            this.Support64bitIntegers=DataStructFromBuild.Support64bitIntegers;
            this.SupportStructureElements=DataStructFromBuild.SupportStructureElements;
            this.ArrayLayout=DataStructFromBuild.ArrayLayout;
            this.HWDeviceType=DataStructFromBuild.HWDeviceType;
            this.Endianess=DataStructFromBuild.Endianess;
            this.PeriodicEventList=DataStructFromBuild.PeriodicEventList;
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
            this.IncludeAUTOSARElements=true;
            this.IncludeDefaultEventList=true;
        end
    end
end


