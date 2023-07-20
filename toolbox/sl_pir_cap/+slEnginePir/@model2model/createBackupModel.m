
function createBackupModel(this)




    if exist(this.fXformDir,'dir')==0
        mkdir(this.fXformDir);
    end

    Prefix=this.fPrefix;


    if isempty(this.fXformedMdls)
        mdls={this.fMdl};
        mdls=[mdls,this.fRefMdls,this.fLibMdls];
        this.fXlinkedBlks=this.fLinkedBlks;
    else
        mdls=this.fXformedMdls;
    end

    for m=1:length(mdls)
        if~strcmpi(mdls{m},'simulink')
            close_system([Prefix,mdls{m}],0);
            mdlfullname=which(mdls{m});
            [~,~,ext]=fileparts(mdlfullname);

            if exist([this.fXformDir,Prefix,mdls{m},ext],'file')==2
                delete([this.fXformDir,Prefix,mdls{m},ext]);
            end
            copyfile(mdlfullname,[this.fXformDir,Prefix,mdls{m},ext],'f');
            fileattrib([this.fXformDir,Prefix,mdls{m},ext],'+w');
            load_system([this.fXformDir,Prefix,mdls{m}]);
            if strcmpi(get_param([Prefix,mdls{m}],'BlockDiagramType'),'library')
                this.fXformedLibs=[this.fXformedLibs,mdls(m)];%#ok
                set_param([Prefix,mdls{m}],'lock','off');
            end
        end
    end

    for m=1:length(this.fMdlRefs)
        dlg=bdroot(this.fMdlRefs(m).block);
        if~bdIsLibrary(dlg)||~isempty(find(strcmp(this.fXformedLibs,dlg),1))
            mdlvariants=get_param([Prefix,this.fMdlRefs(m).block],'Variants');
            if strcmpi(get_param([Prefix,this.fMdlRefs(m).block],'Variant'),'off')||isempty(mdlvariants)
                set_param([Prefix,this.fMdlRefs(m).block],'ModelName',[Prefix,this.fMdlRefs(m).refmdl{1}]);
            else
                for ii=1:length(mdlvariants)
                    mdlvariants(ii).ModelName=[Prefix,mdlvariants(ii).ModelName];
                end
                set_param([Prefix,this.fMdlRefs(m).block],'Variants',mdlvariants);
            end
        end
    end

    this.fXformedMdl=[Prefix,this.fMdl];


    for ii=1:length(this.fXlinkedBlks)
        linkedBlk=this.fXlinkedBlks(ii).block;
        delete_block([Prefix,linkedBlk]);
        referenceblk=get_param(linkedBlk,'ReferenceBlock');
        add_block([Prefix,referenceblk],[Prefix,linkedBlk]);
        slEnginePir.util.copyInfoToNewLinkedBlk([Prefix,linkedBlk],linkedBlk);
    end



    save_system([this.fPrefix,this.fMdl],[this.fXformDir,this.fPrefix,this.fMdl],...
    'SaveDirtyReferencedModels','on');
    for m=1:length(this.fXformedLibs)
        save_system([this.fPrefix,this.fXformedLibs{m}],[this.fXformDir,this.fPrefix,this.fXformedLibs{m}],...
        'SaveDirtyReferencedModels','on');
    end
    for m=1:length(this.fRefMdls)
        save_system([this.fPrefix,this.fRefMdls{m}],[this.fXformDir,this.fPrefix,this.fRefMdls{m}],...
        'SaveDirtyReferencedModels','on');
    end


    close_system([this.fPrefix,this.fMdl]);
    for m=1:length(this.fXformedLibs)
        close_system([this.fPrefix,this.fXformedLibs{m}]);
    end
    for m=1:length(this.fRefMdls)
        close_system([this.fPrefix,this.fRefMdls{m}]);
    end

end
