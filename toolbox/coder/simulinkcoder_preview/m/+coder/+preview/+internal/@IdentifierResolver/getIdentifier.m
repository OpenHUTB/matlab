function out=getIdentifier(obj,rule)




    config=obj.constructConfig;
    config.ruleString=rule;



    out=obj.replaceNonAscii(config.getIdentifier);