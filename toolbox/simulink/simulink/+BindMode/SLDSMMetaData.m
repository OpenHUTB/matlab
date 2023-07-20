

classdef SLDSMMetaData<BindMode.BindableMetaData

    properties(SetAccess=protected,GetAccess=public)
        blockPathStr char;
        hierarchicalPathArr(1,:)cell;
        id char;
    end
    methods
        function metaData=SLDSMMetaData(varargin)
            if nargin==1

                metaDataStruct=varargin{1};
                metaData.name=metaDataStruct.name;
                metaData.blockPathStr=metaDataStruct.blockPathStr;
                metaData.hierarchicalPathArr=metaDataStruct.hierarchicalPathArr;
            else
                dsmName=varargin{1};
                blockPathStr=varargin{2};
                rwSourceBlockPath=varargin{3};
                metaData.name=dsmName;
                metaData.blockPathStr=blockPathStr;
                metaData.hierarchicalPathArr=BindMode.utils.getHierarchicalPathArray(blockPathStr,true);
                if~isempty(rwSourceBlockPath)
                    metaData.blockPathStr=rwSourceBlockPath;
                    metaData.hierarchicalPathArr{end}=rwSourceBlockPath;
                    metaData.hierarchicalPathArr{1}=strjoin(metaData.hierarchicalPathArr(2:end),'|');
                end
            end
            metaData.id=['dsm:',metaData.hierarchicalPathArr{1}];
        end
    end
end