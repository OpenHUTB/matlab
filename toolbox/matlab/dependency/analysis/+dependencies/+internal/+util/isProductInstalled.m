function installed=isProductInstalled(baseCode,~)







    finder=dependencies.internal.analysis.toolbox.ToolboxFinder;
    tbx=finder.fromBaseCode(baseCode);
    installed=~isempty(tbx)&&tbx.IsInstalled&&license('test',tbx.FlexName);

end
