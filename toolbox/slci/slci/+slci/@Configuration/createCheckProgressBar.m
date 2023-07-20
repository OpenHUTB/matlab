function Progressbar=createCheckProgressBar(aObj)





    Progressbar=DAStudio.WaitBar;
    Progressbar.setWindowTitle(DAStudio.message('Slci:ui:CheckProgressTitle',aObj.getModelName()));
    Progressbar.setLabelText(DAStudio.message('Slci:ui:CheckProgressText'));
    Progressbar.setCircularProgressBar(true);
    Progressbar.show();


