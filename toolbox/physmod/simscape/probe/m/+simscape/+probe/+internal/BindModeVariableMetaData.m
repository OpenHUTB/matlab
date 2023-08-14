classdef BindModeVariableMetaData<BindMode.BindableMetaData




    properties(SetAccess=protected,GetAccess=public)
        blockPathStr char;
        hierarchicalPathArr(1,:)cell;
        outputPortNumber single;
        id char;
        tooltip char;
    end
    methods
        function obj=BindModeVariableMetaData(varargin)
            if nargin==1

                in=varargin{1};
                obj.name=in.name;
                obj.blockPathStr=in.blockPathStr;
                obj.tooltip=in.tooltip;
                obj.hierarchicalPathArr=in.hierarchicalPathArr;
                obj.outputPortNumber=in.outputPortNumber;
            else

                obj.name=varargin{1};
                obj.blockPathStr=varargin{2};
                obj.tooltip=varargin{3};
                obj.outputPortNumber=0;
                obj.hierarchicalPathArr=BindMode.utils.getHierarchicalPathArray(obj.blockPathStr,true);
            end
            obj.id=['sig',':',obj.hierarchicalPathArr{1},':',num2str(obj.outputPortNumber)];
        end
    end
end