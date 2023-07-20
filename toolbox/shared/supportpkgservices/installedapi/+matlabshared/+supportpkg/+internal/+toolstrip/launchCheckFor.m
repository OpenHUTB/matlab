function launchCheckFor(addOnType)












    validTypes={'hardware','software'};
    validatestring(addOnType,validTypes);

    foundFigure=findobj('Tag',matlabshared.supportpkg.internal.toolstrip.SupportPackageUpdatesDlg.FIGURE_TAG);
    if~isempty(foundFigure)

        figure(foundFigure);
        return;
    end

    try
        updatablePackages=matlabshared.supportpkg.internal.toolstrip.util.getSpPkgUpdateData(addOnType);
    catch ex



        if strcmp(ex.identifier,'supportpkgservices:matlabshared:NoInternetAccess')
            errMsg=message('supportpkgservices:matlabshared:NoInternetAccessHSP').getString();
        else
            errMsg=ex.message;
        end

        dlgTitle=message('supportpkgservices:matlabshared:CheckForUpdateDlgTitle').getString;
        h=errordlg(errMsg,dlgTitle);
        matlabshared.supportpkg.internal.toolstrip.util.setFigureIconToMembrane(h);
        return;
    end


    if isempty(updatablePackages)
        matlabshared.supportpkg.internal.toolstrip.noUpdatesDialog(addOnType);
        return;
    end




    matlabshared.supportpkg.internal.toolstrip.SupportPackageUpdatesDlg(updatablePackages,addOnType);
end