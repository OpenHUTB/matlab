classdef FeedFactory<handle




    methods
        function feedObj=createFeed(self,Type,varargin)
            switch Type
            case 'feed'
                feedObj=em.internal.pcbDesigner.Feed(varargin{:});
            end
        end
    end
end
