



classdef m2m<handle
    properties(Access='public')
        creator;
        bd;
        sess;
        fOriMdl;
        mdl;
        mdlrefs;
        refmdls;
        linkedblks;
        xlinkedblks;
        libmdls;
        linkedcands;
        fXformedMdl;
        sim_mode;
        prefix;
        sys_constant_map;
        excluded_consts;
        candidate_blks;
        invalid_candidates;
        excluded_blks;
        excluded_libs;
        traceability_map;
        xformed_blks=struct('Operation',{},'Before',{},'After',{});
        prev_xforms=struct('Operation',{},'Before',{},'After',{});
        prev_subsystems=struct('Before',{},'After',{});
        xformed_subsystems=struct('Before',{},'After',{});
        switch_odtcs=struct('BlockName',{},'Datatype',{});
        removed_src_lines;
        removed_dst_lines;
        incr_mode;
        load_prev;
        variant_analyzed;
        xform_commands;
        err_msg;
        skipped_xforms;
        compiled;
        m2m_dir;
        libcopy_opt;
        variantMdls;
        actionSampleTimes;
        use_datadictionary;
        modified_configset;
        fTransformed;
        fUsingUI;
    end

    properties(Hidden)
        cleanup;
    end

    methods(Access='public')

        function m2m_obj=m2m(ori_sys,incr)

            if~license('test','SL_Verification_Validation')
                DAStudio.error('sl_pir_cpp:creator:MdlXformerLicenseFail');
            end

            if builtin('_license_checkout','SL_Verification_Validation','quiet')>0
                DAStudio.error('sl_pir_cpp:creator:MdlXformerLicenseCheckOutFail');
            end

            if nargin>1
                m2m_obj.incr_mode=incr;
                m2m_obj.load_prev=incr;
            else
                m2m_obj.incr_mode=0;
                m2m_obj.load_prev=0;
            end

            m2m_obj.excluded_blks=[];
            m2m_obj.excluded_libs={};
            m2m_obj.candidate_blks=[];
            m2m_obj.traceability_map=[];
            m2m_obj.xform_commands=[];
            m2m_obj.prefix='gen_';
            m2m_obj.fOriMdl=ori_sys;
            m2m_obj.err_msg=[];
            m2m_obj.skipped_xforms=struct('Block',{},'Reason',{});
            m2m_obj.sys_constant_map=containers.Map('KeyType','char','ValueType','any');
            m2m_obj.excluded_consts={};
            m2m_obj.mdlrefs=[];
            m2m_obj.refmdls=[];
            m2m_obj.linkedblks=[];
            m2m_obj.xlinkedblks=[];
            m2m_obj.libmdls=[];
            m2m_obj.linkedcands=containers.Map('KeyType','double','ValueType','any');
            m2m_obj.sim_mode=containers.Map('KeyType','char','ValueType','char');
            m2m_obj.removed_dst_lines=containers.Map('KeyType','char','ValueType','any');
            m2m_obj.removed_src_lines=containers.Map('KeyType','char','ValueType','any');
            m2m_obj.actionSampleTimes=containers.Map('KeyType','char','ValueType','double');
            m2m_obj.invalid_candidates=struct('Handle',{},'Constants',{});
            m2m_obj.variantMdls={};
            m2m_obj.fXformedMdl=ori_sys;
            m2m_obj.mdl=ori_sys;
            m2m_obj.libcopy_opt=1;
            m2m_obj.use_datadictionary=0;
            m2m_obj.modified_configset=containers.Map('KeyType','char','ValueType','any');
            m2m_obj.fTransformed=0;
            m2m_obj.fUsingUI=0;
            hilite_data1=struct('HiliteType','user1','ForegroundColor','black','BackgroundColor','yellow');
            hilite_data2=struct('HiliteType','user2','ForegroundColor','black','BackgroundColor','lightBlue');
            set_param(0,'HiliteAncestorsData',hilite_data1);
            set_param(0,'HiliteAncestorsData',hilite_data2);

            if~bdIsLoaded(ori_sys)
                open_system(ori_sys);
            end

            [m2m_obj.mdlrefs,m2m_obj.refmdls,m2m_obj.linkedblks]=all_referlinked_blk(m2m_obj,ori_sys,[],{});
            if~isempty(m2m_obj.linkedblks)
                m2m_obj.libmdls=unique({m2m_obj.linkedblks.lib});
            end

            for idx=1:length(m2m_obj.libmdls)
                if bdIsLoaded(m2m_obj.libmdls{idx})
                    load_system(m2m_obj.libmdls{idx});
                end
            end

            if hasSimscapeBlock(m2m_obj)
                DAStudio.error('sl_pir_cpp:creator:UnsupportedSimscapeModel');
            end

            m2m_obj.m2m_dir=['m2m_',ori_sys,'/'];



            should_load_previous(m2m_obj);


            if m2m_obj.load_prev
                backup_mdlrefs=m2m_obj.mdlrefs;
                backup_refmdls=m2m_obj.refmdls;
                backup_linkedblks=m2m_obj.linkedblks;

                m2m_obj.fXformedMdl=['gen_',m2m_obj.mdl];
                open_system([m2m_obj.m2m_dir,m2m_obj.mdl]);
                [m2m_obj.mdlrefs,m2m_obj.refmdls,m2m_obj.linkedblks]=all_referlinked_blk(m2m_obj,m2m_obj.mdl,[],{});
                if~isempty(m2m_obj.linkedblks)
                    m2m_obj.libmdls=unique({m2m_obj.linkedblks.lib});
                end
                rmpath(m2m_obj.m2m_dir);
                should_load_previous(m2m_obj);

                if~m2m_obj.load_prev
                    m2m_obj.mdl=ori_sys;
                    m2m_obj.fXformedMdl=['gen_',m2m_obj.mdl];
                    close_system(m2m_obj.refmdls);
                    close_system(m2m_obj.libmdls);
                    m2m_obj.mdlrefs=backup_mdlrefs;
                    m2m_obj.refmdls=backup_refmdls;
                    m2m_obj.linkedblks=backup_linkedblks;
                    m2m_obj.libmdls=backup_libmdls;
                end
            end




            mdls={m2m_obj.mdl};
            mdlref_blks=[];
            mdls=[mdls,m2m_obj.refmdls];
            if~isempty(m2m_obj.refmdls)
                mdlref_blks={m2m_obj.mdlrefs.block};
            end

            accelerator_in_foreach(m2m_obj);
            set_sim_normal(m2m_obj);

            m2m_dir=m2m_obj.m2m_dir;
            sim_mode=m2m_obj.sim_mode;
            m2m_obj.cleanup=onCleanup(@()m2mCleanupFcn(m2m_obj,m2m_dir,mdls,mdlref_blks,sim_mode));

            slEnginePir.PirCleanupFcn([{m2m_obj.mdl},m2m_obj.refmdls]);
            m2m_obj.variant_analyzed=false;




            if slfeature('EditTimePIRwCompileInfo')==1

                pirCreator=slEnginePir.CloneDetectionCreator(Simulink.SLPIR.Event.PostCompBlock);
                pirCreator.createGraphicalPir([{m2m_obj.mdl},m2m_obj.refmdls]);

                m2m_obj.creator=slEnginePir.PIRUpdate(Simulink.SLPIR.Event.PostCompBlock);
                m2m_obj.creator.add;
            else

                m2m_obj.creator=slEnginePir.PIRCreatorM2M(Simulink.SLPIR.Event.PostCompBlock,[{m2m_obj.mdl},m2m_obj.refmdls]);
                m2m_obj.creator.add;
            end

            set_param(m2m_obj.mdl,'SLPIR','on');
            m2m_obj.sess=Simulink.CMI.CompiledSession(Simulink.EngineInterfaceVal.byFiat);
            m2m_obj.bd=Simulink.CMI.CompiledBlockDiagram(m2m_obj.sess,m2m_obj.mdl);
            wstate=warning('QUERY','BACKTRACE');
            warning('OFF','BACKTRACE');
            ME=MException('','');
            try
                m2m_obj.bd.init;
            catch ME
            end

            warning(wstate);
            if~isempty(ME.message)
                DAStudio.error('sl_pir_cpp:creator:UnsimulatableModel',ori_sys);
            end
            m2m_obj.compiled=-1;
            excludeInvalidIfCandidate(m2m_obj);


            if m2m_obj.load_prev
                m2m_obj.import_map([m2m_dir,m2m_obj.mdl]);
            end
        end


        function excludeByLibs(m2m_obj,candidate)
            if~isempty(find(not(cellfun('isempty',strfind(m2m_obj.excluded_libs,candidate.Model))),1))
                m2m_obj.exclude(candidate.Handle);
            end
        end

        function flag=hasSimscapeBlock(m2m_obj)
            flag=false;
            mdls={m2m_obj.mdl};
            mdls=[mdls,m2m_obj.refmdls];
            for i=1:length(mdls)
                mdlname=mdls{i};


                simscapeblocks=find_system(mdlname,...
                'LookUnderMasks','all',...
                'FirstResultOnly',true,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FindAll','on',...
                'BlockType','SimscapeBlock');
                if~isempty(simscapeblocks)
                    flag=true;
                    return;
                end
            end
        end

        function excludeInvalidIfCandidate(m2m_obj)
            mdls={m2m_obj.mdl};
            mdls=[mdls,m2m_obj.refmdls];
            for mIdx=1:length(mdls)


                if_blks=find_system(mdls{mIdx},...
                'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FindAll','on',...
                'RegExp','on',...
                'BlockType','If|SwitchCase',...
                'Commented','off')';
                for ii=1:length(if_blks)
                    invalid_action=0;
                    connects=get_param(if_blks(ii),'PortConnectivity');
                    acts=[connects.DstBlock];
                    for aIdx=1:length(acts)

                        if strcmpi(get_param(acts(aIdx),'LinkStatus'),'resolved')
                            ref_blk=get_param(acts(aIdx),'ReferenceBlock');
                            invalid_candidate=struct('Handle',get_param(ref_blk,'Handle'),'Constants',-10);
                            m2m_obj.invalid_candidates=[m2m_obj.invalid_candidates,invalid_candidate];
                            invalid_action=1;

                        elseif strcmpi(get_param(acts(aIdx),'LinkStatus'),'implicit')
                            compiledSampleTime=get_param(acts(aIdx),'CompiledSampleTime');
                            ref_blk=get_param(acts(aIdx),'ReferenceBlock');
                            if isKey(m2m_obj.actionSampleTimes,ref_blk)
                                if compiledSampleTime~=m2m_obj.actionSampleTimes(ref_blk)
                                    invalid_candidate=struct('Handle',get_param(ref_blk,'Handle'),'Constants',-11);
                                    m2m_obj.invalid_candidates=[m2m_obj.invalid_candidates,invalid_candidate];
                                    invalid_action=1;
                                end
                            else
                                m2m_obj.actionSampleTimes(ref_blk)=compiledSampleTime(1);
                            end
                        end
                    end
                    if invalid_action
                        invalid_candidate=struct('Handle',if_blks(ii),'Constants',-10);
                        m2m_obj.invalid_candidates=[m2m_obj.invalid_candidates,invalid_candidate];
                    end
                end
            end
        end

        function[mdlrefs,refmdls,linkedblks,trvd_mdls]=all_referlinked_blk(m2m_obj,mdl,dir,trvd_mdls)
            referlinked_mdls=cell(1,0);
            mdlref_blks=find_system(mdl,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FindAll','on','BlockType','ModelReference','Commented','off');
            linked_blks=find_system(mdl,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FindAll','on','LinkStatus','resolved','BlockType','SubSystem','Commented','off');


            mdlrefs=struct('block',{},'refmdl',{});
            for ii=1:length(mdlref_blks)
                mdlref=struct('block',[],'refmdl',[]);
                if strcmpi(get_param(mdlref_blks(ii),'ProtectedModel'),'on')
                    DAStudio.error('sl_pir_cpp:creator:UnsupportedProtectedModel',getfullname(mdlref_blks(ii)));
                end
                mdlref.block=getfullname(mdlref_blks(ii));

                if exist(get_param(mdlref_blks(ii),'ModelName'),'file')>0
                    mdlref.refmdl={get_param(mdlref_blks(ii),'ModelName')};
                end
                if~isempty(mdlref.refmdl)
                    mdlrefs=[mdlrefs,mdlref];%#ok
                    referlinked_mdls=[referlinked_mdls,mdlrefs(ii).refmdl];%#ok
                end
            end
            refmdls=unique(referlinked_mdls);


            linkedblks=struct('block',{},'lib',{});
            for ii=1:length(linked_blks)
                linked_blk=struct('block',[],'lib',[]);
                refblock=get_param(linked_blks(ii),'ReferenceBlock');
                Library=strsplit(refblock,'/');
                if check_library(Library{1})
                    linked_blk.block=getfullname(linked_blks(ii));
                    linked_blk.lib=Library{1};
                    linkedblks=[linkedblks,linked_blk];%#ok
                    referlinked_mdls=[referlinked_mdls,refblock];%#ok
                end
            end

            referlinked_mdls=unique(referlinked_mdls);
            for ii=1:length(referlinked_mdls)
                if isempty(find(strcmpi(trvd_mdls,referlinked_mdls{ii}),1))
                    mdlPath=strsplit(referlinked_mdls{ii},'/');
                    if~bdIsLoaded(mdlPath{1})
                        if~isempty(dir)
                            load_system([dir,mdlPath{1}]);
                        else
                            load_system(mdlPath{1});
                        end
                    end
                    trvd_mdls=[trvd_mdls,referlinked_mdls(ii)];%#ok
                    [sub_mdlrefs,sub_refmdls,sub_linkedblks,trvd_mdls]=all_referlinked_blk(m2m_obj,referlinked_mdls{ii},dir,trvd_mdls);
                    mdlrefs=[mdlrefs,sub_mdlrefs];%#ok
                    refmdls=[refmdls,sub_refmdls];%#ok
                    linkedblks=[linkedblks,sub_linkedblks];%#ok
                end
            end
        end

        function xformed_blocks=get_xformed_blocks(m2m_obj)
            xformed_blocks=[];
            for i=1:length(m2m_obj.xformed_blks)
                xformed_blocks=[xformed_blocks;m2m_obj.xformed_blks(i).Before];%#ok
            end
            xformed_refblocks=[{},get_param(xformed_blocks,'ReferenceBlock')];
            xformed_refblocks=xformed_refblocks(~cellfun('isempty',xformed_refblocks));
            xformed_refblocks=get_param(xformed_refblocks,'Handle');
            xformed_blocks=[xformed_blocks;cell2mat(xformed_refblocks)];
        end

        function should_load_previous(m2m_obj)
            if~m2m_obj.load_prev
                return;
            end
            if exist([m2m_obj.m2m_dir,m2m_obj.fOriMdl,'.previous'],'file')
                m2m_obj.load_prev=true;
                mid_sys=fileread([m2m_obj.m2m_dir,m2m_obj.fOriMdl,'.previous']);
                if~exist([m2m_obj.m2m_dir,mid_sys,'.trace'],'file')
                    m2m_obj.load_prev=false;
                    return;
                end
                trace_file=dir([m2m_obj.m2m_dir,mid_sys,'.trace']);
                if trace_file.bytes==0
                    m2m_obj.load_prev=false;
                    return;
                end

                mdls={m2m_obj.mdl};
                mdls=[mdls,m2m_obj.refmdls];
                mdls=[mdls,m2m_obj.libmdls];
                for ii=1:length(mdls)
                    mdl_file=dir(which(mdls{ii}));
                    if mdl_file.datenum>trace_file.datenum
                        m2m_obj.load_prev=false;
                        return;
                    end
                end
                m2m_obj.mdl=mid_sys;
                addpath(m2m_obj.m2m_dir);
            else
                m2m_obj.load_prev=false;
            end
        end


































        function identify_result=identify(m2m_obj)
            identify_result={};
            m2m_obj.candidate_blks=struct('Model',{},'Handle',{},'Constants',{});
            mdls={m2m_obj.mdl};
            mdls=[mdls,m2m_obj.refmdls];

            for m=1:length(mdls)
                if~isempty(find(strcmpi(m2m_obj.variantMdls,mdls(m)),1))
                    continue;
                end
                gpc_off_ivblks=get_gpc_off_ivblks(mdls{m});



                if isempty(gpc_off_ivblks)
                    check_exportfcnmdl(m2m_obj,mdls{m});
                    invalid_cands=[m2m_obj.invalid_candidates.Handle];

                    result=m2m_variant_analyze(m2m_obj.creator,mdls{m},{},[m2m_obj.compiled,invalid_cands]);
                    for i=1:length(result.Candidates)
                        if result.Candidates(i).Constants<0
                            m2m_obj.invalid_candidates=[m2m_obj.invalid_candidates,result.Candidates(i)];
                        else
                            cand_handle=result.Candidates(i).Handle;
                            if strcmpi(get_param(cand_handle,'BlockType'),'If')||strcmpi(get_param(cand_handle,'BlockType'),'SwitchCase')
                                if check_invalid_refact(m2m_obj,cand_handle)
                                    continue;
                                end
                            end

                            linked_blk=getfullname(cand_handle);
                            link_status=get_param(linked_blk,'linkstatus');
                            if strcmpi(link_status,'implicit')||strcmpi(link_status,'resolved')
                                while~strcmpi(link_status,'resolved')
                                    linked_blk=get_param(linked_blk,'parent');
                                    link_status=get_param(linked_blk,'linkstatus');
                                end
                                link_data=get_param(linked_blk,'LinkData');
                                if isempty(link_data)
                                    ref_blk=get_param(cand_handle,'ReferenceBlock');
                                    ref_blk_handle=get_param(ref_blk,'handle');
                                    if~isKey(m2m_obj.linkedcands,ref_blk_handle)
                                        m2m_obj.linkedcands(ref_blk_handle)=cand_handle;
                                        candidate_blk.Model=bdroot(ref_blk);
                                        candidate_blk.Handle=ref_blk_handle;
                                        candidate_blk.Constants=unique(result.Candidates(i).Constants);
                                        m2m_obj.candidate_blks=[m2m_obj.candidate_blks,candidate_blk];
                                        excludeByLibs(m2m_obj,candidate_blk);
                                    else
                                        m2m_obj.linkedcands(ref_blk_handle)=[m2m_obj.linkedcands(ref_blk_handle),cand_handle];

                                        invalid_candidate=struct('Handle',cand_handle,'Constants',-12);
                                        m2m_obj.invalid_candidates=[m2m_obj.invalid_candidates,invalid_candidate];
                                    end
                                    continue;
                                end
                            end
                            candidate_blk=struct('Model',[],'Handle',[],'Constants',[]);
                            candidate_blk.Model=mdls{m};
                            candidate_blk.Handle=result.Candidates(i).Handle;
                            candidate_blk.Constants=unique(result.Candidates(i).Constants);
                            m2m_obj.candidate_blks=[m2m_obj.candidate_blks,candidate_blk];
                            excludeByLibs(m2m_obj,candidate_blk);
                        end
                    end
                else
                    msg=['Model to Model transform on [',mdls{m},'] will be skipped as currently models using inline variant block(s) with GPC off are not supported.'];
                    identify_result=[identify_result,msg];%#ok
                end
            end


            cands_const=struct('index',{},'consts',{});
            cands_wo_const=[];
            for cIdx=1:length(m2m_obj.candidate_blks)
                if isempty(m2m_obj.candidate_blks(cIdx).Constants)
                    cands_wo_const=[cands_wo_const,cIdx];%#ok
                    continue;
                end
                cand_const=struct('index',[],'consts',[]);
                cand_const.index=cIdx;
                cand_const.consts={};
                if length(m2m_obj.candidate_blks(cIdx).Constants)>1
                    cand_const.consts=sort(get_param(m2m_obj.candidate_blks(cIdx).Constants,'Value')');%#ok
                else
                    cand_const.consts={get_param(m2m_obj.candidate_blks(cIdx).Constants,'Value')};
                end
                cands_const=[cands_const,cand_const];
            end
            if~isempty(cands_const)
                all_consts=sort(unique([cands_const.consts]));
                sorted_cands=[];
                sorted_groups=struct('sys_const',[],'group',cands_const);
                for idx=1:length(all_consts)
                    temp_groups=struct('sys_const',{},'group',{});
                    for sIdx=1:length(sorted_groups)
                        matched_idx=[];
                        for cIdx=1:length(sorted_groups(sIdx).group)
                            if strcmpi(all_consts(idx),sorted_groups(sIdx).group(cIdx).consts(1))
                                sorted_groups(sIdx).group(cIdx).consts(1)=[];
                                matched_idx=[matched_idx,cIdx];
                            end
                        end
                        temp_group=struct('sys_const',[],'group',[]);
                        temp_group.sys_const=all_consts(idx);
                        temp_group.group=sorted_groups(sIdx).group(matched_idx);
                        sorted_cands_idx=[];
                        for cIdx=1:length(temp_group.group)
                            if isempty(temp_group.group(cIdx).consts)
                                sorted_cands_idx=[sorted_cands_idx,cIdx];
                            end
                        end
                        sorted_cands=[sorted_cands,temp_group.group(sorted_cands_idx)];
                        temp_group.group(sorted_cands_idx)=[];
                        if~isempty(temp_group.group)
                            temp_groups=[temp_groups,temp_group];
                        end
                        sorted_groups(sIdx).group(matched_idx)=[];
                        temp_groups=[temp_groups,sorted_groups(sIdx)];
                    end
                    sorted_groups=temp_groups;
                end
                no_const_candidates=[];
                for idx=1:length(cands_wo_const)
                    no_const_candidates=[no_const_candidates,m2m_obj.candidate_blks(cands_wo_const(idx))];
                end
                sorted_candidates=[];
                for idx=1:length(sorted_cands)
                    sorted_candidates=[sorted_candidates,m2m_obj.candidate_blks(sorted_cands(idx).index)];
                end
                m2m_obj.candidate_blks=[no_const_candidates,sorted_candidates];
            end
            m2m_obj.variant_analyzed=true;
        end

        function check_exportfcnmdl(m2m_obj,sys)
            if strcmpi(get_param(sys,'IsExportFunctionModel'),'on')
                exc_blks=find_system(sys,'SearchDepth','1','BlockType','Switch','Commented','off')';
                exc_blks=[exc_blks,find_system(sys,'SearchDepth','1','BlockType','MultiPortSwitch','Commented','off')'];
                exc_blks=[exc_blks,find_system(sys,'SearchDepth','1','BlockType','If','Commented','off')'];
                exc_blks=[exc_blks,find_system(sys,'SearchDepth','1','BlockType','SwitchCase','Commented','off')'];

                for ii=1:length(exc_blks)
                    invalid_candidate=struct('Handle',get_param(exc_blks{ii},'Handle'),'Constants',-11);
                    m2m_obj.invalid_candidates=[m2m_obj.invalid_candidates,invalid_candidate];
                end
            end
        end

        function invalid=check_invalid_refact(m2m_obj,cand_handle)
            invalid=0;
            connects=get_param(cand_handle,'PortConnectivity');
            dst=[connects.DstBlock];
            for ii=1:length(dst)
                ref_dst=get_param(dst(ii),'ReferenceBlock');
                if~isempty(ref_dst)&&~isempty(find([m2m_obj.invalid_candidates.Handle]==get_param(ref_dst,'Handle'),1))
                    invalid_candidate=struct('Handle',cand_handle,'Constants',-10);
                    m2m_obj.invalid_candidates=[m2m_obj.invalid_candidates,invalid_candidate];
                    invalid=1;
                    break;
                end
            end
        end


        function sysConst=get_all_sysconst(m2m_obj)
            sysConst={};
            if m2m_obj.use_datadictionary
                mdls={m2m_obj.mdl};
                mdls=[mdls,m2m_obj.refmdls];
                for mIdx=1:length(mdls)
                    try
                        dd=Simulink.data.dictionary.open(get_param(mdls{mIdx},'DataDictionary'));
                        if~isempty(dd)
                            ds=dd.getSection('Design Data');

                            slParams=ds.find('-value','-class','Simulink.Parameter');
                            for pIdx=1:length(slParams)
                                slParam=slParams(pIdx).getValue;
                                if strcmpi(slParam.CoderInfo.StorageClass,'Custom')&&...
                                    strcmp(slParam.CoderInfo.CustomStorageClass,'ImportedDefine')
                                    sysConst=[sysConst,slParams(pIdx).Name];
                                end
                            end

                            mdxParams=ds.find('-value','-class','mdx.SysConst');
                            for pIdx=1:length(mdxParams)
                                mdxParam=mdxParams(pIdx).getValue;
                                if~mdxParam.TargetUserData.IsLocal
                                    sysConst=[sysConst,mdxParams(pIdx).Name];
                                end
                            end
                            m2m_obj.sys_constant_map(mdls{mIdx})=sysConst;
                        end
                    catch
                    end
                end
            else
                ws=evalin('base','whos');
                idx=strcmpi({ws.class},'Simulink.Parameter');
                all_slparams={ws(idx).name};
                for ii=1:length(all_slparams)
                    slparam=evalin('base',all_slparams{ii});
                    if slparam.Dimensions(1)==1&&slparam.Dimensions(2)==1
                        sysConst=[sysConst,all_slparams(ii)];%#ok
                    end
                end
                m2m_obj.sys_constant_map('')=sysConst;
            end
        end


        function constants=get_variant_constants(m2m_obj)
            if~m2m_obj.variant_analyzed
                m2m_obj.identify;
            end
            if m2m_obj.sys_constant_map.Count==0
                m2m_obj.get_all_sysconst;
            end

            xformed_blocks=get_xformed_blocks(m2m_obj);

            if m2m_obj.use_datadictionary
                constants=struct('Model',{},'SysConsts',{});
                variant_sysconst_map=containers.Map('KeyType','char','ValueType','any');
                for i=1:length(m2m_obj.candidate_blks)
                    sys_constants={};
                    candidate_handle=m2m_obj.candidate_blks(i).Handle;
                    if~isempty(find(xformed_blocks==candidate_handle,1))
                        continue;
                    end
                    cand_mdl=m2m_obj.candidate_blks(i).Model;
                    if m2m_obj.use_datadictionary&&isKey(m2m_obj.sys_constant_map,cand_mdl)
                        sys_constants=m2m_obj.sys_constant_map(cand_mdl);
                    end

                    Consts=m2m_obj.candidate_blks(i).Constants;
                    for j=1:length(Consts)
                        constVal=get_param(Consts(j),'Value');
                        if~isempty(find(strcmpi(sys_constants,constVal),1))
                            if isKey(variant_sysconst_map,cand_mdl)
                                variant_sysconst_map(cand_mdl)=[variant_sysconst_map(cand_mdl),constVal];
                            else
                                variant_sysconst_map(cand_mdl)={constVal};
                            end
                        end
                    end
                end
                map_keys=keys(variant_sysconst_map);
                for kIdx=1:length(map_keys)
                    mdl_constant=struct('Model',map_keys{kIdx},'SysConsts',unique(variant_sysconst_map(map_keys{kIdx})));
                    constants=[constants,mdl_constant];
                end
            else
                constants={};
                sys_constants=m2m_obj.sys_constant_map('');
                for i=1:length(m2m_obj.candidate_blks)
                    candidate_handle=m2m_obj.candidate_blks(i).Handle;
                    if m2m_obj.fUsingUI==0&&~isempty(find(xformed_blocks==candidate_handle,1))
                        continue;
                    end
                    Consts=m2m_obj.candidate_blks(i).Constants;
                    for j=1:length(Consts)
                        if~isempty(find(strcmpi(sys_constants,get_param(Consts(j),'Value')),1))
                            constants=[constants,get_param(Consts(j),'Value')];%#ok
                        end
                    end
                end
                constants=unique(constants);
            end
        end

        function set_variant_constants(m2m_obj,sys_constants)
            if m2m_obj.use_datadictionary
                if isa(sys_constants,'containers.Map')
                    m2m_obj.sys_constant_map=sys_constants;
                else
                    error('If the target model is using data dictionary, user-specified system constants need to be provided in a container.Map');
                end
            else
                if isempty(sys_constants)
                    m2m_obj.get_all_sysconst;
                elseif isa(sys_constants,'cell')
                    m2m_obj.sys_constant_map('')=sys_constants;
                else
                    error('User-specified system constants need to be provided in a cell array');
                end
            end
        end

        function[candidates,handles]=get_variant_candidates(m2m_obj,filter_xformed)
            filter_xformed_cands=1;
            if nargin>1
                filter_xformed_cands=filter_xformed;
            end

            if~m2m_obj.variant_analyzed
                m2m_obj.identify;
            end

            handles=[];
            candidates=struct('Model',{},'Block',{},'Handle',{},'Operation',{},'Constants',{});

            if m2m_obj.sys_constant_map.Count==0
                m2m_obj.get_all_sysconst;
            end

            xformed_blocks=get_xformed_blocks(m2m_obj);

            sys_consts={};
            if~m2m_obj.use_datadictionary&&isKey(m2m_obj.sys_constant_map,'')
                sys_consts=m2m_obj.sys_constant_map('');
            end

            for i=1:length(m2m_obj.candidate_blks)
                cand_mdl=m2m_obj.candidate_blks(i).Model;
                if m2m_obj.use_datadictionary&&isKey(m2m_obj.sys_constant_map,cand_mdl)
                    sys_consts=m2m_obj.sys_constant_map(cand_mdl);
                end
                Valid=true;
                Consts=m2m_obj.candidate_blks(i).Constants;
                const_vals=cell([1,length(Consts)]);
                for j=1:length(Consts)
                    const_vals{j}=get_param(Consts(j),'Value');
                    if isempty(find(strcmpi(sys_consts,const_vals{j}),1))||~isempty(find(strcmpi(m2m_obj.excluded_consts,const_vals{j}),1))
                        Valid=false;
                    end
                end

                candidate_handle=m2m_obj.candidate_blks(i).Handle;
                if filter_xformed_cands&&~isempty(find(xformed_blocks==candidate_handle,1))
                    Valid=false;
                end

                if Valid
                    candidate=struct('Model',[],'Block',[],'Handle',[],'Operation',[],'Constants',[]);
                    candidate.Model=m2m_obj.candidate_blks.Model;
                    candidate.Handle=candidate_handle;
                    candidate.Block=getfullname(candidate_handle);
                    candidate.Constants=sort(const_vals);
                    ctype=get_param(candidate.Handle,'BlockType');
                    if strcmpi(ctype,'If')||strcmpi(ctype,'SwitchCase')
                        candidate.Operation='If to Variant';
                    elseif strcmpi(ctype,'Switch')||strcmpi(ctype,'MultiPortSwitch')
                        candidate.Operation='Switch to Variant';
                    end
                    candidates=[candidates,candidate];%#ok
                    if strcmpi(get_param(candidate.Handle,'LinkStatus'),'none')
                        handle=candidate.Handle;
                    else
                        handle=get_param(get_param(candidate.Handle,'ReferenceBlock'),'Handle');
                    end
                    handles=[handles,handle];%#ok
                end
            end
        end

        function exclusions=show_exclusion(m2m_obj)
            exclusion=struct('Block',[],'Handle',[]);
            exclusions=repmat(exclusion,1,length(m2m_obj.excluded_blks));
            for i=1:length(m2m_obj.excluded_blks)
                fullname=getfullname(m2m_obj.excluded_blks(i));
                exclusions(i).Handle=get_param(fullname,'handle');
                exclusions(i).Block=fullname;
            end
        end

        function exclude_const(m2m_obj,const)
            m2m_obj.excluded_consts=unique([m2m_obj.excluded_consts,const]);
        end

        function include_const(m2m_obj,const)
            idx=find(strcmpi(m2m_obj.excluded_consts,const),1);
            if~isempty(idx)
                m2m_obj.excluded_consts(idx)=[];
            end
        end

        function isExcluded=is_excluded_const(m2m_obj,const)
            idx=find(strcmpi(m2m_obj.excluded_consts,const),1);
            if~isempty(idx)
                isExcluded=1;
            else
                isExcluded=0;
            end
        end

        function exclude_libs(m2m_obj,libs)
            if iscell(libs)
                run_exclusion=0;
                for ii=1:length(libs)
                    if bdIsLoaded(libs{ii})&&bdIsLibrary(libs{ii})
                        run_exclusion=1;
                        m2m_obj.excluded_libs=[m2m_obj.excluded_libs,libs(ii)];
                    end
                end
                m2m_obj.excluded_libs=unique(m2m_obj.excluded_libs);
                if run_exclusion
                    for ii=1:length(m2m_obj.candidate_blks)
                        excludeByLibs(m2m_obj,m2m_obj.candidate_blks(ii));
                    end
                end
            end
        end

        function include_libs(m2m_obj,libs)
            if iscell(libs)
                idx=find(ismember(m2m_obj.excluded_libs,libs));
                m2m_obj.excluded_libs(idx)=[];
            end
        end

        function exclude(m2m_obj,blk)
            if isa(blk,'double')
                handle=blk;
            else
                handle=get_param(blk,'handle');
            end

            if isKey(m2m_obj.linkedcands,handle)
                handle=[handle,m2m_obj.linkedcands(handle)];
            end

            m2m_obj.excluded_blks=unique([m2m_obj.excluded_blks,handle]);
        end

        function include(m2m_obj,blk)
            if isa(blk,'double')
                handle=blk;
            else
                handle=get_param(blk,'handle');
            end

            if isKey(m2m_obj.linkedcands,handle)
                handle=[handle,m2m_obj.linkedcands(handle)];
            end

            for ii=1:length(handle)
                idx=find([m2m_obj.excluded_blks]==handle(ii));
                if~isempty(idx)
                    m2m_obj.excluded_blks(idx)=[];
                end
            end
        end

        function isExcluded=is_excluded_blk(m2m_obj,blk)
            if isa(blk,'double')
                handle=blk;
            else
                handle=get_param(blk,'handle');
            end
            idx=find([m2m_obj.excluded_blks]==handle,1);
            if~isempty(idx)
                isExcluded=1;
            else
                isExcluded=0;
            end
        end

        function isCandidate=is_candidate_blk(m2m_obj,blk)
            if isa(blk,'double')
                handle=blk;
            else
                handle=get_param(blk,'handle');
            end
            isCandidate=[];
            idx=find([m2m_obj.candidate_blks.Handle]==handle,1);

            if~isempty(idx)
                consts=get_param(m2m_obj.candidate_blks(idx).Constants,'Value');
                if isa(consts,'char')
                    consts={consts};
                end
                sys_consts=m2m_obj.sys_constant_map('');
                if~isempty(sys_consts)&&check_cand_const(sys_consts,consts)
                    isCandidate=get_param(handle,'BlockType');
                end
            end
        end


        function identify_result=if2variant(m2m_obj)
            identify_result={};
            if~m2m_obj.variant_analyzed
                m2m_obj.identify;
            end




            if m2m_obj.sys_constant_map.Count==0
                m2m_obj.get_all_sysconst;
            end

            sys_consts={};
            if~m2m_obj.use_datadictionary
                sys_consts=get_variant_params(m2m_obj.sys_constant_map(''),m2m_obj.excluded_consts);
            end

            mdls={m2m_obj.mdl};
            mdls=[mdls,m2m_obj.refmdls];
            for m=1:length(mdls)
                if~isempty(find(strcmpi(m2m_obj.variantMdls,mdls(m)),1))
                    continue;
                end
                if m2m_obj.use_datadictionary&&isKey(m2m_obj.sys_constant_map,mdls{m})
                    sys_consts=get_variant_params(m2m_obj.sys_constant_map(mdls{m}),m2m_obj.excluded_consts);
                end
                gpc_off_ivblks=get_gpc_off_ivblks(mdls{m});



                if isempty(gpc_off_ivblks)
                    invalid_cands=[m2m_obj.invalid_candidates.Handle];
                    result=m2m_if2variant(m2m_obj.creator,mdls{m},sys_consts,[invalid_cands,m2m_obj.excluded_blks]);
                    for i=1:length(result.Xformed_Blks)
                        m2m_obj.xformed_blks=[m2m_obj.xformed_blks,result.Xformed_Blks(i)];
                    end
                    for i=1:length(result.Xform_Cmds)
                        m2m_obj.xform_commands=[m2m_obj.xform_commands,result.Xform_Cmds(i)];
                    end
                    for i=1:length(result.Skipped)
                        m2m_obj.skipped_xforms=[m2m_obj.skipped_xforms,result.Skipped(i)];
                        invalid_candidate=struct('Handle',get_param(result.Skipped(i).Block,'Handle'),'Constants',-13);
                        m2m_obj.invalid_candidates=[m2m_obj.invalid_candidates,invalid_candidate];
                    end
                else
                    if~isempty(gpc_off_ivblks)
                        msg=['Variant transform on [',mdls{m},'] is skipped as the model has inline variant block(s) with GPC off are not supported.'];
                    end
                    identify_result=[identify_result,msg];%#ok
                end
            end
        end

        function identify_result=sw2varsrc(m2m_obj)
            identify_result={};
            if~m2m_obj.variant_analyzed
                m2m_obj.identify;
            end





            if m2m_obj.sys_constant_map.Count==0
                m2m_obj.get_all_sysconst;
            end

            sys_consts={};
            if~m2m_obj.use_datadictionary
                sys_consts=get_variant_params(m2m_obj.sys_constant_map(''),m2m_obj.excluded_consts);
            end

            mdls={m2m_obj.mdl};
            mdls=[mdls,m2m_obj.refmdls];
            for m=1:length(mdls)
                if~isempty(find(strcmpi(m2m_obj.variantMdls,mdls(m)),1))
                    continue;
                end
                if m2m_obj.use_datadictionary&&isKey(m2m_obj.sys_constant_map,mdls{m})
                    sys_consts=get_variant_params(m2m_obj.sys_constant_map(mdls{m}),m2m_obj.excluded_consts);
                end
                gpc_off_ivblks=get_gpc_off_ivblks(mdls{m});



                if isempty(gpc_off_ivblks)
                    invalid_cands=[m2m_obj.invalid_candidates.Handle];
                    result=m2m_sw2varsrc(m2m_obj.creator,mdls{m},sys_consts,[invalid_cands,m2m_obj.excluded_blks]);
                    for i=1:length(result.Xformed_Blks)
                        m2m_obj.xformed_blks=[m2m_obj.xformed_blks,result.Xformed_Blks(i)];
                    end
                    for i=1:length(result.Xform_Cmds)
                        m2m_obj.xform_commands=[m2m_obj.xform_commands,result.Xform_Cmds(i)];
                    end
                    for i=1:length(result.Skipped)
                        m2m_obj.skipped_xforms=[m2m_obj.skipped_xforms,result.Skipped(i)];
                        invalid_candidate=struct('Handle',get_param(result.Skipped(i).Block,'Handle'),'Constants',-13);
                        m2m_obj.invalid_candidates=[m2m_obj.invalid_candidates,invalid_candidate];
                    end
                else
                    if~isempty(gpc_off_ivblks)
                        msg=['Variant transform on [',mdls{m},'] is skipped as the model has inline variant block(s) with GPC off are not supported.'];
                    end
                    identify_result=[identify_result,msg];%#ok
                end
            end
        end



        function[mdls,linkedblkInXformedLibs]=transformedModels(m2m_obj)
            mdls={m2m_obj.mdl};
            xformedLibs={};
            mdls=[mdls,m2m_obj.refmdls];

            xformedblks_in_libs={};
            for xIdx=1:length(m2m_obj.xformed_blks)
                handle=m2m_obj.xformed_blks(xIdx).Before(1);
                if(strcmpi(get_param(handle,'LinkStatus'),'resolved')||strcmpi(get_param(handle,'LinkStatus'),'implicit'))
                    xformedLibs=[xformedLibs,bdroot(get_param(handle,'ReferenceBlock'))];%#ok
                    xformedblks_in_libs=[xformedblks_in_libs;get_param(m2m_obj.xformed_blks(xIdx).Before,'ReferenceBlock')];%#ok
                end
            end
            xformedLibs=unique(xformedLibs);
            for ii=1:length(xformedblks_in_libs)
                if~strcmpi(get_param(xformedblks_in_libs(ii),'BlockType'),'SubSystem')
                    xformedblks_in_libs(ii)=get_param(xformedblks_in_libs(ii),'Parent');%#ok
                end
            end
            xformedblks_in_libs=unique(xformedblks_in_libs);


            linked_blks=m2m_obj.linkedblks;
            if m2m_obj.libcopy_opt==0
                xformedLibs=m2m_obj.libmdls;
                linkedblkInXformedLibs=m2m_obj.linkedblks;

            elseif m2m_obj.libcopy_opt==1
                [linkedblkInXformedLibs,xformedLibs]=libcopy_option1(linked_blks,xformedLibs,xformedblks_in_libs);

            else
                [linkedblkInXformedLibs,xformedLibs]=libcopy_option2(linked_blks,xformedLibs);
            end
            mdls=unique([mdls,xformedLibs]);
        end

        function set_model_param(m2m_obj,mdl,param,value)
            if m2m_obj.use_datadictionary
                cfs_ref=getActiveConfigSet(mdl);
                if isa(cfs_ref,'Simulink.ConfigSetRef')
                    cfs=cfs_ref.getRefConfigSet;

                    cfsName=cfs_ref.WSVarName;
                    if isKey(m2m_obj.modified_configset,cfsName)
                        modified_params=m2m_obj.modified_configset(cfsName);
                    else
                        modified_params=containers.Map('KeyType','char','ValueType','any');
                        copy_datadictionary(m2m_obj,mdl);
                        cfs_ref=getActiveConfigSet(mdl);
                        cfs=cfs_ref.getRefConfigSet;
                    end
                    modified_params(param)=value;
                    m2m_obj.modified_configset(cfsName)=modified_params;
                    set_param(cfs,param,value);
                end
            else
                set_param(mdl,param,value);
            end
        end

        function copy_datadictionary(m2m_obj,mdl)
            addpath(m2m_obj.m2m_dir);
            ddFile=get_param(mdl,'datadictionary');
            if exist([m2m_obj.m2m_dir,m2m_obj.prefix,ddFile],'file')==2
                delete([m2m_obj.m2m_dir,m2m_obj.prefix,ddFile]);
            end
            copyfile(ddFile,[m2m_obj.m2m_dir,m2m_obj.prefix,ddFile],'f');
            dd=Simulink.data.dictionary.open([m2m_obj.prefix,ddFile]);
            try
                dd.removeDataSource(ddFile);
                dd.addDataSource([m2m_obj.prefix,ddFile]);
            catch
            end
            dd.saveChanges();
            set_param(mdl,'datadictionary',[m2m_obj.prefix,ddFile]);
            dd.close();
        end

        function initGenModels(m2m_obj,prefix,mdls)
            if exist(m2m_obj.m2m_dir,'dir')==0
                mkdir(m2m_obj.m2m_dir);
            end

            if m2m_obj.libcopy_opt==0
                mdls={m2m_obj.mdl};
                mdls=[mdls,m2m_obj.refmdls,m2m_obj.libmdls];
                m2m_obj.xlinkedblks=m2m_obj.linkedblks;
            end

            xformedLibs={};

            for m=1:length(mdls)
                if~strcmpi(mdls{m},'simulink')
                    close_system([prefix,mdls{m}],0);
                    mdlfullname=which(mdls{m});
                    [~,~,ext]=fileparts(mdlfullname);

                    if exist([m2m_obj.m2m_dir,prefix,mdls{m},ext],'file')==2
                        delete([m2m_obj.m2m_dir,prefix,mdls{m},ext]);
                    end
                    copyfile(mdlfullname,[m2m_obj.m2m_dir,prefix,mdls{m},ext],'f');
                    fileattrib([m2m_obj.m2m_dir,prefix,mdls{m},ext],'+w');
                    load_system([m2m_obj.m2m_dir,prefix,mdls{m}]);
                    if strcmpi(get_param([prefix,mdls{m}],'BlockDiagramType'),'library')
                        xformedLibs=[xformedLibs,mdls(m)];%#ok
                        set_param([prefix,mdls{m}],'lock','off');
                    end
                end
            end
            for m=1:length(m2m_obj.mdlrefs)
                dlg=bdroot(m2m_obj.mdlrefs(m).block);
                if~bdIsLibrary(dlg)||~isempty(find(strcmp({xformedLibs},dlg),1))

                    set_param([prefix,m2m_obj.mdlrefs(m).block],'ModelName',[prefix,m2m_obj.mdlrefs(m).refmdl{1}]);
                end
            end

            m2m_obj.fXformedMdl=[prefix,m2m_obj.mdl];

            for ii=1:length(m2m_obj.xlinkedblks)
                linked_blk=m2m_obj.xlinkedblks(ii).block;
                delete_block([prefix,linked_blk]);
                referenceblk=get_param(linked_blk,'ReferenceBlock');
                add_block([prefix,referenceblk],[prefix,linked_blk]);
                slEnginePir.util.copyInfoToNewLinkedBlk([prefix,linked_blk],linked_blk);
            end


            save_system([m2m_obj.prefix,m2m_obj.mdl],[m2m_obj.m2m_dir,m2m_obj.prefix,m2m_obj.mdl],'SaveDirtyReferencedModels','on');%#ok
            for m=1:length(m2m_obj.refmdls)
                save_system([m2m_obj.prefix,m2m_obj.refmdls{m}],[m2m_obj.m2m_dir,m2m_obj.prefix,m2m_obj.refmdls{m}],'SaveDirtyReferencedModels','on');%#ok
            end
            for m=1:length(xformedLibs)
                save_system([prefix,xformedLibs{m}],[m2m_obj.m2m_dir,prefix,xformedLibs{m}],'SaveDirtyReferencedModels','on');
            end


            close_system([m2m_obj.prefix,m2m_obj.mdl]);
            for m=1:length(m2m_obj.refmdls)
                close_system([m2m_obj.prefix,m2m_obj.refmdls{m}]);
            end
            for m=1:length(xformedLibs)
                close_system([prefix,xformedLibs{m}]);
            end


            for m=1:length(xformedLibs)
                load_system([m2m_obj.m2m_dir,prefix,xformedLibs{m}]);
            end
            warnId='Simulink:modelReference:ModelNotFoundWithBlockName';
            warning('off',warnId);
            for m=1:length(m2m_obj.refmdls)
                load_system([m2m_obj.m2m_dir,m2m_obj.prefix,m2m_obj.refmdls{m}]);
            end
            warning('on',warnId);
            load_system([m2m_obj.m2m_dir,m2m_obj.prefix,m2m_obj.mdl]);
        end

        function set_param(m2m_obj,blk,param,value)
            set_param([m2m_obj.prefix,blk],param,value);
        end

        function add_block(m2m_obj,src,dest)
            add_block(src,[m2m_obj.prefix,dest]);
            if~strcmpi(src,'built-in/VariantSource')
                return;
            end
            sys=get_param([m2m_obj.prefix,dest],'Parent');
            while~isempty(sys)
                try
                    if strcmpi(get_param(sys,'Variant'),'on')&&strcmpi(get_param(sys,'PropagateVariantConditions'),'off')
                        set_param(sys,'PropagateVariantConditions','on');
                    end
                catch
                end
                sys=get_param(sys,'Parent');
            end
        end

        function delete_action_port(m2m_obj,actPort)
            actionSS=get_param([m2m_obj.prefix,actPort],'Parent');
            set_param(actionSS,'TreatAsAtomicUnit','on');
            try
                compiledSampleTime=get_param(actPort,'CompiledSampleTime');
                set_param(actionSS,'SystemSampleTime',num2str(compiledSampleTime(1)));
            catch
                potentialIndices=[];
                for sIdx=1:length(m2m_obj.xformed_subsystems)
                    if strfind([m2m_obj.prefix,actPort],m2m_obj.xformed_subsystems(sIdx).After)==1
                        potentialIndices=[potentialIndices,sIdx];
                    end
                end
                maxStrLen=0;
                matchIdx=0;
                for sIdx=1:length(potentialIndices)
                    strLen=length(m2m_obj.xformed_subsystems(potentialIndices(sIdx)).After);
                    if strLen>maxStrLen
                        matchIdx=potentialIndices(sIdx);
                        maxStrLen=strLen;
                    end
                end
                if matchIdx>0
                    oriActPort=[m2m_obj.xformed_subsystems(matchIdx).Before...
                    ,actPort(length(m2m_obj.xformed_subsystems(matchIdx).After)-length(m2m_obj.prefix)+1:end)];
                    compiledSampleTime=get_param(oriActPort,'CompiledSampleTime');
                    set_param(actionSS,'SystemSampleTime',num2str(compiledSampleTime(1)));
                end
            end
            delete_block([m2m_obj.prefix,actPort]);
        end

        function delete_block(m2m_obj,blk)
            delete_block([m2m_obj.prefix,blk]);
        end

        function copy_block_to_subsystem(m2m_obj,src,dest)
            position=get_param([m2m_obj.prefix,src],'position');
            add_block([m2m_obj.prefix,src],[m2m_obj.prefix,dest],'position',position);
        end

        function set_fixdt_by_name(m2m_obj,blk,named_type)
            try
                type_obj=fixdt(named_type);
                type_str=fixdt(type_obj);
                set_param([m2m_obj.prefix,blk],'OutDataTypeStr',type_str);
            catch
            end
        end


        function add_line(m2m_obj,sys,outport,inport)
            add_line([m2m_obj.prefix,sys],outport,inport,'autorouting','on');
            seg=[];
            if isKey(m2m_obj.removed_dst_lines,[m2m_obj.prefix,sys,'/',outport])
                seg=m2m_obj.removed_dst_lines([m2m_obj.prefix,sys,'/',outport]);
            elseif isKey(m2m_obj.removed_src_lines,[m2m_obj.prefix,sys,'/',inport])
                seg=m2m_obj.removed_src_lines([m2m_obj.prefix,sys,'/',inport]);
            end
            if~isempty(seg)
                port=strsplit(outport,'/');
                lh=get_param([m2m_obj.prefix,sys,'/',port{1}],'LineHandles');
                new_seg=get_param(lh.Outport(str2double(port{2})),'object');
                set_segement_param(new_seg,seg);
            end
        end

        function delete_signal(m2m_obj,sys,outport,inport)
            port=strsplit(outport,'/');
            lh=get_param([m2m_obj.prefix,sys,'/',port{1}],'LineHandles');
            seg=get_param(lh.Outport(str2double(port{2})),'object');
            m2m_obj.removed_dst_lines([m2m_obj.prefix,sys,'/',outport])=seg.get;
            m2m_obj.removed_src_lines([m2m_obj.prefix,sys,'/',inport])=seg.get;
            delete_line([m2m_obj.prefix,sys],outport,inport);
        end

        function set_pos_overlap(m2m_obj,new_blk,ori_blk)
            set_param([m2m_obj.prefix,new_blk],'position',get_param(ori_blk,'position'));
        end

        function set_pos_refer_to(m2m_obj,blk,ref,dir,dist)
            pos=get_param([m2m_obj.prefix,blk],'position');
            if strcmpi(get_param([m2m_obj.prefix,blk],'BlockType'),'DataTypeConversion')
                width=30;
                height=30;
            else
                width=pos(3)-pos(1);
                height=pos(4)-pos(2);
            end

            try
                ref_pos=get_param([m2m_obj.prefix,ref],'position');
            catch
            end

            if isempty(ref)
                pos(1)=200;
                pos(2)=200;
                pos(3)=pos(1)+width;
                pos(4)=pos(2)+height;
            elseif dir=='o'
                pos=ref_pos;
            elseif dir=='n'
                pos(4)=ref_pos(2)-dist;
                pos(2)=pos(4)-height;
                mid=(ref_pos(1)+ref_pos(3))/2;
                pos(1)=mid-(width/2);
                pos(3)=mid+(width/2);
            elseif dir=='s'
                pos(2)=ref_pos(4)+dist;
                pos(4)=pos(2)+height;
                mid=(ref_pos(1)+ref_pos(3))/2;
                pos(1)=mid-(width/2);
                pos(3)=mid+(width/2);
            elseif dir=='w'
                pos(3)=ref_pos(1)-dist;
                pos(1)=pos(3)-width;
                mid=(ref_pos(2)+ref_pos(4))/2;
                pos(2)=mid-(height/2);
                pos(4)=mid+(height/2);
            else
                pos(1)=ref_pos(3)+dist;
                pos(3)=pos(1)+width;
                mid=(ref_pos(2)+ref_pos(4))/2;
                pos(2)=mid-(height/2);
                pos(4)=mid+(height/2);
            end
            set_param([m2m_obj.prefix,blk],'position',pos);
        end

        function set_pos_subsys(m2m_obj,ss_comp)
            center=[0,0];
            width=0;
            height=0;
            blocks=get_param([m2m_obj.prefix,ss_comp],'Blocks');
            for ii=1:length(blocks)
                position=get_param([m2m_obj.prefix,ss_comp,'/',blocks{ii}],'position');
                width=max(width,position(3)-position(1));
                height=height+(position(4)-position(2));
                center=center+[(position(3)+position(1))/2,(position(4)+position(2))/2];
            end

            center=center/length(blocks);
            position(1)=center(1)-(width/2);
            position(3)=center(1)+(width/2);
            position(2)=center(2)-(height/2);
            position(4)=center(2)+(height/2);
            set_param([m2m_obj.prefix,ss_comp],'position',position);
        end

        function add_trace(m2m_obj,xformed_blk,ori_blk)
            for ii=1:length(m2m_obj.traceability_map)
                if~isempty(find([m2m_obj.traceability_map(ii).Before]==get_param(ori_blk,'handle'),1))
                    m2m_obj.traceability_map(ii).After=[m2m_obj.traceability_map(ii).After,{[m2m_obj.prefix,xformed_blk]}];
                    break;
                end
            end
        end

        function insert_odtc(m2m_obj,xformed_blk,ori_blk)
            switch_odtc=[];
            if strcmpi(get_param([m2m_obj.prefix,xformed_blk],'BlockType'),'VariantSource')&&...
                (strcmpi(get_param(ori_blk,'BlockType'),'Switch')||strcmpi(get_param(ori_blk,'BlockType'),'MultiPortSwitch'))&&...
                ~strcmpi(get_param(ori_blk,'OutDataTypeStr'),'Inherit: Inherit via internal rule')&&...
                ~strcmpi(get_param(ori_blk,'OutDataTypeStr'),'Inherit: Inherit via back propagation')
                switch_odtc=struct('BlockName',xformed_blk,'Datatype',get_param(ori_blk,'OutDataTypeStr'));
            end

            if~isempty(switch_odtc)
                m2m_obj.switch_odtcs=[m2m_obj.switch_odtcs,switch_odtc];
            end
        end

        function insert_odtcs(m2m_obj)
            for ii=1:length(m2m_obj.switch_odtcs)
                blk=[m2m_obj.prefix,m2m_obj.switch_odtcs(ii).BlockName];
                linehandles=get_param(blk,'LineHandles');
                seg=get_param(linehandles.Outport,'object');
                DstBlocks=seg.DstBlockHandle;
                DstPorts=seg.DstPortHandle;
                sys=get_param(blk,'Parent');
                srcblk=get_param(blk,'Name');
                add_block('built-in/datatypeconversion',[blk,'_odtc'],'OutDataTypeStr',m2m_obj.switch_odtcs(ii).Datatype);
                set_pos_refer_to(m2m_obj,[m2m_obj.switch_odtcs(ii).BlockName,'_odtc'],m2m_obj.switch_odtcs(ii).BlockName,'e',20);
                add_line(sys,[srcblk,'/1'],[srcblk,'_odtc/1']);
                for jj=1:length(DstBlocks)
                    dstblk=get_param(DstBlocks(jj),'Name');
                    dstport=num2str(get_param(DstPorts(jj),'PortNumber'));
                    delete_line(sys,[srcblk,'/1'],[dstblk,'/',dstport]);
                    add_line(sys,[srcblk,'_odtc/1'],[dstblk,'/',dstport]);
                end
            end
        end


        function update_trace_map(m2m_obj,new_subsys,old_subsys)
            for ii=1:length(m2m_obj.traceability_map)
                for jj=1:length(m2m_obj.traceability_map(ii).After)
                    if strfind(m2m_obj.traceability_map(ii).After{jj},[m2m_obj.prefix,old_subsys])==1
                        after_string=m2m_obj.traceability_map(ii).After{jj};
                        after_string=[m2m_obj.prefix,new_subsys,after_string(length([m2m_obj.prefix,old_subsys])+1:end)];
                        m2m_obj.traceability_map(ii).After{jj}=after_string;
                    end
                end
            end
        end

        function add_subsys_map(m2m_obj,xformed_blk,ori_blk)
            ori_blk_fullname=getfullname(ori_blk);
            subsys_map=struct('Before',ori_blk_fullname,'After',[m2m_obj.prefix,xformed_blk]);
            m2m_obj.xformed_subsystems=[m2m_obj.xformed_subsystems,subsys_map];
        end

        function msg=genmodel(m2m_obj,prefix)
            if~m2m_obj.variant_analyzed
                m2m_obj.identify;
            end
            if m2m_obj.compiled<0
                m2m_obj.bd.term;
                m2m_obj.compiled=0;
            end
            restore_sim_mode(m2m_obj);

            m2m_obj.switch_odtcs=struct('BlockName',{},'Datatype',{});

            m2m_dir=['m2m_',m2m_obj.fOriMdl];%#ok
            m2m_dir=[m2m_dir,'/'];%#ok
            set_param(m2m_obj.mdl,'HiliteAncestors','off');
            msg=[];
            num_new_xform=length(m2m_obj.xformed_blks);
            m2m_obj.xformed_subsystems=[];
            m2m_obj.traceability_map=m2m_obj.xformed_blks;


            m2m_obj.removed_dst_lines=containers.Map('KeyType','char','ValueType','any');
            m2m_obj.removed_src_lines=containers.Map('KeyType','char','ValueType','any');


            if nargin>1&&~isempty(prefix)
                if~isempty(regexp(prefix,'\W','once'))
                    error('Only word charaters (A-Z, a-z, 0-9, and _) are allowed in the prefix of transformed model name');
                elseif~isempty(regexp(prefix(1),'[\d_]','once'))
                    error('The first character of the prefix of transformed model name must be an alphabet(a-z or A-Z)');
                else
                    m2m_obj.prefix=prefix;
                end
            else
                m2m_obj.prefix='gen_';
            end

            m2m_obj.fXformedMdl=[m2m_obj.prefix,m2m_obj.mdl];

            [mdls,m2m_obj.xlinkedblks]=transformedModels(m2m_obj);
            initGenModels(m2m_obj,m2m_obj.prefix,mdls);
            set_param([m2m_obj.prefix,m2m_obj.mdl],'Open','on');


            if m2m_obj.load_prev
                for ii=1:length(m2m_obj.prev_xforms)
                    prev_trace=struct('Operation',[],'Before',[],'After',[]);
                    prev_trace.Operation=m2m_obj.prev_xforms(ii).Operation;
                    prev_trace.Before=m2m_obj.prev_xforms(ii).Before;
                    for jj=1:length(m2m_obj.prev_xforms(ii).After)
                        after_string=m2m_obj.prev_xforms(ii).After{jj};
                        prev_trace.After=[prev_trace.After,{[m2m_obj.prefix,after_string]}];
                    end
                    m2m_obj.traceability_map=[m2m_obj.traceability_map,prev_trace];
                end
            end

            broken_links={};
            for ii=1:length(m2m_obj.xformed_blks)
                path=get_param([m2m_obj.prefix,getfullname(m2m_obj.xformed_blks(ii).Before(1))],'parent');
                while~strcmpi(get_param(path,'Type'),'block_diagram')&&...
                    strcmpi(get_param(path,'linkstatus'),'implicit')
                    path=get_param(path,'parent');
                end
                if~strcmpi(get_param(path,'Type'),'block_diagram')
                    if strcmpi(get_param(path,'linkstatus'),'resolved')
                        if isempty(get_param(path,'LinkData'))
                            broken_links=[broken_links,path];%#ok
                        else
                            MSLDiagnostic('sl_pir_cpp:creator:BreakingLinkLibrary',path).reportAsWarning;
                        end
                        set_param(path,'linkstatus','inactive');
                    end
                end
            end


            failed_cmd=[];
            for ii=1:length(m2m_obj.xform_commands)
                cmd=strrep(m2m_obj.xform_commands{ii},newline,' ');
                try
                    eval(cmd);
                catch
                    failed_cmd=[failed_cmd,{cmd}];%#ok
                end
            end
            insert_odtcs(m2m_obj);

            for lIdx=1:length(broken_links)
                try
                    set_param(broken_links{lIdx},'linkstatus','propagatehierarchy');
                catch
                    missingSS=broken_links{lIdx};
                    path=missingSS(length(m2m_obj.prefix)+1:end);
                    found=[];
                    while isempty(found)
                        path=get_param(path,'parent');
                        found=find(strcmpi(path,{m2m_obj.xformed_subsystems.Before}),1);
                    end
                    missingSS=[m2m_obj.xformed_subsystems(found).After...
                    ,missingSS(length([m2m_obj.prefix,m2m_obj.xformed_subsystems(found).Before])+1:end)];
                    set_param(missingSS,'linkstatus','propagatehierarchy');
                end
            end


            if m2m_obj.load_prev
                for ii=1:num_new_xform
                    for jj=1:length(m2m_obj.traceability_map(ii).Before)
                        ori_blk=map_to_prev_subsys(m2m_obj,m2m_obj.traceability_map(ii).Before(jj));
                        m2m_obj.traceability_map(ii).Before(jj)=get_param(ori_blk,'handle');
                    end
                end
                for ii=1:length(m2m_obj.xformed_subsystems)
                    ori_blk=map_to_prev_subsys(m2m_obj,m2m_obj.xformed_subsystems(ii).Before);
                    m2m_obj.xformed_subsystems(ii).Before=ori_blk;
                end
            else
                for ii=1:length(m2m_obj.xformed_subsystems)
                    m2m_obj.xformed_subsystems(ii).Before=m2m_obj.xformed_subsystems(ii).Before;
                end
            end

            for ii=1:length(m2m_obj.xformed_subsystems)
                if strcmpi(get_param(m2m_obj.xformed_subsystems(ii).Before,'LinkStatus'),'resolved')||...
                    strcmpi(get_param(m2m_obj.xformed_subsystems(ii).Before,'LinkStatus'),'implicit')
                    m2m_obj.xformed_subsystems(ii).Before=get_param(m2m_obj.xformed_subsystems(ii).Before,'ReferenceBlock');
                    m2m_obj.xformed_subsystems(ii).After=get_param(m2m_obj.xformed_subsystems(ii).After,'ReferenceBlock');
                end
            end


            for i=1:length(m2m_obj.traceability_map)
                if i<=num_new_xform
                    if~isempty(m2m_obj.traceability_map(i).After)&&...
                        (strcmpi(get_param(m2m_obj.traceability_map(i).After{1},'LinkStatus'),'resolved')||...
                        strcmpi(get_param(m2m_obj.traceability_map(i).After{1},'LinkStatus'),'implicit'))
                        m2m_obj.traceability_map(i).Before=get_param(m2m_obj.traceability_map(i).Before,'ReferenceBlock');
                        m2m_obj.traceability_map(i).After=get_param(m2m_obj.traceability_map(i).After,'ReferenceBlock');
                    end

                    m2m_obj.traceability_map(i).Before=[{},Simulink.ID.getSID(m2m_obj.traceability_map(i).Before)];
                end
                if(nargin>1)
                    m2m_obj.traceability_map(i).After=strrep(Simulink.ID.getSID(m2m_obj.traceability_map(i).After),['gen_',m2m_obj.mdl,':'],[m2m_obj.fXformedMdl,':']);
                else
                    m2m_obj.traceability_map(i).After=Simulink.ID.getSID(m2m_obj.traceability_map(i).After);
                end
            end



            outport_blks=find_system([m2m_obj.prefix,m2m_obj.mdl],'SearchDepth',1,'BlockType','Outport','Commented','off');
            if~isempty(m2m_obj.xform_commands)&&length(outport_blks)>1&&...
                strcmpi(get_param([m2m_obj.prefix,m2m_obj.mdl],'SaveOutput'),'on')
                output_save_name='y';
                for ii=1:length(outport_blks)-1
                    output_save_name=[output_save_name,',y_',int2str(ii)];%#ok
                end
                set_model_param(m2m_obj,[m2m_obj.prefix,m2m_obj.mdl],'OutputSaveName',output_save_name);
                set_model_param(m2m_obj,[m2m_obj.prefix,m2m_obj.mdl],'SaveFormat','Structure');
            end


            if strcmpi(get_param([m2m_obj.prefix,m2m_obj.mdl],'GenerateASAP2'),'on')
                set_model_param(m2m_obj,[m2m_obj.prefix,m2m_obj.mdl],'GenerateASAP2','off');
            end
            remove_unconnected_terminator([m2m_obj.prefix,m2m_obj.mdl]);
            save_system([m2m_obj.prefix,m2m_obj.mdl],[m2m_dir,m2m_obj.prefix,m2m_obj.mdl],'SaveDirtyReferencedModels','on');%#ok

            for m=1:length(m2m_obj.refmdls)

                if strcmpi(get_param([m2m_obj.prefix,m2m_obj.refmdls{m}],'GenerateASAP2'),'on')
                    set_model_param(m2m_obj,[m2m_obj.prefix,m2m_obj.refmdls{m}],'GenerateASAP2','off');
                end
                remove_unconnected_terminator([m2m_obj.prefix,m2m_obj.refmdls{m}]);
                save_system([m2m_obj.prefix,m2m_obj.refmdls{m}],[m2m_dir,m2m_obj.prefix,m2m_obj.refmdls{m}],'SaveDirtyReferencedModels','on');%#ok
            end

            for m=1:length(m2m_obj.libmdls)
                if bdIsLoaded([m2m_obj.prefix,m2m_obj.libmdls{m}])
                    remove_unconnected_terminator([m2m_obj.prefix,m2m_obj.libmdls{m}]);
                    save_system([m2m_obj.prefix,m2m_obj.libmdls{m}],[m2m_dir,m2m_obj.prefix,m2m_obj.libmdls{m}],'SaveDirtyReferencedModels','on');%#ok
                end
            end

            if m2m_obj.incr_mode
                export_map(m2m_obj,m2m_obj.fXformedMdl);
            end
            if isempty(msg)
                m2m_obj.fTransformed=1;
                msg='Model Generation Finished';
            end

            if m2m_obj.use_datadictionary
                try
                    config_keys=keys(m2m_obj.modified_configset);
                    if~isempty(config_keys)

                        msg=[msg,newline,'-------- Modified ConfigSets ----------',newline];
                    end
                    for kIdx=1:length(config_keys)
                        msg=[msg,config_keys{kIdx},newline];
                        params=m2m_obj.modified_configset(config_keys{kIdx});
                        param_keys=keys(params);
                        for pIdx=1:length(param_keys)
                            msg=[msg,'   Parameter [',param_keys{pIdx},']: ',params(param_keys{pIdx}),newline];
                        end
                    end
                    m2m_obj.modified_configset=containers.Map('KeyType','char','ValueType','any');
                catch
                end
            end
        end


        function found=accelerator_in_foreach(m2m_obj)
            found=0;
            mdls={m2m_obj.mdl};
            mdls=[mdls,m2m_obj.refmdls];

            for ii=1:length(mdls)


                foreaches=find_system(mdls{ii},'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FindAll','on','BlockType','ForEach','Commented','off');

                for jj=1:length(foreaches)
                    sys=get_param(foreaches(ii),'Parent');


                    accel_mdlrefs=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FindAll','on','BlockType','ModelReference','SimulationMode','Accelerator','Commented','off');
                    if~isempty(accel_mdlrefs)
                        DAStudio.error('sl_pir_cpp:creator:AcceleratorMdlRefInForeach',getfullname(mdls{ii}));
                    end
                end
            end
        end

        function set_sim_normal(m2m_obj)
            m2m_obj.sim_mode=containers.Map('KeyType','char','ValueType','char');
            mdls={m2m_obj.mdl};
            mdls=[mdls,m2m_obj.refmdls];

            mdlref_blks=[];
            if~isempty(m2m_obj.refmdls)
                mdlref_blks={m2m_obj.mdlrefs.block};
            end

            for ii=1:length(mdlref_blks)
                if~strcmpi(get_param(mdlref_blks{ii},'SimulationMode'),'normal')
                    root_mdl=bdroot(mdlref_blks{ii});
                    [~,MESSAGE,~]=fileattrib(which(root_mdl));
                    if MESSAGE.UserWrite==0
                        DAStudio.error('sl_pir_cpp:creator:UnwriteableModelUnsupportedSimulationMode',getfullname(root_mdl));
                    end
                end
            end

            for ii=1:length(mdls)
                if~strcmpi(get_param(mdls{ii},'SimulationMode'),'normal')
                    if ii==1
                        [~,MESSAGE,~]=fileattrib(which(mdls{ii}));
                        if MESSAGE.UserWrite==0
                            DAStudio.error('sl_pir_cpp:creator:UnwriteableModelUnsupportedSimulationMode',getfullname(mdls{ii}));
                        end
                    end
                    m2m_obj.sim_mode(mdls{ii})=get_param(mdls{ii},'SimulationMode');
                    set_param(mdls{ii},'SimulationMode','normal');
                end
            end

            for ii=1:length(mdlref_blks)
                if~strcmpi(get_param(mdlref_blks{ii},'SimulationMode'),'normal')
                    m2m_obj.sim_mode(mdlref_blks{ii})=get_param(mdlref_blks{ii},'SimulationMode');
                    set_param(mdlref_blks{ii},'SimulationMode','normal');
                end
            end
        end

        function restore_sim_mode(m2m_obj)
            mdls={m2m_obj.mdl};
            mdls=[mdls,m2m_obj.refmdls];
            mdlref_blks=[];
            if~isempty(m2m_obj.refmdls)
                mdlref_blks={m2m_obj.mdlrefs.block};
            end
            for ii=1:length(mdls)
                if isKey(m2m_obj.sim_mode,mdls{ii})
                    set_param(mdls{ii},'SimulationMode',m2m_obj.sim_mode(mdls{ii}));
                end
            end
            modified_mdls=cell(1,0);
            for ii=1:length(mdlref_blks)
                if isKey(m2m_obj.sim_mode,mdlref_blks{ii})
                    set_param(mdlref_blks{ii},'SimulationMode',m2m_obj.sim_mode(mdlref_blks{ii}));
                    modified_mdls=unique([modified_mdls,bdroot(mdlref_blks{ii})]);
                end
            end
            for ii=1:length(modified_mdls)
                model_obj=get_param(modified_mdls{ii},'Object');
                model_obj.refreshModelBlocks;
                save_system(modified_mdls{ii},modified_mdls{ii},'SaveDirtyReferencedModels','on');
            end
            m2m_obj.sim_mode=containers.Map('KeyType','char','ValueType','char');
        end

        function xforms=xform_report(m2m_obj)
            xform=struct('Operation',[],'Before',[],'After',[]);
            xforms=repmat(xform,1,length(m2m_obj.traceability_map));
            for i=1:length(m2m_obj.traceability_map)
                xforms(i).Operation=m2m_obj.traceability_map(i).Operation;
                xforms(i).Before=cell(size(m2m_obj.traceability_map(i).Before));
                xforms(i).After=cell(m2m_obj.traceability_map(i).After);

                for j=1:length(m2m_obj.traceability_map(i).Before)
                    handle=Simulink.ID.getHandle(m2m_obj.traceability_map(i).Before{j});
                    xforms(i).Before{j}=getfullname(handle);
                end
                for j=1:length(m2m_obj.traceability_map(i).After)
                    handle=Simulink.ID.getHandle(m2m_obj.traceability_map(i).After{j});
                    xforms(i).After{j}=getfullname(handle);
                end
            end
        end

        function isTraceable=isTraceableBlk(m2m_obj,blk)
            isTraceable=0;
            sid=Simulink.ID.getSID(blk);
            for i=1:length(m2m_obj.traceability_map)
                if~isempty(find(strcmpi(m2m_obj.traceability_map(i).Before,sid),1))
                    isTraceable=1;
                    break;
                elseif~isempty(find(strcmpi(m2m_obj.traceability_map(i).After,sid),1))
                    isTraceable=2;
                    break;
                end
            end
        end

        function xformed_blks=trace(m2m_obj,ori_blk)
            clear_all_hilite;
            xformed_blks=[];
            if isa(ori_blk,'double')
                sid=Simulink.ID.getSID(ori_blk);
            elseif isa(ori_blk,'char')
                try
                    sid=Simulink.ID.getSID(ori_blk);
                catch
                    sid=ori_blk;
                end
            end
            for i=1:length(m2m_obj.traceability_map)
                if~isempty(find(strcmpi(m2m_obj.traceability_map(i).Before,sid),1))
                    path=strsplit(m2m_obj.traceability_map(i).After{1},':');
                    if~bdIsLoaded(path{1})
                        load_system([m2m_obj.m2m_dir,'/',path{1}]);
                    end
                    hilite_system(m2m_obj.traceability_map(i).After,'user2');
                    xformed_blks=m2m_obj.traceability_map(i).After;
                    break;
                elseif~isempty(find(strcmpi(m2m_obj.traceability_map(i).After,sid),1))
                    path=strsplit(m2m_obj.traceability_map(i).Before{1},':');
                    if~bdIsLoaded(path{1})
                        load_system(path{1});
                    end
                    hilite_system(m2m_obj.traceability_map(i).Before,'user2');
                    xformed_blks=m2m_obj.traceability_map(i).Before;
                    break;
                end
            end
        end

        function serialized_map=export_map(m2m_obj,filename)
            serialized_map=[];
            for ii=1:length(m2m_obj.traceability_map)
                if~isempty(m2m_obj.traceability_map(ii).After)

                    serialized_map=[serialized_map,m2m_obj.traceability_map(ii).Operation];%#ok

                    serialized_map=[serialized_map,'>'];%#ok
                    [len,~]=size(m2m_obj.traceability_map(ii).Before);
                    for jj=1:len-1
                        serialized_map=[serialized_map,m2m_obj.traceability_map(ii).Before{jj}];%#ok
                        serialized_map=[serialized_map,'/'];%#ok
                    end
                    serialized_map=[serialized_map,m2m_obj.traceability_map(ii).Before{len}];%#ok

                    serialized_map=[serialized_map,'>'];%#ok
                    [len,~]=size(m2m_obj.traceability_map(ii).After);
                    for jj=1:len-1
                        serialized_map=[serialized_map,m2m_obj.traceability_map(ii).After{jj}];%#ok
                        serialized_map=[serialized_map,'/'];%#ok
                    end
                    serialized_map=[serialized_map,m2m_obj.traceability_map(ii).After{len}];%#ok
                    serialized_map=[serialized_map,'|'];%#ok
                end
            end

            for ii=1:length(m2m_obj.xformed_subsystems)

                serialized_map=[serialized_map,'Subsystem'];%#ok

                serialized_map=[serialized_map,'>'];%#ok
                serialized_map=[serialized_map,Simulink.ID.getSID(m2m_obj.xformed_subsystems(ii).Before)];%#ok

                serialized_map=[serialized_map,'>'];%#ok
                serialized_map=[serialized_map,Simulink.ID.getSID(m2m_obj.xformed_subsystems(ii).After)];%#ok
                serialized_map=[serialized_map,'|'];%#ok
            end

            fileID=fopen(['m2m_',m2m_obj.fOriMdl,'/',filename,'.trace'],'w');
            fprintf(fileID,'%s',serialized_map);
            fclose(fileID);
            fileID2=fopen(['m2m_',m2m_obj.fOriMdl,'/',m2m_obj.fOriMdl,'.previous'],'w');
            fprintf(fileID2,'%s',filename);
            fclose(fileID2);
        end

        function import_map(m2m_obj,filename)
            traceability=[];
            smap=fileread([filename,'.trace']);
            if isempty(smap)
                return;
            end
            xforms=textscan(smap,'%s','delimiter','|');
            [num_xforms,~]=size(xforms{1});
            if num_xforms>0
                traceability=struct('Operation',{},'Before',{},'After',{});
                previous_xforms=struct('Operation',{},'Before',{},'After',{});
            end
            for ii=1:num_xforms
                fields=textscan(xforms{1}{ii},'%s','delimiter','>');
                if m2m_obj.load_prev&&strcmpi(fields{1}{1},'Subsystem')
                    prev_subsys=struct('Before',[],'After',[]);
                    prev_subsys.Before=fields{1}{2};
                    prev_subsys.After=fields{1}{3};
                    m2m_obj.prev_subsystems=[m2m_obj.prev_subsystems,prev_subsys];
                else
                    xform=struct('Operation',[],'Before',[],'After',[]);
                    prev_xform=struct('Operation',[],'Before',[],'After',[]);
                    xform.Operation=fields{1}{1};
                    prev_xform.Operation=fields{1}{1};
                    blks=textscan(fields{1}{2},'%s','delimiter','/');
                    xform.Before=blks{1};
                    prev_xform.Before=blks{1};
                    blks=textscan(fields{1}{3},'%s','delimiter','/');
                    xform.After=blks{1};
                    for jj=1:length(blks{1})
                        prev_xform.After=[prev_xform.After,{getfullname(blks{1}{jj})}];
                    end
                    traceability=[traceability,xform];%#ok
                    previous_xforms=[previous_xforms,prev_xform];%#ok
                end
            end
            m2m_obj.traceability_map=traceability;
            m2m_obj.prev_xforms=previous_xforms;
        end
        function term(m2m_obj)
            if ishandle(m2m_obj.bd.Handle)&&strcmpi(get_param(m2m_obj.bd.Handle,'SimulationStatus'),'paused')
                m2m_obj.bd.term;
            end
        end
    end

    methods(Access='private')
        function m2mCleanupFcn(m2m_obj,m2m_dir,PIRs,mdlref_blks,sim_mode)%#ok
            p=pir;
            for ii=1:length(PIRs)
                p.destroyPirCtx([PIRs{ii}]);
                try
                    if isKey(sim_mode,PIRs{ii})&&...
                        ~strcmpi(get_param(PIRs{ii},'SimulationMode'),sim_mode(PIRs{ii}))
                        set_param(PIRs{ii},'SimulationMode',sim_mode(PIRs{ii}));
                    end
                catch
                end
            end
            modified_mdls=cell(1,0);
            for ii=1:length(mdlref_blks)
                try
                    if isKey(sim_mode,mdlref_blks{ii})&&...
                        ~strcmpi(get_param(mdlref_blks{ii},'SimulationMode'),sim_mode(mdlref_blks{ii}))
                        set_param(mdlref_blks{ii},'SimulationMode',sim_mode(mdlref_blks{ii}));
                        modified_mdls=unique([modified_mdls,bdroot(mdlref_blks{ii})]);
                    end
                catch
                end
            end
            for ii=1:length(modified_mdls)
                save_system(modified_mdls{ii});
            end
        end
    end
end

function remove_unconnected_terminator(mdl)




    term_blks=find_system(bdroot,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FindAll','on','BlockType','Terminator');
    for bIdx=1:length(term_blks)
        pc=get_param(term_blks(bIdx),'PortConnectivity');
        if isempty(pc.SrcPort)
            delete_block(term_blks(bIdx));
        end
    end
end

function[linkedblkInXformedLibs,xformedLibs]=libcopy_option1(linked_blks,xformedLibs,xformedblks_in_libs)
    linkedblkInXformedLibs=struct('block',{},'lib',{});
    keep_search=1;
    while~isempty(linked_blks)&&keep_search
        keep_search=0;
        blks_to_remove=[];
        for bIdx=1:length(linked_blks)
            dlg=bdroot(linked_blks(bIdx).block);
            if~isempty(find(strcmpi(xformedLibs,linked_blks(bIdx).lib),1))
                if~bdIsLibrary(dlg)||link2xformedLibBlk(linked_blks(bIdx).block,xformedblks_in_libs)
                    linkedblkInXformedLibs=[linkedblkInXformedLibs,linked_blks(bIdx)];%#ok
                    blks_to_remove=[blks_to_remove,bIdx];%#ok
                    if bdIsLibrary(dlg)
                        xformedLibs=unique([xformedLibs,dlg]);
                        xformedblks_in_libs=[xformedblks_in_libs;linked_blks(bIdx).block];%#ok
                        keep_search=1;
                    end
                end
            end
        end
        linked_blks(blks_to_remove)=[];
    end
end

function[linkedblkInXformedLibs,xformedLibs]=libcopy_option2(linked_blks,xformedLibs)
    linkedblkInXformedLibs=struct('block',{},'lib',{});
    keep_searching=1;
    while~isempty(linked_blks)&&keep_searching
        keep_searching=0;
        blks_to_remove=[];
        for bIdx=1:length(linked_blks)
            if~isempty(find(strcmpi(xformedLibs,linked_blks(bIdx).lib),1))
                linkedblkInXformedLibs=[linkedblkInXformedLibs,linked_blks(bIdx)];%#ok
                blks_to_remove=[blks_to_remove,bIdx];%#ok
                dlg=bdroot(linked_blks(bIdx).block);
                if bdIsLibrary(dlg)
                    xformedLibs=[xformedLibs,dlg];%#ok
                    keep_searching=0;
                end
            end
        end
        linked_blks(blks_to_remove)=[];
        xformedLibs=unique(xformedLibs);
    end
end


function linked=link2xformedLibBlk(blk,xformedblk_in_libs)
    refblk=get_param(blk,'ReferenceBlock');
    foundStr=strfind(xformedblk_in_libs,refblk);
    idx=find(not(cellfun('isempty',foundStr)));
    linked=~isempty(find([foundStr{idx}]==1,1));
end


function modified_prop=set_prop(mdl,prop,value)%#ok
    modified_prop=struct('prop',prop,'value',get_param(mdl,prop));
    modified_prop.value=set_param(mdl,prop,value);
end

function ori_blk=map_to_prev_subsys(m2m_obj,block)
    prev_subsys_map=m2m_obj.prev_subsystems;
    ori_blk=get_param(block,'Name');
    parent=get_param(block,'parent');
    found_in_map=false;
    while~isempty(parent)&&~found_in_map
        idx=find(strcmpi({prev_subsys_map.After},Simulink.ID.getSID(parent)));
        if~isempty(idx)
            ori_blk=[getfullname(prev_subsys_map(idx).Before),'/',ori_blk];%#ok
            found_in_map=true;
        else
            ori_blk=[get_param(parent,'Name'),'/',ori_blk];%#ok
            parent=get_param(parent,'parent');
        end
    end
    if~found_in_map
        if strcmpi(getfullname(bdroot(block)),m2m_obj.mdl)
            ori_blk=[m2m_obj.fOriMdl,ori_blk(length(m2m_obj.mdl)+1:end)];
        else
            ori_blk=ori_blk(5:end);
        end
    end
end

function clear_all_hilite
    systems=find_system('type','block_diagram');
    for i=1:length(systems)
        set_param(systems{i},'HiliteAncestors','off');
    end
end

function gpc_off_ivblks=get_gpc_off_ivblks(mdl)



    gpc_off_ivblks=find_system(mdl,'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'RegExp','on',...
    'BlockType','VariantSource|VariantSink',...
    'GeneratePreprocessorConditionals','off',...
    'Commented','off');
end

function result=are_all_slparams(constants)
    result=cell(1,0);
    for ii=1:length(constants)
        var=evalin('base',constants{ii});
        if isa(var,'Simulink.Parameter')&&var.Dimensions(1)==1&&var.Dimensions(2)==1
            result=[result,constants(ii)];%#ok
        end
    end
end

function slparams=get_all_slparams
    slparams=cell(1,0);
    ws=evalin('base','whos');
    idx=strcmpi({ws.class},'Simulink.Parameter');
    all_slparams={ws(idx).name};
    for ii=1:length(all_slparams)
        slparam=evalin('base',all_slparams{ii});
        if slparam.Dimensions(1)==1&&slparam.Dimensions(2)==1
            slparams=[slparams,all_slparams(ii)];%#ok
        end
    end
end

function valid=check_cand_const(all_sys_consts,cand_consts)
    valid=true;
    for ii=1:length(cand_consts)
        if isempty(find(strcmpi(cand_consts{ii},all_sys_consts),1))
            valid=false;
        end
    end
end

function is_cand_lib=check_library(lib)
    is_cand_lib=false;
    simulink_library_list={'simulink','simulink_need_slupdate'};
    if isempty(find(strcmpi(simulink_library_list,lib),1))&&exist(lib,'file')>0
        is_cand_lib=true;
    end
end


function sys_params=get_variant_params(sys_consts,ex_consts)
    sys_params=sys_consts;
    for ii=1:length(ex_consts)
        idx=find(strcmpi(sys_params,ex_consts{ii}),1);
        if~isempty(idx)
            sys_params(idx)=[];
        end
    end
end


function set_segement_param(new_seg,seg)
    new_seg.DataLogging=seg.DataLogging;
    new_seg.DataLoggingNameMode=seg.DataLoggingNameMode;
    new_seg.DataLoggingName=seg.DataLoggingName;
    new_seg.DataLoggingDecimateData=seg.DataLoggingDecimateData;
    new_seg.DataLoggingDecimation=seg.DataLoggingDecimation;
    new_seg.DataLoggingSampleTime=seg.DataLoggingSampleTime;
    new_seg.DataLoggingLimitDataPoints=seg.DataLoggingLimitDataPoints;
    new_seg.DataLoggingMaxPoints=seg.DataLoggingMaxPoints;
    new_seg.TestPoint=seg.TestPoint;
    new_seg.StorageClass=seg.StorageClass;
    if seg.MustResolveToSignalObject&&isempty(seg.SignalNameFromLabel)
        new_seg.SignalNameFromLabel=seg.Name;
    else
        new_seg.SignalNameFromLabel=seg.SignalNameFromLabel;
    end
    new_seg.MustResolveToSignalObject=seg.MustResolveToSignalObject;
    new_seg.ShowPropagatedSignals=seg.ShowPropagatedSignals;
    new_seg.TaskTransitionSpecified=seg.TaskTransitionSpecified;
    new_seg.TaskTransitionIC=seg.TaskTransitionIC;
    new_seg.ExtrapolationMethod=seg.ExtrapolationMethod;
    new_seg.TaskTransitionType=seg.TaskTransitionType;
    new_seg.UserSpecifiedLogName=seg.UserSpecifiedLogName;
    new_seg.SignalPropagation=seg.SignalPropagation;
    new_seg.Name=seg.Name;
    new_seg.HiliteAncestors=seg.HiliteAncestors;
end





