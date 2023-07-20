function cloneReplaceResults=refactorCallBack(this)



    cloneReplaceResults=[];
    cloneReplaceResults.ReplacedClones={};

    if isempty(this.m2mObj)
        return;
    end

    if~isempty(this.refactoredClonesLibFileName)
        libraryname=this.refactoredClonesLibFileName;
    else
        libraryname='newLibraryFile';
    end

    timestampe=char(datetime('now','TimeZone','local','Format','yyyy-MM-dd_HH_mm_ss'));
    timestampe=strrep(timestampe,'-','_');
    genmodel_prefix=[slEnginePir.util.Constants.BackupModelPrefix,'_',timestampe,'_'];


    try
        if~isempty(this.libraryList)
            cloneReplaceResults=this.m2mObj.replace_clones(genmodel_prefix);
        elseif this.enableClonesAnywhere
            cloneReplaceResults=this.m2mObj.replace_clonesAnywhere(libraryname,genmodel_prefix);
        else
            cloneReplaceResults=this.m2mObj.replace_clones(libraryname,genmodel_prefix);
        end
    catch ME
        set_param(this.m2mObj.mdlName,'CloneDetectionUIObj',this);
        ME.throwAsCaller();
        return;
    end


    updatedObj=this;
    if~exist(this.backUpPath,'dir')
        mkdir(this.backUpPath);
        this.historyVersions=[];
    end
    set_param(this.m2mObj.mdlName,'CloneDetectionUIObj',this);
    save(this.objectFile,'updatedObj');

    this.m2mObj.closeOpenedModels();
end


