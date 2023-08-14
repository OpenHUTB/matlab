function validateStringPropertyValue(value,propertyName,choices,defaultChoice)





    if nargin<4
        defaultChoice=choices{1};
    end


    dnnfpga.config.validateStringProperty(value,propertyName,defaultChoice);


    len=length(choices);


    for ii=1:len
        aChoice=choices{ii};
        if strcmpi(value,aChoice)
            return;
        end
    end

    notMatchValueStr=sprintf('%s',value);


    choiceStr=dnnfpga.config.getPropertyChoiceString(choices);

    error(message('hdlcommon:plugin:InvalidPropertyValue',...
    notMatchValueStr,propertyName,choiceStr));

end
