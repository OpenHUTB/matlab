function success=deleteRestorePoint(this,name)




    success=false;

    foundInList=false;
    [snapshots,snapshotdir,snapshotInfoMat]=this.getRestorePointList;
    newsnapshots={};
    deleteIdx=0;
    for i=1:length(snapshots)
        if strcmp(snapshots{i}.name,name)
            foundInList=true;
            deleteIdx=i;
        else
            newsnapshots{end+1}=snapshots{i};
        end
    end

    if~foundInList
        DAStudio.error('Simulink:tools:MAUnableLocateRestorePointName',name);
        return
    end


    subdirName=num2str(snapshots{deleteIdx}.Index);
    fullsubdirName=fullfile(snapshotdir,subdirName);



    if exist(fullfile(snapshotdir,['dd',subdirName,'.sldd']),'file')
        delete(fullfile(snapshotdir,['dd',subdirName,'.sldd']));
    else
        delete(fullfile(snapshotdir,['workspace',subdirName,'.mat']));
    end



    if strcmp(this.CustomTARootID,'com.mathworks.FPCA.FixedPointConversionTask')
        fpcadvisorprivate('utilHandle_FPAdvisorData','delete',this.System,snapshotdir,subdirName);
    end


    rmdir(fullsubdirName,'s');


    snapshots=newsnapshots;%#ok<NASGU>
    save(snapshotInfoMat,'snapshots');

    success=true;