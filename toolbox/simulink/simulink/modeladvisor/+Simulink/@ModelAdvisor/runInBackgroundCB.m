function runInBackgroundCB(sys)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(sys);
    iconpath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources');
    if strcmp(mdladvObj.Toolbar.RunInBackground.on,'on')
        mdladvObj.Toolbar.RunInBackground.icon=fullfile(iconpath,'runinbackground.png');
        mdladvObj.runInBackground=true;
    else
        mdladvObj.Toolbar.RunInBackground.icon=fullfile(iconpath,'runinforeground.png');
        mdladvObj.runInBackground=false;
    end