function code2req(sid,reqId)



    if ischar(sid)&&any(sid=='|')&&sid(1)=='<'

        [block,rem]=strtok(sid,'|');
        if contains(sid,'.m>')

            fileName=block;
            fileName(fileName=='<'|fileName=='>')=[];

            dataLinkSet=slreq.utils.getLinkSet(fileName,'linktype_rmi_matlab',false);
            if isempty(dataLinkSet)
                slreq.utils.loadLinkSet(fileName);
            end
            sid=[fileName,rem];
        else

            [sysNum,subSysId]=strtok(block,':');
            sid=Simulink.ID.getSID(sysNum);
            sid=[sid,subSysId,rem];
        end
    end
    reqs=rmi('codereqs',sid);
    if isempty(reqs)

        return;
    end
    act_id=loc_getActualReqId(reqId,reqs);
    rtwprivate('code2req',sid,act_id);
end



function out=loc_getActualReqId(reqId,reqs)
    nNonLinkedIds=0;
    for i=1:length(reqs)
        if~reqs(i).linked
            nNonLinkedIds=nNonLinkedIds+1;
        elseif i-nNonLinkedIds==reqId
            out=i;
            return;
        end
    end
    out=str2double(reqId);
end


