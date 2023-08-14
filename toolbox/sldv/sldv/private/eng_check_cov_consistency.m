function status=eng_check_cov_consistency(modelH,testcomp)




    persistent lastMsg;

    status=true;

    if isempty(lastMsg)
        lastMsg=' ';
    end

    if nargin==0

        status=lastMsg;
        return;
    end

    lastMsg=' ';
    dbgLvl=slavteng('feature','DebugLevel');
    nonlinDetect=slavteng('feature','NonlinearAnalysis');

    if dbgLvl==0||nonlinDetect==1||~strcmp(testcomp.activeSettings.mode,'TestGeneration')
        return;
    end

    if Sldv.utils.isValidContainerMap(testcomp.analysisInfo.disabledCvIdInfo)&&...
        testcomp.analysisInfo.disabledCvIdInfo.length~=0
        return;
    end
    blocks=sldv_datamodel_get_modelobjects(testcomp);
    dvBlkCnt=length(blocks);
    dvBlkCvIds=zeros(1,dvBlkCnt);



    for blkIdx=1:dvBlkCnt
        mdlObj=blocks(blkIdx);

        slsfCvId=Sldv.CvApi.slsfId(mdlObj.emlFilePath,mdlObj.slBlkH,mdlObj.sfObjID);
        dvBlkCvIds(1,blkIdx)=slsfCvId;

        lastMsg=[lastMsg,check_decision_consistency(mdlObj,slsfCvId)];
        lastMsg=[lastMsg,check_condition_consistency(mdlObj,slsfCvId)];
        lastMsg=[lastMsg,check_mcdc_consistency(mdlObj,slsfCvId)];
    end


    cvBlkIds=find_cv_slsf_with_cov(modelH);
    missingCvIds=setdiff(cvBlkIds,dvBlkCvIds);
    for cvId=missingCvIds(:)'
        lastMsg=[lastMsg,missing_cov_object_warning(cvId)];
        status=false;
    end
end


function cvIds=find_cv_slsf_with_cov(modelH)
    cvIds=[];


    modelcov=get_param(modelH,'CoverageId');
    rootId=cv('get',modelcov,'.rootTree.child');
    [topCvId,topSlH]=cv('get',rootId,'.topSlsf','.topSlHandle');
    if(modelH==topSlH)
        cvIds=cv('DecendentsOf',topCvId);


        cvIdCnt=length(cvIds);
        removeIdx=false(1,cvIdCnt);
        for idx=1:cvIdCnt
            cvId=cvIds(idx);
            if(isempty(allDecisions(cvId))&&...
                isempty(allConditions(cvId))&&...
                isempty(allmcdcExprs(cvId)))
                removeIdx(idx)=true;
            end
        end

        cvIds(removeIdx)=[];
    end
end


function str=cv_id_description(cvId)

    cmd=sprintf('%s',['cv get ',num2str(cvId)]);
    str=evalc(cmd);
end

function msg=missing_cov_object_warning(cvId)
    cvDecIds=allDecisions(cvId);
    cvCondIds=allConditions(cvId);
    cvMCDCIds=allmcdcExprs(cvId);

    msg=getString(message('Sldv:eng_check_cov_consistency:DesignVerifierIsMissing',cv_id_description(cvId)));

    if~isempty(cvDecIds)
        decMsg=getString(message('Sldv:eng_check_cov_consistency:ThatContainsFollowingDecisions'));
        for decId=cvDecIds(:)'
            decMsg=sprintf('%s    %s\n',decMsg,Sldv.CvApi.getText(decId));
        end
        decMsg=sprintf('%s\n',decMsg);
    else
        decMsg='';
    end

    if~isempty(cvCondIds)
        condMsg=getString(message('Sldv:eng_check_cov_consistency:ThatContainsFollowingConditions'));
        for id=cvCondIds(:)'
            condMsg=sprintf('%s    %s\n',condMsg,Sldv.CvApi.getText(id));
        end
        condMsg=sprintf('%s\n',condMsg);
    else
        condMsg='';
    end

    if~isempty(cvMCDCIds)
        mcdcMsg=getString(message('Sldv:eng_check_cov_consistency:ThatContainsFollowingMCDCExpressions'));
        for id=cvMCDCIds(:)'
            mcdcMsg=sprintf('%s    %s\n',mcdcMsg,Sldv.CvApi.getText(id));
        end
        mcdcMsg=sprintf('%s\n',mcdcMsg);
    else
        mcdcMsg='';
    end
    msg=[msg,decMsg,condMsg,mcdcMsg];
    disp(msg);
end



function msg=check_decision_consistency(mdlObj,cvId)
    msg='';

    dvDecisions=mdlObj.decisions;
    cvDecIds=allDecisions(cvId);

    if length(dvDecisions)~=length(cvDecIds)
        msg=getString(message('Sldv:eng_check_cov_consistency:DecisionCountMismatchSLDV0numberinteger',length(dvDecisions),length(cvDecIds),cv_id_description(cvId)));
        disp(msg);
        return;
    end

    for idx=1:length(dvDecisions)
        dvOutCnt=length(dvDecisions(idx).goals);
        cvOutCnt=cv('get',cvDecIds(idx),'.dc.numOutcomes');


        if dvOutCnt~=cvOutCnt
            msg=getString(message('Sldv:eng_check_cov_consistency:Decision0numberintegerOutcomeMismatch',idx,dvOutCnt,cvOutCnt,cv_id_description(cvId)));
            disp(msg);
            return;
        end
    end
end


function msg=check_condition_consistency(mdlObj,cvId)
    msg='';

    dvConditions=mdlObj.conditions;
    cvCondIds=allConditions(cvId);

    if length(dvConditions)~=length(cvCondIds)
        msg=getString(message('Sldv:eng_check_cov_consistency:ConditionCountMismatchSLDV0numberinteger',length(dvConditions),length(cvCondIds),cv_id_description(cvId)));
        disp(msg);
        return;
    end
end



function msg=check_mcdc_consistency(mdlObj,cvId)
    msg='';

    dvMcdcEntries=mdlObj.mcdcExprs;
    cvMCDCIds=allmcdcExprs(cvId);

    if length(dvMcdcEntries)~=length(cvMCDCIds)
        msg=getString(message('Sldv:eng_check_cov_consistency:MCDCCountMismatchSLDV0numberinteger',length(dvMcdcEntries),length(cvMCDCIds),cv_id_description(cvId)));
        disp(msg);
        return;
    end
end





function cvIds=allDecisions(slsfId)
    cvIds=[];
    idx=0;
    stopped=false;

    if slsfId==0
        return;
    end

    while(~stopped)
        cvId=Sldv.CvApi.getDecision(slsfId,idx);

        if cvId==0
            stopped=true;
        else
            cvIds=[cvIds,cvId];%#ok<*AGROW>
        end
        idx=idx+1;
    end
end


function cvIds=allConditions(slsfId)
    cvIds=[];
    idx=0;
    stopped=false;

    if slsfId==0
        return;
    end

    while(~stopped)
        cvId=Sldv.CvApi.getCondition(slsfId,idx);

        if cvId==0
            stopped=true;
        else
            cvIds=[cvIds,cvId];
        end
        idx=idx+1;
    end
end

function cvIds=allmcdcExprs(slsfId)
    cvIds=[];
    idx=0;
    stopped=false;

    if slsfId==0
        return;
    end

    while(~stopped)
        cvId=Sldv.CvApi.getMcdcEntry(slsfId,idx);

        if cvId==0
            stopped=true;
        else
            cvIds=[cvIds,cvId];
        end
        idx=idx+1;
    end
end
