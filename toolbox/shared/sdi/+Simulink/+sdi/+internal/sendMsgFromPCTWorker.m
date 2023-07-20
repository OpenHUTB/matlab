function sendMsgFromPCTWorker(msg,copyDMR,eng)




    if nargin<3
        eng=Simulink.sdi.Instance.engine;
    end
    if~isempty(eng.PCTDataQueueFromWorker)
        msg=locAttachWorkerInfo(msg,eng);
        if copyDMR
            msg=locAddDMRCopyToMsg(msg);
        end
        send(eng.PCTDataQueueFromWorker,msg);



        if strcmpi(msg.Type,'update_runs')
            Simulink.sdi.internal.getSetWorkerRunSentToClient(true);
        end
    end
end


function msg=locAttachWorkerInfo(msg,eng)
    msg.InstanceID=getInstanceID(eng.sigRepository);
    msg.DMRPath=getSource(eng);
    msg.DMRData=[];
    msg.HostName='';
    msg.TaskName='';
    msg.TaskID=0;


    w=getCurrentWorker();
    if isprop(w,'Host')
        msg.HostName=w.Host;
    elseif isprop(w,'Name')
        msg.HostName=w.Name;
    end


    t=getCurrentTask();
    if~isempty(t)
        msg.TaskID=double(t.ID);
        msg.TaskName=t.Name;
    end
end


function msg=locAddDMRCopyToMsg(msg)
    c=getCurrentCluster();
    bIsLocalPool=isa(c,'parallel.cluster.Local');
    if bIsLocalPool

        newPath=[tempname,'.dmr'];
        status=copyfile(msg.DMRPath,newPath);
        assert(status);
        msg.DMRPath=newPath;
        msg.IsDMRTemporary=true;
    else
        fid=fopen(msg.DMRPath);
        msg.DMRData=fread(fid,'uint8');
        fclose(fid);
    end
end
