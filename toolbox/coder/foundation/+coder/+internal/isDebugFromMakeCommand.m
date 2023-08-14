function isDebugEnabled=isDebugFromMakeCommand(makeCommand)



    isDebugEnabled=~isempty(regexpi(makeCommand,'DEBUG_BUILD\s*=\s*1'));
