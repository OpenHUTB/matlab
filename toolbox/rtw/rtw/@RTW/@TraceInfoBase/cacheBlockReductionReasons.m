function cacheBlockReductionReasons(h)





    if isempty(h.ReuseMap)
        h.cacheReuseInfo;
    end




    reducedBlockMap=containers.Map;
    if~isempty(h.ReducedBlocks)
        tmpReducedBlocks=h.ReducedBlocks;
        if iscell(tmpReducedBlocks)
            for i=1:numel(tmpReducedBlocks)
                reducedBlockMap(tmpReducedBlocks{i}.Name)=tmpReducedBlocks{i}.Comment;
            end
        else
            for i=1:numel(tmpReducedBlocks)
                reducedBlockMap(tmpReducedBlocks(i).Name)=tmpReducedBlocks(i).Comment;
            end
        end
    end

    reasonMap=containers.Map;
    tmp_reuse_map=h.ReuseMap;
    tmp_reuse_info=h.ReuseInfo;
    tmp_system_map=h.SystemMap;
    mergedRegistry=h.getRegistry;

    if isa(h,'RTW.TraceInfo')
        rptInfo=h.getReportInfo;
    else
        rptInfo=[];
    end
    for regIdx=1:numel(mergedRegistry)
        reg=mergedRegistry(regIdx);
        if~isempty(reg.location)||reasonMap.isKey(reg.sid)
            continue;
        end

        msgId='';
        comment='';

        if strfind(reg.pathname,'''')
            msgId='RTW:traceInfo:illegalCharacter';
            comment=DAStudio.message('RTW:traceInfo:illegalCharacterShort','''');
        end

        rtwname=strrep(reg.rtwname,newline,' ');
        if reducedBlockMap.isKey(rtwname)
            msgId='RTW:traceInfo:reducedBlock';
            comment=reducedBlockMap(rtwname);
        end

        if isempty(msgId)




            sysnum=sscanf(reg.rtwname,'<S%d>');
            if~isempty(sysnum)

                index=sysnum+1;
                while index>1
                    reuseInfoIndex=tmp_reuse_map(index);
                    if reuseInfoIndex~=0
                        if reuseInfoIndex>0
                            msgId='RTW:traceInfo:reusableFunction';
                            comment=tmp_reuse_info(reuseInfoIndex).ReuseFlag;
                        end
                        break
                    end
                    assert(isempty(tmp_system_map(index).parent)||tmp_system_map(index).parent<sysnum+1);
                    index=tmp_system_map(index).parent;
                end
            end
        end
        if isempty(msgId)&&isa(Simulink.ID.getHandle(reg.sid),'Stateflow.Object')
            msgId='RTW:traceInfo:optimizedSfObject';
            [sfType,~]=RTW.getSfTypeName(reg.pathname);
            comment=DAStudio.message('RTW:traceInfo:optimizedSfObjectShort',sfType);
        end

        if~rtw.report.ReportInfo.featureReportV2
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
        else

            if isempty(msgId)
                try
                    isVirtual=strcmp(get_param(reg.pathname,'Virtual'),'on');
                    if isVirtual
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
                catch
                end
            end
        end


        if isempty(msgId)
            [msgId,comment]=getTargetLanguageSpecificReason(h,reg,rptInfo);
        end

        if isempty(msgId)
            msgId='RTW:traceInfo:notTraceable';
            comment=DAStudio.message('RTW:traceInfo:notTraceableShort');
        end

        reason.msgId=msgId;
        reason.comment=comment;

        reasonMap(reg.sid)=reason;
    end

    h.BlockReductionReasons=reasonMap;
    h.ReductionReasonIsCached=true;


