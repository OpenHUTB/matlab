function newFigs=getNewFigures(varargin)


    try

        currFigs=handle(sort(double(findall(0,'type','figure'))));
        if(nargin==0)
            newFigs=currFigs;
        else
            oldFigs=varargin{1};
            [newFigs,ix]=setdiff(currFigs,oldFigs);

            [~,six]=sort(ix);
            newFigs=newFigs(six);
        end
    catch
        newFigs=[];
    end
end