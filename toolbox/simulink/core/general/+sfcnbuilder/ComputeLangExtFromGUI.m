function applicationData=ComputeLangExtFromGUI(blockHandle,applicationData)




    langExt=applicationData.SfunWizardData.LangExt;
    assert(any(strcmpi(langExt,{'inherit','cpp','c'})));
    if strcmpi(langExt,'inherit')


        if~strcmp(get_param(bdroot(blockHandle),'BlockDiagramType'),'model')
            langExt='c';
        else
            genCPP=rtwprivate('rtw_is_cpp_build',bdroot(blockHandle));
            if genCPP
                langExt='cpp';
            else
                langExt='c';
            end
        end
    end
    applicationData.LangExt=langExt;
end
