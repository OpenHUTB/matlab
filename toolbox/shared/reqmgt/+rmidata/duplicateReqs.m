function[fromExt,toExt]=duplicateReqs(objH,modelH,isSf,fromKey,extraArg)

    if nargin<5
        extraArg='';
    end

    dstIsExternal=rmidata.isExternal(modelH);

    fromExt=false;
    toExt=false;

    if~isSf
        if isCutPasteOrUndo(objH,fromKey)
            return;
        elseif is_an_implicit_link(objH)
            return;
        elseif rmisl.is_signal_builder_block(objH)
            isSigBuilder=true;
        else
            isSigBuilder=false;
        end
    else
        isSigBuilder=false;
    end

    reqStr=getEmbeddedReqString(objH,isSf);

    if~isempty(fromKey)&&hasExternalData(fromKey)
        [reqs,grps]=rmidata.getDataForSid(fromKey,isSigBuilder);
        if~isempty(reqs)
            fromExt=true;
        end
    else
        if isempty(reqStr)
            if~dstIsExternal
                return;
            else
                reqs=[];
            end
        else
            reqs=rmi.parsereqs(reqStr);
        end

        if isSigBuilder
            if isempty(reqs)
                grps=[];
            else
                blkInfo=rmisl.sigb_get_info(objH);
                grps=rmidata.convertSigbGrpInfo(blkInfo,length(reqs));
                if isempty(grps)
                    grps=ones(length(reqs),1);
                else


                    [reqs,grps]=excludeSurrogateLinks(reqs,grps);
                end
            end
        end
    end

    if~isempty(reqs)
        isSlLink=strcmp({reqs.reqsys},'linktype_rmi_simulink');
        if any(isSlLink)
            if~fromExt&&~isempty(fromKey)
                srcMdl=strtok(fromKey,':');
                reqs(isSlLink)=rmisl.intraLinksResolve(reqs(isSlLink),srcMdl);
            end
            if~dstIsExternal
                reqs(isSlLink)=rmisl.intraLinksTrim(reqs(isSlLink),get_param(modelH,'Name'));
            end
        end
    end

    if dstIsExternal
        if isSigBuilder&&~isempty(grps)
            toExt=rmidata.objCopy(objH,reqs,modelH,false,grps);
        else
            toExt=rmidata.objCopy(objH,reqs,modelH,isSf,extraArg);
        end

        if~isempty(reqStr)
            rmi.setRawReqs(objH,isSf,'',modelH);
        end
    else
        reqStr=rmi.reqs2str(reqs);
        hadReqInfo=strcmp(get_param(modelH,'HasReqInfo'),'on');
        rmi.objCopy(objH,reqStr,modelH,isSf);
        if~hadReqInfo&&~isempty(reqs)
            rmi_sl_callback('markForMigration',modelH);
        end
        if isSigBuilder
            blkInfo=rmisl.sigb_get_info(objH);
            blkInfo.groupReqCnt=rmidata.convertSigbGrpInfo(blkInfo.groupCnt,grps);
            blkInfo.blockH=objH;
            rmisl.sigb_write_info(blkInfo);
        end
    end
end


function reqStr=getEmbeddedReqString(objH,isSf)

    if isSf
        reqStr=sf('get',objH,'.requirementInfo');
    else
        reqStr=get_param(objH,'requirementInfo');
    end
end


function isImplicit=is_an_implicit_link(blockH)
    parentH=get_param(get_param(blockH,'parent'),'handle');
    if~strcmp(get_param(parentH,'type'),'block_diagram')&&...
        (~isempty(get_param(parentH,'referenceblock'))||~isempty(get_param(parentH,'templateblock')))
        isImplicit=true;
    else
        isImplicit=false;
    end
end


function result=hasExternalData(srcKey)

    srcModelName=strtok(srcKey,':');
    try
        srcModelH=get_param(srcModelName,'Handle');
        result=rmidata.bdHasExternalData(srcModelH,true);
    catch ME %#ok<NASGU>
        warning(message('Slvnv:rmidata:duplicateReqs:DataNotLoaded',srcModelName));
        result=false;
    end
end


function[reqs,grps]=excludeSurrogateLinks(reqs,grps)
    if any(~[reqs.linked])
        grps=grps([reqs.linked]);
        reqs=reqs([reqs.linked]);
    end
end


function yesno=isCutPasteOrUndo(objH,fromKey)
    if isempty(fromKey)
        yesno=false;
    else
        try
            srcH=Simulink.ID.getHandle(fromKey);
            yesno=(objH==srcH);
        catch ex %#ok<NASGU>


            yesno=false;
            return;
        end
    end
end

