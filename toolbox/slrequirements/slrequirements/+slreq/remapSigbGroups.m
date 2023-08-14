

















function remapSigbGroups(sigbH,remapIdx)


    src=slreq.utils.getRmiStruct(sigbH);
    needsRefresh=false;
    reqData=slreq.data.ReqData.getInstance();
    for i=1:length(remapIdx)
        if remapIdx(i)==i
            continue;
        else
            origId=sprintf('%s.%d',src.id,remapIdx(i));
            newId=sprintf('%s.%d',src.id,i);
            if any(remapIdx==i)
                reqData.swapSourceIds(src.artifact,origId,newId);
                return;
            else
                reqData.replaceSourceId(src.artifact,origId,newId);

                needsRefresh=true;
            end
        end
    end
    if needsRefresh


        vnv_panel_mgr('sbUpdateReq',sigbH);
    end
end
