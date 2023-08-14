function out=getReqInfoForObjects(obj,modelH,isSf)











    if rmidata.isExternal(modelH)
        out=cell(length(obj),1);
        for i=1:length(obj)
            reqs=rmidata.getReqs(obj(i));
            out{i}=rmi.reqs2str(reqs);
            if mod(i,100)==0&&~rmiut.progressBarFcn('isCanceled')
                rmiut.progressBarFcn('set',0.05+i/length(obj)/5,getString(message('Slvnv:rmiut:progressBar:SyncPleaseWait')));
            end
        end
    else
        if isSf
            sfReqStrMat=sf('get',obj,'.requirementInfo');
            out=cellstr(sfReqStrMat);
        else
            out=rmisl.cellGetParam(obj,'RequirementInfo');
        end
    end
end
