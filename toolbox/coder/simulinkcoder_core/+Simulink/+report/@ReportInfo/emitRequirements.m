function emitRequirements(obj)
    mdlname=obj.getActiveModelName;
    try
        [slHs,sfHs]=rmi('getHandlesWithRequirements',mdlname);
    catch
        return
    end

    sids=cell(length(slHs)+length(sfHs));
    nSlHs=length(slHs);
    for i=1:nSlHs
        try
            sids{i}=Simulink.ID.getSID(slHs(i));
        catch
        end
    end
    sfRoot=Stateflow.Root;
    for i=1:length(sfHs)
        try
            sids{i+nSlHs}=Simulink.ID.getSID(sfRoot.idToHandle(sfHs(i)));
        catch
        end
    end

    filename=fullfile(obj.getReportDir,'requirements.js');
    fid=fopen(filename,'w','n','utf-8');
    fwrite(fid,sprintf('function ReqIDs() {\n'),'char');
    fwrite(fid,sprintf('\tthis.reqIds = new Array();\n'),'char');
    for i=1:length(sids)
        sid=sids{i};
        reqs=rmi('codereqs',sid);
        for j=1:length(reqs)
            try
                str=sprintf('\tthis.reqIds["%s,%d"] = {req_id: "%d"};\n',sid,j,loc_getActualReqId(j,reqs));
                fwrite(fid,str,'char');
            catch
            end
        end
    end
    fwrite(fid,sprintf('\tthis.getReqID = function(sid) { return this.reqIds[sid];}\n}\n'),'char');
    fwrite(fid,sprintf('ReqIDs.instance = new ReqIDs();\n'),'char');
    fclose(fid);
end
