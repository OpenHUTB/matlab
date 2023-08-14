function rule=addChildPair(parentContainer,newPairName,newPairValue)



















    p=inputParser;
    p.addRequired('parentContainer',@ischar);
    p.addRequired('newPairName',@ischar);
    p.addRequired('newPairValue',@ischar);
    p.parse(parentContainer,newPairName,newPairValue);

    escPC=slexportprevious.utils.escapeRuleCharacters(parentContainer);
    escNewPN=slexportprevious.utils.escapeRuleCharacters(newPairName);
    escNewPV=slexportprevious.utils.escapeRuleCharacters(newPairValue);
    rule=['<',escPC,':insertpair ',escNewPN,' "',escNewPV,'">'];
end
