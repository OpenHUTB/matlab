



function[mdlrefs,refmdls,linkedblks,trvd_mdls,loadedModels]=all_referlinked_blk(mdl,dir,trvd_mdls,includeCommentedMdl)



    if nargin<4

        includeCommentedMdl='on';
    end

    loadedModels={};
    referlinked_mdls=cell(1,0);
    mdlref_blks=find_system(mdl,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FindAll','on','IncludeCommented',includeCommentedMdl,'BlockType','ModelReference');
    linked_blks=find_system(mdl,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FindAll','on','IncludeCommented',includeCommentedMdl,'LinkStatus','resolved','BlockType','SubSystem');


    mdlrefs=struct('block',{},'refmdl',{});

    for ii=1:length(mdlref_blks)
        mdlref=struct('block',[],'refmdl',[]);
        if strcmpi(get_param(mdlref_blks(ii),'ProtectedModel'),'on')
            ExceptionLog=DAStudio.message('sl_pir_cpp:creator:UnsupportedProtectedModelForCloneDetection',getfullname(mdlref_blks(ii)));
            cloneDetectionExceptionLogObj=slEnginePir.util.CloneDetectionExceptionLog.getInstance;
            cloneDetectionExceptionLogObj.addException(ExceptionLog);
            continue;
        end
        mdlref.block=getfullname(mdlref_blks(ii));
        mdlvariants=get_param(mdlref_blks(ii),'Variants');
        if isempty(mdlvariants)
            t=get_param(mdlref_blks(ii),'ModelName');
            if~strcmp(t,'<Enter Model Name>')
                mdlref.refmdl={t};
            end
        else
            mdlref.refmdl=[];
            for m=1:length(mdlvariants)
                [~,refmdl_name,~]=fileparts(mdlvariants(m).ModelName);
                if~strcmp(refmdl_name,'<Enter Model Name>')
                    mdlref.refmdl=unique([mdlref.refmdl,{refmdl_name}],'stable');
                end
            end
        end
        if~isempty(mdlref.refmdl)
            mdlrefs=[mdlrefs,mdlref];%#ok
            referlinked_mdls=[referlinked_mdls,mdlref.refmdl];%#ok
        end
    end
    refmdls=unique(referlinked_mdls);


    linkedblks=struct('block',{},'lib',{});
    for ii=1:length(linked_blks)
        linked_blk=struct('block',[],'lib',[]);
        Library=strsplit(get_param(linked_blks(ii),'ReferenceBlock'),'/');
        if check_library(Library{1})
            linked_blk.block=getfullname(linked_blks(ii));
            linked_blk.lib=Library{1};
            referlinked_mdls=[referlinked_mdls,Library{1}];%#ok
            linkedblks=[linkedblks,linked_blk];%#ok
        end
    end

    referlinked_mdls=unique(referlinked_mdls);
    for ii=1:length(referlinked_mdls)
        if isempty(find(strcmpi(trvd_mdls,referlinked_mdls{ii}),1))
            trvd_mdls=[trvd_mdls,referlinked_mdls(ii)];

            if~bdIsLoaded(referlinked_mdls{ii})
                if exist([dir,referlinked_mdls{ii}],'file')>0
                    load_system([dir,referlinked_mdls{ii}]);
                    [~,modelNameWithoutExtension,~]=fileparts(referlinked_mdls{ii});
                    loadedModels=[loadedModels;modelNameWithoutExtension];
                else
                    continue;
                end
            end
            [sub_mdlrefs,sub_refmdls,sub_linkedblks,trvd_mdls,explicitlyLoadedModels]=...
            slEnginePir.all_referlinked_blk(referlinked_mdls{ii},dir,trvd_mdls,includeCommentedMdl);
            loadedModels=[loadedModels;explicitlyLoadedModels];
            mdlrefs=mergeModelReferenceBlocksStruct(mdlrefs,sub_mdlrefs);

            refmdls=unique([refmdls,sub_refmdls],'stable');
            linkedblks=[linkedblks,sub_linkedblks];
        end
    end
end


function topModelReferenceBlocks=mergeModelReferenceBlocksStruct(topModelReferenceBlocks,childModelReferenceBlock)

    tmpModelReferenceBlock=struct('block',{},'refmdl',{});
    for i=1:length(childModelReferenceBlock)
        flag=false;
        for j=1:length(topModelReferenceBlocks)
            if strcmp(topModelReferenceBlocks(j).block,childModelReferenceBlock(i).block)

                flag=true;
                break;
            end
        end
        if flag
            continue;
        else
            tmpModelReferenceBlock=[tmpModelReferenceBlock,childModelReferenceBlock(i)];
        end
    end
    topModelReferenceBlocks=[topModelReferenceBlocks,tmpModelReferenceBlock];
end


function is_cand_lib=check_library(lib)
    is_cand_lib=false;

    inside_mlroot=Advisor.component.isMWFile(sls_resolvename(lib));
    if inside_mlroot
        return;
    end

    simulink_library_list={'simulink','simulink_need_slupdate'};
    if isempty(find(strcmpi(simulink_library_list,lib),1))
        is_cand_lib=true;
    end
end


