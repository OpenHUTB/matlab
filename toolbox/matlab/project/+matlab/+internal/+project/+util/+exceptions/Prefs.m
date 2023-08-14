
classdef Prefs<handle

    methods(Access=public,Static)
        function shorten=ShortenStacks(varargin)
            narginchk(0,1)
            persistent shortenStacks;

            if(isempty(shortenStacks))
                shortenStacks=true;
            end

            if(nargin==1)
                shortenStacks=varargin{1};
            end

            shorten=shortenStacks;
        end

    end

end

