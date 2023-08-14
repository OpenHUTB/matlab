function failObj=getFailingSFObj_hisl_0070(sfObjs,opts)

    sfObjs=sfObjs(cellfun(@(x)~Advisor.Utils.Utils_hisl_0070.isSFObjExcluded_hisl_0070(x,opts,true),sfObjs));
    failObj=sfObjs(cellfun(@(x)~Advisor.Utils.Utils_hisl_0070.hasReqs(x,opts),sfObjs));

end

