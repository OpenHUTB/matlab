

classdef SFDataMetaData<BindMode.BindableMetaData

    properties(SetAccess=protected,GetAccess=public)
        localPath char;
        hierarchicalPathArr(1,:)cell;
        scope char;
        sid char;
        id char;
        tooltip char;
    end
    methods
        function metaData=SFDataMetaData(varargin)
            if nargin==1

                metaDataStruct=varargin{1};
                metaData.name=metaDataStruct.name;
                metaData.localPath=metaDataStruct.localPath;
                metaData.hierarchicalPathArr=metaDataStruct.hierarchicalPathArr;
                metaData.sid=metaDataStruct.sid;
                metaData.scope=metaDataStruct.scope;
            else
                metaData.name=varargin{1};
                metaData.sid=varargin{2};
                metaData.scope=varargin{3};
                dataObjHandle=Simulink.ID.getHandle(metaData.sid);
                localPath=get(dataObjHandle,'Path');
                metaData.localPath=localPath;
                metaData.hierarchicalPathArr=BindMode.utils.getSFHierarchicalPathArray(localPath,true);
            end
            metaData.id=['sfdata',':',metaData.hierarchicalPathArr{1},':',metaData.sid];
            metaData.tooltip=[metaData.hierarchicalPathArr{1},'/',metaData.name,'(',metaData.scope,')'];
        end
    end
end