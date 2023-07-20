








function link=getConfigSetParameterHyperlink(system,parameterName)

    cs=getActiveConfigSet(bdroot(system));

    if isa(cs,'Simulink.ConfigSetRef')
        cs=cs.getRefConfigSet();
    end

    try
        prop=configset.getParameterInfo(cs,parameterName);


        if prop.IsUI

            prompt=prop.Description;
            prompt=regexprep(prompt,':','');
        else

            prompt='';
        end
    catch

        prompt='';
    end

    if~isempty(prompt)
        linktext=[prompt,' (',parameterName,')'];
    else
        linktext=parameterName;
    end

    link=Advisor.Text(linktext);



    if~isempty(prompt)
        link.setHyperlink(['matlab:%20modeladvisorprivate%20openCSAndHighlight%20',bdroot(system),'%20',parameterName]);
    end
end
