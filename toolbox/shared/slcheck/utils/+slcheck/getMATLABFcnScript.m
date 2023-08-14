
function script=getMATLABFcnScript(handle)
    script='';
    h=sf('IdToHandle',sfprivate('block2chart',handle));
    script=h.Script;

end

