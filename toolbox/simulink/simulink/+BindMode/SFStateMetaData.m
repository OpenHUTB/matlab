

classdef SFStateMetaData<BindMode.BindableMetaData

    properties(SetAccess=protected,GetAccess=public)
        localPath char;
        hierarchicalPathArr(1,:)cell;
        sid char;
        activityType char;
        id char;
        tooltip char;
    end
    methods
        function metaData=SFStateMetaData(varargin)
            if nargin==1

                metaDataStruct=varargin{1};
                metaData.name=metaDataStruct.name;
                metaData.sid=metaDataStruct.sid;
                metaData.localPath=metaDataStruct.localPath;
                metaData.hierarchicalPathArr=metaDataStruct.hierarchicalPathArr;
                metaData.activityType=metaDataStruct.activityType;
            else
                metaData.name=varargin{1};
                metaData.sid=varargin{2};
                stateHandle=Simulink.ID.getHandle(metaData.sid);
                localPath=get(stateHandle,'Path');
                metaData.localPath=localPath;
                metaData.hierarchicalPathArr=BindMode.utils.getSFHierarchicalPathArray(localPath,true);
                metaData.activityType=varargin{3};
            end
            stateName=get(Simulink.ID.getHandle(metaData.sid),'Name');
            metaData.id=['state',':',metaData.hierarchicalPathArr{1},'/',stateName,':',metaData.activityType];
            metaData.tooltip=[metaData.hierarchicalPathArr{1},'/',stateName,'(',metaData.activityType,')'];
        end
    end
end