function out=queryMoveDictionaryToSLDD(mdlName,ddName)













    move=DAStudio.message('SimulinkCoderApp:ui:QueryMove');
    returnVal=questdlg(DAStudio.message('SimulinkCoderApp:ui:QueryMoveDictToSLDD',...
    mdlName,ddName,move,ddName),...
    DAStudio.message('SimulinkCoderApp:ui:QueryMoveDictToSLDDTitle'),...
    move,...
    DAStudio.message('SimulinkCoderApp:ui:QueryCancel'),...
    move);
    out=strcmp(returnVal,move);

end


