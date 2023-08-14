
classdef(ConstructOnLoad)ItemSelectedEvent<event.EventData
    properties

Index
Data
        AttributeName=''
    end

    methods
        function this=ItemSelectedEvent(idx,varargin)
            this.Index=idx;
            if nargin>1
                this.Data=varargin{1};
            end
            if nargin>2
                this.AttributeName=varargin{2};
            end
        end
    end
end