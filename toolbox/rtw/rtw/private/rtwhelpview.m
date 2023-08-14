function rtwhelpview(topic_id)








    if license('test','Real-Time_Workshop')
        helpview([docroot,'/toolbox/rtw/helptargets.map'],topic_id);
    else
        warndlg(DAStudio.message('RTW:utility:NoRTWLicenseNoDoc'),'Warning','modal');
    end
