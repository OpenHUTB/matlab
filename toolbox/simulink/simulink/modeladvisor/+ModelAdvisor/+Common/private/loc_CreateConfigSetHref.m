




function htmlStr=loc_CreateConfigSetHref(inputStr,configsetParam,encodedModelName)



    htmlStr=ModelAdvisor.Text(inputStr);
    htmlStr.setHyperlink(['matlab: modeladvisorprivate openCSAndHighlight ',[encodedModelName,' ''',configsetParam,''' ']]);


    function value=safe_get_param(cs,paramName)
        if cs.isValidParam(paramName)
            value=get_param(cs,paramName);
        else
            value='not valid field';
        end
