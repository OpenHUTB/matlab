function verifyHitTimes(hitTimes,partitionLink)
    ex=MSLException([],message('SimulinkPartitioning:General:InvalidHitTimes',...
    partitionLink));

    if~isa(hitTimes,'double')
        ex=ex.addCause(MSLException([],message(...
        'SimulinkPartitioning:General:InvalidHitTimesNotDouble')));


        throw(ex);
    end
    if~isreal(hitTimes)
        ex=ex.addCause(MSLException([],message(...
        'SimulinkPartitioning:General:InvalidHitTimesNotReal')));
    end
    if any(~isfinite(hitTimes))
        ex=ex.addCause(MSLException([],message(...
        'SimulinkPartitioning:General:InvalidHitTimesNotFinite')));
    end

    if~iscolumn(hitTimes)&&~isrow(hitTimes)
        ex=ex.addCause(MSLException([],message(...
        'SimulinkPartitioning:General:InvalidHitTimesNotVector')));
    end
    if any(diff(hitTimes)<0)
        ex=ex.addCause(MSLException([],message(...
        'SimulinkPartitioning:General:InvalidHitTimesNotMonotonic')));
    end

    if~isempty(ex.cause)
        throw(ex);
    end
end