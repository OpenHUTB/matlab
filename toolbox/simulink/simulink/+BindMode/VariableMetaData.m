

classdef VariableMetaData<BindMode.BindableMetaData

    properties(SetAccess=protected,GetAccess=public)
        workspaceTypeStr char;
        blockPathStr char;
        hierarchicalPathArr(1,:)cell;
        id char;
        tooltip char;
        enableInputField logical=false;
    end
    properties
        inputValue char;
    end
    properties(Hidden)
        workspaceType BindMode.VarWorkspaceTypeEnum;
    end
    methods
        function metaData=VariableMetaData(varargin)
            if nargin==1

                metaDataStruct=varargin{1};
                metaData.name=metaDataStruct.name;
                metaData.workspaceType=BindMode.VarWorkspaceTypeEnum.getEnumTypeFromStr(metaDataStruct.workspaceTypeStr);
                metaData.workspaceTypeStr=metaDataStruct.workspaceTypeStr;
                metaData.blockPathStr=metaDataStruct.blockPathStr;
                metaData.hierarchicalPathArr=metaDataStruct.hierarchicalPathArr;
                if isfield(metaDataStruct,'enableInputField')
                    metaData.enableInputField=metaDataStruct.enableInputField;
                end
                if isfield(metaDataStruct,'inputValue')
                    metaData.inputValue=metaDataStruct.inputValue;
                end
            else
                varName=varargin{1};
                workspaceType=varargin{2};
                blockPathStr=varargin{3};
                metaData.name=varName;
                metaData.workspaceType=workspaceType;
                metaData.workspaceTypeStr=metaData.workspaceType.sourceName;
                metaData.blockPathStr=blockPathStr;
                metaData.hierarchicalPathArr=BindMode.utils.getHierarchicalPathArray(blockPathStr,true);
                if nargin>=4
                    metaData.enableInputField=varargin{4};
                end
                if nargin>=5
                    metaData.inputValue=varargin{5};
                end
            end
            metaData.id=['var',':',metaData.name,':',metaData.workspaceTypeStr];
            metaData.tooltip=[metaData.name,'(',metaData.workspaceTypeStr,' workspace',')'];
        end
    end
end