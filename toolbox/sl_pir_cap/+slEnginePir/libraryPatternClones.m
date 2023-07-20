



classdef libraryPatternClones<handle

    properties(Access='public')

        traceability_map;
        cloneresult;
        mdlName;
        mdl;
        libraryName;
        libname;

        refBlocksModels;
        refModels;
        libmdls;
        linkedblks;

        changedLibraries;
        m2m_dir;
        genmodelprefix;
        xformed_mdl;
        onemodelflag;

        loadedModels;
        excluded_sysclone;
        subsystemClones;
        clonepattern;
        domain;
        exclusionList;

        clonegroups;
        includeMdl;
        includeLib;
        ignoreSignalName;
        ignoreBlockProperty;

        needrefactor;
        enableClonesAnywhere;
        ExceptionLog='';
    end

    properties(SetAccess='public',GetAccess='public',Hidden=true)
        region2BlockList;
    end

    methods(Access='public')
        function obj=libraryPatternClones(libraryfile,model,clonepattern,includeMdl,includeLib,ignoreSignalName,ignoreBlockProperty)
            if nargin<3
                clonepattern='StructuralParameters';
            end
            if nargin<4
                includeMdl=true;
            end

            if nargin<5
                includeLib=true;
            end
            if nargin<6
                ignoreSignalName=true;
            end
            if nargin<7
                ignoreBlockProperty=true;
            end

            obj.includeMdl=includeMdl;
            obj.includeLib=includeLib;
            obj.ignoreSignalName=ignoreSignalName;
            obj.ignoreBlockProperty=ignoreBlockProperty;
            obj.changedLibraries.keys=[];
            if isempty(libraryfile)
                DAStudio.error('sl_pir_cpp:creator:emptyModelName');
            end
            ME=MException('','');

            try
                C=textscan(model,'%s','Delimiter','/');
                model=C{1}{1};
                mh=load_system(model);
            catch ME
            end
            if~isempty(ME.message)
                DAStudio.error('sl_pir_cpp:creator:invalideModelName',model);
            end

            model=get_param(mh,'Name');


            obj.traceability_map=[];
            obj.mdlName=model;
            obj.mdl=obj.mdlName;
            obj.libname=obj.libraryName;
            obj.excluded_sysclone=containers.Map('KeyType','char','ValueType','char');
            obj.subsystemClones=containers.Map('KeyType','char','ValueType','char');
            obj.region2BlockList=containers.Map('KeyType','char','ValueType','any');
            obj.traceability_map=[];
            obj.m2m_dir=['m2m_',obj.mdlName,'/'];
            obj.genmodelprefix=[slEnginePir.util.Constants.BackupModelPrefix,'_'];
            obj.onemodelflag=true;
            obj.clonepattern=clonepattern;
            obj.domain='GraphicalDomain';
            obj.exclusionList=[];
            obj.clonegroups=[];

            for i=1:length(libraryfile)
                libraryHandle=obj.loadLibraries(libraryfile{i});

                if~isempty(ME.message)
                    DAStudio.error('sl_pir_cpp:creator:invalideModelName',libraryfile{i});
                end
                libraryname=get_param(libraryHandle,'Name');

                if strcmp(libraryname,model)
                    DAStudio.error('sl_pir_cpp:creator:sameLibraryModelName');
                end
                obj.libraryName{i}=libraryname;
            end
            obj.computeChecksumForLibraryandModels();
            obj.needrefactor=false;
            obj.enableClonesAnywhere=false;
        end

        function checkChartInOutports(obj)

            oldclonegroups=obj.clonegroups;
            if length(oldclonegroups)<1
                return;
            end

            newclonegroups=obj.clonegroups;
            newcgind=1;
            for i=1:length(oldclonegroups)



                curLibSubsysBlk=oldclonegroups(i).Operation;
                if~strcmp(get_param(curLibSubsysBlk,'Type'),'block_diagram')&&...
                    ~strcmpi(get_param(curLibSubsysBlk,'SFBlockType'),'NONE')



                    chartId=sfprivate('block2chart',curLibSubsysBlk);
                    dataIds=sf('DataIn',chartId);
                    LibdataProps=[];
                    for k=1:length(dataIds)
                        LibdataProps=[LibdataProps,sf('get',dataIds(k),'.props'),-1];
                    end


                    mdlBlk=get_param(oldclonegroups(i).Before(1),'Parent');
                    chartId=sfprivate('block2chart',mdlBlk);
                    dataIds=sf('DataIn',chartId);
                    MdldataProps=[];
                    for k=1:length(dataIds)
                        MdldataProps=[MdldataProps,sf('get',dataIds(k),'.props'),-1];
                    end

                    if isequal(LibdataProps,MdldataProps)
                        newclonegroups(newcgind)=oldclonegroups(i);
                        newclonegroups(newcgind).Before=get_param(mdlBlk,'Handle');
                        newclonegroups(newcgind).After=get_param(curLibSubsysBlk,'Handle');
                        newcgind=newcgind+1;
                    end
                else

                    newclonegroups(newcgind)=oldclonegroups(i);
                    newcgind=newcgind+1;
                end
            end
            obj.clonegroups=newclonegroups(1:newcgind-1);
        end



        function checkForEachBlock(obj)

            if~strcmp(obj.clonepattern,'StructuralParameters')
                return;
            end


            oldclonegroups=obj.clonegroups;
            if length(oldclonegroups)<1
                return;
            end

            newclonegroups=obj.clonegroups;
            newcgind=1;
            for i=1:length(oldclonegroups)
                flag=true;
                for j=1:length(oldclonegroups(i).Before)
                    if strcmp(get_param(oldclonegroups(i).Before(j),'BlockType'),'ForEach')&&...
                        ~obj.hasSameDialogParam(oldclonegroups(i).Before(j),oldclonegroups(i).After(j))
                        flag=false;
                        break;
                    end
                end
                if flag
                    newclonegroups(newcgind)=oldclonegroups(i);
                    newcgind=newcgind+1;
                end
            end
            obj.clonegroups=newclonegroups(1:newcgind-1);
        end


        function flag=hasSameDialogParam(~,srcH,dstH)
            flag=true;
            dp=get_param(srcH,'DialogParameters');
            fn=fieldnames(dp);
            for i=1:length(fn)
                pname=fn{i};
                if~isequal(get_param(srcH,pname),get_param(dstH,pname))
                    flag=false;
                    return;
                end
            end
        end


        function result=identify_clones(obj,exclusionList,threshold)
            if nargin<2
                exclusionList=[];
                threshold=50;
            end

            if nargin<3
                threshold=50;
            end


            if threshold==0
                obj.clonepattern='StructuralParameters';
            end

            obj.checkChartInOutports();
            obj.checkForEachBlock();
            tmp=obj.clonegroups;
            if length(tmp)<1
                result=[];
                return;
            end

            obj.exclusionList=exclusionList;
            j=1;
            for i=1:length(tmp)
                beforeFullName=getfullname(tmp(i).Before);
                afterFullName=getfullname(tmp(i).After);

                if~iscell(beforeFullName)
                    beforeFullName={beforeFullName};
                    afterFullName={afterFullName};
                end

                if isUnderExclusion(obj,beforeFullName{1})
                    continue;
                end
                result.mdlBlks{j}=beforeFullName;
                result.libBlocks{j}=afterFullName;
                result.libsubsysBlk{j}=tmp(i).Operation;
                result.similarCloneFlag{j}=tmp(i).similarCloneFlag;




                if~result.similarCloneFlag{j}
                    obj.needrefactor=true;
                end

                j=j+1;
            end

            if j==1
                result=[];
                return;
            end

            obj.cloneresult.Before=result;
            [newIndx,NumberBlks]=sortwithNumBlksNumClones(obj,obj.cloneresult.Before);
            obj.cloneresult.NumberBlks=NumberBlks;
            obj.cloneresult.newIndx=newIndx;



            obj.cloneresult.dissimiliarty=cell(1,length(result));
            obj.cloneresult.dissimiliartyParamNum=zeros(1,length(result));
            obj.cloneresult.differentblocks=cell(size(result));
        end


        function[tableIndx,numberBLK]=sortwithNumBlksNumClones(~,LPCloneGroup)

            allLibsubsysBlk=unique(LPCloneGroup.libsubsysBlk);
            len=length(allLibsubsysBlk);
            tableIndx=zeros(1,len);
            numberBLK=zeros(1,len);

            lenBlk=length(LPCloneGroup.mdlBlks);

            for i=1:len

                if~strcmp(get_param(allLibsubsysBlk{i},'Type'),'block_diagram')&&~strcmp(get_param(allLibsubsysBlk{i},'SFBlockType'),'NONE')
                    numberBLK(i)=1;
                else
                    allblks=find_system(allLibsubsysBlk{i},'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on','LookUnderMasks','all','FollowLinks','on');
                    allblksIn=find_system(allLibsubsysBlk{i},'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on','LookUnderMasks','all','FollowLinks','on','blocktype','Inport');
                    allblksOut=find_system(allLibsubsysBlk{i},'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on','LookUnderMasks','all','FollowLinks','on','blocktype','Outport');

                    numberBLK(i)=length(allblks)-1-length(allblksIn)-length(allblksOut);
                end

                cnum=0;
                for j=1:lenBlk
                    if strcmp(LPCloneGroup.libsubsysBlk{j},allLibsubsysBlk{i})
                        cnum=cnum+1;
                    end
                end

                tableIndx(i)=cnum*numberBLK(i);
            end

            [~,tableIndx]=sort(tableIndx,'descend');
        end

        function flag=isUnderExclusion(obj,blocksName)
            flag=false;
            if isempty(obj.exclusionList)
                return;
            end
            for i=1:length(obj.exclusionList)
                excludeSys=obj.exclusionList{i};
                if slEnginePir.isParent(getfullname(excludeSys),blocksName)||slEnginePir.isParent(blocksName,getfullname(excludeSys))
                    flag=true;
                    return;
                end
            end
        end

        function include_sysclones(obj,name)
            if isKey(obj.excluded_sysclone,name)
                remove(obj.excluded_sysclone,name);
            end
        end

        function exclude_sysclones(obj,name)
            obj.excluded_sysclone(name)='unselected';
        end

        function isExcluded=is_excluded_sysclone(obj,name)
            isExcluded=0;
            allKeys=keys(obj.excluded_sysclone);
            for i=1:length(name)
                name1=name{i};
                if(isKey(obj.excluded_sysclone,name1))
                    isExcluded=1;
                    break;
                else
                    for k=1:length(allKeys)
                        if slEnginePir.isParent(allKeys{k},name1)
                            isExcluded=1;
                            break;
                        end
                    end
                end
            end
        end

        function checkActionPortsInSys(obj)
            libsubsysBlks=obj.cloneresult.Before.libsubsysBlk;
            for i=1:length(libsubsysBlks)
                if isKey(obj.subsystemClones,obj.cloneresult.Before.mdlBlks{i}{1})||...
                    is_excluded_sysclone(obj,obj.cloneresult.Before.mdlBlks{i})
                    continue;
                end

                [tsysclonemap,tflag]=slEnginePir.excludedSyswithTriggerPorts(obj.excluded_sysclone,libsubsysBlks{i},obj.cloneresult.Before.mdlBlks{i}{1});
                if~tflag
                    continue;
                end
                parentblk=get_param(obj.cloneresult.Before.mdlBlks{i}{1},'Parent');
                if strcmp(get_param(parentblk,'Type'),'block_diagram')
                    obj.excluded_sysclone=tsysclonemap;
                    disp([libsubsysBlks{i},' includes trigger/action/enable port in system']);
                elseif subsystemMatch(obj,libsubsysBlks{i},parentblk)

                    newblk=slEnginePir.updateBlock(parentblk,libsubsysBlks{i});
                    obj.subsystemClones(obj.cloneresult.Before.mdlBlks{i}{1})=getfullname(newblk);
                else
                    obj.excluded_sysclone=tsysclonemap;
                    disp([libsubsysBlks{i},' includes trigger/action/enable port in system']);
                end
            end
        end

        function flag=subsystemMatch(~,srcSubsys,dstSubsys)

            if strcmp(get_param(srcSubsys,'Type'),'block_diagram')||strcmp(get_param(dstSubsys,'Type'),'block_diagram')
                flag=false;
                return;
            end

            srcallblks=find_system(srcSubsys,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on','LookUnderMasks','all','FollowLinks','on');
            dstallblks=find_system(dstSubsys,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on','LookUnderMasks','all','FollowLinks','on');
            if length(srcallblks)==length(dstallblks)
                flag=true;
            else
                flag=false;
            end
        end

        function checkDSMInSys(obj)
            libsubsysBlks=obj.cloneresult.Before.libsubsysBlk;
            for i=1:length(libsubsysBlks)
                if isKey(obj.subsystemClones,obj.cloneresult.Before.mdlBlks{i}{1})||...
                    is_excluded_sysclone(obj,obj.cloneresult.Before.mdlBlks{i})
                    continue;
                end

                dsmBlkName=find_system(libsubsysBlks{i},'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on','SearchDepth',1,'regexp','on','BlockType','DataStoreMemory');
                if~isempty(dsmBlkName)
                    parentblk=get_param(obj.cloneresult.Before.mdlBlks{i}{1},'Parent');

                    if subsystemMatch(obj,libsubsysBlks{i},parentblk)

                        newblk=slEnginePir.updateBlock(parentblk,libsubsysBlks{i});
                        obj.subsystemClones(obj.cloneresult.Before.mdlBlks{i}{1})=getfullname(newblk);
                    else
                        obj.excluded_sysclone(obj.cloneresult.Before.mdlBlks{i}{1})='Contains DSM block';
                        disp([libsubsysBlks{i},' Contains DSM in system']);

                    end
                end
            end
        end

        function checkVariantSys(obj)
            libsubsysBlks=obj.cloneresult.Before.libsubsysBlk;
            for i=1:length(libsubsysBlks)

                if isKey(obj.subsystemClones,obj.cloneresult.Before.mdlBlks{i}{1})||...
                    is_excluded_sysclone(obj,obj.cloneresult.Before.mdlBlks{i})
                    continue;
                end

                if strcmp(get_param(libsubsysBlks{i},'Variant'),'on')
                    parentblk=get_param(obj.cloneresult.Before.mdlBlks{i}{1},'Parent');

                    if subsystemMatch(obj,libsubsysBlks{i},parentblk)

                        newblk=slEnginePir.updateBlock(parentblk,libsubsysBlks{i});
                        obj.subsystemClones(obj.cloneresult.Before.mdlBlks{i}{1})=getfullname(newblk);
                    else
                        obj.excluded_sysclone(obj.cloneresult.Before.mdlBlks{i}{1})='Contains Variant Subsystem';
                        disp([libsubsysBlks{i},' Contains Variant Subsystem']);
                    end
                end
            end
        end

        function checkMaskSys(obj)
            libsubsysBlks=obj.cloneresult.Before.libsubsysBlk;
            for i=1:length(libsubsysBlks)

                if isKey(obj.subsystemClones,obj.cloneresult.Before.mdlBlks{i}{1})||...
                    is_excluded_sysclone(obj,obj.cloneresult.Before.mdlBlks{i})
                    continue;
                end

                if strcmp(get_param(libsubsysBlks{i},'Mask'),'on')
                    parentblk=get_param(obj.cloneresult.Before.mdlBlks{i}{1},'Parent');

                    if subsystemMatch(obj,libsubsysBlks{i},parentblk)

                        newblk=slEnginePir.updateBlock(parentblk,libsubsysBlks{i});
                        obj.subsystemClones(obj.cloneresult.Before.mdlBlks{i}{1})=getfullname(newblk);
                    else
                        obj.excluded_sysclone(obj.cloneresult.Before.mdlBlks{i}{1})='Contains mask blocks';
                        disp([libsubsysBlks{i},' Contains mask blocks']);
                    end
                end
            end
        end



        function checkSampleTimeCallFcn(obj)



            libsubsysBlks=obj.cloneresult.Before.libsubsysBlk;
            for i=1:length(libsubsysBlks)
                if isKey(obj.excluded_sysclone,obj.cloneresult.Before.mdlBlks{i}{1})
                    continue;
                end
                if hasSampleTime(obj,obj.cloneresult.Before.libBlocks{i})
                    obj.excluded_sysclone(obj.cloneresult.Before.mdlBlks{i}{1})=' Library block has explicit sample time';
                    disp(['Library group ',obj.cloneresult.Before.libBlocks{i}{1},' has explicit sample time']);
                elseif slEnginePir.hasCallBackFcn(obj.cloneresult.Before.libBlocks{i})
                    obj.excluded_sysclone(obj.cloneresult.Before.mdlBlks{i}{1})=' Library block has explicit Callbacks';
                    disp(['Library group ',obj.cloneresult.Before.libBlocks{i}{1},' has explicit callbacks']);
                end
            end

            for i=1:length(obj.cloneresult.Before.mdlBlks)
                mdlblks=obj.cloneresult.Before.mdlBlks{i};
                if is_excluded_sysclone(obj,mdlblks)
                    continue;
                end




                if hasSampleTime(obj,mdlblks)
                    obj.excluded_sysclone(mdlblks{1})=' Has explicit sample time';
                    disp(['Group ',mdlblks{1},' has explicit sample time.']);
                elseif slEnginePir.hasCallBackFcn(mdlblks)
                    obj.excluded_sysclone(mdlblks{1})=' Has explicit Callbacks';
                    disp(['Group ',mdlblks{1},' has explicit sample time.']);
                end
            end
        end

        function flag=hasSampleTime(~,blockset)
            flag=false;
            for i=1:length(blockset)
                fname=blockset{i};
                blktype=get_param(fname,'BlockType');

                if strcmp(blktype,'SubSystem')&&~strcmp(get_param(fname,'Type'),'block_diagram')
                    if~strcmp(get_param(fname,'SystemSampleTime'),'-1')
                        flag=true;
                        return;
                    end
                end
            end
        end

        function checkSLinChart(obj)
            for i=1:length(obj.cloneresult.Before.mdlBlks)
                mdlblks=obj.cloneresult.Before.mdlBlks{i};

                if is_excluded_sysclone(obj,mdlblks)
                    continue;
                end

                fname=mdlblks{1};
                parentfname=get_param(fname,'Parent');
                if~strcmp(get_param(parentfname,'Type'),'block_diagram')&&strcmp(get_param(parentfname,'SFBlockType'),'Chart')
                    obj.excluded_sysclone(mdlblks{1})=' Inside stateflow chart.';
                end
            end
        end

        function flag=includeStateWriter(~,fname)
            flag=false;
            systemType=get_param(fname,'SystemType');
            if strcmp(systemType,'EventFunction')
                flag=true;
            end
        end

        function checkStateReadWriteSystem(obj)

            libsubsysBlks=obj.cloneresult.Before.libsubsysBlk;
            for i=1:length(libsubsysBlks)
                if isKey(obj.excluded_sysclone,obj.cloneresult.Before.mdlBlks{i}{1})
                    continue;
                end
                fname=libsubsysBlks{i};
                if~strcmp(get_param(fname,'Type'),'block_diagram')&&includeStateWriter(obj,fname)
                    disp([fname,' includes state read/writer block, will be excluded from replacement.']);
                    obj.excluded_sysclone(obj.cloneresult.Before.mdlBlks{i}{1})='Includes a state read or a state writer block.';
                end
            end
        end

        function removelist=chooseOneIntoExclusionList(obj,srclibblk,overlapLibBlks,removelist)

            if length(overlapLibBlks)<1
                return;
            end

            fcnpacking=get_param(obj.cloneresult.Before.libsubsysBlk{srclibblk},'RTWSystemCode');
            if strcmp(fcnpacking,'Reusable function')
                for i=1:length(overlapLibBlks)
                    k=overlapLibBlks(i);
                    removelist=[removelist,k];
                end
            else
                removelist=[removelist,srclibblk];
            end

        end

        function excludeSimilarClones(obj)
            if isempty(obj.cloneresult)
                return;
            end

            similarCloneIndices=[];
            for cloneIndex=1:length(obj.cloneresult.Before.similarCloneFlag)
                if(obj.cloneresult.Before.similarCloneFlag{cloneIndex}==1)
                    similarCloneIndices=[similarCloneIndices,cloneIndex];
                    obj.excluded_sysclone(['Pattern with block ',obj.cloneresult.Before.mdlBlks{cloneIndex}{1}])=...
                    message('sl_pir_cpp:creator:SimilarClonesNotSupportedForLibrary').getString;
                end
            end

            allCloneIndices=1:length(obj.cloneresult.Before.similarCloneFlag);
            nonSimilarCloneIndices=setdiff(allCloneIndices,similarCloneIndices);

            obj.cloneresult.Before.mdlBlks=obj.cloneresult.Before.mdlBlks(nonSimilarCloneIndices);
            obj.cloneresult.Before.libsubsysBlk=obj.cloneresult.Before.libsubsysBlk(nonSimilarCloneIndices);
            obj.cloneresult.Before.libBlocks=obj.cloneresult.Before.libBlocks(nonSimilarCloneIndices);
            obj.cloneresult.Before.similarCloneFlag=obj.cloneresult.Before.similarCloneFlag(nonSimilarCloneIndices);
        end





        function checkOverlapCandidates(obj)

            if isempty(obj.cloneresult)
                return;
            end

            removelist=[];

            for i=1:length(obj.cloneresult.Before.mdlBlks)

                mdlblks=obj.cloneresult.Before.mdlBlks{i};

                if~isempty(find(removelist==i,1))
                    continue;
                end




                overlapLibsubsys=[];
                for j=1:length(mdlblks)
                    for k=i+1:length(obj.cloneresult.Before.mdlBlks)
                        mdlblks2=obj.cloneresult.Before.mdlBlks{k};

                        if~isempty(find(removelist==k,1))
                            continue;
                        end

                        if~isempty(find(overlapLibsubsys==k,1))
                            continue;
                        end

                        for l=1:length(mdlblks2)
                            if strcmp(mdlblks{j},mdlblks2{l})

                                overlapLibsubsys=[overlapLibsubsys,k];
                                break;
                            end
                        end
                    end
                end




                removelist=obj.chooseOneIntoExclusionList(i,overlapLibsubsys,removelist);
            end


            allindex=[1:length(obj.cloneresult.Before.mdlBlks)];
            difindex=setdiff(allindex,removelist);
            obj.cloneresult.Before.mdlBlks=obj.cloneresult.Before.mdlBlks(difindex);
            obj.cloneresult.Before.libsubsysBlk=obj.cloneresult.Before.libsubsysBlk(difindex);
            obj.cloneresult.Before.libBlocks=obj.cloneresult.Before.libBlocks(difindex);
            obj.cloneresult.Before.similarCloneFlag=obj.cloneresult.Before.similarCloneFlag(difindex);
        end


        function checkCSCinfor(obj)


            libsubsysBlks=obj.cloneresult.Before.libsubsysBlk;
            for i=1:length(libsubsysBlks)
                if isKey(obj.excluded_sysclone,obj.cloneresult.Before.mdlBlks{i}{1})
                    continue;
                end



                L=find_system(libsubsysBlks{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','IncludeCommented','on','FindAll','on','LookUnderMasks','all','type','line');
                for j=1:length(L)
                    ol=get_param(L(j),'Object');
                    parentblk=ol.Parent;

                    if~strcmp(get_param(parentblk,'Type'),'block_diagram')&&~strcmp(get_param(parentblk,'SFBlockType'),'NONE')
                        continue;
                    end

                    if ol.MustResolveToSignalObject||ol.DataLogging||~isempty(ol.UserSpecifiedLogName)
                        obj.excluded_sysclone(obj.cloneresult.Before.mdlBlks{i}{1})=' Library block contains signal name or CSC or data logging';
                        disp([libsubsysBlks{i},' Library block contains signal name or CSC or data logging']);
                        break;
                    end
                end
            end


            for i=1:length(obj.cloneresult.Before.mdlBlks)
                mdlblks=obj.cloneresult.Before.mdlBlks{i};

                if isKey(obj.excluded_sysclone,mdlblks{1})
                    continue;
                end

                parentblk=get_param(mdlblks{1},'Parent');

                L=find_system(parentblk,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on',...
                'SearchDepth',1,'regexp','on','FindAll','on','type','line');
                for j=1:length(L)
                    ol=get_param(L(j),'Object');
                    parentblk=ol.Parent;

                    if~strcmp(get_param(parentblk,'Type'),'block_diagram')&&~strcmp(get_param(parentblk,'SFBlockType'),'NONE')
                        continue;
                    end

                    if ol.MustResolveToSignalObject||ol.DataLogging||~isempty(ol.UserSpecifiedLogName)



                        hblksrc=get_param(L(j),'SrcBlockHandle');
                        hblkdst=get_param(L(j),'DstBlockHandle');
                        for k=1:length(mdlblks)
                            if strcmp(mdlblks{k},getfullname(hblksrc))||strcmp(mdlblks{k},getfullname(hblkdst))
                                obj.excluded_sysclone(mdlblks{1})=' Contains signal name or CSC or data logging.';
                                disp([mdlblks{1},'Contains signal name or CSC or data logging.']);
                                break;
                            end
                        end

                        if k<length(mdlblks)
                            break;
                        end
                    end
                end

                if j<length(L)
                    continue;
                end



                for j=1:length(mdlblks)
                    if strcmp(get_param(mdlblks{j},'BlockType'),'SubSystem')


                        L2=find_system(mdlblks{j},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','IncludeCommented','on','FindAll','on','type','line');
                        for k=1:length(L2)
                            ol=get_param(L2(k),'Object');
                            parentblk=ol.Parent;

                            if~strcmp(get_param(parentblk,'Type'),'block_diagram')&&~strcmp(get_param(parentblk,'SFBlockType'),'NONE')
                                continue;
                            end

                            if ol.MustResolveToSignalObject||ol.DataLogging||~isempty(ol.UserSpecifiedLogName)
                                obj.excluded_sysclone(mdlblks{1})=' Contains signal name or CSC or data logging.';
                                disp([mdlblks{1},' Contains signal name or CSC or data logging.']);
                                break;
                            end
                        end
                        if k<length(L2)
                            break;
                        end
                    end
                end
            end
        end


        function handleExclusions(obj)
            excluded_regions=keys(obj.excluded_sysclone);
            for k=1:length(excluded_regions)
                reg=obj.region2BlockList(excluded_regions{k});
                remove(obj.excluded_sysclone,excluded_regions{k});
                for l=1:length(reg)
                    obj.excluded_sysclone(reg{l})='filtered out regions';
                end
            end
        end



        function replacedClones=replaceSubsysClones(obj)
            replacedClones=struct([]);
            libsubsysBlks=obj.cloneresult.Before.libsubsysBlk;
            for i=1:length(libsubsysBlks)
                mdlblk=obj.cloneresult.Before.mdlBlks{i}{1};

                if obj.cloneresult.Before.similarCloneFlag{i}
                    continue;
                end

                if~isKey(obj.subsystemClones,mdlblk)&&~is_excluded_sysclone(obj,obj.cloneresult.Before.mdlBlks{i})
                    if obj.onemodelflag
                        validBlockPath=obj.cloneresult.Before.mdlBlks{i}{1};
                    else
                        validBlockPath=slEnginePir.util.getValidBlockPath(obj.genmodelprefix,...
                        obj.cloneresult.Before.mdlBlks{i}{1});
                    end
                    parentblk=get_param(validBlockPath,'Parent');

                    if subsystemMatch(obj,libsubsysBlks{i},parentblk)...
                        &&~hasSampleTime(obj,{parentblk})...
                        &&~slEnginePir.hasCallBackFcn({parentblk})

                        newblk=slEnginePir.updateBlock(parentblk,libsubsysBlks{i});
                        obj.subsystemClones(mdlblk)=getfullname(newblk);

                        appendingIndex=...
                        slEnginePir.util.getAppendIndexForStructArray(replacedClones);
                        replacedClones(appendingIndex).Name=getfullname(newblk);
                        replacedClones(appendingIndex).ReferenceSubsystem=libsubsysBlks{i};
                    end
                end
            end
        end


        function undoModelRefactor(obj,backmdlprefix)


            mdls=[{obj.mdlName},obj.refModels];
            slEnginePir.undoModelRefactor(mdls,backmdlprefix,obj.m2m_dir);
        end

        function nonEmpthyIdx=sortAndPruneCloneRegions(obj,result)
            len=length(result);
            if len<1
                return;
            end

            sorted_index=[];
            for i=1:len
                sorted_index=[sorted_index,i];
            end

            for i=1:len
                for j=i+1:len
                    if(isLarger(obj,result{i},result{j}))
                        t=result{j};
                        result{j}=result{i};
                        result{i}=t;
                        sorted_index([i,j])=sorted_index([j,i]);
                    end
                end
            end

            obj.cloneresult.Before.mdlBlks=result;
            obj.cloneresult.Before.libsubsysBlk=obj.cloneresult.Before.libsubsysBlk(sorted_index);
            obj.cloneresult.Before.libBlocks=obj.cloneresult.Before.libBlocks(sorted_index);
            obj.cloneresult.Before.similarCloneFlag=obj.cloneresult.Before.similarCloneFlag(sorted_index);

            for i=1:len
                for j=i+1:len
                    if(issubRegion(obj,result{i},result{j}))
                        result{i}={};
                    elseif(issubRegion(obj,result{j},result{i}))
                        result{j}={};
                    end
                end
            end

            nonEmpthyIdx=[];
            for i=1:len
                if~isempty(result{i})
                    nonEmpthyIdx=[nonEmpthyIdx,i];
                end
            end
        end


        function flag=issubRegion(~,r1,r2)
            len1=length(r1);
            len2=length(r2);
            flag=true;
            count=0;

            for i=1:len1
                for j=1:len2
                    if strcmp(r1{i},r2{j})
                        count=count+1;
                        break;
                    end
                end
            end
            if(count==i)
                flag=true;
                return;
            end
            flag=false;
        end

        function flag=isLarger(~,ri,rj)
            leni=length(ri);
            lenj=length(rj);
            flag=false;
            if leni>lenj
                flag=true;
                return;
            elseif leni<lenj
                flag=false;
                return;
            end
        end

        function cloneResplaceResults=replace_clones(obj,genmodel_prefix)
            if nargin>1
                obj.genmodelprefix=genmodel_prefix;
            end

            cloneResplaceResults=[];
            cloneResplaceResults.ReplacedClones=struct([]);



            if~obj.needrefactor&&~isempty(obj.cloneresult)

                DAStudio.error('sl_pir_cpp:creator:SimilarClonesNotSupportedForLibrary');
            end

            [~]=obj.loadLibraries(obj.libraryName);


            mdls={obj.mdlName};
            mdls=[mdls,obj.refModels,obj.libmdls];

            slEnginePir.modelChanged(mdls);





            if(~isempty(obj.region2BlockList))
                obj.handleExclusions();
            end
            obj.excludeSimilarClones();
            if~isempty(obj.cloneresult)
                nonEmpthyIdx=obj.sortAndPruneCloneRegions(obj.cloneresult.Before.mdlBlks);
                obj.cloneresult.Before.mdlBlks=obj.cloneresult.Before.mdlBlks(nonEmpthyIdx);
                obj.cloneresult.Before.libsubsysBlk=obj.cloneresult.Before.libsubsysBlk(nonEmpthyIdx);
                obj.cloneresult.Before.libBlocks=obj.cloneresult.Before.libBlocks(nonEmpthyIdx);
                obj.cloneresult.Before.similarCloneFlag=obj.cloneresult.Before.similarCloneFlag(nonEmpthyIdx);
            end
            obj.checkOverlapCandidates();
            obj.excludeCommentedRegion();

            [obj.xformed_mdl,loadedModelsList]=...
            slEnginePir.initGenModels(obj.m2m_dir,obj.refBlocksModels,...
            obj.mdlName,obj.linkedblks,obj.genmodelprefix,mdls,false);
            obj.loadedModels=...
            [obj.loadedModels;loadedModelsList];

            if isempty(obj.cloneresult)
                return;
            end

            libsubsysBlks=obj.cloneresult.Before.libsubsysBlk;
            mdlBlks=obj.cloneresult.Before.mdlBlks;
            libBlks=obj.cloneresult.Before.libBlocks;

            cloneResplaceResults.ModelBlocksListByClone=obj.cloneresult.Before.mdlBlks;
            obj.cloneresult.After=[];
            obj.checkCSCinfor();
            obj.excluded_sysclone=slEnginePir.checkmachineParentedData(mdlBlks,[{obj.mdlName},obj.refModels],obj.excluded_sysclone,false);
            obj.checkSLinChart();
            obj.checkStateReadWriteSystem();
            obj.checkSampleTimeCallFcn();
            obj.checkActionPortsInSys();
            obj.checkDSMInSys();
            obj.checkVariantSys();
            obj.checkMaskSys();
            obj.replaceSFcnSystem();



            replacedSubsystemPatterns=obj.replaceSubsysClones();
            cloneResplaceResults.ReplacedClones=slEnginePir.util.appendToStructArray(...
            cloneResplaceResults.ReplacedClones,replacedSubsystemPatterns);

            saveflag=false;
            for i=1:length(libsubsysBlks)
                if isKey(obj.subsystemClones,mdlBlks{i}{1})
                    obj.cloneresult.After{i}=obj.subsystemClones(mdlBlks{i}{1});
                    saveflag=true;
                    continue;
                end

                if obj.cloneresult.Before.similarCloneFlag{i}
                    continue;
                end

                if islinkedLibrary(obj,mdlBlks{i})
                    name=mdlBlks{i}{1};
                    obj.excluded_sysclone(name)='linked library block';
                end

                if is_excluded_sysclone(obj,mdlBlks{i})
                    continue;
                end

                [l,t,r,b]=getLibPosition(obj,mdlBlks{i});

                if obj.onemodelflag
                    newLibBlockName=getLibBlockName(obj,mdlBlks{i}{1},libsubsysBlks{i});
                else
                    newLibBlockName=slEnginePir.util.getValidBlockPath(obj.genmodelprefix,...
                    getLibBlockName(obj,mdlBlks{i}{1},libsubsysBlks{i}));
                end


                newlibBlkhandle=add_block(libsubsysBlks{i},newLibBlockName,'MakeNameUnique','on','Position',[l,t,r,b]);

                try
                    buildConnectivity(obj,newlibBlkhandle,libsubsysBlks{i},libBlks{i},mdlBlks{i});
                catch
                end
                obj.cloneresult.After{i}=getfullname(newlibBlkhandle);
                saveflag=true;

                appendingIndex=...
                slEnginePir.util.getAppendIndexForStructArray(cloneResplaceResults.ReplacedClones);
                cloneResplaceResults.ReplacedClones(appendingIndex).Name=getfullname(newlibBlkhandle);
                cloneResplaceResults.ReplacedClones(appendingIndex).ReferenceSubsystem=libsubsysBlks{i};
            end

            if obj.onemodelflag
                if strcmp(get_param(obj.mdlName,'Dirty'),'on')||saveflag
                    save_system(obj.mdlName,obj.mdlName,'SaveDirtyReferencedModels','on');
                end
            else
                if strcmp(get_param(obj.xformed_mdl,'Dirty'),'on')||saveflag
                    save_system(obj.xformed_mdl,[obj.m2m_dir,obj.xformed_mdl],'SaveDirtyReferencedModels','on');
                end
            end

        end


        function replaceSFcnSystem(obj)
            libsubsysBlks=obj.cloneresult.Before.libsubsysBlk;
            for i=1:length(libsubsysBlks)

                if isKey(obj.subsystemClones,obj.cloneresult.Before.mdlBlks{i}{1})
                    continue;
                end

                if~strcmp(get_param(libsubsysBlks{i},'Type'),'block_diagram')&&...
                    ~strcmpi(get_param(libsubsysBlks{i},'SFBlockType'),'NONE')
                    if obj.onemodelflag
                        curblk=obj.cloneresult.Before.mdlBlks{i}{1};
                    else
                        curblk=slEnginePir.util.getValidBlockPath(obj.genmodelprefix,...
                        obj.cloneresult.Before.mdlBlks{i}{1});
                    end
                    newblk=slEnginePir.updateBlock(curblk,libsubsysBlks{i});
                    obj.subsystemClones(obj.cloneresult.Before.mdlBlks{i}{1})=getfullname(newblk);
                end
            end
        end


        function[l,t,r,b]=getLibPosition(~,blockset)
            blockWidth=30;
            blockLength=30;

            cx=0;
            cy=0;
            numBlk=length(blockset);
            for i=1:numBlk
                bpos=get_param(blockset{i},'Position');
                cx=cx+(bpos(1)+bpos(3))/2;
                cy=cy+(bpos(2)+bpos(4))/2;
            end
            cx=cx/numBlk;
            cy=cy/numBlk;
            l=cx-blockWidth;
            r=cx+blockWidth;
            t=cy-blockLength;
            b=cy+blockLength;
        end

        function flag=islinkedLibrary(~,blockset)
            flag=false;

            fname=blockset{1};
            if~strcmp(get_param(fname,'Type'),'block_diagram')&&(strcmp(get_param(fname,'LinkStatus'),'resolved')||strcmp(get_param(fname,'LinkStatus'),'implicit'))
                flag=true;
            end
        end




        function newLibBlockName=getLibBlockName(~,blockfullname,libfullname)
            pname=get_param(blockfullname,'Parent');
            libname=get_param(libfullname,'Name');
            newLibBlockName=[pname,'/',libname];
        end



        function buildConnectivity(obj,newlibblkHandle,libsysBlock,libBlocks,mdlBlocks)




            sysName=get_param(newlibblkHandle,'Parent');


            InportName=find_system(libsysBlock,'LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'regexp','on','blocktype','Inport');


            directOutPortBlocks={};
            for i=1:length(InportName)

                pc=get_param(InportName{i},'PortConnectivity');
                allDstBlocks=pc.DstBlock;
                allDstports=pc.DstPort;
                for j=1:length(allDstBlocks)
                    libDstBlkFullName=getfullname(allDstBlocks(j));
                    dstnBlkType=get_param(libDstBlkFullName,'BlockType');
                    if strcmp(dstnBlkType,'Outport')



                        directOutPortBlocks{end+1}=libDstBlkFullName;
                        continue;
                    end
                    portIndex=allDstports(j);
                    for k=1:length(libBlocks)
                        if strcmp(libDstBlkFullName,libBlocks{k})
                            break;
                        end
                    end
                    if obj.onemodelflag
                        mdlDstBlkFullName=mdlBlocks{k};
                    else
                        mdlDstBlkFullName=slEnginePir.util.getValidBlockPath(obj.genmodelprefix,...
                        mdlBlocks{k});
                    end
                    mdlpc=get_param(mdlDstBlkFullName,'PortConnectivity');
                    srcPc=mdlpc(portIndex+1);

                    delete_line(sysName,[get_param(srcPc.SrcBlock,'Name'),'/',int2str(srcPc.SrcPort+1)],[get_param(mdlDstBlkFullName,'Name'),'/',srcPc.Type]);
                    if j==1
                        add_line(sysName,[get_param(srcPc.SrcBlock,'Name'),'/',int2str(srcPc.SrcPort+1)],[get_param(newlibblkHandle,'Name'),'/',int2str(i)],'autorouting','on');
                    end
                end
            end

            OutportName=find_system(libsysBlock,'LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'regexp','on','blocktype','Outport');
            for i=1:length(OutportName)










                opName=OutportName{i};
                if any(strcmp(directOutPortBlocks,opName))


                    continue;
                end
                pc=get_param(opName,'PortConnectivity');


                srcBlock=pc.SrcBlock;
                srcBlockFullName=getfullname(srcBlock);

                srcIndex=pc.SrcPort;


                for j=1:length(libBlocks)
                    if strcmp(srcBlockFullName,libBlocks{j})
                        break;
                    end
                end

                if obj.onemodelflag
                    mdlSrcBlkFullName=mdlBlocks{j};
                else
                    mdlSrcBlkFullName=slEnginePir.util.getValidBlockPath(obj.genmodelprefix,...
                    mdlBlocks{j});
                end

                pc=get_param(mdlSrcBlkFullName,'PortConnectivity');
                ph=get_param(mdlSrcBlkFullName,'PortHandles');
                noInputs=length(ph.Inport)+length(ph.Enable)+length(ph.Trigger)+length(ph.State)+length(ph.LConn)+length(ph.Ifaction)+length(ph.Reset);
                pc2=pc(noInputs+srcIndex+1);


                for j=1:length(pc2.DstBlock)
                    delete_line(sysName,[get_param(mdlSrcBlkFullName,'Name'),'/',int2str(srcIndex+1)],[get_param(pc2.DstBlock(j),'Name'),'/',int2str(pc2.DstPort(j)+1)]);
                    add_line(sysName,[get_param(newlibblkHandle,'Name'),'/',int2str(i)],[get_param(pc2.DstBlock(j),'Name'),'/',int2str(pc2.DstPort(j)+1)],'autorouting','on');
                end
            end


            inp2dirOutBlkMap=containers.Map();
            for pIdx=1:length(directOutPortBlocks)
                outBlk=directOutPortBlocks{pIdx};
                pc=get_param(outBlk,'PortConnectivity');
                srcBlk=getfullname(pc.SrcBlock);
                if~isKey(inp2dirOutBlkMap,srcBlk)
                    inp2dirOutBlkMap(srcBlk)={outBlk};
                else
                    val=inp2dirOutBlkMap(srcBlk);
                    val{end+1}=srcBlk;
                    inp2dirOutBlkMap(srcBlk)=val;
                end
            end

            inBlocks=keys(inp2dirOutBlkMap);
            for pIdx=1:length(inBlocks)
                inSrcBlk=inBlocks{pIdx};
                outDstnBlks=inp2dirOutBlkMap(inSrcBlk);
                inPort=str2double(get_param(inSrcBlk,'Port'));
                pcNewLibBlk=get_param(newlibblkHandle,'PortConnectivity');
                srcBlk=pcNewLibBlk(inPort).SrcBlock;
                srcPort=pcNewLibBlk(inPort).SrcPort+1;
                pcSrcBlk=get_param(srcBlk,'PortConnectivity');
                phSrcBlk=get_param(srcBlk,'PortHandles');
                noInputs=length(phSrcBlk.Inport)+length(phSrcBlk.Enable)+length(phSrcBlk.Trigger)+length(phSrcBlk.State)+length(phSrcBlk.LConn)+length(phSrcBlk.Ifaction)+length(phSrcBlk.Reset);
                pcSrcBlk=pcSrcBlk(noInputs+1);
                srcDstnBlks=pcSrcBlk(srcPort).DstBlock;
                srcDstnPorts=pcSrcBlk(srcPort).DstPort+1;

                indices=srcDstnBlks~=newlibblkHandle;
                srcDstnBlks=srcDstnBlks(indices);
                srcDstnPorts=srcDstnPorts(indices);
                for bIdx=1:numel(outDstnBlks)
                    srcDstnBlk=srcDstnBlks(bIdx);
                    srcDstnPort=srcDstnPorts(bIdx);
                    delete_line(sysName,[get_param(srcBlk,'Name'),'/',int2str(srcPort)],[get_param(srcDstnBlk,'Name'),'/',int2str(srcDstnPort)]);
                    outDstnBlk=outDstnBlks{bIdx};
                    outDstnBlkPort=str2double(get_param(outDstnBlk,'Port'));
                    add_line(sysName,[get_param(newlibblkHandle,'Name'),'/',int2str(outDstnBlkPort)],[get_param(srcDstnBlk,'Name'),'/',int2str(srcDstnPort)],'autorouting','on');
                end



                lastIdx=bIdx;
                for idx=bIdx+1:numel(srcDstnBlks)
                    srcDstnBlk=srcDstnBlks(idx);
                    srcDstnPort=srcDstnPorts(idx);
                    delete_line(sysName,[get_param(srcBlk,'Name'),'/',int2str(srcPort)],[get_param(srcDstnBlk,'Name'),'/',int2str(srcDstnPort)]);
                    outDstnBlk=outDstnBlks{lastIdx};
                    outDstnBlkPort=str2double(get_param(outDstnBlk,'Port'));
                    add_line(sysName,[get_param(newlibblkHandle,'Name'),'/',int2str(outDstnBlkPort)],[get_param(srcDstnBlk,'Name'),'/',int2str(srcDstnPort)],'autorouting','on');
                end

            end


            for i=1:length(mdlBlocks)
                if obj.onemodelflag
                    delete_block(mdlBlocks{i});
                else
                    delete_block(slEnginePir.util.getValidBlockPath(obj.genmodelprefix,...
                    mdlBlocks{i}));
                end
            end


            delete_line(find_system(sysName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','IncludeCommented','on','findall','on','Type','Line','Connected','off'));

        end

        function libraryHandle=loadLibraries(obj,libraryfile)
            try
                [~,libraryNameWithoutExtension,~]=fileparts(libraryfile);
                if~bdIsLoaded(libraryNameWithoutExtension)
                    try
                        libraryHandle=load_system(libraryNameWithoutExtension);
                    catch
                        libraryHandle=load_system(libraryfile);
                    end
                    obj.loadedModels=...
                    [obj.loadedModels;{libraryfile}];
                else
                    libraryHandle=get_param(libraryNameWithoutExtension,'handle');
                end
            catch exception
                exception.throwAsCaller();
            end
        end

        function closeOpenedModels(this)
            this.loadedModels=slEnginePir.util.closeBlockDiagramsInList(this.loadedModels);
        end
    end

    methods(Access='private')

        function excludeCommentedRegion(obj)
            if isempty(obj.cloneresult)
                return;
            end
            allCloneCandidates=obj.cloneresult.Before;

            for i=1:length(allCloneCandidates.mdlBlks)
                mdlBlks=allCloneCandidates.mdlBlks{i};
                libBlks=allCloneCandidates.libBlocks{i};

                if iscell(mdlBlks)
                    if~is_excluded_sysclone(obj,mdlBlks)
                        for j=1:length(mdlBlks)
                            if~strcmp(get_param(mdlBlks{j},'Commented'),get_param(libBlks{j},'Commented'))
                                obj.excluded_sysclone(mdlBlks{1})='Blocks Commented properties are not consistent';
                                disp('Blocks commented properties are not consistent, excluded for clone replacement');
                                break;
                            end
                        end
                    end
                elseif~is_excluded_sysclone(obj,mdlBlks)
                    if~strcmp(get_param(mdlBlks,'Commented'),get_param(libBlks,'Commented'))
                        obj.excluded_sysclone(mdlBlks)='Blocks Commented properties are not consistent';
                        disp('Blocks commented properties are not consistent, excluded for replacement.');
                        break;
                    end
                end
            end
        end

        function computeChecksumForLibraryandModels(obj)


            refModelsLib=obj.getmodelListsforModelandLibrary();

            mdlList=[{getfullname(obj.mdlName)},obj.refModels];
            for i=length(mdlList):-1:1
                if i==length(mdlList)

                    obj.computeLibraryModelRefChksum(refModelsLib);
                    for j=1:length(obj.libraryName)
                        libhandle=get_param(obj.libraryName{j},'Handle');
                        Simulink.SLPIR.CloneDetection.buildLibraryBlockTypeAndChecksumMap(libhandle,obj.clonepattern);
                    end
                end
                if(i==1)
                    obj=obj.doLibraryClones(mdlList{i},obj.clonepattern,1);
                else
                    obj=obj.doLibraryClones(mdlList{i},obj.clonepattern,0);
                end
            end
        end

        function obj=doLibraryClones(obj,mdlname,~,clearRootbdChksumFlag)
            if(nargin<4)
                clearRootbdChksumFlag=0;
            end

            try
                if~bdIsLoaded(mdlname)
                    return;
                end



                xformedblks=Simulink.SLPIR.CloneDetection.findLibraryClones(get_param(mdlname,'Handle'),obj.domain,obj.clonepattern,clearRootbdChksumFlag);
                if isempty(obj.clonegroups)
                    obj.clonegroups=xformedblks;
                elseif~isempty(xformedblks)
                    obj.clonegroups(end+1:end+length(xformedblks),1)=xformedblks(1:end);
                end

            catch ME
                for i=1:length(ME.stack)
                    fprintf('%s:%d\n',ME.stack(i).file,ME.stack(i).line);
                end
                fprintf('invoke failed with error %s\n',ME.identifier);
                fprintf('%s\n',ME.message);
            end
        end




        function refModelsLib=getmodelListsforModelandLibrary(obj)
            mdlfullname=getfullname(obj.mdlName);
            C=textscan(mdlfullname,'%s','Delimiter','/');
            mdlname=C{1}{1};

            if obj.includeMdl||obj.includeLib
                [obj.refBlocksModels,obj.refModels,obj.linkedblks,~,explicitlyLoadedModels]=...
                slEnginePir.all_referlinked_blk(mdlname,[],{},'on');
                obj.loadedModels=[obj.loadedModels;explicitlyLoadedModels];
                if~isempty(obj.linkedblks)
                    obj.libmdls=unique({obj.linkedblks.lib});
                end
            end

            if~obj.includeMdl
                obj.refBlocksModels=[];
                obj.refModels=[];
            end

            if~obj.includeLib
                obj.libmdls=[];
                obj.linkedblks=[];
            end

            for i=1:length(obj.libraryName)
                libfullname=getfullname(obj.libraryName{i});
                C=textscan(libfullname,'%s','Delimiter','/');
                libname=C{1}{1};
                [~,refModelsLib,~,~,explicitlyLoadedModels]=slEnginePir.all_referlinked_blk(libname,[],{},'on');
                obj.loadedModels=[obj.loadedModels;explicitlyLoadedModels];
            end
        end

        function computeLibraryModelRefChksum(obj,refModelsLib)

            if isempty(refModelsLib)
                return;
            end

            slSubSysHandle=0;
            isSubSystem=false;
            for i=length(refModelsLib):-1:1
                if bdIsLoaded(refModelsLib{i})
                    slhandle=get_param(refModelsLib{i},'Handle');
                    Simulink.SLPIR.CloneDetection.computeSystemChecksum(slhandle,obj.domain,obj.clonepattern,obj.ignoreSignalName,obj.ignoreBlockProperty,slSubSysHandle,isSubSystem);
                end
            end
        end

        function buildTraceability(obj)
            allBefores=obj.cloneresult.Before.mdlBlks;
            allAfters=obj.cloneresult.After;

            ind=length(obj.traceability_map)+1;
            for i=1:length(allBefores)

                if obj.is_excluded_sysclone(allBefores{i})||isempty(allAfters{i})
                    continue;
                end

                for j=1:length(allBefores{i})
                    obj.traceability_map(ind).Before={Simulink.ID.getSID(allBefores{i}{j})};
                    obj.traceability_map(ind).After={Simulink.ID.getSID(allAfters{i})};
                    ind=ind+1;
                end
            end
        end
    end
end






