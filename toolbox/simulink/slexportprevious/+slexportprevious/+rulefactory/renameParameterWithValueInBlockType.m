function rule=renameParameterWithValueInBlockType(currentParamName,paramValue,replaceWithName,blockType)






















    p=inputParser;
    p.addRequired('currentParamName',@ischar);
    p.addRequired('paramValue',@ischar);
    p.addRequired('replaceWithName',@ischar);
    p.addRequired('blockType',@ischar);
    p.parse(currentParamName,paramValue,replaceWithName,blockType);

    escPN=slexportprevious.utils.escapeRuleCharacters(currentParamName);
    escPV=slexportprevious.utils.escapeRuleCharacters(paramValue);
    escNewPN=slexportprevious.utils.escapeRuleCharacters(replaceWithName);
    escBT=slexportprevious.utils.escapeRuleCharacters(blockType);
    rule=['<Block<BlockType|',escBT,'><',escPN,'|',escPV,':rename ',escNewPN,'>>'];
end
