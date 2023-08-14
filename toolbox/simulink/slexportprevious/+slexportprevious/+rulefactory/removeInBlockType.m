function rule=removeInBlockType(aName,blockType)



















    p=inputParser;
    p.addRequired('aName',@ischar);
    p.addRequired('blockType',@ischar);
    p.parse(aName,blockType);

    escPN=slexportprevious.utils.escapeRuleCharacters(aName);
    escBT=slexportprevious.utils.escapeRuleCharacters(blockType);
    rule=['<Block<BlockType|',escBT,'><',escPN,':remove>>'];
end
