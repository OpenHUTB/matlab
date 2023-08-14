function rtwdemoHelpButton(product,page)






    try
        mapfile=[docroot,'/',product,'/helptargets.map'];
        helpview(mapfile,page);
    catch ME
        if strcmp(product,'ecoder')
            errordlg(message('rtwdemos:rtwconfiguredemo:helpRequiresERT').getString,...
            message('rtwdemos:rtwconfiguredemo:helpError').getString);
        else

            errordlg(ME.message,...
            message('rtwdemos:rtwconfiguredemo:helpError').getString);
        end
    end

end

