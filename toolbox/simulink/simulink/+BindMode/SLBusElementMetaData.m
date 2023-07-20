
classdef SLBusElementMetaData<BindMode.BindableMetaData

    properties(SetAccess=protected,GetAccess=public)
        blockPathStr char;
        hierarchicalPathArr(1,:)cell;
        outputPortNumber single;
        id char;
        parentId char;
        tooltip char;
    end
    methods
        function metaData=SLBusElementMetaData(varargin)
            if nargin==1

                metaDataStruct=varargin{1};
                signalName=metaDataStruct.name;
            else
                signalName=varargin{1};
                metaDataStruct=varargin{2};
            end
            metaData.name=signalName;
            metaData.blockPathStr=metaDataStruct.blockPathStr;
            metaData.hierarchicalPathArr=metaDataStruct.hierarchicalPathArr;
            metaData.outputPortNumber=metaDataStruct.outputPortNumber;


            leafPath=char(signalName);
            indx=strfind(leafPath,'.');
            leafPath=leafPath(indx(1)+1:end);

            metaData.id=['busElem',':',metaData.hierarchicalPathArr{1},':',num2str(metaData.outputPortNumber),':',leafPath];
            metaData.parentId=['sig',':',metaData.hierarchicalPathArr{1},':',num2str(metaData.outputPortNumber)];
            metaData.tooltip=signalName;
        end
    end
end