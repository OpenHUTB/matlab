classdef Location<handle















































    properties(SetAccess={?coder.ScreenerInfo})
        StartIndex double=0
        EndIndex double=0
    end

    properties(Access={?coder.ScreenerInfo})
        StartLine double=0
        StartColumn double=0
        EndLine double=0
        EndColumn double=0
    end

    methods(Access={?codergui.internal.CodegenInfoBuilder,?coder.Function,?coder.Message,?coder.ScreenerInfo,?coder.CallSite})
        function obj=Location(startIndex,endIndex,startLine,startColumn,...
            endLine,endColumn)
            if nargin==0
                return
            end
            narginchk(6,6);
            obj.StartIndex=startIndex;
            obj.EndIndex=endIndex;
            obj.StartLine=startLine;
            obj.StartColumn=startColumn;
            obj.EndLine=endLine;
            obj.EndColumn=endColumn;
        end

        function setLocation(obj,idx,lines,columns)
            obj.StartIndex=idx(1);
            obj.EndIndex=idx(2);
            obj.StartLine=lines(1);
            obj.EndLine=lines(2);
            obj.StartColumn=columns(1);
            obj.EndColumn=columns(2);
        end

        function setLocationByCopy(obj,aOtherLocation)
            obj.StartIndex=aOtherLocation.StartIndex;
            obj.EndIndex=aOtherLocation.EndIndex;
            obj.StartLine=aOtherLocation.StartLine;
            obj.EndLine=aOtherLocation.EndLine;
            obj.StartColumn=aOtherLocation.StartColumn;
            obj.EndColumn=aOtherLocation.EndColumn;
        end
    end

    methods
        function[startLocation,endLocation]=getLineColumn(obj)
            startLocation=struct('Line',{obj.StartLine},'Column',{obj.StartColumn});
            endLocation=struct('Line',{obj.EndLine},'Column',{obj.EndColumn});
        end
    end
end
