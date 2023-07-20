function rule=removeParameterWithValue(parameterName,parameterValue)



















    p=inputParser;
    p.addRequired('parameterName',@ischar);
    p.addRequired('parameterValue',@ischar);
    p.parse(parameterName,parameterValue);

    escPN=slexportprevious.utils.escapeRuleCharacters(parameterName);
    escPV=slexportprevious.utils.escapeRuleCharacters(parameterValue);
    rule=['<',escPN,'|',escPV,':remove>'];
end
