function copyDisabled(objH,modelH,isSf,srcSID,skipEmpty)







    if rmidata.isExternal(modelH)
        toExt=true;
    else
        toExt=false;
    end

    if isempty(srcSID)
        fromExt=false;
        srcMdl='';
    else
        srcMdl=strtok(srcSID,':');
        try
            srcModelH=get_param(srcMdl,'Handle');
            if rmidata.isExternal(srcModelH)
                fromExt=true;
            else
                fromExt=false;
            end
        catch ME %#ok<NASGU>



            libPath=which(srcMdl);
            if~isempty(libPath)&&any(strcmp(libPath(end-3:end),{'.mdl','.slx'}))
                libReqs=rmimap.StorageMapper.getInstance.getStorageFor(libPath);
                if exist(libReqs,'file')==2
                    fromExt=true;


                    load_system(srcMdl);
                else
                    fromExt=false;
                end
            else
                fromExt=false;
            end
        end
    end


    if isSf
        isSigBuilder=false;
    elseif strcmp(get_param(objH,'MaskType'),'Sigbuilder block')
        isSigBuilder=true;
    else
        isSigBuilder=false;
    end


    if fromExt
        [reqs,grps]=rmidata.getDataForSid(srcSID,isSigBuilder);
    else
        reqStr=rmi.getRawReqs(objH,isSf);
        reqs=rmi.parsereqs(reqStr);
        grps=[];
        if~isempty(reqs)&&isSigBuilder
            blkInfo=rmisl.sigb_get_info(objH);
            grps=rmidata.convertSigbGrpInfo(blkInfo,length(reqs));
            if isempty(grps)
                grps=ones(length(reqs),1);
            end
        end
    end

    if isempty(reqs)
        if skipEmpty
            return;
        elseif~rmi.objHasReqs(objH,[])
            return;
        end
        isSlLink=[];
    else




        isSlLink=strcmp({reqs.reqsys},'linktype_rmi_simulink');
        if any(isSlLink)
            if~fromExt
                reqs(isSlLink)=rmisl.intraLinksResolve(reqs(isSlLink),srcMdl);
            end
            if~toExt
                reqs(isSlLink)=rmisl.intraLinksTrim(reqs(isSlLink),get_param(modelH,'Name'));
            end
        end
    end



    if toExt
        rmidata.setDataForSlObj(objH,reqs,grps);






        if~fromExt&&~isempty(reqs)
            setStructReqs(objH,isSf,modelH,[]);
        end
    else
        if fromExt
            if isSigBuilder


                sigbInfo=rmisl.sigb_get_info(objH);
                total_groups=sigbInfo.groupCnt;
                groupReqCnt=rmidata.convertSigbGrpInfo(total_groups,grps);
                setStructReqs(objH,false,modelH,reqs,-1,-1,groupReqCnt);
            else
                setStructReqs(objH,isSf,modelH,reqs);
            end
        else




            if any(isSlLink)
                setStructReqs(objH,isSf,modelH,reqs);
            end
        end





        if~isempty(reqs)&&strcmp(get_param(modelH,'hasReqInfo'),'off')
            rmidata.storageModeCache('mark_from_lib',modelH);
        end
    end



    if fromExt&&~skipEmpty&&~isempty(reqs)
        rmidata.setDataForSlObj(srcSID,[],grps);
    end
end


function setStructReqs(objH,isSf,modelH,structArray,varargin)


    reqstr=rmi.reqs2str(structArray);


    GUID=rmi.guidGet(objH);


    if isempty(reqstr)
        reqstr='{} ';
    end
    reqstr=[reqstr,' %',GUID];


    rmi.setRawReqs(objH,isSf,reqstr,modelH);

    if~isempty(varargin)
        vnv_panel_mgr('sbUpdateReq',objH,varargin{:});
    end

end
