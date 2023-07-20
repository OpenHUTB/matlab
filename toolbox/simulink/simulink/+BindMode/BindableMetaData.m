

classdef BindableMetaData<handle




    properties(SetAccess=protected,GetAccess=public)
        name char;
    end
    methods
        function metaData=BindableMetaData(varargin)
            if(nargin==1)
                metaData.name=varargin{1};
            end
        end
    end
end