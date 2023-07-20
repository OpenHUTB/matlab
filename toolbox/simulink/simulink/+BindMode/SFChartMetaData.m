

classdef SFChartMetaData<BindMode.BindableMetaData

    properties(SetAccess=protected,GetAccess=public)
        localPath char;
        hierarchicalPathArr(1,:)cell;
        sid char;
        activityType char;
        id char;
        tooltip char;
    end
    methods
        function metaData=SFChartMetaData(varargin)
            if nargin==1

                metaDataStruct=varargin{1};
                metaData.name=metaDataStruct.name;
                metaData.sid=metaDataStruct.sid;
                metaData.localPath=metaDataStruct.localPath;
                metaData.hierarchicalPathArr=metaDataStruct.hierarchicalPathArr;
                metaData.activityType=metaDataStruct.activityType;
            else
                metaData.name=varargin{1};
                metaData.localPath=varargin{2};
                metaData.sid=varargin{3};
                metaData.hierarchicalPathArr=BindMode.utils.getSFHierarchicalPathArray(metaData.localPath,true);
                metaData.activityType=varargin{4};
            end
            metaData.id=['chart',':',metaData.hierarchicalPathArr{1},':',metaData.activityType];
            metaData.tooltip=[metaData.hierarchicalPathArr{1},'(',metaData.activityType,')'];
        end
    end
end