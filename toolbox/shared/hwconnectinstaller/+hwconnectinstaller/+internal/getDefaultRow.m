function row=getDefaultRow(packageInfo,hardwareIndex)






    assert(numel(packageInfo)>0);
    assert(isfield(packageInfo,'PackageIsSelectable'));
    assert(isfield(packageInfo,'Action'));

    try

        row=0;


        if numel(hardwareIndex)>1
            selectableRows=[];
            for i=1:numel(hardwareIndex)
                if packageInfo(hardwareIndex(i)).PackageIsSelectable
                    selectableRows=[selectableRows,i-1];
                end
            end

            if~isempty(selectableRows)
                if length(selectableRows)>1

                    xlateEnt=struct(...
                    'Install','',...
                    'Download','',...
                    'Uninstall','');
                    xlateEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','SelectPackage',xlateEnt);



                    pkgInfoIdx=hardwareIndex(selectableRows(1)+1);
                    if isequal(packageInfo(pkgInfoIdx).Action,xlateEnt.Install)...
                        ||isequal(packageInfo(pkgInfoIdx).Action,xlateEnt.Download)...
                        ||isequal(packageInfo(pkgInfoIdx).Action,xlateEnt.Uninstall)
                        row=selectableRows;
                    else
                        row=selectableRows(1);
                    end
                else
                    row=selectableRows;
                end
            end
        end

    catch ME
        error(ME.identifier,ME.message);
    end