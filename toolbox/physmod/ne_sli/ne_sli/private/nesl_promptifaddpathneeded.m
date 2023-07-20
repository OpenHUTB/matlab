function info=nesl_promptifaddpathneeded(info)







    if info.IsFile&&~info.IsOnPath&&~info.IsShadowed

        theMessage=getString(message('physmod:ne_sli:dialog:AddFileToPathPrompt',...
        info.FileName));
        theTitle=getString(message('physmod:ne_sli:dialog:AddFileToPathTitle'));


        choices={getString(message('physmod:ne_sli:dialog:AddFileToPathAddLabel')),...
        getString(message('physmod:ne_sli:dialog:AddFileToPathCancelLabel'))};
        userChoice=questdlg(theMessage,theTitle,choices{:},choices{1});
        if strcmp(userChoice,choices{1})
            rootPath=regexp(fileparts(info.FileName),'[^\+]*','match','once');
            addpath(rootPath);


            nesl_getfunctioninfo=nesl_private('nesl_getfunctioninfo');
            info=nesl_getfunctioninfo(info.FileName);
        end
    end

end
