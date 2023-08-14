function rule=replaceInSourceBlock(aName,sourceBlock,aNewValue)



















    p=inputParser;
    p.addRequired('aName',@ischar);
    p.addRequired('sourceBlock',@ischar);
    p.addRequired('aNewValue',@ischar);
    p.parse(aName,sourceBlock,aNewValue);

    escPN=slexportprevious.utils.escapeRuleCharacters(aName);
    escBT=slexportprevious.utils.escapeRuleCharacters(sourceBlock);
    escVal=slexportprevious.utils.escapeRuleCharacters(aNewValue);
    rule=['<Block<SourceBlock|"',escBT,'"><',escPN,':repval "',escVal,'">>'];
end
