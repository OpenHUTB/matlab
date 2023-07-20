function rule=addParameterToBlock(identifyingRule,paramName,paramValue)



















    p=inputParser;
    p.addRequired('identifyingRule');
    p.addRequired('paramName',@ischar);
    p.addRequired('paramValue',@ischar);
    p.parse(identifyingRule,paramName,paramValue);

    paramName=slexportprevious.utils.escapeRuleCharacters(paramName);
    paramValue=slexportprevious.utils.escapeRuleCharacters(paramValue);
    rule=['<Block',identifyingRule,':insertpair ',paramName,' ',paramValue,'>'];
end
