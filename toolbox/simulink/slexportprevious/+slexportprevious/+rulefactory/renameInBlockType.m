function rule=renameInBlockType(currentName,replaceWithName,blockType)





















    p=inputParser;
    p.addRequired('currentName',@ischar);
    p.addRequired('replaceWithName',@ischar);
    p.addRequired('blockType',@ischar);
    p.parse(currentName,replaceWithName,blockType);

    escPN=slexportprevious.utils.escapeRuleCharacters(currentName);
    escBT=slexportprevious.utils.escapeRuleCharacters(blockType);
    escNewPN=slexportprevious.utils.escapeRuleCharacters(replaceWithName);
    rule=['<Block<BlockType|',escBT,'><',escPN,':rename ',escNewPN,'>>'];
end
