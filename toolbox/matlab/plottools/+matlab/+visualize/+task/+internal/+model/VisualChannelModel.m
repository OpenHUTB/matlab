classdef(Hidden)VisualChannelModel<matlab.mixin.Copyable






    properties
Name
Type
Description
        hasTuple(1,1)logical
        IsRequired(1,1)logical
        HasMultiple(1,1)logical
        DataMapped char='select variable'
        ConfigurationName string=string.empty
        MappedRow=[]
        CustomValidationFcn=[]
        KeyType string
    end

    methods(Access=protected)
        function cp=copyElement(obj)
            cp=copyElement@matlab.mixin.Copyable(obj);
            cp.DataMapped='select variable';
            cp.MappedRow=[];
        end
    end

    methods
        function obj=VisualChannelModel(name,description)
            if nargin>0
                obj.Name=name;
                obj.Description=description;
            end
        end


        function deserializeVisualChannels(obj,channelStruct)
            obj.Name=channelStruct.Name;
            obj.MappedRow=channelStruct.MappedRow;
            obj.Type=channelStruct.Type;
            obj.Description=channelStruct.Description;
            obj.hasTuple=channelStruct.hasTuple;
            obj.IsRequired=channelStruct.IsRequired;
            obj.HasMultiple=channelStruct.HasMultiple;
            obj.DataMapped=channelStruct.DataMapped;
            if isfield(channelStruct,'ConfigurationName')
                obj.ConfigurationName=channelStruct.ConfigurationName;
            end
            obj.KeyType=channelStruct.KeyType;
            obj.CustomValidationFcn=channelStruct.CustomValidationFcn;
        end

        function updateMappedDataAndCachedRow(obj,rowData)
            obj.MappedRow=rowData;
            obj.DataMapped=rowData.VariableName;
        end
    end
end