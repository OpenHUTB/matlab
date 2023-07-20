function rule=rename(currentName,replaceWithName)






















    currentName=convertStringsToChars(currentName);
    replaceWithName=convertStringsToChars(replaceWithName);

    p=inputParser;
    p.addRequired('currentName',@ischarorcellstr);
    p.addRequired('replaceWithName',@ischarorcellstr);
    p.parse(currentName,replaceWithName);

    function b=ischarorcellstr(obj)
        b=ischar(obj)||iscellstr(obj);
    end

    escPN=slexportprevious.utils.escapeRuleCharacters(currentName);
    escNewPN=slexportprevious.utils.escapeRuleCharacters(replaceWithName);

    if ischar(escPN)
        assert(ischar(escNewPN),'slexportprevious:rulefactory:InputTypeMismatch',...
        'currentName and replaceWithName must be the same type');
        rule=['<',escPN,':rename ',escNewPN,'>'];
    else
        assert(iscell(escNewPN),'slexportprevious:rulefactory:InputTypeMismatch',...
        'currentName and replaceWithName must be the same type');
        assert(isequal(size(escPN),size(escNewPN)),'slexportprevious:rulefactory:InputSizeMismatch',...
        'currentName and replaceWithName must be the same size');
        array=[escPN(:),escNewPN(:)]';
        rule=sprintf('<%s:rename %s>',array{:});
    end

end
