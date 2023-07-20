

function covHTMLSettings=getHTMLSettings(model)
    import stm.internal.Coverage;

    if Coverage.isModel(model)&&~Coverage.isNotUnique(model)
        covHTMLSettings=cvi.CvhtmlSettings(model);
    else
        covHTMLSettings=cvi.CvhtmlSettings();
    end

    covHTMLSettings.generateWebViewReport=0;
    covHTMLSettings.showReport=0;
    covHTMLSettings.modelDisplay=1;
end
