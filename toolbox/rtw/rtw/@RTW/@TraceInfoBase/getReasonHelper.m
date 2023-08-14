function reason=getReasonHelper(h,reg)




    if isempty(h.BlockReductionReasons)
        h.BlockReductionReasons=containers.Map;
    end
    if h.BlockReductionReasons.isKey(reg.sid)
        reason=h.BlockReductionReasons(reg.sid);
        return
    end
    reason=[];
    msgId='';
    comment='';

    if isempty(h.ReuseMap)
        h.cacheReuseInfo;
    end

    if strfind(reg.pathname,'''')
        msgId='RTW:traceInfo:illegalCharacter';
        comment=DAStudio.message('RTW:traceInfo:illegalCharacterShort','''');
    end

    rtwname=strrep(reg.rtwname,newline,' ');
    i=find(strcmp(h.ReducedBlocks,rtwname));
    if~isempty(i)
        msgId='RTW:traceInfo:reducedBlock';
        if iscell(h.ReducedBlocks{i})
            comment=h.ReducedBlocks{i}.Comment;
        else
            comment=h.ReducedBlocks(i).Comment;
        end
    end

    if isempty(msgId)




        sysnum=sscanf(reg.rtwname,'<S%d>');
        if~isempty(sysnum)

            index=sysnum+1;
            while index>1
                reuseInfoIndex=h.ReuseMap(index);
                if reuseInfoIndex~=0
                    if reuseInfoIndex>0
                        msgId='RTW:traceInfo:reusableFunction';
                        comment=h.ReuseInfo(reuseInfoIndex).ReuseFlag;
                    end
                    break
                end
                assert(isempty(h.SystemMap(index).parent)||h.SystemMap(index).parent<sysnum+1);
                index=h.SystemMap(index).parent;
            end
        end
    end
    if isempty(msgId)&&isa(Simulink.ID.getHandle(reg.sid),'Stateflow.Object')
        msgId='RTW:traceInfo:optimizedSfObject';
        [sfType,~]=RTW.getSfTypeName(reg.pathname);
        comment=DAStudio.message('RTW:traceInfo:optimizedSfObjectShort',sfType);
    end

    if isempty(msgId)&&isValidSlObject(slroot,reg.pathname)&&...
        strcmp(get_param(reg.pathname,'Virtual'),'on')
        blocktype=get_param(reg.pathname,'BlockType');
        msgId='RTW:traceInfo:virtualBlock';
        if strcmp(blocktype,'SubSystem')
            if isempty(get_param(reg.pathname,'Blocks'))
                comment=DAStudio.message('RTW:traceInfo:emptySubsystem');
            elseif strcmp(get_param(reg.pathname,'Mask'),'on')
                msgId='RTW:traceInfo:maskedSubSystem';
                comment=DAStudio.message('RTW:traceInfo:maskedSubsystem');
            else
                comment=DAStudio.message('RTW:traceInfo:virtualSubsystem');
            end
        else
            comment=blocktype;
        end
    end


    if isempty(msgId)

        if isa(h,'RTW.TraceInfo')
            rptInfo=h.getReportInfo;
        else
            rptInfo=[];
        end
        [msgId,comment]=getTargetLanguageSpecificReason(h,reg,rptInfo);
    end

    if isempty(msgId)
        msgId='RTW:traceInfo:notTraceable';
        comment=DAStudio.message('RTW:traceInfo:notTraceableShort');
    end

    reason.msgId=msgId;
    reason.comment=comment;
    h.BlockReductionReasons(reg.sid)=reason;


