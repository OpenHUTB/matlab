

classdef SLPortMetaData<BindMode.BindableMetaData

    properties(SetAccess=protected,GetAccess=public)
        blockPathStr char;
        hierarchicalPathArr(1,:)cell;
        portType char;
        portNumber single;
        id char;
        tooltip char;
    end
    methods
        function metaData=SLPortMetaData(varargin)
            if nargin==1

                metaDataStruct=varargin{1};
                metaData.name=metaDataStruct.name;
                metaData.blockPathStr=metaDataStruct.blockPathStr;
                metaData.hierarchicalPathArr=metaDataStruct.hierarchicalPathArr;
                metaData.portType=metaDataStruct.portType;
                metaData.portNumber=metaDataStruct.portNumber;
            else
                blockPathStr=varargin{1};
                portType=varargin{2};
                portNumber=varargin{3};
                blockName=get_param(blockPathStr,'Name');
                if(strcmpi(portType,'inport')||strcmpi(portType,'outport'))
                    metaData.name=[blockName,':(',portType,'):',num2str(portNumber)];
                else
                    metaData.name=[blockName,':(',portType,')'];
                end
                metaData.blockPathStr=blockPathStr;
                metaData.hierarchicalPathArr=BindMode.utils.getHierarchicalPathArray(blockPathStr,true);
                metaData.portType=portType;
                metaData.portNumber=portNumber;
            end
            if(strcmpi(portType,'inport')||strcmpi(portType,'outport'))
                metaData.id=['port',':',metaData.hierarchicalPathArr{1},':(',metaData.portType,'):',num2str(metaData.portNumber)];
                metaData.tooltip=[metaData.hierarchicalPathArr{1},':(',metaData.portType,'):',num2str(metaData.portNumber)];
            else
                metaData.id=['port',':',metaData.hierarchicalPathArr{1},':(',metaData.portType,')'];
                metaData.tooltip=[metaData.hierarchicalPathArr{1},':(',metaData.portType,')'];
            end
        end
    end
end