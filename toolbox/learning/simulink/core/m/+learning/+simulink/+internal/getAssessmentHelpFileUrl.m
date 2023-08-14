function webUrl=getAssessmentHelpFileUrl()

    url=fullfile(learning.simulink.preferences.slacademyprefs.toolboxPath,...
    'slbridge','signalChecks','AssessmentHelp.html');

    webUrl=['file:///',url];
end