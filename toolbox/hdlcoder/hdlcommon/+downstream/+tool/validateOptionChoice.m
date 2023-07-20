function validateOptionChoice(optionValue,choice,optionID)





    if~isempty(choice)
        cmpresult=strcmpi(optionValue,choice);
        if~any(cmpresult)
            error(message('hdlcommon:workflow:DownstreamInvalidValue',optionValue,optionID,optionID,sprintf('%s; ',choice{:})));
        end
    end

end


