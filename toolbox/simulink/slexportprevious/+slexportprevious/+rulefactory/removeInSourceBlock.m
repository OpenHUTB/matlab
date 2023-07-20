function rule=removeInSourceBlock(aName,sourceBlock)



















    p=inputParser;
    p.addRequired('aName',@ischar);
    p.addRequired('sourceBlock',@ischar);
    p.parse(aName,sourceBlock);

    escPN=slexportprevious.utils.escapeRuleCharacters(aName);
    escBT=slexportprevious.utils.escapeRuleCharacters(sourceBlock);
    rule=['<Block<SourceBlock|"',escBT,'"><',escPN,':remove>>'];
end
