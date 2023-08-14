function ret=evalSyncMATLABPlugin(fnName,jsonStr)
    try
        msg=jsondecode(jsonStr);
        ret=['"',feval(fnName,msg),'"'];
    catch ME
        ret=['"error":',ME.message];
    end
end