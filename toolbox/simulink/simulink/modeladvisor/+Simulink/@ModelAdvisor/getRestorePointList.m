function[snapshots,snapshotdir,snapshotInfoMat]=getRestorePointList(this)




    snapshots={};

    snapshotdir=fullfile(this.getWorkDir('CheckOnly'),'_snapshot');
    snapshotInfoMat=fullfile(snapshotdir,'info.mat');
    if exist(snapshotInfoMat,'file')
        snapshots=load(snapshotInfoMat);
        snapshots=snapshots.snapshots;
    end
