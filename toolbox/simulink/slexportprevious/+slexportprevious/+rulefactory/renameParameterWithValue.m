function rule=renameParameterWithValue(currentParamName,paramValue,replaceWithName)





















    p=inputParser;
    p.addRequired('currentParamName',@ischar);
    p.addRequired('paramValue',@ischar);
    p.addRequired('replaceWithName',@ischar);
    p.parse(currentParamName,paramValue,replaceWithName);

    escPN=slexportprevious.utils.escapeRuleCharacters(currentParamName);
    escPV=slexportprevious.utils.escapeRuleCharacters(paramValue);
    escNewPN=slexportprevious.utils.escapeRuleCharacters(replaceWithName);
    rule=['<',escPN,'|',escPV,':rename ',escNewPN,'>'];
end
