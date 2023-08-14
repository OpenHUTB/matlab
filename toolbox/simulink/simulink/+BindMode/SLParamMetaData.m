

classdef SLParamMetaData<BindMode.BindableMetaData

    properties(SetAccess=protected,GetAccess=public)
        blockPathStr char;
        hierarchicalPathArr(1,:)cell;
        id char;
        tooltip char;
        enableInputField logical=false;
    end
    properties
        inputValue char;
    end
    methods
        function metaData=SLParamMetaData(varargin)
            if nargin==1

                metaDataStruct=varargin{1};
                metaData.name=metaDataStruct.name;
                metaData.blockPathStr=metaDataStruct.blockPathStr;
                metaData.hierarchicalPathArr=metaDataStruct.hierarchicalPathArr;
                if isfield(metaDataStruct,'enableInputField')
                    metaData.enableInputField=metaDataStruct.enableInputField;
                end
                if isfield(metaDataStruct,'inputValue')
                    metaData.inputValue=metaDataStruct.inputValue;
                end
            else
                paramName=varargin{1};
                blockPathStr=varargin{2};
                metaData.name=paramName;
                metaData.blockPathStr=blockPathStr;
                metaData.hierarchicalPathArr=BindMode.utils.getHierarchicalPathArray(blockPathStr,true);
                if nargin>=3
                    metaData.enableInputField=varargin{3};
                end
                if nargin>=4
                    metaData.inputValue=varargin{4};
                end
            end
            metaData.id=['param',':',metaData.name,':',metaData.hierarchicalPathArr{1}];
            metaData.tooltip=[metaData.hierarchicalPathArr{1},':',metaData.name];
        end
    end
end