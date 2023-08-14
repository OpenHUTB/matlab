

classdef SLSignalMetaData<BindMode.BindableMetaData

    properties(SetAccess=protected,GetAccess=public)
        blockPathStr char;
        hierarchicalPathArr(1,:)cell;
        outputPortNumber single;
        id char;
        tooltip char;
    end
    methods
        function metaData=SLSignalMetaData(varargin)
            if nargin==1

                metaDataStruct=varargin{1};
                metaData.name=metaDataStruct.name;
                metaData.blockPathStr=metaDataStruct.blockPathStr;
                metaData.hierarchicalPathArr=metaDataStruct.hierarchicalPathArr;
                metaData.outputPortNumber=metaDataStruct.outputPortNumber;
                if(isempty(metaData.name))

                    blockName=get_param(metaData.blockPathStr,'Name');
                    metaData.name=[blockName,':',num2str(metaData.outputPortNumber)];
                end
            else
                signalName=varargin{1};
                blockPathStr=varargin{2};
                outputPortNumber=varargin{3};
                if(~isempty(signalName))
                    metaData.name=signalName;
                else

                    blockName=get_param(blockPathStr,'Name');
                    metaData.name=[blockName,':',num2str(outputPortNumber)];
                end
                metaData.blockPathStr=blockPathStr;
                metaData.hierarchicalPathArr=BindMode.utils.getHierarchicalPathArray(blockPathStr,true);
                metaData.outputPortNumber=outputPortNumber;
            end
            metaData.id=['sig',':',metaData.hierarchicalPathArr{1},':',num2str(metaData.outputPortNumber)];
            metaData.tooltip=[metaData.hierarchicalPathArr{1},':',num2str(metaData.outputPortNumber)];
        end
    end
end