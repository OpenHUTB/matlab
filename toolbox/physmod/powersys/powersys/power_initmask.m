function[isLicensed]=power_initmask(Block)






    isLicensed=true;

    if exist('Block','var')==0
        rootSystem=bdroot(gcb);
    else
        rootSystem=bdroot(Block);
    end
    blockIsInLibrary=strcmp(get_param(rootSystem,'BlockDiagramType'),'library');

    if blockIsInLibrary
        licenseParam='LibLicenseID';
        licenseValue='Power_System_Blocks';
        params=get_param(rootSystem,'ObjectParameters');
        isLicensedLibrary=isfield(params,licenseParam)&&...
        strcmp(get_param(rootSystem,licenseParam),licenseValue);
        if isLicensedLibrary
            return;
        end
    else

        isLicensed=power_checklicense('false');
    end

    if(isLicensed==false)

        dispScript=sprintf('color(''red'');\ndisp(''%s\\n%s'');','No','License');
        set_param(gcb,'MaskDisplay',dispScript,'MaskIconOpaque','on','BackgroundColor','white');

    end

