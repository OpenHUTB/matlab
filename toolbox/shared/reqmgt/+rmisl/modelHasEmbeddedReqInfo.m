function result=modelHasEmbeddedReqInfo(modelH)








    if strcmp(get_param(modelH,'hasReqInfo'),'on')
        result=true;
        return;
    end


    bdReqInfo=get_param(modelH,'requirementInfo');
    if~isempty(bdReqInfo)&&contains(bdReqInfo,'{''')
        set_param(modelH,'hasReqInfo','on');
        result=true;
        return;
    end

    result=false;
end


