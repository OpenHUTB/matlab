








function link=getHyperlinkToConfigSetParameter(model,paramName)

    try
        d=configset.getParameterInfo(model,paramName);

        if d.IsUI&&d.IsReadable
            prompt=Advisor.Utils.getConfigSetParameterUIPrompt(model,paramName);

            if~isempty(prompt)
                linktext=[prompt,' (',paramName,')'];
                link=Advisor.Text(linktext);

                encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
                encodedModelName=[encodedModelName{:}];

                link.setHyperlink(...
                ['matlab:%20modeladvisorprivate%20openCSAndHighlight%20',...
                encodedModelName,'%20',paramName]);
            else
                link=Advisor.Text(paramName);
            end

        else
            link=Advisor.Text(paramName);
        end

    catch


        link=Advisor.Text(paramName);
    end
end