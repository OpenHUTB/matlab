function providers=registerSLDiffGUIProviders(~)




    providers=[sldiff.internal.SLDiffGUIProvider();...
    sldiff.internal.ModelTemplateDiffGUIProvider();...
    sldiff.internal.ProjectTemplateDiffGUIProvider()];

end

