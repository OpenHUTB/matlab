function ret=getHelpArgs(~)




    if linkfoundation.util.isMWSoftwareInstalled('rtw-ec')
        ret={fullfile(docroot,'toolbox','ecoder','helptargets.map'),'targetpreferences'};
    else
        ret={fullfile(docroot,'toolbox','rtw','helptargets.map'),'targetpreferences'};
    end
