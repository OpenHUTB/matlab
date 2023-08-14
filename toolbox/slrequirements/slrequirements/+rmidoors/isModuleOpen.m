function isOpen=isModuleOpen(modulepath)




    hDoors=rmidoors.comApp();
    hDoors.runStr(['dmiModuleIsOpen("',modulepath,'")']);
    isOpen=strcmp(hDoors.Result,'true');
end
