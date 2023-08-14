function laSchema=getLogicAnalyzerSchema()







    isDSPInstalled=dig.isProductInstalled('DSP System Toolbox');
    isSoCB_Installed=dig.isProductInstalled('SoC Blockset');
    if isDSPInstalled||isSoCB_Installed
        laSchema=@(x)Simulink.scopes.SLMenus.openLogicAnalyzer(x,true);
    else
        laSchema=@(x)hiddenActionSchema(x,'Simulink:OpenLogicAnalyzer');
    end
end