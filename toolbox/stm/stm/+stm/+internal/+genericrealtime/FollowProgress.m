classdef FollowProgress

    methods(Static)


        function out=verboseLevel(in)
            persistent v;
            if nargin
                v=in;
            end
            out=v;
        end

        function progress(msg,varargin)
            persistent c;
            p=inputParser;
            addOptional(p,'clock',[]);
            addOptional(p,'level',1);
            parse(p,varargin{:});
            if(isempty(c))
                c=clock;
            else
                if(~isempty(p.Results.clock))
                    c=p.Results.clock;
                end
            end
            if stm.internal.genericrealtime.FollowProgress.verboseLevel>=p.Results.level
                str=sprintf('### [%6.2fs] ',etime(clock,c));
                msgrep=regexprep(msg,'\\','\\\\');
                str=[str,msgrep,'\n'];
                fprintf(str);
            end
        end
    end

end
