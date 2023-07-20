function trvdMdls=getAllMdlRefAndLibBlks(this,aMdl,aDir,aTrvdMdls)



    trvdMdls=aTrvdMdls;
    refedLinkedMdls=cell(1,0);
    mdlRefBlks=find_system(aMdl,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'FindAll','on','BlockType','ModelReference','Commented','off');
    linkedBlks=find_system(aMdl,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'FindAll','on','LinkStatus','resolved','BlockType','SubSystem','Commented','off');

    this.getAllReferlinkedBlks_addOn();


    mdlRefsInfo=struct('block',{},'refmdl',{});
    for ii=1:length(mdlRefBlks)
        sidMdlrefBlk=Simulink.ID.getSID(mdlRefBlks(ii));
        mdlRefInfo=struct('block',[],'refmdl',[]);
        if strcmpi(get_param(mdlRefBlks(ii),'ProtectedModel'),'on')
            DAStudio.error('sl_pir_cpp:creator:UnsupportedProtectedModel',getfullname(mdlRefBlks(ii)));
        end
        mdlRefInfo.block=getfullname(mdlRefBlks(ii));
        mdlVariants=get_param(mdlRefBlks(ii),'Variants');
        if strcmpi(get_param(mdlRefBlks(ii),'Variant'),'off')||isempty(mdlVariants)
            if exist(get_param(mdlRefBlks(ii),'ModelName'),'file')>0
                mdlRefInfo.refmdl={get_param(mdlRefBlks(ii),'ModelName')};

            end
        else
            mdlRefInfo.refmdl=[];
            for m=1:length(mdlVariants)
                [~,refmdlName,~]=fileparts(mdlVariants(m).ModelName);
                if exist(refmdlName,'file')>0
                    mdlRefInfo.refmdl=[mdlRefInfo.refmdl,{refmdlName}];
                end
            end
        end
        if~isempty(mdlRefInfo.refmdl)
            mdlRefsInfo=[mdlRefsInfo,mdlRefInfo];%#ok
            refedLinkedMdls=[refedLinkedMdls,mdlRefsInfo(ii).refmdl];%#ok
            rootBd=bdroot(aMdl);
            if strcmpi(get_param(rootBd,'BlockDiagramType'),'library')
                for mIdx=1:length(mdlRefInfo.refmdl)
                    if isKey(this.fMdlRefInLibMap,mdlRefInfo.refmdl{mIdx})
                        this.fMdlRefInLibMap(mdlRefInfo.refmdl{mIdx})=[this.fMdlRefInLibMap(mdlRefInfo.refmdl),sidMdlrefBlk];
                    else
                        this.fMdlRefInLibMap(mdlRefInfo.refmdl{mIdx})={sidMdlrefBlk};
                    end
                end
            end
        end
    end

    this.fRefMdls=[this.fRefMdls,refedLinkedMdls];
    this.fMdlRefs=[this.fMdlRefs,mdlRefsInfo];


    linkedBlksInfo=struct('block',{},'lib',{});
    for ii=1:length(linkedBlks)
        linkedBlkInfo=struct('block',[],'lib',[]);
        refBlock=get_param(linkedBlks(ii),'ReferenceBlock');
        Library=strsplit(refBlock,'/');
        if isSimulinkLibrary(Library{1})
            linkedBlkInfo.block=getfullname(linkedBlks(ii));
            linkedBlkInfo.lib=Library{1};
            refedLinkedMdls=[refedLinkedMdls,refBlock];%#ok
            linkedBlksInfo=[linkedBlksInfo,linkedBlkInfo];%#ok
        end
    end
    this.fLinkedBlks=[this.fLinkedBlks,linkedBlksInfo];


    refedLinkedMdls=unique(refedLinkedMdls);
    for ii=1:length(refedLinkedMdls)
        if isempty(find(strcmpi(trvdMdls,refedLinkedMdls{ii}),1))
            mdlPath=strsplit(refedLinkedMdls{ii},'/');
            if~bdIsLoaded(mdlPath{1})
                if~isempty(aDir)
                    load_system([aDir,mdlPath{1}]);
                else
                    load_system(mdlPath{1});
                end
            end
            trvdMdls=[trvdMdls,refedLinkedMdls(ii)];%#ok
            trvdMdls=getAllMdlRefAndLibBlks(this,refedLinkedMdls{ii},aDir,trvdMdls);
        end
    end
    this.fRefMdls=unique(this.fRefMdls);
end

function isCandLib=isSimulinkLibrary(aLib)
    isCandLib=false;
    simulink_library_list={'simulink','simulink_need_slupdate'};
    if isempty(find(strcmpi(simulink_library_list,aLib),1))&&exist(aLib,'file')>0
        isCandLib=true;
    end
end
