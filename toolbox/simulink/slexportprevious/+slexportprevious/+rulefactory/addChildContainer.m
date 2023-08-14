function rule=addChildContainer(parentContainer,newContainerName)



















    p=inputParser;
    p.addRequired('parentContainer',@ischar);
    p.addRequired('newContainerName',@ischar);
    p.parse(parentContainer,newContainerName);

    escPC=slexportprevious.utils.escapeRuleCharacters(parentContainer);
    escNewCN=slexportprevious.utils.escapeRuleCharacters(newContainerName);
    rule=['<',escPC,':insertcontainer ',escNewCN,'>'];
end
