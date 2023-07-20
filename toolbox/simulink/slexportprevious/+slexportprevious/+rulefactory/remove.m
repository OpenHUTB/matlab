function rule=remove(aName)





















    aName=convertStringsToChars(aName);

    p=inputParser;
    p.addRequired('aName',@ischarorcellstr);
    p.parse(aName);

    function b=ischarorcellstr(obj)
        b=ischar(obj)||iscellstr(obj);
    end

    escPN=slexportprevious.utils.escapeRuleCharacters(aName);

    if ischar(escPN)
        escPN={escPN};
    end
    rule=sprintf('<%s:remove>',escPN{:});
end
