




function hyperLink=utilCreateConfigSetHref(model,configsetParam)



    encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
    encodedModelName=[encodedModelName{:}];
    hyperLink=['matlab: modeladvisorprivate openCSAndHighlight ',[encodedModelName,' ''',configsetParam,''' ']];

