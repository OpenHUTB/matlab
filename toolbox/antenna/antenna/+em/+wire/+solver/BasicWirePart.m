classdef(Abstract)BasicWirePart<matlab.mixin.SetGet&...
    matlab.mixin.Heterogeneous&matlab.mixin.Copyable
    properties(Abstract)
PrevParts
NextParts
AffectedByOtherPartsZ




AffectingOtherPartsZ




Medium

MatchingPoints
    end

    methods(Abstract,Access=protected)
        PopulateEMSolution(obj)
    end

    methods(Abstract,Hidden)
        UpdatePartData(obj)
    end

    methods(Sealed)


        function varargout=eq(obj,varargin)
            [varargout{1:nargout}]=...
            eq@matlab.mixin.SetGet(obj,varargin{:});
        end
        function varargout=ne(obj,varargin)
            [varargout{1:nargout}]=...
            ne@matlab.mixin.SetGet(obj,varargin{:});
        end
    end

end