
function UpdateInterpNDValidIndexFlatInterp(block,h)















    modelVersion=get_param(bdroot(block),'VersionLoaded');
    SLVersion_R2014b=8.4;
    if(modelVersion>=SLVersion_R2014b)
        return
    end


    if(~strcmp(get_param(block,'InterpMethod'),'Flat'))
        return;
    end



    if(~strcmp(get_param(block,'ValidIndexMayReachLast'),'on'))
        return;
    end



    if askToReplace(h,block)
        funcSet=uSafeSetParam(h,block,'ValidIndexMayReachLast','off');
        reasonStr=DAStudio.message('SimulinkBlocks:upgrade:InterpolationUpdateHiddenValidIndexParameterforFlatInterp',...
        h.cleanLocationName(block));

        appendTransaction(h,block,reasonStr,{funcSet})
    end


end