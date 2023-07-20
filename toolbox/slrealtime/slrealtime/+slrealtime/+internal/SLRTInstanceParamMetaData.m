

classdef SLRTInstanceParamMetaData<BindMode.BindableMetaData


    properties(SetAccess=protected,GetAccess=public)
        blockPathStr char;
        hierarchicalPathArr(1,:)cell;
        id char;
        tooltip char;

        instHierarchicalPathArr(1,:)cell;
    end
    properties
        inputValue char;
    end
    methods
        function metaData=SLRTInstanceParamMetaData(varargin)
            paramName=varargin{1};
            blockPath=varargin{2};
            metaData.instHierarchicalPathArr=varargin{3};
            metaData.name=paramName;
            metaData.blockPathStr=blockPath;
            metaData.hierarchicalPathArr=BindMode.utils.getHierarchicalPathArray(blockPath,true);

            metaData.id=['param',':',metaData.name,':',metaData.hierarchicalPathArr{1}];
            metaData.tooltip=[metaData.hierarchicalPathArr{1},':',metaData.name];
        end
    end
end