



function initializeModelGen(this)
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
        mdls=combine(mdls,this.fRefMdls);
    end

    xformedLibs={};

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
                xformedLibs=[xformedLibs,mdls(m)];%#ok
                set_param([Prefix,mdls{m}],'lock','off');
            end
        end
    end
    for m=1:length(this.fMdlRefs)
        dlg=bdroot(this.fMdlRefs(m).block);
        if~bdIsLibrary(dlg)||~isempty(find(strcmp({xformedLibs},dlg),1))
            mdlvariants=get_param([Prefix,this.fMdlRefs(m).block],'Variants');
            variantOn=strcmpi(get_param([Prefix,this.fMdlRefs(m).block],'Variant'),'on');
            if~variantOn||isempty(mdlvariants)
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
        referenceblk=get_param(linkedBlk,'ReferenceBlock');

        set_param([Prefix,linkedBlk],'LinkStatus','inactive');
        set_param([Prefix,linkedBlk],'ReferenceBlock',[Prefix,referenceblk]);
        set_param([Prefix,linkedBlk],'LinkStatus','propagateHierarchy');
        slEnginePir.util.copyInfoToNewLinkedBlk([Prefix,linkedBlk],linkedBlk);
    end
    for ii=1:length(this.fCopyLib)
        set_param(this.fCopyLib{ii},'referenceblock',this.fCopyLibRef{ii});
    end



    save_system([this.fPrefix,this.fMdl],[this.fXformDir,this.fPrefix,this.fMdl],...
    'SaveDirtyReferencedModels','on');
    for m=1:length(xformedLibs)
        save_system([this.fPrefix,xformedLibs{m}],[this.fXformDir,this.fPrefix,xformedLibs{m}],...
        'SaveDirtyReferencedModels','on');
    end
    for m=1:length(this.fRefMdls)
        save_system([this.fPrefix,this.fRefMdls{m}],[this.fXformDir,this.fPrefix,this.fRefMdls{m}],...
        'SaveDirtyReferencedModels','on');
    end


    close_system([this.fPrefix,this.fMdl]);
    for m=1:length(xformedLibs)
        close_system([this.fPrefix,xformedLibs{m}]);
    end
    for m=1:length(this.fRefMdls)
        close_system([this.fPrefix,this.fRefMdls{m}]);
    end


    for m=1:length(xformedLibs)
        load_system([this.fXformDir,this.fPrefix,xformedLibs{m}]);
    end
    warning('off','Simulink:modelReference:ModelNotFoundWithBlockName');
    for m=1:length(this.fRefMdls)
        load_system([this.fXformDir,this.fPrefix,this.fRefMdls{m}]);
    end
    warning('on','Simulink:modelReference:ModelNotFoundWithBlockName');
    open_system([this.fXformDir,this.fPrefix,this.fMdl]);
end


function outSet=combine(setA,setB)



    aLen=length(setA);
    bLen=length(setB);
    outSet=setA;
    for i=1:bLen
        mdl=setB{i};
        included=false;
        for j=1:aLen
            if strcmp(mdl,setA{j})
                included=true;
                break;
            end
        end
        if~included
            outSet{end+1}=mdl;
        end
    end
end


