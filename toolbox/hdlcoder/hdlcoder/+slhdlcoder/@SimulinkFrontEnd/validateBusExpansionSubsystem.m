function validateBusExpansionSubsystem(this,blockName,slbh)




    obj=get_param(blockName,'Object');

    if strcmp(obj.BlockType,'Delay')&&~strcmp(obj.ExternalReset,'None')
        msgObj=message('hdlcoder:validate:DelayBusReset',blockName);
        this.updateChecks(blockName,'block',msgObj,'Error');
        error(msgObj);
    end
end