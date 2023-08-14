function[AppData]=sfunbuilderLangExt(Action,AppData,reportErr)
    if nargin<3
        reportErr=true;
    end

    blockHandle=getSimulinkBlockHandle(AppData.blockName);
    switch(Action)
    case 'SetupWidget'



    case 'ComputeLangExtFromWidget'


        LangExt=AppData.SfunWizardData.LangExt;
        AppData.LangExt=computeLangExtFromSetting(LangExt,blockHandle);
        if reportErr&&strcmpi(AppData.LangExt,'cpp')&&~rtwprivate('rtw_is_cpp_build',bdroot(blockHandle))


        end
    case 'ComputeLangExtFromWizardData'




        if~isfield(AppData.SfunWizardData,'LangExt')||...
            isempty(AppData.SfunWizardData.LangExt)||...
            ~any(strcmp(AppData.SfunWizardData.LangExt,{'inherit','cpp','c'}))
            AppData.SfunWizardData.LangExt='inherit';
        end
        AppData.LangExt=computeLangExtFromSetting(AppData.SfunWizardData.LangExt,blockHandle);

    otherwise
        DAStudio.error('Simulink:blocks:SFunctionBuilderInvalidInput');
    end
end

function LangExtOptStr=syncLangExtFromWidget(AppData)

    LangExtOpts={'inherit','cpp','c'};
    LangExtIdx=AppData.SfunBuilderPanel.getLangExtIndex();
    LangExtOptStr=LangExtOpts{LangExtIdx+1};
end

function langExt=computeLangExtFromSetting(widgetSetting,blockHandle)
    assert(any(strcmpi(widgetSetting,{'inherit','cpp','c'})));

    langExt=widgetSetting;
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
end
