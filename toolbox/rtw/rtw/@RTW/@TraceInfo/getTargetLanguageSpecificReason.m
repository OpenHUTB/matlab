

function[msgId,comment]=getTargetLanguageSpecificReason(h,reg,reportInfo)


    msgId=[];
    comment=[];

    if~isempty(reportInfo)
        blockTracker=reportInfo.BlockTracker;
        comment=blockTracker.getSimulinkReductionReason(reg.sid);
        if~isempty(comment)
            msgId='RTW:traceInfo:SimulationReducedBlock';
        else
            if blockTracker.isCgirReducedBlock(reg.sid)
                msgId='RTW:traceInfo:CodeGenerationReducedBlock';
                comment=DAStudio.message('RTW:traceInfo:CodeGenerationReducedBlockShort');
            end
        end
    end


