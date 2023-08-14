function rule=removeParameterWithValueInBlockType(parameterName,parameterValue,blockType)




















    p=inputParser;
    p.addRequired('parameterName',@ischar);
    p.addRequired('parameterValue',@ischar);
    p.addRequired('blockType',@ischar);
    p.parse(parameterName,parameterValue,blockType);

    escPN=slexportprevious.utils.escapeRuleCharacters(parameterName);
    escPV=slexportprevious.utils.escapeRuleCharacters(parameterValue);
    escBT=slexportprevious.utils.escapeRuleCharacters(blockType);
    rule=['<Block<BlockType|',escBT,'><',escPN,'|',escPV,':remove>>'];
end
