



function[isExternalInit,isCommentOutStep]=getRefreshInitOptions(blockPath,direction,oppositeDirection)
    isExternalInit=false;
    isCommentOutStep=false;
    externalInitMaskParameterName='ExternalInit';
    commentStepMaskParameterName='CommentStep';

    initMaskPath=[bdroot(blockPath),'/',direction,'/Init'];
    maskObj=Simulink.Mask.get(initMaskPath);
    maskNames={maskObj.Parameters.Name};

    if~any(contains(maskNames,externalInitMaskParameterName))||...
        ~any(contains(maskNames,commentStepMaskParameterName))
        return
    end
    initMaskExternalInit=maskObj.Parameters(strcmp(maskNames,externalInitMaskParameterName)).Value;
    if~isempty(initMaskExternalInit)&&strcmp(initMaskExternalInit,'on')
        isExternalInit=true;
    end

    oppositeDirectionInitMaskPath=[bdroot(blockPath),'/',oppositeDirection,'/Init'];
    oppositeDirectionMaskObj=Simulink.Mask.get(oppositeDirectionInitMaskPath);
    oppositeDirectionInitMaskExternalInit=oppositeDirectionMaskObj.Parameters(strcmp(maskNames,externalInitMaskParameterName)).Value;
    if~isempty(oppositeDirectionInitMaskExternalInit)&&~strcmp(oppositeDirectionInitMaskExternalInit,initMaskExternalInit)
        oppositeDirectionMaskObj.Parameters(strcmp(maskNames,externalInitMaskParameterName)).Value=initMaskExternalInit;
    end

    initMaskCommentOutStep=maskObj.Parameters(strcmp(maskNames,commentStepMaskParameterName)).Value;
    if~isempty(initMaskCommentOutStep)&&strcmp(initMaskCommentOutStep,'on')
        isCommentOutStep=true;
    end
end