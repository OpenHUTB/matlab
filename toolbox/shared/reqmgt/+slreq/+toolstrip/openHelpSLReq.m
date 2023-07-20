function openHelpSLReq(userdata,cbinfo)
    switch userdata
    case 'main'
        helpview(fullfile(docroot,'slrequirements','helptargets.map'),'slreqLandingPageID');
    case 'authoring'
        helpview(fullfile(docroot,'slrequirements','helptargets.map'),'authorreqs_editor');
    end
end