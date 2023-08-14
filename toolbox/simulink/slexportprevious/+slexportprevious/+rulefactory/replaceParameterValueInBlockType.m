function rule=replaceParameterValueInBlockType(paramName,currentParamValue,replaceWithValue,blockType)






















    p=inputParser;
    p.addRequired('paramName',@ischar);
    p.addRequired('currentParamValue',@ischar);
    p.addRequired('replaceWithValue',@ischar);
    p.addRequired('blockType',@ischar);
    p.parse(paramName,currentParamValue,replaceWithValue,blockType);

    escPN=slexportprevious.utils.escapeRuleCharacters(paramName);
    escPV=slexportprevious.utils.escapeRuleCharacters(currentParamValue);
    escNewPV=slexportprevious.utils.escapeRuleCharacters(replaceWithValue);
    escBT=slexportprevious.utils.escapeRuleCharacters(blockType);

    rule=['<Block<BlockType|',escBT,'><',escPN,'|',escPV,':repval ',escNewPV,'>>'];
end
