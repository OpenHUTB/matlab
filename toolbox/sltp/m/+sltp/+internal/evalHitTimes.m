function evalHitTimes(modelName,nodeTitle,hitTimes)
    try
        hitTimes=sltp.internal.evalStringWithWorkspaceResolution(modelName,false,hitTimes);
    catch E
        if strcmp(E.identifier,'MATLAB:m_incomplete_statement')

            throw(MSLException([],message(...
            'SimulinkPartitioning:General:InvalidHitTimes',nodeTitle)));
        elseif strcmp(E.identifier,'MATLAB:UndefinedFunction')

            return;
        else
            throw(MSLException([],message(...
            'SimulinkPartitioning:General:InvalidHitTimes',nodeTitle)));
        end
    end
    sltp.internal.verifyHitTimes(hitTimes,nodeTitle);
end