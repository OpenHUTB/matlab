






function prompt=getConfigSetParameterUIPrompt(model,paramName)

    try
        props=configset.getParameterInfo(model,paramName);

        prompt=props.Description;
        prompt=regexprep(prompt,':','');

    catch

        prompt='';
    end
end