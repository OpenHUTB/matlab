function rule=replaceParameterValue(paramName,currentParamValue,replaceWithValue)





















    p=inputParser;
    p.addRequired('paramName',@ischar);
    p.addRequired('currentParamValue',@ischar);
    p.addRequired('replaceWithValue',@ischar);
    p.parse(paramName,currentParamValue,replaceWithValue);

    escPN=slexportprevious.utils.escapeRuleCharacters(paramName);
    escPV=slexportprevious.utils.escapeRuleCharacters(currentParamValue);
    escNewPN=slexportprevious.utils.escapeRuleCharacters(replaceWithValue);
    rule=['<',escPN,'|',escPV,':repval ',escNewPN,'>'];
end
