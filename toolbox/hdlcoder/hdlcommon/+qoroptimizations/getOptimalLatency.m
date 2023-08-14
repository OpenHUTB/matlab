function optimalLatency=getOptimalLatency(criticalPathSet,varargin)



    if(nargin>1)
        pp=varargin{1};
    else
        pp=[];
    end

    if(isempty(criticalPathSet))
        optimalLatency=0;
    elseif(~isempty(pp))
        for i=1:length(criticalPathSet)
            if(~isempty(criticalPathSet(i).cp))
                dll=[];
                lastL=0;
                for j=1:length(criticalPathSet(i).cp)
                    curS=qoroptimizations.retrieveSignal(j,criticalPathSet(i).cp,pp);
                    if(qoroptimizations.isValidInsertionPoint(curS)||j==length(criticalPathSet(i).cp))
                        dll(end+1)=criticalPathSet(i).cp(j).latency-lastL;
                        lastL=criticalPathSet(i).cp(j).latency;
                    end
                end
                if(lastL==0)
                    lat(i)=criticalPathSet(i).cp(end).latency;
                else
                    lat(i)=max([dll,0]);
                end
            else
                lat(i)=0;
            end
        end
        optimalLatency=max(lat);
    else
        for i=1:length(criticalPathSet)
            ll=[0,criticalPathSet(i).cp.latency];
            dll=ll(2:end)-ll(1:end-1);
            lat(i)=max([dll,0]);
        end
        optimalLatency=max(lat);
    end
end
