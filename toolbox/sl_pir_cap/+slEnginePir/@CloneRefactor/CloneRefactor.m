classdef CloneRefactor<handle





    methods(Static,Access=public)
        function[result,loadedModels]=replaceClones(cloneDetectionObj,libname,genmodel_prefix)
            result=[];
            result.ReplacedClones=struct([]);
            loadedModels={};
            if isempty(cloneDetectionObj.cloneresult)
                return;
            end
            slEnginePir.CloneRefactor.checkWritableAllModels(cloneDetectionObj);


            if slEnginePir.hasStateReadWriter([{cloneDetectionObj.mdl},cloneDetectionObj.refModels])
                DAStudio.error('sl_pir_cpp:creator:ModelhasStateReadWrite');
            end

            if nargin>2
                cloneDetectionObj.genmodelprefix=genmodel_prefix;
            end

            mdls={cloneDetectionObj.mdlName};
            mdls=[mdls,cloneDetectionObj.refModels,cloneDetectionObj.changedLibraries.keys];
            [~,explicitlyLoadedModels]=...
            slEnginePir.initGenModels(cloneDetectionObj.m2m_dir,cloneDetectionObj.refBlocksModels,...
            cloneDetectionObj.mdlName,cloneDetectionObj.linkedblks,cloneDetectionObj.genmodelprefix,mdls);
            loadedModels=[loadedModels;explicitlyLoadedModels];
            clonesListByGroup=cloneDetectionObj.cloneresult.Before;
            slEnginePir.CloneRefactor.checkforRefactorOptions(cloneDetectionObj,...
            clonesListByGroup);
            for i=1:length(cloneDetectionObj.refBlocksModels)
                for l=1:length(cloneDetectionObj.refBlocksModels(i).block)
                    if(strcmp(cloneDetectionObj.refBlocksModels(i).block(l),'/'))
                        break;
                    end
                end
                temp=cloneDetectionObj.refBlocksModels(i).block(1:l-1);
                if~strcmp(get_param(temp,'BlockDiagramType'),'library')
                    for j=1:length(cloneDetectionObj.refBlocksModels(i).refmdl)
                        modelName=get_param(cloneDetectionObj.refBlocksModels(i).refmdl{j},'Name');
                        temporaryValidModelName=slEnginePir.util.getTemporaryModelName(cloneDetectionObj.genmodelprefix,modelName);
                        temporaryValidBlockPath=slEnginePir.util.getTemporaryValidBlockPath(cloneDetectionObj.genmodelprefix,...
                        cloneDetectionObj.refBlocksModels(i).block);
                        set_param(temporaryValidBlockPath,'ModelName',temporaryValidModelName);
                    end
                end
            end

            for i=1:length(cloneDetectionObj.creator.differentBlockParamName)
                if(~cloneDetectionObj.creator.differentBlockParamName(i).RefactorOption)
                    warning(message('sl_pir_cpp:creator:DifferentMaskParameterNameNotSupported',cloneDetectionObj.mdlName));
                    return;
                end
            end

            if(cloneDetectionObj.isReplaceExactCloneWithSubsysRef)
                [rawResults,explicitlyLoadedModels]=...
                slEnginePir.CloneRefactor.replaceExactClonesWithSubsystemreferences(cloneDetectionObj);
                result.ReplacedClones=rawResults.ReplacedClones;
            else
                [result.ReplacedClones,explicitlyLoadedModels]=...
                slEnginePir.CloneRefactor.replaceClonesWithLibrary(cloneDetectionObj,libname);
            end
            loadedModels=[loadedModels;explicitlyLoadedModels];
        end

        function[refLibraryBlock,existClonesToRefactorInCloneGroupFlag,this]=...
            existClonesToRefactorInCloneGroup(this,listOfClonesInAGroup,cloneGroupIndex)
            refLibraryBlock='';
            existClonesToRefactorInCloneGroupFlag=false;
            linkAvailable=false;

            for cloneIndex=1:length(listOfClonesInAGroup)
                cloneName=listOfClonesInAGroup{cloneIndex};
                if isKey(this.excluded_sysclone,cloneName)
                    continue;
                end
                if~strcmp(get_param(cloneName,'Type'),'block_diagram')&&...
                    (strcmp(get_param(cloneName,'LinkStatus'),'resolved')||strcmp(get_param(cloneName,'LinkStatus'),'implicit'))&&...
                    isempty(get_param(cloneName,'linkdata'))
                    refLibraryBlock=get_param(cloneName,'ReferenceBlock');
                    this.cloneresult.lib{cloneGroupIndex}=cloneName;
                    linkAvailable=true;
                    continue;
                end
                existClonesToRefactorInCloneGroupFlag=true;
                if linkAvailable
                    break;
                end
            end
        end

        function[existClonesToRefactorInCloneGroupFlag,this]=...
            existClonesToRefactorInCloneGroupClonesAny(this,listOfClonesInAGroup)
            existClonesToRefactorInCloneGroupFlag=false;

            for cloneIndex=1:length(listOfClonesInAGroup)
                cloneName=listOfClonesInAGroup(cloneIndex).Candidates{1};
                parentName=get_param(cloneName,'Parent');
                if isKey(this.excluded_sysclone,cloneName)||isKey(this.excluded_sysclone,parentName)
                    continue;
                end
                if~strcmp(get_param(cloneName,'Type'),'block_diagram')&&...
                    (strcmp(get_param(cloneName,'LinkStatus'),'resolved')||strcmp(get_param(cloneName,'LinkStatus'),'implicit'))&&...
                    isempty(get_param(cloneName,'linkdata'))
                    continue;
                end
                existClonesToRefactorInCloneGroupFlag=true;
            end
        end


        function[this,isExplicitlyLoaded]=loadLibraryFile(this,libName)
            isExplicitlyLoaded=false;
            this.inputLibName=libName;

            if~exist([libName,'.slx'],'file')&&~exist([libName,'.mdl'],'file')
                if bdIsLoaded(libName)
                    close_system(libName,0);
                end
                new_system(libName,'Library');
                isExplicitlyLoaded=true;

            else
                if slEnginePir.util.loadBlockDiagramIfNotLoaded(libName)
                    isExplicitlyLoaded=true;
                end

                [~,libName,~]=fileparts(libName);
                if~strcmp(get_param(libName,'BlockDiagramType'),'library')
                    DAStudio.error('sl_pir_cpp:creator:IllegalName3_lib',libName);
                else
                    set_param(libName,'Lock','off');
                end
            end
            this.libname=libName;
        end

        function[posx,posy,libblkno,refBlock]=...
            getNewReferenceblocks(this,posx,posy,libblkno,...
            listOfClonesInAGroup,libname,cloneGroupIndex)


            [fname,setAuto]=slEnginePir.CloneRefactor.getLibrarySubsystem(this,listOfClonesInAGroup);
            if strcmp(get_param(fname,'Type'),'block_diagram')

                tmpfnameblk=slEnginePir.CloneRefactor.getmdlrefBlocks(this,fname);

                if iscell(tmpfnameblk)
                    fnameblk=tmpfnameblk{1};
                else
                    fnameblk=tmpfnameblk;
                end
            else
                fnameblk=fname;
            end
            this.cloneresult.lib{cloneGroupIndex}=fname;

            refBlock=[libname,'/',strrep(get_param(fnameblk,'Name'),'/','//')];
            [w,l]=slEnginePir.CloneRefactor.getBlocksize(this,fnameblk);
            deltax=30;
            deltay=30;
            pos(1)=posx;
            pos(2)=posy;
            pos(3)=posx+w;
            pos(4)=posy+l;
            posx=posx+w+deltax;
            if mod(libblkno,5)==0
                posx=0;
                posy=pos(4)+deltay;
                libblkno=1;
            else
                libblkno=libblkno+1;
            end


            if~strcmp(get_param(fname,'Type'),'block_diagram')
                blkhandle=add_block(fname,refBlock,'MakeNameUnique','on','Position',pos);
                if~strcmp(get_param(blkhandle,'LinkStatus'),'none')
                    set_param(blkhandle,'LinkStatus','none');
                end
            else
                blkhandle=add_block('built-in/Subsystem',refBlock,'MakeNameUnique','on','Position',pos);
                Simulink.BlockDiagram.copyContentsToSubSystem(fname,getfullname(blkhandle));
            end

            if setAuto
                set_param(blkhandle,'RTWSystemCode','Auto');
            end

            set_param(blkhandle,'VariantControl','');

            refBlock=getfullname(blkhandle);
        end

        function[replacedClones,innerSubsysMask]=updateBlockwithRefernceBlock(this,listOfClonesInAGroup,...
            refBlock,cloneGroupIndex,clonesListOfAllGroups,existClonesToRefactorAllGroupsFlags,replaceWithOriginal,return_val,innerSubsysMask)
            replacedClones=struct([]);
            for j=1:length(listOfClonesInAGroup)
                fname=listOfClonesInAGroup{j};
                if isKey(this.excluded_sysclone,fname)
                    continue;
                end

                if~strcmp(get_param(fname,'Type'),'block_diagram')&&...
                    (strcmp(get_param(fname,'LinkStatus'),'resolved')||strcmp(get_param(fname,'LinkStatus'),'implicit'))&&...
                    isempty(get_param(fname,'linkdata'))
                    this.excluded_sysclone(fname)=...
                    DAStudio.message('sl_pir_cpp:creator:ExclusionReasonCloneLinkedToLibrary',fname,get_param(fname,'ReferenceBlock'));
                    continue;
                end
                oriMdlName=fname;


                if strcmp(get_param(fname,'Type'),'block_diagram')
                    isCloneReplaced=slEnginePir.CloneRefactor.updateModelRef(this,fname,refBlock,oriMdlName,cloneGroupIndex,replaceWithOriginal);
                    if isCloneReplaced
                        appendingIndex=...
                        slEnginePir.util.getAppendIndexForStructArray(replacedClones);
                        replacedClones(appendingIndex).Name=fname;
                        replacedClones(appendingIndex).ReferenceSubsystem=refBlock;
                    end
                    continue;
                end




                if~isempty(get_param(fname,'VariantControl'))&&~slEnginePir.CloneRefactor.hasSameInOutPortName(this,fname,refBlock)

                    this.excluded_sysclone(oriMdlName)='Inside variant subsystem and has different in/out port name.';
                    continue;
                end

                [isCloneReplaced,innerSubsysMask]=slEnginePir.CloneRefactor.updateStructBlock(this,...
                oriMdlName,fname,refBlock,cloneGroupIndex,clonesListOfAllGroups,existClonesToRefactorAllGroupsFlags,replaceWithOriginal,replacedClones,return_val,innerSubsysMask);

                if isCloneReplaced
                    appendingIndex=...
                    slEnginePir.util.getAppendIndexForStructArray(replacedClones);
                    replacedClones(appendingIndex).Name=fname;
                    replacedClones(appendingIndex).ReferenceSubsystem=refBlock;
                end
            end
        end


        function saveAllModelsAndLibrary(this,libname,newlibsaveflag)

            for i=length(this.refModels):-1:1
                mdlname=this.refModels{i};
                if bdIsLoaded(mdlname)&&strcmp(get_param(mdlname,'Dirty'),'on')
                    try
                        save_system(mdlname,[],'SaveDirtyReferencedModels',true);
                    catch
                        DAStudio.error('sl_pir_cpp:creator:ModelHierarchyCannotBeSaved',...
                        mdlname);
                    end
                end
            end


            save_system(this.mdlName,[],'SaveDirtyReferencedModels',true);


            if newlibsaveflag&&strcmp(get_param(libname,'Dirty'),'on')
                slEnginePir.CloneRefactor.checkWritableforSystem(this,libname);
                save_system(libname,[],'SaveDirtyReferencedModels',true);
            elseif~newlibsaveflag
                close_system(libname,0);

            end
        end


        function checkWritableAllModels(this)

            for i=length(this.refModels):-1:1
                mdlname=this.refModels{i};
                if bdIsLoaded(mdlname)&&strcmp(get_param(mdlname,'Dirty'),'on')
                    slEnginePir.CloneRefactor.checkWritableforSystem(this,mdlname);
                end
            end
            slEnginePir.CloneRefactor.checkWritableforSystem(this,this.mdlName);
        end


        function maxposy=getMaxPosyPosition(libname)
            allblks=find_system(libname,'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on',...
            'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on');
            if length(allblks)==1
                maxposy=0;
                return;
            end

            maxposy=0;
            for i=2:length(allblks)
                r=get_param(allblks{i},'Position');
                if(r(4)>maxposy)
                    maxposy=r(4);
                end
            end
        end


        function checkforRefactorOptions(this,clonesListByGroup)
            slEnginePir.CloneRefactor.checkCSCinfor(this,clonesListByGroup);
            this.excluded_sysclone=slEnginePir.checkmachineParentedData(clonesListByGroup,[{this.mdlName},this.refModels],this.excluded_sysclone,true);
            slEnginePir.CloneRefactor.checkSLinChart(this,clonesListByGroup);
            slEnginePir.CloneRefactor.checkSampleTimeCallFcn(this,clonesListByGroup);
            slEnginePir.CloneRefactor.checkTriggerPortsInMdlRef(this,clonesListByGroup);
            slEnginePir.CloneRefactor.checkSimulinkFunctionStruct(this,clonesListByGroup);



            slEnginePir.CloneRefactor.checkSubsystemDialogParameters(this,clonesListByGroup);
            slEnginePir.CloneRefactor.checkSubsystemPermission(this,clonesListByGroup);
            slEnginePir.CloneRefactor.checkConfigurableSubsystem(this,clonesListByGroup);
        end

        function[l,t,r,b]=getLibraryPosition(~,blockset)
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

        function newLibBlockName=getLibBlockName(~,blockfullname,libfullname)
            pname=get_param(blockfullname,'Parent');
            libname=get_param(libfullname,'Name');
            newLibBlockName=[pname,'/',libname];
        end

        function buildConnectivity(obj,newlibblkHandle,libsysBlock,libBlocks,mdlBlocks)





            sysName=get_param(newlibblkHandle,'Parent');


            InportName=find_system(libsysBlock,'LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'regexp','on','blocktype','Inport');

            for i=1:length(InportName)

                pc=get_param(InportName{i},'PortConnectivity');

                allDstBlocks=pc.DstBlock;
                allDstports=pc.DstPort;
                for j=1:length(allDstBlocks)
                    libDstBlkFullName=getfullname(allDstBlocks(j));
                    portIndex=allDstports(j);

                    for k=1:length(libBlocks)
                        if strcmp(libDstBlkFullName,libBlocks{k})
                            break;
                        end
                    end

                    mdlDstBlkFullName=mdlBlocks{k};

                    mdlpc=get_param(mdlDstBlkFullName,'PortConnectivity');
                    srcPc=mdlpc(portIndex+1);
                    if(srcPc.SrcBlock==-1)
                        continue;
                    end

                    delete_line(sysName,[get_param(srcPc.SrcBlock,'Name'),'/',int2str(srcPc.SrcPort+1)],[get_param(mdlDstBlkFullName,'Name'),'/',srcPc.Type]);
                    if j==1
                        add_line(sysName,[get_param(srcPc.SrcBlock,'Name'),'/',int2str(srcPc.SrcPort+1)],[get_param(newlibblkHandle,'Name'),'/',int2str(i)],'autorouting','on');
                    end
                end
            end

            OutportName=find_system(libsysBlock,'LookUnderMasks','all','IncludeCommented','on','SearchDepth',1,'regexp','on','blocktype','Outport');
            for i=1:length(OutportName)










                opName=OutportName{i};
                pc=get_param(opName,'PortConnectivity');


                srcBlock=pc.SrcBlock;
                srcBlockFullName=getfullname(srcBlock);

                srcIndex=pc.SrcPort;


                for j=1:length(libBlocks)
                    if strcmp(srcBlockFullName,libBlocks{j})
                        break;
                    end
                end

                mdlSrcBlkFullName=mdlBlocks{j};

                pc=get_param(mdlSrcBlkFullName,'PortConnectivity');
                ph=get_param(mdlSrcBlkFullName,'PortHandles');
                noInputs=length(ph.Inport)+length(ph.Enable)+length(ph.Trigger)+length(ph.State)+length(ph.LConn)+length(ph.Ifaction)+length(ph.Reset);
                pc2=pc(noInputs+srcIndex+1);


                for j=1:length(pc2.DstBlock)
                    if(pc2.DstBlock(j)==-1)
                        continue;
                    end

                    idx=pc2.DstPort(j)+1;
                    connectivity=get_param(pc2.DstBlock(j),'PortConnectivity');
                    if strcmp(connectivity(idx).Type,'enable')
                        enablePortsInSystem=find_system(pc2.DstBlock(j),'BlockType','EnablePort');
                        enablePortName=get_param(enablePortsInSystem,'Name');
                        delete_line(sysName,[get_param(mdlSrcBlkFullName,'Name'),'/',int2str(srcIndex+1)],[get_param(pc2.DstBlock(j),'Name'),'/',enablePortName]);
                        add_line(sysName,[get_param(newlibblkHandle,'Name'),'/',int2str(i)],[get_param(pc2.DstBlock(j),'Name'),'/',enablePortName],'autorouting','on');
                    else
                        delete_line(sysName,[get_param(mdlSrcBlkFullName,'Name'),'/',int2str(srcIndex+1)],[get_param(pc2.DstBlock(j),'Name'),'/',int2str(pc2.DstPort(j)+1)]);
                        add_line(sysName,[get_param(newlibblkHandle,'Name'),'/',int2str(i)],[get_param(pc2.DstBlock(j),'Name'),'/',int2str(pc2.DstPort(j)+1)],'autorouting','on');
                    end
                end
            end

            for i=1:length(mdlBlocks)
                delete_block(mdlBlocks{i});
            end


            delete_line(find_system(sysName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','IncludeCommented','on','findall','on','Type','Line','Connected','off'));
        end

        function flag=isUnsuportedBlocks(this,blk)
            flag=0;
            if strcmp(get_param(blk,'BlockType'),'WhileIterator')||...
                strcmp(get_param(blk,'BlockType'),'ForIterator')||...
                strcmp(get_param(blk,'BlockType'),'ArgIn')||...
                strcmp(get_param(blk,'BlockType'),'ArgOut')||...
                strcmp(get_param(blk,'BlockType'),'Goto')||...
                strcmp(get_param(blk,'BlockType'),'From')
                this.excluded_sysclone(blk)=DAStudio.message('sl_pir_cpp:creator:ContainsUnsupportedBlocks');
                flag=1;
            end
        end


        function cloneReplaceResults=replaceClonesAnywhere(this,libname,genmodel_prefix)
            cloneReplaceResults=[];
            cloneReplaceResults.ReplacedClones=struct([]);

            if isempty(this.cloneresult)
                return;
            end

            slEnginePir.CloneRefactor.checkWritableAllModels(this);

            if nargin>2
                this.genmodelprefix=genmodel_prefix;
            end


            if slEnginePir.hasStateReadWriter([{this.mdl},this.refModels])
                DAStudio.error('sl_pir_cpp:creator:ModelhasStateReadWrite');
            end

            mdls={this.mdlName};
            mdls=[mdls,this.refModels,this.changedLibraries.keys];
            [~,~]=...
            slEnginePir.initGenModels(this.m2m_dir,this.refBlocksModels,...
            this.mdlName,this.linkedblks,this.genmodelprefix,mdls);

            if(~isempty(this.region2BlockList))
                slEnginePir.CloneRefactor.handleIgnoredListForRefactoring(this);
            end

            clonesListByGroup=this.creator.clonegroups;
            existClonesToRefactorForGroupsFlag=zeros(1,length(clonesListByGroup));
            needToLoadTargetLibrary=false;
            for cloneGroupIndex=length(clonesListByGroup):-1:1
                [existClonesToRefactorInCloneGroupFlag]=...
                slEnginePir.CloneRefactor.existClonesToRefactorInCloneGroupClonesAny(this,...
                clonesListByGroup(cloneGroupIndex).Region);
                existClonesToRefactorForGroupsFlag(cloneGroupIndex)=existClonesToRefactorInCloneGroupFlag;
                needToLoadTargetLibrary=needToLoadTargetLibrary||existClonesToRefactorInCloneGroupFlag;
            end
            if needToLoadTargetLibrary
                slEnginePir.CloneRefactor.loadLibraryFile(this,libname);
                RegNo=1;
            end
            for i=1:length(clonesListByGroup)
                if~existClonesToRefactorForGroupsFlag(i)




                    continue;
                end
                port_src=containers.Map('KeyType','char','ValueType','double');
                port_dst=containers.Map('KeyType','char','ValueType','double');
                added_blks=containers.Map('KeyType','char','ValueType','double');
                inputBlkName=containers.Map('KeyType','char','ValueType','char');
                bh=[];
                if~isempty(this.cloneresult.dissimiliarty{i})
                    idx=slEnginePir.CloneRefactor.chooseLib(this,clonesListByGroup(i));
                else
                    idx=1;
                end
                contains_invalid_blocks=0;
                libblks=[];
                existingSubsystemNo=length(find_system(libname,'SearchDepth',1,'BlockType','SubSystem'))+1;
                for j=1:length(clonesListByGroup(i).Region(idx).Candidates)
                    name1=get_param(clonesListByGroup(i).Region(idx).Candidates{j},'Name');
                    contains_invalid_blocks=slEnginePir.CloneRefactor.isUnsuportedBlocks(this,clonesListByGroup(i).Region(idx).Candidates{j});
                    if(contains_invalid_blocks)
                        break;
                    end

                    try
                        add_block(clonesListByGroup(i).Region(idx).Candidates{j},libname+"/"+name1);
                    catch
                        contains_invalid_blocks=1;
                        break;
                    end
                    bh=[bh,get_param(libname+"/"+name1,'handle')];
                    added_blks(name1)=1;
                    libblks=[libblks,libname+"/"+"region"+existingSubsystemNo+"/"+name1];
                end

                if contains_invalid_blocks
                    alreadyAddedBlocks=find_system(libname,'SearchDepth',1);
                    for k=2:length(alreadyAddedBlocks)
                        if~strcmp(get_param(alreadyAddedBlocks{k},'Type'),'block_diagram')&&...
                            ~strcmp(get_param(alreadyAddedBlocks{k},'BlockType'),'SubSystem')
                            delete_block(alreadyAddedBlocks{k});
                        end
                    end
                    continue;
                end

                for j=1:length(clonesListByGroup(i).Region(idx).Candidates)
                    name1=get_param(clonesListByGroup(i).Region(idx).Candidates{j},'Name');
                    portDst=get_param(clonesListByGroup(i).Region(idx).Candidates{j},'PortHandles');
                    allPorts=get_param(clonesListByGroup(i).Region(idx).Candidates{j},'PortConnectivity');
                    for k=1:length(allPorts)
                        for n=1:length(allPorts(k).SrcBlock)
                            if(allPorts(k).SrcBlock(n)==-1)
                                continue;
                            end
                            srcBlkName=getfullname(allPorts(k).SrcBlock(n));
                            pos=get_param(allPorts(k).SrcBlock(n),'Position');
                            if~isempty(srcBlkName)
                                name2=get_param(srcBlkName,'Name');
                                allPorts1=get_param(srcBlkName,'PortConnectivity');
                                portDst1=get_param(srcBlkName,'PortHandles');
                                imsrcBlkName=srcBlkName;
                                for l=1:length(allPorts1)
                                    for m=1:length(allPorts1(l).DstBlock)
                                        if(strcmp(getfullname(allPorts1(l).DstBlock(m)),clonesListByGroup(i).Region(idx).Candidates{j})&&...
                                            ~isempty(str2num(allPorts(k).Type))&&(allPorts1(l).DstPort(m)+1==str2num(allPorts(k).Type)))
                                            if strcmp(get_param(imsrcBlkName,'BlockType'),'Inport')
                                                src_port=1;
                                            else
                                                src_port=allPorts(k).SrcPort(n)+1;
                                            end
                                            count=0;
                                            dst_port=allPorts1(l).DstPort(m)+1;
                                            for port_idx=1:length(allPorts1(l).DstBlock)
                                                for ele_idx=1:length(clonesListByGroup(i).Region(idx).Candidates)
                                                    if strcmp(clonesListByGroup(i).Region(idx).Candidates{ele_idx},getfullname(allPorts1(l).DstBlock(port_idx)))
                                                        count=count+1;
                                                        break;
                                                    end
                                                end
                                            end
                                            is_multiple_dest=isKey(port_src,name2+"/"+src_port)&&(count>1);
                                            isconnected=(~isKey(port_src,name2+"/"+src_port)||is_multiple_dest)&&...
                                            ~isKey(port_dst,name1+"/"+dst_port);
                                            if(isconnected)

                                                if(strcmp(get_param(srcBlkName,'BlockType'),'Inport')||...
                                                    ~isKey(added_blks,name2))&&(~is_multiple_dest)
                                                    inportBlks=find_system(libname,'SearchDepth',1,'BlockType','Inport');
                                                    inNumber=length(inportBlks)+1;
                                                    src_port=1;
                                                    port_src(name2+"/"+src_port)=1;
                                                    add_block('simulink/Ports & Subsystems/In1',libname+"/"+'In'+inNumber);
                                                    inputBlkName(name2)=get_param(libname+"/"+'In'+inNumber,'Name');
                                                    name2=get_param(libname+"/"+'In'+inNumber,'Name');
                                                    added_blks(name2)=1;
                                                    imsrcBlkName=libname+"/"+'In'+inNumber;
                                                end
                                                if(~isKey(added_blks,name2)&&...
                                                    isKey(inputBlkName,name2)&&is_multiple_dest)
                                                    inportBlks=find_system(libname,'SearchDepth',1,'BlockType','Inport');
                                                    inNumber=length(inportBlks)+1;
                                                    add_block('simulink/Ports & Subsystems/In1',libname+"/"+'In'+inNumber);
                                                    inputBlkName(name2)=get_param(libname+"/"+'In'+inNumber,'Name');
                                                    name2=get_param(libname+"/"+'In'+inNumber,'Name');
                                                    added_blks(name2)=1;
                                                end
                                                if strcmp(allPorts(dst_port).Type,'enable')
                                                    enablePortsInSystem=find_system(clonesListByGroup(i).Region(idx).Candidates{j},'BlockType','EnablePort');
                                                    enablePortName=char(get_param(enablePortsInSystem,'Name'));
                                                    if isempty(enablePortName)
                                                        enablePortName='enable';
                                                    end
                                                    try
                                                        add_line(libname,name2+"/"+src_port,[name1,'/',enablePortName],'autorouting','on');
                                                    catch
                                                        warning("Can not connect the blocks in the library");
                                                    end
                                                elseif strcmp(allPorts(dst_port).Type,'ifaction')||strcmp(allPorts(dst_port).Type,'trigger')
                                                    pos=get_param(portDst1.Outport(src_port),'Position');
                                                    try
                                                        add_line(libname,[pos;allPorts(dst_port).Position]);
                                                    catch
                                                        warning("Can not connect the blocks in the library");
                                                    end
                                                else
                                                    try
                                                        add_line(libname,name2+"/"+src_port,name1+"/"+dst_port,'autorouting','on');
                                                    catch
                                                        warning("Can not connect the blocks in the library");
                                                    end

                                                end
                                                port_src(name2+"/"+src_port)=1;
                                                port_dst(name1+"/"+dst_port)=1;
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        for n=1:length(allPorts(k).DstBlock)
                            if(allPorts(k).DstBlock(n)==-1)
                                continue;
                            end
                            dstBlkName=getfullname(allPorts(k).DstBlock(n));
                            if~isempty(dstBlkName)
                                name2=get_param(dstBlkName,'Name');
                                allPorts1=get_param(dstBlkName,'PortConnectivity');
                                imdstBlkName=dstBlkName;
                                for l=1:length(allPorts1)
                                    for m=1:length(allPorts1(l).SrcBlock)
                                        if(strcmp(getfullname(allPorts1(l).SrcBlock(m)),clonesListByGroup(i).Region(idx).Candidates{j})&&...
                                            (allPorts1(l).SrcPort(m)+1==str2num(allPorts(k).Type)))
                                            if strcmp(get_param(imdstBlkName,'BlockType'),'Outport')
                                                dst_port=1;
                                            else
                                                dst_port=allPorts1(l).SrcPort(m)+1;
                                            end
                                            src_port=allPorts(k).DstPort(n)+1;
                                            isconnected=(~isKey(port_src,name1+"/"+dst_port)||(isKey(port_src,name1+"/"+dst_port)&&(length(allPorts(k).DstBlock)>1)))&&...
                                            ~isKey(port_dst,name2+"/"+src_port);
                                            if(isconnected&&...
                                                (isKey(added_blks,name1)||...
                                                strcmp(get_param(dstBlkName,'BlockType'),'Outport')))

                                                if(strcmp(get_param(dstBlkName,'BlockType'),'Outport')||...
                                                    ~isKey(added_blks,name2))
                                                    outportBlks=find_system(libname,'SearchDepth',1,'BlockType','Outport');
                                                    outNumber=length(outportBlks)+1;
                                                    src_port=1;
                                                    add_block('simulink/Ports & Subsystems/Out1',libname+"/"+'Out'+outNumber);
                                                    name2=get_param(libname+"/"+'Out'+outNumber,'Name');
                                                    added_blks(name2)=1;
                                                    imdstBlkName=libname+"/"+'Out'+outNumber;
                                                end
                                                if~strcmp(allPorts1(src_port).Type,'ifaction')&&...
                                                    ~strcmp(allPorts1(src_port).Type,'enable')&&...
                                                    ~strcmp(allPorts1(src_port).Type,'trigger')
                                                    try
                                                        add_line(libname,name1+"/"+dst_port,name2+"/"+src_port);
                                                    catch
                                                        warning("Can not connect the blocks in the library");
                                                    end
                                                else
                                                    pos=get_param(portDst.Outport(dst_port),'Position');
                                                    try
                                                        add_line(libname,[pos;allPorts1(src_port).Position]);
                                                    catch
                                                        warning("Can not connect the blocks in the library");
                                                    end
                                                end
                                                port_src(name1+"/"+dst_port)=1;
                                                port_dst(name2+"/"+src_port)=1;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                Simulink.BlockDiagram.createSubsystem(bh,'Name',"region"+existingSubsystemNo);
                blocksInLib=find_system(libname,'SearchDepth',1);
                for len=2:length(blocksInLib)
                    if(strcmp(get_param(blocksInLib{len},'BlockType'),'Inport')||...
                        strcmp(get_param(blocksInLib{len},'BlockType'),'Outport'))
                        delete_block(blocksInLib{len});
                    end
                end


                delete_line(find_system(libname,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all','IncludeCommented','on','findall','on','Type','Line','Connected','off'));
                warningState=warning('query','diagram_autolayout:autolayout:layoutRejectedCommandLine');
                warning('off','diagram_autolayout:autolayout:layoutRejectedCommandLine');
                cleanup=onCleanup(@()warning(warningState.state,'diagram_autolayout:autolayout:layoutRejectedCommandLine'));

                save_system(libname,[],'SaveDirtyReferencedModels',true);
                close_system(libname,1,'SaveDirtyReferencedModels','on');
                load_system(libname);
                set_param(libname,'Lock','off');
                refblocks=libname+"/"+"region"+existingSubsystemNo;
                needmasking=false;
                if~isempty(this.cloneresult.dissimiliarty{i})
                    needmasking=true;
                    try
                        [maskableFlag,errmessage]=slEnginePir.CloneRefactor.addMaskToLibraryForClonesAnywhere(this,i,refblocks,clonesListByGroup(i),clonesListByGroup(i).Region(idx).Candidates);
                    catch ME
                        disp(ME.message);
                        maskableFlag=false;
                        errmessage='';
                    end
                    if~maskableFlag
                        messageCatalog=DAStudio.message('sl_pir_cpp:creator:ExclusionReasonCloneLinkedToLibrary','###','###');
                        if contains(errmessage,extractBetween(messageCatalog,'###','###'))
                            for region_count=1:length(clonesListByGroup(i).Region)
                                parent=get_param(clonesListByGroup(i).Region(region_count).Candidates{1},'Parent');
                                this.excluded_sysclone(parent)=errmessage;
                            end
                            continue;
                        end

                        for region_count=1:length(clonesListByGroup(i).Region)
                            for j=1:length(clonesListByGroup(i).Region(region_count).Candidates)
                                this.excluded_sysclone(clonesListByGroup(i).Region(region_count).Candidates{j})=errmessage;
                            end
                        end
                        continue;
                    end
                end

                parameterNames=[];
                if needmasking
                    [parameterNames,~]=slEnginePir.CloneRefactor.getstructParameterNameValueForClonesAnywhere(this,clonesListByGroup(i).Region(idx).Candidates,i,idx,RegNo,idx);
                end
                for region_size=1:length(clonesListByGroup(i).Region)
                    found=0;
                    for candidate_count=1:length(clonesListByGroup(i).Region(region_size).Candidates)
                        if isKey(this.excluded_sysclone,clonesListByGroup(i).Region(region_size).Candidates{candidate_count})
                            found=1;
                            break;
                        end
                    end
                    if found
                        continue;
                    end
                    len=length(clonesListByGroup(i).Region(region_size).Candidates{1});
                    fname=clonesListByGroup(i).Region(region_size).Candidates{1};
                    if~strcmp(get_param(fname,'Type'),'block_diagram')&&...
                        (strcmp(get_param(fname,'LinkStatus'),'resolved'))
                        this.excluded_sysclone(fname)=...
                        DAStudio.message('sl_pir_cpp:creator:ExclusionReasonCloneLinkedToLibrary',fname,get_param(fname,'ReferenceBlock'));
                        continue;
                    end
                    for k=len:-1:1
                        if strcmp(fname(k),'/')
                            break;
                        end
                    end
                    fname=fname(1:k);
                    if~strcmp(get_param(fname,'Type'),'block_diagram')&&...
                        (strcmp(get_param(fname,'LinkStatus'),'resolved')||strcmp(get_param(fname,'LinkStatus'),'implicit'))&&...
                        isempty(get_param(fname,'linkdata'))
                        this.excluded_sysclone(fname)=...
                        DAStudio.message('sl_pir_cpp:creator:ExclusionReasonCloneLinkedToLibrary',fname,get_param(fname,'ReferenceBlock'));
                        continue;
                    end

                    if~strcmp(get_param(fname,'Type'),'block_diagram')&&...
                        ~isempty(get_param(fname,'ReferencedSubsystem'))
                        this.excluded_sysclone(fname)=...
                        DAStudio.message('sl_pir_cpp:creator:ExclusionReasonCloneLinkedToSubsystemRef',fname,get_param(fname,'ReferenceBlock'));
                        continue;
                    end
                    [l,t,r,b]=slEnginePir.CloneRefactor.getLibraryPosition(this,clonesListByGroup(i).Region(region_size).Candidates);
                    pname=get_param(clonesListByGroup(i).Region(region_size).Candidates{1},'Parent');
                    newLibBlockName=[pname,'/','region',num2str(RegNo)];
                    newlibBlkhandle=add_block(refblocks,newLibBlockName,'MakeNameUnique','on','Position',[l,t,r,b]);
                    if needmasking
                        [~,parameterValue]=slEnginePir.CloneRefactor.getstructParameterNameValueForClonesAnywhere(this,clonesListByGroup(i).Region(region_size).Candidates,i,region_size,RegNo,idx);
                        for j=1:length(parameterNames)
                            try
                                if(strcmp(parameterNames{j},parameterValue{j})~=1)
                                    set_param(newLibBlockName,parameterNames{j},parameterValue{j});
                                end
                            catch
                                this.excluded_sysclone("Clone Region"+region_size)=[parameterNames{j},' cannot set the value as it is promoted.'];
                                for k=1:length(clonesListByGroup(i).Region(region_size).Candidates)
                                    blockname=[this.genmodelprefix,clonesListByGroup(i).Region(region_size).Candidates{k}];
                                    pos=get_param(clonesListByGroup(i).Region(region_size).Candidates{k},'Position');
                                    ori=get_param(clonesListByGroup(i).Region(region_size).Candidates{k},'Orientation');
                                    namepl=get_param(clonesListByGroup(i).Region(region_size).Candidates{k},'NamePlacement');
                                    add_block(blockname,clonesListByGroup(i).Region(region_size).Candidates{k},'Position',pos,'Orientation',ori,'NamePlacement',namepl);
                                end
                                delete_block(newLibBlockName);
                            end
                        end
                    end
                    slEnginePir.CloneRefactor.buildConnectivity(this,newlibBlkhandle,refblocks,libblks,clonesListByGroup(i).Region(region_size).Candidates);
                    appendingIndex=...
                    slEnginePir.util.getAppendIndexForStructArray(cloneReplaceResults.ReplacedClones);
                    cloneReplaceResults.ReplacedClones(appendingIndex).Name=getfullname(newlibBlkhandle);
                    cloneReplaceResults.ReplacedClones(appendingIndex).ReferenceSubsystem=refblocks;
                    RegNo=RegNo+1;
                    slEnginePir.CloneRefactor.saveAllModelsAndLibrary(this,libname,true);
                end
            end
        end


        function idx=chooseLib(this,cloneGroup)
            idx=1;
            for i=1:length(cloneGroup.Region)
                for j=1:length(cloneGroup.Region(i).Candidates)
                    for k=1:length(this.creator.differentBlockParamName)
                        if slEnginePir.isParent(cloneGroup.Region(i).Candidates{j},this.creator.differentBlockParamName(k).Block)||...
                            strcmp(cloneGroup.Region(i).Candidates{j},this.creator.differentBlockParamName(k).Block)
                            idx=i;
                            break;
                        end
                    end
                    if idx~=0
                        break;
                    end
                end
                if idx~=0
                    break;
                end
            end
        end

        function handleIgnoredListForRefactoring(this)
            excluded_regions=keys(this.excluded_sysclone);
            for k=1:length(excluded_regions)
                if isKey(this.region2BlockList,excluded_regions{k})
                    reg=this.region2BlockList(excluded_regions{k});
                    remove(this.excluded_sysclone,excluded_regions{k});
                    for l=1:length(reg)
                        this.excluded_sysclone(reg{l})='Added to ignored list';
                    end
                else
                    this.excluded_sysclone(excluded_regions{k})='Added to ignored list';
                end
            end
        end


        function[maskableFlag,errmessage]=addMaskToLibraryForClonesAnywhere(this,i,refblocks,cloneGroup,blks)
            uniqueDiffBlock=containers.Map('KeyType','char','ValueType','double');
            uniqueLibBlock=containers.Map('KeyType','char','ValueType','double');
            uniqueMaskName=containers.Map('KeyType','char','ValueType','double');
            maskobj=Simulink.Mask.get(refblocks);
            maskableFlag=true;
            errmessage='';
            if isempty(maskobj)
                maskobj=Simulink.Mask.create(refblocks);
            end
            t_ind=0;
            ind=this.cloneresult.dissimiliarty{i};
            for u=1:length(ind)
                curdiffbp=this.creator.differentBlockParamName(ind(u));
                needtable=true;


                obj=get_param([this.genmodelprefix,curdiffbp.Block],'DialogParameters');


                t_ind=t_ind+1;
                for j=1:length(curdiffbp.ParameterNames)

                    if~isfield(obj,curdiffbp.ParameterNames{j})
                        continue;
                    end

                    libblock=slEnginePir.CloneRefactor.getLibraryBlockForClonesAnywhere(this,curdiffbp,...
                    blks,uniqueDiffBlock,j);
                    v=get_param(libblock,curdiffbp.ParameterNames{j});
                    sid_val=strrep(Simulink.ID.getSID([this.genmodelprefix,curdiffbp.Block]),':','_');
                    sub_sid=sid_val(length(this.genmodelprefix)+1:length(sid_val));
                    maskparametername=strcat(curdiffbp.ParameterNames{j},'_',sub_sid);

                    if length(maskparametername)>namelengthmax
                        maskparametername=maskparametername(1:namelengthmax-1);
                    end
                    blockfullname=char(slEnginePir.CloneRefactor.getblockfullnameForClonesAnywhere(this,refblocks,curdiffbp,...
                    blks,uniqueLibBlock,j));

                    cond=isempty(nonzeros(strcmp('dont-eval',obj.(curdiffbp.ParameterNames{j}).Attributes)))&&...
                    ~strcmp(obj.(curdiffbp.ParameterNames{j}).Type,'boolean')&&...
                    ~(strcmp(obj.(curdiffbp.ParameterNames{j}).Type,'enum'));

                    cond2=isempty(nonzeros(strcmp('not-link-instance',obj.(curdiffbp.ParameterNames{j}).Attributes)));

                    if~cond2&&~cond
                        blktype=get_param(curdiffbp.Block,'BlockType');
                        errmessage=DAStudio.message('sl_pir_cpp:creator:MaskParameterNotPromoted',curdiffbp.ParameterNames{j},blktype);
                        maskableFlag=false;
                        return;
                    end



                    if~Simulink.Mask.isPromotable(curdiffbp.Block,curdiffbp.ParameterNames{j})
                        maskableFlag=false;
                        blktype=get_param(curdiffbp.Block,'BlockType');
                        errmessage=DAStudio.message('sl_pir_cpp:creator:MaskParameterNotPromoted',curdiffbp.ParameterNames{j},blktype);
                        return;
                    end


                    if slEnginePir.CloneRefactor.cannotEvluateParam(this,curdiffbp.Block,curdiffbp.ParameterNames{j})
                        maskableFlag=false;
                        blktype=get_param(curdiffbp.Block,'BlockType');
                        errmessage=DAStudio.message('sl_pir_cpp:creator:MaskParameterNotPromoted',curdiffbp.ParameterNames{j},blktype);
                        return;
                    end

                    if needtable
                        tablename=['table',num2str(t_ind)];
                        try
                            maskobj.addDialogControl('Type','table','Prompt',blockfullname(strlength(refblocks)+2:end),'Name',tablename);
                        catch ME
                            disp(ME.message);
                        end
                    end
                    needtable=false;
                    if cond&&...
                        ~strcmp(curdiffbp.ParameterNames{j},'OutDataTypeStr')&&~strcmp(curdiffbp.ParameterNames{j},'ParamDataTypeStr')
                        parent=get_param(libblock,'Parent');
                        if(~strcmp(get_param(parent,'Type'),'block_diagram')&&...
                            (strcmp(get_param(parent,'LinkStatus'),'implicit')||...
                            strcmp(get_param(parent,'LinkStatus'),'resolved')))
                            maskableFlag=false;
                            errmessage=DAStudio.message('sl_pir_cpp:creator:ExclusionReasonCloneLinkedToLibrary',parent,get_param(parent,'ReferenceBlock'));
                            return;
                        end
                        maskobj1=Simulink.Mask.get(parent);
                        bp=get_param(libblock,curdiffbp.ParameterNames{j});
                        if~isempty(maskobj1)
                            for k=1:length(maskobj1.Parameters)
                                if strcmp(maskobj1.Parameters(k).Name,bp)
                                    maskparametername=maskobj1.Parameters(k).Name;
                                end
                            end
                        end
                        if isKey(uniqueMaskName,maskparametername)
                            maskparametername=maskparametername+uniqueMaskName(maskparametername);
                            uniqueMaskName(maskparametername)=uniqueMaskName(maskparametername)+1;
                        else
                            uniqueMaskName(maskparametername)=1;
                        end
                        maskobj.addParameter('Name',maskparametername,'Prompt',curdiffbp.ParameterNames{j},'Value',v,'Container',['table',num2str(t_ind)]);
                        if~strcmp(get_param(blockfullname,curdiffbp.ParameterNames{j}),maskparametername)

                            try
                                set_param(blockfullname,curdiffbp.ParameterNames{j},maskparametername);
                            catch ME

                                disp(ME.message);
                            end
                        end
                    else
                        if isKey(uniqueMaskName,maskparametername)
                            maskparametername=[maskparametername,int2str(uniqueMaskName(maskparametername))];
                            uniqueMaskName(maskparametername)=uniqueMaskName(maskparametername)+1;
                        else
                            uniqueMaskName(maskparametername)=1;
                        end
                        typeopetions=[blockfullname(strlength(refblocks)+2:end),'/',curdiffbp.ParameterNames{j}];
                        pos=strfind(libblock,'/');
                        for len1=length(pos):-1:1
                            libblock=libblock(1:pos(len1)-1);
                            superMask=Simulink.Mask.get(libblock);
                            if~isempty(superMask)
                                warning(message('sl_pir_cpp:creator:ParameterFromMaskedSubsystem',this.mdlName));
                                maskableFlag=false;
                                return;
                            end
                        end
                        try
                            maskobj.addParameter('Type','promote','TypeOptions',{typeopetions},'Name',maskparametername,'Prompt',curdiffbp.ParameterNames{j},'Container',['table',num2str(t_ind)]);
                        catch ME
                            disp(ME.message);
                            maskobj.addParameter('Type','promote','TypeOptions',{typeopetions},'Name',maskparametername,'Prompt',curdiffbp.ParameterNames{j});
                        end
                    end
                end
            end
        end


        function[replacedClones,loadedModels]=replaceClonesWithLibrary(this,libname)
            if strcmp(get_param(this.mdlName,'BlockDiagramType'),'library')
                set_param(this.mdlName,'Lock','off');
            end

            loadedModels={};

            replacedClones=struct([]);

            clonesListByGroup=this.cloneresult.Before;

            this.cloneresult.lib=cell(size(clonesListByGroup));






            refLibraryBlockForGroups=cell(1,length(clonesListByGroup));
            existClonesToRefactorForGroupsFlag=zeros(1,length(clonesListByGroup));
            saveLinkedLibrary=false;
            visitedBlocks=containers.Map('KeyType','char','ValueType','double');
            replaceWithOriginal=containers.Map('KeyType','char','ValueType','any');
            maskedBlockParams=containers.Map('KeyType','char','ValueType','any');
            innerSubsysMask=containers.Map('KeyType','char','ValueType','any');
            needToLoadTargetLibrary=false;
            for cloneGroupIndex=length(clonesListByGroup):-1:1
                [refLibraryBlock,existClonesToRefactorInCloneGroupFlag]=...
                slEnginePir.CloneRefactor.existClonesToRefactorInCloneGroup(this,...
                clonesListByGroup{cloneGroupIndex},cloneGroupIndex);
                existClonesToRefactorForGroupsFlag(cloneGroupIndex)=existClonesToRefactorInCloneGroupFlag;
                refLibraryBlockForGroups{cloneGroupIndex}=refLibraryBlock;
                needToLoadTargetLibrary=needToLoadTargetLibrary||existClonesToRefactorInCloneGroupFlag;
            end
            if(needToLoadTargetLibrary)
                [~,isExplicitlyLoaded]=slEnginePir.CloneRefactor.loadLibraryFile(this,libname);
                if isExplicitlyLoaded
                    loadedModels=[loadedModels;{libname}];
                end
                set_param(this.mdlName,'SaveWithParameterizedLinksMsg','none');
                posx=0;
                deltay=30;
                posy=slEnginePir.CloneRefactor.getMaxPosyPosition(this.libname)+deltay;
            end


            libblkno=1;
            for cloneGroupIndex=length(clonesListByGroup):-1:1

                if~existClonesToRefactorForGroupsFlag(cloneGroupIndex)




                    continue;
                end




                if isempty(refLibraryBlockForGroups{cloneGroupIndex})||...
                    ~isempty(this.cloneresult.dissimiliarty{cloneGroupIndex})




                    [posx,posy,libblkno,refLibraryBlockForGroups{cloneGroupIndex}]=...
                    slEnginePir.CloneRefactor.getNewReferenceblocks(this,posx,posy,libblkno,...
                    clonesListByGroup{cloneGroupIndex},this.libname,cloneGroupIndex);
                    saveLinkedLibrary=true;
                end


                if saveLinkedLibrary
                    save_system(libname,this.inputLibName,'SaveDirtyReferencedModels','on');
                end

                refLibraryBlock=refLibraryBlockForGroups{cloneGroupIndex};
                updateBlock=true;

                nonemptyBlocks=[];
                for j=1:numel(this.creator.differentBlockParamName)
                    if~isempty(this.creator.differentBlockParamName(j).ParameterNames)
                        nonemptyBlocks=[nonemptyBlocks,j];%#ok<AGROW>
                    end
                end

                if~isempty(intersect(this.cloneresult.dissimiliarty{cloneGroupIndex},nonemptyBlocks))
                    try
                        [maskableFlag,errmessage,updateBlock,return_val,innerSubsysMask]=...
                        slEnginePir.CloneRefactor.addMasktoLibBlock(this,refLibraryBlock,...
                        clonesListByGroup{cloneGroupIndex},this.cloneresult.lib{cloneGroupIndex},...
                        cloneGroupIndex,visitedBlocks,maskedBlockParams,replaceWithOriginal,updateBlock,innerSubsysMask);
                    catch ME
                        disp(ME.message);
                        maskableFlag=false;
                        errmessage='';
                    end
                    if~maskableFlag
                        for j=1:length(clonesListByGroup{cloneGroupIndex})
                            if isempty(errmessage)
                                this.excluded_sysclone(clonesListByGroup{cloneGroupIndex}{j})=' cannot promote parameters across mask hierarchy, exclude for replacement.';
                            else
                                this.excluded_sysclone(clonesListByGroup{cloneGroupIndex}{j})=[errmessage,', exclude for replacement.'];
                            end
                            if slfeature('NestedCloneRefactoring')~=0
                                key=keys(replaceWithOriginal);
                                for k=1:length(key)
                                    if(slEnginePir.isParent(clonesListByGroup{cloneGroupIndex}{j},char(key(k))))
                                        [parameterNames,parameterValue]=slEnginePir.CloneRefactor.getstructParameterNameValue(this,char(key(k)),replaceWithOriginal(char(key(k))),replaceWithOriginal);
                                        for l=1:length(parameterNames)
                                            if(~strcmp(get_param(char(key(k)),parameterNames{l}),parameterValue{l}))
                                                try
                                                    set_param(char(key(k)),parameterNames{l},parameterValue{l});
                                                catch
                                                    this.excluded_sysclone(char(key(k)))=[parameterNames{l},' cannot set the value as it is promoted.'];
                                                    delete_block(char(key(k)));
                                                    break;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        continue;
                    end
                else
                    return_val=[];
                end

                if(updateBlock)
                    [replacedClonesOfOneGroup,innerSubsysMask]=...
                    slEnginePir.CloneRefactor.updateBlockwithRefernceBlock(this,...
                    clonesListByGroup{cloneGroupIndex},refLibraryBlock,cloneGroupIndex,clonesListByGroup,existClonesToRefactorForGroupsFlag,...
                    replaceWithOriginal,return_val,innerSubsysMask);
                    replacedClones=slEnginePir.util.appendToStructArray(...
                    replacedClones,replacedClonesOfOneGroup);

                    for j=1:numel(this.creator.differentBlockParamName)
                        for k=1:length(replacedClones)
                            if slEnginePir.isParent(replacedClones(k).Name,this.creator.differentBlockParamName(j).Block)
                                visitedBlocks(this.creator.differentBlockParamName(j).Block)=1;
                            end
                            for l=1:length(this.creator.differentBlockParamName(j).MappedBlocks)
                                if slEnginePir.isParent(replacedClones(k).Name,this.creator.differentBlockParamName(j).MappedBlocks{l})
                                    visitedBlocks(this.creator.differentBlockParamName(j).MappedBlocks{l})=1;
                                end
                            end
                        end
                        result1=clonesListByGroup{cloneGroupIndex};
                        for k=1:length(result1)
                            key=keys(replaceWithOriginal);
                            for l=1:length(key)
                                if slEnginePir.isParent(result1{k},char(key(l)))&&~strcmp(result1{k},char(key(l)))
                                    remove(replaceWithOriginal,char(key(l)));
                                end
                            end
                        end
                    end
                end
            end
            ui=get_param(this.mdlName,'CloneDetectionUIObj');
            if~isempty(ui)
                ui.overWriteBlockPathCategoryMap(this.cloneresult,this.exclusionList);
            end

            slEnginePir.CloneRefactor.saveAllModelsAndLibrary(this,libname,saveLinkedLibrary);
            [~]=slEnginePir.CloneRefactor.removeExcluded_sysclone(this,clonesListByGroup);
        end

        function[result,loadedModels]=replaceExactClonesWithSubsystemreferences(this)
            result.ReplacedClones=struct([]);
            result.CloneGroups=this.cloneresult.Before;
            loadedModels={};

            if isfield(this.cloneresult,'exact')
                exactCloneGroups=this.cloneresult.exact;
            else
                exactCloneGroups=slEnginePir.CloneRefactor.construct_result_exact(this);
            end
            this.cloneresult.SSRef=cell(size(result.CloneGroups));
            for exactCloneGroupIndex=length(exactCloneGroups):-1:1
                idx=exactCloneGroups{exactCloneGroupIndex}.index;
                singleExactCloneGroup=this.cloneresult.Before{idx};
                [refLibraryBlock,existClonesToRefactorInCloneGroupFlag,this]=...
                slEnginePir.CloneRefactor.existClonesToRefactorInCloneGroup(this,...
                singleExactCloneGroup,exactCloneGroupIndex);
                if~existClonesToRefactorInCloneGroupFlag
                    continue;
                end
                if~isempty(refLibraryBlock)
                    continue;
                end
                subsysref_name=slEnginePir.util.SubsystemRef.checkReferencedSubsystem(singleExactCloneGroup);
                if isempty(subsysref_name)
                    subsysref_name=exactCloneGroups{exactCloneGroupIndex}.targetLib;
                    subsysref_name=matlab.lang.makeValidName(subsysref_name);
                    subsystem_file_created=false;
                else
                    subsystem_file_created=true;
                end
                this.cloneresult.SSRef{idx}=subsysref_name;
                for cloneIndex=1:length(singleExactCloneGroup)
                    if(strcmp(subsysref_name,""))
                        break;
                    end
                    fname=singleExactCloneGroup{cloneIndex};
                    if isKey(this.excluded_sysclone,fname)
                        continue;
                    end
                    if~subsystem_file_created
                        temp=1;
                        while isfile(subsysref_name+".slx")
                            subsysref_name=subsysref_name+"_"+string(temp);
                            temp=temp+1;
                        end
                        this.cloneresult.SSRef{idx}=subsysref_name;
                        if~(strcmp(get_param(fname,'type'),'block_diagram'))
                            subsystem_file_created=SubsystemReferenceConverter.createSubsystemReference(fname,subsysref_name,false);
                        else
                            subsystem_file_created=slEnginePir.CloneRefactor.create_SubsystemFile_From_Model(fname,subsysref_name);
                        end
                    end
                    if subsystem_file_created
                        if~(strcmp(get_param(fname,'type'),'block_diagram'))



                            if~isempty(get_param(fname,'VariantControl'))&&...
                                ~slEnginePir.CloneRefactor.hasSameInOutPortName(this,fname,subsysref_name)
                                this.excluded_sysclone(fname)=...
                                'Inside variant subsystem and has different in/out port name.';
                                continue;
                            end
                            set_param(fname,'ReferencedSubsystem',subsysref_name);

                            appendingIndex=...
                            slEnginePir.util.getAppendIndexForStructArray(result.ReplacedClones);
                            result.ReplacedClones(appendingIndex).Name=fname;
                            result.ReplacedClones(appendingIndex).ReferenceSubsystem=subsysref_name;
                        else
                            replacedCloneForModelReference=...
                            slEnginePir.CloneRefactor.update_RefModel_With_SubsystemReference(...
                            fname,subsysref_name);
                            result.ReplacedClones=slEnginePir.util.appendToStructArray(...
                            result.ReplacedClones,replacedCloneForModelReference);
                        end

                    end
                end
            end
            result.CloneGroups=...
            slEnginePir.CloneRefactor.removeExcluded_sysclone(this,result.CloneGroups);
            for cloneIndex=length(this.refModels):-1:1
                mdlname=this.refModels{cloneIndex};
                if bdIsLoaded(mdlname)&&strcmp(get_param(mdlname,'Dirty'),'on')
                    save_system(mdlname,[],'SaveDirtyReferencedModels',true);
                end
            end
            save_system(this.mdlName,[],'SaveDirtyReferencedModels',true);
        end

        function subsysref_name=get_subsysref_name(this,listOfClonesInAGroup,cloneGroupIndex)
            [~,existClonesToRefactorInCloneGroupFlag,this]=...
            slEnginePir.CloneRefactor.existClonesToRefactorInCloneGroup(this,...
            listOfClonesInAGroup,cloneGroupIndex);
            if~existClonesToRefactorInCloneGroupFlag
                subsysref_name="N/A";
                return;
            end
            subsysref_name=slEnginePir.util.SubsystemRef.checkReferencedSubsystem(listOfClonesInAGroup);
            if~isempty(subsysref_name)
                return;
            end
            for i=1:length(listOfClonesInAGroup)
                fnameblk=listOfClonesInAGroup{i};
                if isKey(this.excluded_sysclone,fnameblk)
                    continue;
                end
                subsysref_name=strrep(get_param(fnameblk,'Name'),'/','//');
                break;
            end
            temp=1;
            while isfile(subsysref_name+".slx")
                subsysref_name=subsysref_name+"_"+string(temp);
                temp=temp+1;
            end

        end

        function exactCloneGroups=construct_result_exact(this)
            exactCloneGroups=[];
            excloneIndx=1;
            result=this.cloneresult.Before;
            for ii=1:length(result)
                i=this.cloneresult.newIndx(ii);
                if isempty(this.cloneresult.dissimiliarty{i})
                    exactCloneGroups{excloneIndx}.index=i;
                    exactCloneGroups{excloneIndx}.targetLib=slEnginePir.CloneRefactor.get_subsysref_name(this,result{i},i);
                    excloneIndx=excloneIndx+1;
                end
            end
        end

        function subsystem_file_created=create_SubsystemFile_From_Model(fname,subsysref_name)
            blocks=find_system(fname,'SearchDepth',1);
            bh=[];
            for i=2:length(blocks)
                bh=[bh,get_param(blocks{i},'handle')];
            end
            Simulink.BlockDiagram.createSubsystem(bh);


            subsystem=find_system(fname,'SearchDepth',1,'type','block','blocktype','SubSystem');
            subsystem=subsystem{1};
            subsystem_file_created=SubsystemReferenceConverter.createSubsystemReference(subsystem,char(subsysref_name),false);
            Simulink.BlockDiagram.expandSubsystem(subsystem,'CreateArea','Off')
        end


        function replacedClones=update_RefModel_With_SubsystemReference(fname,subsysref_name)
            replacedClones=struct([]);

            blocks=find_system(fname,'SearchDepth',1);
            bh=[];
            for i=2:length(blocks)
                bh=[bh,get_param(blocks{i},'handle')];
            end
            Simulink.BlockDiagram.createSubsystem(bh);

            subsystem=find_system(fname,'SearchDepth',1,'type','block','blocktype','SubSystem');
            subsystem=subsystem{1};
            set_param(subsystem,'ReferencedSubsystem',subsysref_name);
            set_param(subsystem,'Name',subsysref_name);

            appendingIndex=...
            slEnginePir.util.getAppendIndexForStructArray(replacedClones);
            replacedClones(appendingIndex).Name=fname;
            replacedClones(appendingIndex).ReferenceSubsystem=subsysref_name;
        end


        function checkWritableforSystem(~,mdlname)

            [status,values]=fileattrib(which(mdlname));
            val=status&&values.UserWrite;
            if~val
                DAStudio.error('sl_pir_cpp:creator:FileisNotWritable',mdlname);
            end
        end



        function parameterValue=updateMaskValuetoRealValue(~,parameterValue,pv)

            for i=1:length(parameterValue)
                paramv=parameterValue{i};

                len=length(pv);
                for j=1:len
                    paramv=strrep(paramv,pv{j},pv{j+len});
                end
                parameterValue{i}=paramv;
            end
        end


        function[isCloneReplaced,innerSubsysMask]=updateStructBlock(this,oriMdlName,fname,...
            refblocks,clonegroupID,result,allneedmap,replaceWithOriginal,~,return_val,innerSubsysMask)

            isCloneReplaced=true;
            pos=get_param(fname,'Position');
            ori=get_param(fname,'Orientation');
            namepl=get_param(fname,'NamePlacement');


            pv=slEnginePir.getMaskDlgParams(fname);


            typeopeCheck=[];
            if slfeature('NestedCloneRefactoring')~=0
                for i=length(result):-1:1
                    resultI=result{i};
                    for j=1:length(resultI)
                        if slEnginePir.isParent(resultI{j},fname)&&~isKey(this.excluded_sysclone,resultI{j})
                            if(allneedmap(i))
                                replaceWithOriginal(fname)=clonegroupID;
                            end
                            typeopeCheck=resultI{j};
                            break;
                        end
                    end
                end
                for j=1:length(this.cloneGrpsOfExclusionList)
                    if~isempty(char(this.cloneGrpsOfExclusionList{j}))&&...
                        slEnginePir.isParent(char(this.cloneGrpsOfExclusionList{j}),fname)
                        typeopeCheck=char(this.cloneGrpsOfExclusionList{j});
                        break;
                    end
                end
                for j=1:length(this.exclusionList)
                    if slEnginePir.isParent(this.exclusionList{j},fname)
                        typeopeCheck=this.exclusionList{j};
                        break;
                    end
                end


                [parameterNames,parameterValue]=slEnginePir.CloneRefactor.getstructParameterNameValue(this,oriMdlName,clonegroupID,replaceWithOriginal,return_val);

                if(isKey(replaceWithOriginal,fname))
                    parameterValue=parameterNames;
                end



                list_of_block_in_subsystem=find_system(fname,...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,...
                'BlockType','SubSystem');

            end
            maskobj1=Simulink.Mask.get(fname);
            mask_param_length=0;
            if~isempty(maskobj1)
                mask_param_length=length(maskobj1.Parameters);
            end

            if hasmask(fname)
                parameterValue=slEnginePir.CloneRefactor.updateMaskValuetoRealValue(this,parameterValue,pv);
            end





            delete_block(fname);


            save_system(this.inputLibName,[],'SaveDirtyReferencedModels','on');

            set_param(this.libname,'Lock','off');




            newblk=add_block(refblocks,[fname,num2str(rand)],'Position',[0,0,0,0]);

            slEnginePir.setMaskParams(newblk,pv);





            obj=Simulink.Mask.get(newblk);
            mask_param_length1=0;
            if~isempty(obj)
                mask_param_length1=length(obj.Parameters);
            end
            if(mask_param_length1==length(parameterNames))
                index=0;
                len_ParameterNames=length(parameterNames);
            else
                index=mask_param_length;
                if(mask_param_length==0)
                    len_ParameterNames=length(parameterNames);
                else
                    len_ParameterNames=mask_param_length1-mask_param_length;
                end
            end
            innerSubsysMask(fname)=[];
            for i=1:len_ParameterNames



                if(~strcmp(obj.Parameters(index+i).Type,'promote')||((strcmp(obj.Parameters(index+i).Type,'promote'))&&...
                    ~strcmp(parameterNames{i},parameterValue{i})))
                    try
                        set_param(newblk,parameterNames{i},parameterValue{i});
                    catch



                        this.excluded_sysclone(fname)=[parameterNames{i},' cannot set the value as it is promoted.'];


                        blockname=slEnginePir.util.getValidBlockPath(this.genmodelprefix,fname);
                        add_block(blockname,fname,'Position',pos,'Orientation',ori,'NamePlacement',namepl);
                        set_param(fname,'VariantControl',get_param(blockname,'VariantControl'));
                        delete_block(newblk);
                        isCloneReplaced=false;
                        return;
                    end
                end
            end
            add_block(newblk,fname,'Position',pos,'Orientation',ori,'NamePlacement',namepl);





            set_param(fname,'VariantControl',get_param(newblk,'VariantControl'));

            if slfeature('NestedCloneRefactoring')~=0
                diffbp=this.creator.differentBlockParamName;
                diffbp1=this.diffParam;
                uniqueDiffBlock=containers.Map('KeyType','char','ValueType','double');
                maskobj=[];
                if~isempty(typeopeCheck)
                    maskobj=Simulink.Mask.get(typeopeCheck);
                end
                innerSubsysMask(fname)=parameterNames;
                maskingIdx=1;
                for i=1:length(return_val)
                    for v=1:length(return_val(i).index)
                        ind=return_val(i).index;
                        blkname=slEnginePir.CloneRefactor.getBlockname(this,diffbp1(ind(v)),fname,uniqueDiffBlock);

                        for j=1:length(diffbp(ind(v)).ParameterNames)










                            typeop=[blkname(length(typeopeCheck)+2:end),'/',diffbp1(ind(v)).ParameterNames{j}];
                            for len=1:length(typeop)
                                if strcmp(typeop(len),'/')
                                    break;
                                end
                            end
                            typeop1=typeop(1:len-1);
                            if~isempty(maskobj)
                                for k=1:length(maskobj.Parameters)
                                    if strcmp(maskobj.Parameters(k).TypeOptions,typeop)
                                        maskobj.Parameters(k).TypeOptions=[typeop1,'/',parameterNames{maskingIdx}];
                                    end
                                end
                            end
                            maskingIdx=maskingIdx+1;
                        end
                    end
                end


                list_of_block_in_subsystem1=find_system(fname,...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,...
                'BlockType','SubSystem');

                for i=length(list_of_block_in_subsystem):-1:2
                    if(~strcmp(list_of_block_in_subsystem{i},list_of_block_in_subsystem1{i}))

                        for j=1:length(diffbp)
                            subStrPos=strfind(diffbp(j).Block,list_of_block_in_subsystem{i});
                            if~isempty(subStrPos)&&...
                                (length(list_of_block_in_subsystem{i})==length(diffbp(j).Block)||...
                                strcmp(diffbp(j).Block(1+length(list_of_block_in_subsystem{i})),'/'))
                                diffbp(j).Block=replace(diffbp(j).Block,list_of_block_in_subsystem{i},list_of_block_in_subsystem1{i});
                            end
                            for k=1:length(diffbp(j).MappedBlocks)
                                MappedBlock=diffbp(j).MappedBlocks{k};
                                subStrPos=strfind(MappedBlock,list_of_block_in_subsystem{i});
                                if~isempty(subStrPos)&&...
                                    (length(list_of_block_in_subsystem{i})==length(MappedBlock)||...
                                    strcmp(MappedBlock(1+length(list_of_block_in_subsystem{i})),'/'))
                                    diffbp(j).MappedBlocks{k}=replace(diffbp(j).MappedBlocks{k},...
                                    list_of_block_in_subsystem{i},list_of_block_in_subsystem1{i});
                                end
                            end
                        end
                        newName=get_param(list_of_block_in_subsystem1{i},'Name');
                        temporaryValidBlockPath=slEnginePir.util.getTemporaryValidBlockPath(this.genmodelprefix,...
                        list_of_block_in_subsystem{i});
                        set_param(temporaryValidBlockPath,'Name',newName);

                        key=keys(replaceWithOriginal);
                        for k=1:length(key)
                            temp=replace(char(key(k)),list_of_block_in_subsystem{i},list_of_block_in_subsystem1{i});
                            val=replaceWithOriginal(char(key(k)));
                            remove(replaceWithOriginal,key(k));
                            replaceWithOriginal(temp)=val;
                        end

                        for m=1:length(this.cloneresult.lib)
                            if(~isempty(this.cloneresult.lib{m}))
                                subStrPos=strfind(this.cloneresult.lib{m},list_of_block_in_subsystem{i});
                                libName=this.cloneresult.lib{m};
                                if~isempty(subStrPos)&&...
                                    (length(list_of_block_in_subsystem{i})==length(libName)||...
                                    strcmp(libName(1+length(list_of_block_in_subsystem{i})),'/'))
                                    this.cloneresult.lib{m}=replace(this.cloneresult.lib{m},list_of_block_in_subsystem{i},list_of_block_in_subsystem1{i});
                                end
                            end
                        end

                        for m=1:length(this.cloneresult.Before)
                            res=this.cloneresult.Before{m};
                            for n=1:length(res)
                                subStrPos=strfind(char(res(n)),list_of_block_in_subsystem{i});
                                resN=char(res(n));
                                if~isempty(subStrPos)&&...
                                    (length(list_of_block_in_subsystem{i})==length(char(res(n)))||...
                                    strcmp(resN(1+length(list_of_block_in_subsystem{i})),'/'))
                                    res(n)={replace(char(res(n)),list_of_block_in_subsystem{i},list_of_block_in_subsystem1{i})};
                                end
                            end
                            this.cloneresult.Before{m}=res;
                        end
                    end
                end
                validModelName=slEnginePir.util.getTemporaryModelName(this.genmodelprefix,this.mdlName);
                if exist([this.m2m_dir,validModelName,'.slx'],'file')==2
                    save_system(validModelName,[],'SaveDirtyReferencedModels','on');
                end
                this.creator.differentBlockParamName=diffbp;

                key=keys(replaceWithOriginal);
                if(isempty(parameterNames))
                    for k=1:length(key)
                        if(slEnginePir.isParent(fname,char(key(k))))
                            [parameterNames1,parameterValue1]=slEnginePir.CloneRefactor.getstructParameterNameValue(this,char(key(k)),replaceWithOriginal(char(key(k))),replaceWithOriginal);
                            for l=1:length(parameterNames1)
                                if(~strcmp(get_param(char(key(k)),parameterNames1{l}),parameterValue1{l}))
                                    try
                                        set_param(char(key(k)),parameterNames1{l},parameterValue1{l});
                                    catch
                                        this.excluded_sysclone(char(key(k)))=[parameterNames1{l},' cannot set the value as it is promoted.'];
                                        isCloneReplaced=false;
                                    end
                                end
                            end
                        end
                    end
                end
            end

            delete_block(newblk);
            isCloneReplaced=true;

        end

        function blockname=getBlockname(~,diffbpI,oriMdlName,uniqueDiffBlock)

            blockname=diffbpI.Block;
            if slEnginePir.isParent(oriMdlName,blockname)&&~isKey(uniqueDiffBlock,blockname)
                uniqueDiffBlock(blockname)=1;
                return;
            end

            for i=1:length(diffbpI.MappedBlocks)
                fname=diffbpI.MappedBlocks{i};
                if slEnginePir.isParent(oriMdlName,fname)&&~isKey(uniqueDiffBlock,fname)
                    uniqueDiffBlock(fname)=1;
                    blockname=fname;
                    return;
                end
            end
        end

        function blockname=getBlocknameForClonesAnywhere(~,diffbpI,oriMdlName,uniqueDiffBlock)
            blockname=diffbpI.Block;
            for idx=1:length(oriMdlName)
                if strcmp(oriMdlName{idx},blockname)||(slEnginePir.isParent(oriMdlName{idx},blockname))...
                    &&~isKey(uniqueDiffBlock,blockname)
                    uniqueDiffBlock(blockname)=1;
                    return;
                end

                for i=1:length(diffbpI.MappedBlocks)
                    fname=diffbpI.MappedBlocks{i};
                    if(strcmp(oriMdlName{idx},fname)||slEnginePir.isParent(oriMdlName{idx},fname))...
                        &&~isKey(uniqueDiffBlock,fname)
                        uniqueDiffBlock(fname)=1;
                        blockname=fname;
                        return;
                    end
                end
            end
        end


        function maskparametername=existingVar(this,diffbp,parametername,clone_lib)
            maskparametername='';

            maskobj=Simulink.Mask.get(clone_lib);
            if isempty(maskobj)
                return;
            end

            uniqueDiffBlock=containers.Map('KeyType','char','ValueType','double');
            libblock=slEnginePir.CloneRefactor.getLibraryBlock(this,diffbp,clone_lib,uniqueDiffBlock,1);
            v=get_param(libblock,parametername);
            if slEnginePir.CloneRefactor.isExsitingMaskParam(this,v,maskobj.Parameters)
                maskparametername=v;
            end

            for p=1:length(maskobj.Parameters)
                if(strcmp(maskobj.Parameters(p).Value,v)&&strcmp(maskobj.Parameters(p).Type,'promote'))
                    paramdf='';
                    for q=1:length(maskobj.Parameters(p).TypeOptions)
                        typeope=maskobj.Parameters(p).TypeOptions{q};
                        len=length(typeope);
                        for s=len:-1:1
                            if strcmp(typeope(s),'/')
                                break;
                            end
                            len=len-1;
                        end
                        paramdf=typeope(len+1:end);
                        typeope=typeope(1:len);
                    end
                    if strcmp(parametername,paramdf)&&contains(libblock,typeope)
                        maskparametername=maskobj.Parameters(p).Name;
                    end
                end
            end
        end

        function[parameterNames,parameterValue]=getstructParameterNameValueForClonesAnywhere(this,oriMdlName,clonegroupID,regionID,RegNo,idx)
            parameterNames=[];
            parameterValue=[];
            diffbp=this.creator.differentBlockParamName;
            uniqueDiffBlock=containers.Map('KeyType','char','ValueType','double');
            uniqueMaskName=containers.Map('KeyType','char','ValueType','double');

            indexs=this.cloneresult.dissimiliarty{clonegroupID};

            for ii=1:length(indexs)
                i=indexs(ii);
                blockname=slEnginePir.CloneRefactor.getBlocknameForClonesAnywhere(this,diffbp(i),oriMdlName,uniqueDiffBlock);
                blockname1=[this.genmodelprefix,blockname];
                for j=1:length(diffbp(i).ParameterNames)
                    maskparametername=[];
                    if(regionID==idx)
                        sid_val=strrep(Simulink.ID.getSID([this.genmodelprefix,diffbp(i).Block]),':','_');
                        sub_sid=sid_val(length(this.genmodelprefix)+1:length(sid_val));
                        maskparametername=strcat(diffbp(i).ParameterNames(j),'_',sub_sid);
                        if length(maskparametername{:})>namelengthmax
                            maskparametername={maskparametername{:}(1:namelengthmax-1)};
                        end
                    end
                    parent=get_param(blockname1,'Parent');
                    maskobj1=Simulink.Mask.get(parent);
                    bp=get_param(blockname1,diffbp(i).ParameterNames{j});
                    typeope=[blockname1(length(parent)+2:end),'/',diffbp(i).ParameterNames{j}];
                    val='0';
                    if~isempty(maskobj1)
                        for k=1:length(maskobj1.Parameters)
                            if strcmp(maskobj1.Parameters(k).Name,bp)
                                maskparametername={maskobj1.Parameters(k).Name};
                                val=maskobj1.Parameters(k).Value;
                            end
                            if strcmp(maskobj1.Parameters(k).TypeOptions,typeope)
                                maskobj1.Parameters(k).TypeOptions=['region',num2str(RegNo),'/',diffbp(i).ParameterNames{j}];
                            end
                        end
                    end
                    if isKey(uniqueMaskName,char(maskparametername))
                        maskparametername=maskparametername+uniqueMaskName(char(maskparametername));
                        uniqueMaskName(char(maskparametername))=uniqueMaskName(char(maskparametername))+1;
                    else
                        uniqueMaskName(char(maskparametername))=1;
                    end
                    parameterNames=[parameterNames,maskparametername];


                    if(strcmp(val,'0')==1)
                        parameterValue=[parameterValue,{get_param(blockname1,diffbp(i).ParameterNames{j})}];
                    else
                        parameterValue=[parameterValue,{val}];
                    end
                end
            end
        end

        function[parameterNames,parameterValue]=getstructParameterNameValue(this,oriMdlName,clonegroupID,replaceWithOriginal,return_val)
            parameterNames=[];
            parameterValue=[];
            diffbp=this.creator.differentBlockParamName;
            diffbp1=this.diffParam;

            if slfeature('NestedCloneRefactoring')~=0
                if nargin<5
                    key=keys(replaceWithOriginal);
                    index=[];
                    return_val=[];
                    len=1;

                    for j=1:length(key)
                        if slEnginePir.isParent(this.cloneresult.lib{clonegroupID},char(key(j)))
                            ind=this.cloneresult.dissimiliarty{replaceWithOriginal(char(key(j)))};
                            for k=1:length(ind)
                                curdiffbp=diffbp(ind(k));
                                if slEnginePir.isParent(char(key(j)),curdiffbp.Block)
                                    index=[index,ind(k)];
                                end
                                for l=1:length(curdiffbp.MappedBlocks)
                                    if slEnginePir.isParent(char(key(j)),char(curdiffbp.MappedBlocks{l}))
                                        index=[index,ind(k)];
                                        break;
                                    end
                                end
                            end

                            if~isempty(index)
                                return_val(len).index=index;
                                len=len+1;
                                index=[];
                            end
                        end
                    end

                    indexs=this.cloneresult.dissimiliarty{clonegroupID};
                    if isempty(return_val)
                        return_val(len).index=indexs;
                    else
                        ind=[];
                        for i=1:length(return_val)
                            if(intersect(return_val(i).index,indexs))
                                indexs=[ind,setxor(return_val(i).index,indexs)];
                            end
                        end
                    end
                    return_val(len).index=indexs;
                    for i=1:length(return_val)
                        return_curdiff_index=[];
                        for u=1:length(return_val(i).index)
                            index=[];
                            ind=return_val(i).index;
                            for j=1:length(diffbp(ind(u)).ParameterNames)
                                index=[index,j];
                            end
                            return_curdiff_index=[return_curdiff_index,{index}];
                        end
                        return_val(i).curdiff_index=return_curdiff_index;
                    end
                end
            end

            uniqueMaskedParam=containers.Map('KeyType','char','ValueType','double');
            uniqueDiffBlock=containers.Map('KeyType','char','ValueType','double');


            for i=1:length(return_val)
                for v=1:length(return_val(i).index)
                    ind=return_val(i).index;
                    blkname=slEnginePir.CloneRefactor.getBlockname(this,diffbp1(ind(v)),oriMdlName,uniqueDiffBlock);
                    blockname=slEnginePir.util.getValidBlockPath(this.genmodelprefix,blkname);




                    masked_diffbp=return_val(i).curdiff_index{v};
                    k=1;
                    for j=1:length(diffbp(ind(v)).ParameterNames)
                        maskparametername={slEnginePir.CloneRefactor.existingVar(this,diffbp(ind(v)),diffbp(ind(v)).ParameterNames{j},this.cloneresult.lib{clonegroupID})};
                        if~isempty(masked_diffbp)&&(masked_diffbp(k)==j)
                            k=k+1;
                            if isempty(maskparametername{:})
                                validBlockName=slEnginePir.util.getValidBlockPath(this.genmodelprefix,diffbp1(ind(v)).Block);
                                maskparametername=strcat(diffbp(ind(v)).ParameterNames(j),'_',strrep(Simulink.ID.getSID(validBlockName),':','_'));
                            end
                            if length(maskparametername{:})>namelengthmax
                                maskparametername={maskparametername{:}(1:namelengthmax-1)};
                            end

                            if(~isKey(uniqueMaskedParam,maskparametername))
                                uniqueMaskedParam(char(maskparametername))=1;
                            else
                                maskparametername1=char(maskparametername);
                                maskparametername=char(maskparametername)+string(uniqueMaskedParam(char(maskparametername)));
                                uniqueMaskedParam(maskparametername1)=uniqueMaskedParam(maskparametername1)+1;
                            end
                        end
                        if~isempty(char(maskparametername))
                            parameterNames=[parameterNames,maskparametername];



                            parameterValue=[parameterValue,{get_param(blockname,diffbp1(ind(v)).ParameterNames{j})}];
                        end
                    end
                end
            end
        end

        function flag=cannotEvluateParam(~,blockfullname,parameter)
            flag=false;
            if strcmp(get_param(blockfullname,'BlockType'),'BusCreator')&&strcmp(parameter,'Inputs')
                flag=true;
            end
            if strcmp(get_param(blockfullname,'BlockType'),'Math')&&strcmp(parameter,'Operator')
                flag=true;
            end
            if strcmp(get_param(blockfullname,'BlockType'),'BusCreator')&&strcmp(parameter,'NonVirtualBus')
                flag=true;
            end
        end

        function libblock=getLibraryBlock(~,curdiffbp,clone_lib,uniqueDiffBlock,j)
            if slEnginePir.isParent(clone_lib,curdiffbp.Block)&&~isKey(uniqueDiffBlock,[curdiffbp.Block,curdiffbp.ParameterNames{j}])
                libblock=curdiffbp.Block;
                uniqueDiffBlock([libblock,curdiffbp.ParameterNames{j}])=1;
                return;
            end
            for i=1:length(curdiffbp.MappedBlocks)
                if slEnginePir.isParent(clone_lib,curdiffbp.MappedBlocks{i})&&~isKey(uniqueDiffBlock,[curdiffbp.MappedBlocks{i},curdiffbp.ParameterNames{j}])
                    libblock=curdiffbp.MappedBlocks{i};
                    uniqueDiffBlock([libblock,curdiffbp.ParameterNames{j}])=1;
                    return;
                end
            end
            libblock=curdiffbp.Block;
        end


        function libblock=getLibraryBlockForClonesAnywhere(~,curdiffbp,clone_lib,uniqueDiffBlock,j)
            for i=1:length(clone_lib)
                if(slEnginePir.isParent(clone_lib{i},curdiffbp.Block)||strcmp(clone_lib{i},curdiffbp.Block))...
                    &&~isKey(uniqueDiffBlock,[curdiffbp.Block,curdiffbp.ParameterNames{j}])
                    libblock=curdiffbp.Block;
                    uniqueDiffBlock([libblock,curdiffbp.ParameterNames{j}])=1;
                    return;
                end
                for l=1:length(curdiffbp.MappedBlocks)
                    if(slEnginePir.isParent(clone_lib{i},curdiffbp.MappedBlocks{l})||...
                        strcmp(clone_lib{i},curdiffbp.MappedBlocks{l}))&&~isKey(uniqueDiffBlock,[curdiffbp.MappedBlocks{l},curdiffbp.ParameterNames{j}])
                        libblock=curdiffbp.MappedBlocks{l};
                        uniqueDiffBlock([libblock,curdiffbp.ParameterNames{j}])=1;
                        return;
                    end
                end
            end
            libblock=curdiffbp.Block;
        end

        function[maskableFlag,errmessage,updateBlock,return_val,innerSubsysMask]=...
            addMasktoLibBlock(this,refBlock,listOfClonesInAGroup,existingLinkedSSInLibrary,cloneGroupIndex,visitedBlocks,...
            maskedBlockParams,replaceWithOriginal,updateBlock,innerSubsysMask)

            maskableFlag=true;



            errmessage='';
            diffbp=this.creator.differentBlockParamName;
            diffbp1=this.diffParam;
            val={};
            len=1;
            new_dissimilarity=[];
            return_len=1;
            return_val=[];
            ind1=this.cloneresult.dissimiliarty{cloneGroupIndex};
            key=keys(replaceWithOriginal);
            if slfeature('NestedCloneRefactoring')~=0
                index=[];


                for j=1:length(key)
                    if slEnginePir.isParent(existingLinkedSSInLibrary,char(key(j)))
                        ind=this.cloneresult.dissimiliarty{replaceWithOriginal(char(key(j)))};
                        for k=1:length(ind)
                            curdiffbp=diffbp(ind(k));
                            if slEnginePir.isParent(char(key(j)),curdiffbp.Block)
                                index=[index,ind(k)];
                            end
                            for l=1:length(curdiffbp.MappedBlocks)
                                if slEnginePir.isParent(char(key(j)),char(curdiffbp.MappedBlocks{l}))
                                    index=[index,ind(k)];
                                    break;
                                end
                            end
                        end

                        if~isempty(index)
                            val{len}=index;
                            len=len+1;
                        end
                        index=[];
                    end
                end
            end







            maskobj=Simulink.Mask.get(refBlock);
            if isempty(maskobj)
                maskobj=Simulink.Mask.create(refBlock);
            end
            maskParam=maskobj.Parameters;





            uniqueDiffBlock=containers.Map('KeyType','char','ValueType','double');
            uniqueDiffBlock1=containers.Map('KeyType','char','ValueType','double');
            uniqueLibBlock=containers.Map('KeyType','char','ValueType','double');
            uniquePromotedParam=containers.Map('KeyType','char','ValueType','double');
            uniqueMaskedParam=containers.Map('KeyType','char','ValueType','double');
            childSubsysSrt=containers.Map('KeyType','char','ValueType','any');
            saveTypeopetions=containers.Map('KeyType','char','ValueType','double');

            t_ind=0;
            if isempty(val)
                val{len}=ind1;
            else
                ind=[];
                for i=1:length(val)
                    if(intersect(val{i},ind1))
                        ind1=[ind,setxor(val{i},ind1)];
                    end
                end
                val{len}=ind1;
            end

            for i=1:length(val)
                return_index=[];
                return_curdiff_index=[];
                for u=1:length(val{i})
                    curdiff_index=[];
                    ind=val{i};
                    return_index=[return_index,ind(u)];
                    curdiffbp=diffbp(ind(u));
                    new_dissimilarity=[new_dissimilarity,ind(u)];
                    curdiffbp1=diffbp1(ind(u));

                    flag=false;
                    needtable=true;


                    validBlockName=slEnginePir.util.getValidBlockPath(this.genmodelprefix,...
                    curdiffbp1.Block);
                    obj=get_param(validBlockName,'DialogParameters');


                    t_ind=t_ind+1;
                    no_of_rows_in_table=0;
                    for j=1:length(curdiffbp.ParameterNames)






                        if~isfield(obj,curdiffbp1.ParameterNames{j})
                            continue;
                        end

                        libblock=slEnginePir.CloneRefactor.getLibraryBlock(this,curdiffbp,existingLinkedSSInLibrary,uniqueDiffBlock,j);
                        libblock1=slEnginePir.CloneRefactor.getLibraryBlock(this,curdiffbp1,existingLinkedSSInLibrary,uniqueDiffBlock1,j);
                        if slfeature('NestedCloneRefactoring')==0
                            if(isKey(visitedBlocks,libblock))
                                warning(message('sl_pir_cpp:creator:RefactoringNotSupported',this.mdlName));
                                updateBlock=false;
                                return;
                            end
                        end
                        libBlockName=libblock;
                        v=get_param(libblock,curdiffbp.ParameterNames{j});
                        v1=get_param(slEnginePir.util.getValidBlockPath(this.genmodelprefix,libblock1),...
                        curdiffbp.ParameterNames{j});


                        maskparametername=strcat(curdiffbp.ParameterNames{j},'_',...
                        strrep(Simulink.ID.getSID(slEnginePir.util.getValidBlockPath(this.genmodelprefix,curdiffbp1.Block)),':','_'));

                        if length(maskparametername)>namelengthmax
                            maskparametername=maskparametername(1:namelengthmax-1);
                        end

                        if(isKey(uniquePromotedParam,maskparametername))
                            maskparametername1=maskparametername;
                            maskparametername=maskparametername+string(uniquePromotedParam(maskparametername));
                            uniquePromotedParam(maskparametername1)=uniquePromotedParam(maskparametername1)+1;
                        end

                        if(~isKey(uniqueMaskedParam,maskparametername))
                            uniqueMaskedParam(maskparametername)=1;
                        else
                            maskparametername1=maskparametername;
                            maskparametername=maskparametername+string(uniqueMaskedParam(maskparametername));
                            uniqueMaskedParam(maskparametername1)=uniqueMaskedParam(maskparametername1)+1;
                        end

                        existingParam=slEnginePir.CloneRefactor.existingVar(this,diffbp(ind(u)),diffbp(ind(u)).ParameterNames{j},existingLinkedSSInLibrary);
                        if~isempty(existingParam)
                            continue;
                        end




                        for k=1:length(key)
                            if slEnginePir.isParent(key{k},libblock)
                                key1=key{k};
                                key1=[refBlock,key1(length(existingLinkedSSInLibrary)+1:end)];

                                if isKey(childSubsysSrt,key1)
                                    childSubsysSrt(key1)=[childSubsysSrt(key1),{maskparametername}];
                                else
                                    childSubsysSrt(key1)=[];
                                    childSubsysSrt(key1)=[childSubsysSrt(key1),{maskparametername}];
                                end
                            end
                        end



                        if strcmp(v1,maskparametername)
                            continue;
                        end
                        set_param(bdroot(refBlock),'Lock','off');


                        blockfullname=slEnginePir.CloneRefactor.getblockfullname(this,refBlock,curdiffbp,existingLinkedSSInLibrary,uniqueLibBlock,j);
                        if isempty(blockfullname)









                            for k=1:length(listOfClonesInAGroup)
                                if slEnginePir.isParent(listOfClonesInAGroup{k},curdiffbp.Block)






                                    blockfullname=[refBlock,curdiffbp.Block(length(listOfClonesInAGroup{k})+1:end)];
                                    break;
                                end
                            end
                        end

                        if slEnginePir.CloneRefactor.isRepeated(this,maskobj,maskparametername)
                            continue;
                        end


                        obj1=Simulink.Mask.get(libblock);
                        spinbox_check=1;
                        if(~isempty(obj1)&&length(obj1.Parameters)>=j&&strcmp(obj1.Parameters(j).Type,'spinbox'))
                            spinbox_check=0;
                        end
                        cond=isempty(nonzeros(strcmp('dont-eval',obj.(curdiffbp.ParameterNames{j}).Attributes)))&&...
                        ~strcmp(obj.(curdiffbp.ParameterNames{j}).Type,'boolean')&&...
                        ~(strcmp(obj.(curdiffbp.ParameterNames{j}).Type,'enum'))&&...
                        spinbox_check;
                        cond2=isempty(nonzeros(strcmp('not-link-instance',obj.(curdiffbp.ParameterNames{j}).Attributes)));
                        if~cond2&&~cond
                            blktype=get_param(curdiffbp.Block,'BlockType');
                            errmessage=[curdiffbp.ParameterNames{j},' is not able to promote for ',blktype,' block'];
                            maskableFlag=false;
                            return;
                        end



                        if(~isKey(visitedBlocks,libblock))
                            if~Simulink.Mask.isPromotable(curdiffbp.Block,curdiffbp.ParameterNames{j})
                                maskableFlag=false;
                                blktype=get_param(curdiffbp.Block,'BlockType');
                                errmessage=[curdiffbp1.ParameterNames{j},' is not able to promote for ',blktype,' block'];
                                return;
                            end


                            if slEnginePir.CloneRefactor.cannotEvluateParam(this,curdiffbp.Block,curdiffbp.ParameterNames{j})
                                maskableFlag=false;
                                blktype=get_param(curdiffbp.Block,'BlockType');
                                errmessage=[curdiffbp.ParameterNames{j},' is not able to promote for ',blktype,' block'];
                                return;
                            end
                        end

                        if needtable
                            tablename=['table',num2str(t_ind)];
                            try
                                maskobj.addDialogControl('Type','table','Prompt',blockfullname(length(refBlock)+2:end),'Name',tablename);
                            catch ME
                                disp(ME.message);!
                            end
                        end
                        needtable=false;








                        if cond&&...
                            ~strcmp(curdiffbp1.ParameterNames{j},'OutDataTypeStr')&&~strcmp(curdiffbp1.ParameterNames{j},'ParamDataTypeStr')



                            if(strcmp(get_param(slEnginePir.util.getValidBlockPath(this.genmodelprefix,libblock1),'LinkStatus'),'implicit')||...
                                strcmp(get_param(slEnginePir.util.getValidBlockPath(this.genmodelprefix,libblock1),'LinkStatus'),'resolved'))
                                fullpath=blockfullname;
                                flag=0;
                                bp=get_param(blockfullname,curdiffbp1.ParameterNames{j});
                                len=length(fullpath);
                                while length(fullpath)>0
                                    maskobj1=Simulink.Mask.get(fullpath);
                                    if(~isempty(maskobj1))
                                        for s=1:length(maskobj1.Parameters)
                                            if(strcmp(maskobj1.Parameters(s).Name,bp))
                                                maskparametername=maskobj1.Parameters(s).Name;
                                                flag=1;
                                            end
                                        end
                                    end

                                    while len>0&&~strcmp(fullpath(len),'/')
                                        len=len-1;
                                    end

                                    len=len-1;
                                    fullpath=fullpath(1:len);
                                end
                                maskobj.addParameter('Name',maskparametername,'Prompt',curdiffbp.ParameterNames{j},'Value',v,'Container',['table',num2str(t_ind)]);
                                if(flag==0)
                                    try
                                        set_param(blockfullname,curdiffbp.ParameterNames{j},maskparametername);
                                        flag=true;
                                    catch ME

                                        disp(ME.message);
                                    end
                                end
                            else
                                maskobj.addParameter('Name',maskparametername,'Prompt',curdiffbp.ParameterNames{j},'Value',v,'Container',['table',num2str(t_ind)]);




                                if~strcmp(get_param(blockfullname,curdiffbp.ParameterNames{j}),maskparametername)&&...
                                    ~isKey(visitedBlocks,libblock)

                                    try
                                        set_param(blockfullname,curdiffbp.ParameterNames{j},maskparametername);
                                        flag=true;
                                    catch ME

                                        disp(ME.message);
                                    end
                                end
                            end
                            curdiff_index=[curdiff_index,j];
                            no_of_rows_in_table=no_of_rows_in_table+1;
                        else
                            if slfeature('NestedCloneRefactoring')~=0
                                lastwarn('');
                                try
                                    if(~isKey(visitedBlocks,libblock))
                                        typeopetions1=[blockfullname(length(refBlock)+2:end),'/',curdiffbp.ParameterNames{j}];
                                        typeopetions=blockfullname;

                                        prename=typeopetions;
                                        blk=[];
                                        len=length(typeopetions);
                                        found=0;
                                        insideMaskedSubsystem=false;
                                        len1=length(libblock);
                                        while len1>0&&~strcmp(libblock(len1),'/')
                                            len1=len1-1;
                                        end
                                        len1=len1-1;
                                        libblock=libblock(1:len1);
                                        while len1>0
                                            superMask=Simulink.Mask.get(libblock);
                                            if~isempty(superMask)
                                                for cloneindex=1:length(listOfClonesInAGroup)
                                                    if slEnginePir.isParent(listOfClonesInAGroup{cloneindex},libblock)
                                                        insideMaskedSubsystem=true;
                                                    end
                                                end
                                            end
                                            while len1>0&&~strcmp(libblock(len1),'/')
                                                len1=len1-1;
                                            end
                                            len1=len1-1;
                                            libblock=libblock(1:len1);
                                        end

                                        while len>0&&~strcmp(typeopetions(len),'/')
                                            len=len-1;
                                        end
                                        len=len-1;
                                        typeopetions=typeopetions(1:len);

                                        while length(typeopetions)>0
                                            maskobj1=Simulink.Mask.get(typeopetions);
                                            if(~isempty(maskobj1))
                                                for s=1:length(maskobj1.Parameters)
                                                    if(strcmp(maskobj1.Parameters(s).Type,'promote'))
                                                        for t=1:length(maskobj1.Parameters(s).TypeOptions)
                                                            if slEnginePir.isParent(typeopetions1,maskobj1.Parameters(s).TypeOptions{t})
                                                                found=1;
                                                                prename=typeopetions;
                                                                blk=maskobj1.Parameters(s).Name;
                                                                break;
                                                            end
                                                        end
                                                    else
                                                        if strcmp(maskobj1.Parameters(s).Name,v)
                                                            found=1;
                                                            prename=typeopetions;
                                                            blk=maskobj1.Parameters(s).Name;
                                                            break;
                                                        end
                                                    end
                                                    if(found==1)
                                                        if(length(maskobj1.Parameters(s).TypeOptions)>1)
                                                            for typeop=1:length(maskobj1.Parameters(s).TypeOptions)
                                                                saveTypeopetions(maskobj1.Parameters(s).TypeOptions{typeop})=1;
                                                            end
                                                        end
                                                        break;
                                                    end
                                                end
                                                if(found==1)
                                                    break;
                                                end
                                            end
                                            if(found==1)
                                                break;
                                            end

                                            while len>0&&~strcmp(typeopetions(len),'/')
                                                len=len-1;
                                            end
                                            if len==0
                                                typeopetions=[blockfullname(length(refBlock)+2:end),'/',curdiffbp.ParameterNames{j}];
                                                break;
                                            end
                                            len=len-1;
                                            typeopetions=typeopetions(1:len);
                                        end
                                        if(found==1)&&~isempty((prename(length(refBlock)+2:end)))
                                            typeopetions=[prename(length(refBlock)+2:end),'/',blk];
                                        else
                                            if(insideMaskedSubsystem)
                                                warning(message('sl_pir_cpp:creator:ParameterFromMaskedSubsystem',this.mdlName));
                                                updateBlock=false;
                                                return;
                                            end
                                            typeopetions=[blockfullname(length(refBlock)+2:end),'/',curdiffbp.ParameterNames{j}];
                                        end
                                        if isKey(saveTypeopetions,typeopetions)
                                            continue;
                                        else
                                            saveTypeopetions(typeopetions)=1;
                                        end

                                    else
                                        typeopetions=blockfullname;
                                        prename=typeopetions;
                                        len=length(typeopetions);
                                        typeopetions1=[blockfullname(length(refBlock)+2:end),'/',curdiffbp.ParameterNames{j}];
                                        found=0;
                                        len1=length(libblock1);
                                        while len1>0&&~strcmp(libblock1(len1),'/')
                                            len1=len1-1;
                                        end
                                        len1=len1-1;
                                        insideMaskedSubsystem=false;
                                        libblock1=libblock1(1:len1);
                                        while len1>0
                                            superMask=Simulink.Mask.get(slEnginePir.util.getValidBlockPath(this.genmodelprefix,libblock1));
                                            if~isempty(superMask)
                                                for cloneindex=1:length(listOfClonesInAGroup)
                                                    if slEnginePir.isParent(listOfClonesInAGroup{cloneindex},libblock)
                                                        insideMaskedSubsystem=true;
                                                    end
                                                end
                                            end
                                            while len1>0&&~strcmp(libblock1(len1),'/')
                                                len1=len1-1;
                                            end
                                            len1=len1-1;
                                            libblock1=libblock1(1:len1);
                                        end

                                        while length(typeopetions)>0
                                            maskobj1=Simulink.Mask.get(typeopetions);
                                            if(~isempty(maskobj1))
                                                for s=1:length(maskobj1.Parameters)
                                                    if(strcmp(maskobj1.Parameters(s).Name,maskparametername))
                                                        found=1;
                                                        prename=typeopetions;
                                                        break;
                                                    end
                                                end
                                            end

                                            while len>0&&~strcmp(typeopetions(len),'/')
                                                len=len-1;
                                            end
                                            if len==0
                                                typeopetions=[blockfullname(length(refBlock)+2:end),'/',curdiffbp.ParameterNames{j}];
                                                break;
                                            end
                                            len=len-1;
                                            typeopetions=typeopetions(1:len);
                                        end
                                        if(found==1)
                                            typeopetions=[prename(length(refBlock)+2:end),'/',char(maskparametername)];
                                        else
                                            if(insideMaskedSubsystem)
                                                warning(message('sl_pir_cpp:creator:ParameterFromMaskedSubsystem',this.mdlName));
                                                updateBlock=false;
                                                return;
                                            end
                                            typeopetions=typeopetions1;
                                        end
                                        if isKey(saveTypeopetions,typeopetions)
                                            continue;
                                        else
                                            saveTypeopetions(typeopetions)=1;
                                        end
                                    end

                                    flag_promote=0;
                                    for p=1:length(maskParam)
                                        if(strcmp(maskParam(p).Name,curdiffbp.ParameterNames{j})&&...
                                            strcmp(maskParam(p).TypeOptions,typeopetions))
                                            flag_promote=1;
                                        end
                                    end

                                    if(flag_promote~=0)
                                        uniqueMaskedParam(maskparametername)=uniqueMaskedParam(maskparametername)-1;
                                        if uniqueMaskedParam(maskparametername)==0
                                            remove(uniqueMaskedParam,maskparametername);
                                        end
                                        continue;
                                    end
                                    curdiff_index=[curdiff_index,j];
                                    no_of_rows_in_table=no_of_rows_in_table+1;
                                    try
                                        maskobj.addParameter('Type','promote','TypeOptions',{typeopetions},'Name',maskparametername,'Prompt',curdiffbp.ParameterNames{j},'Container',['table',num2str(t_ind)]);
                                    catch ME








                                        maskobj.addParameter('Type','promote','TypeOptions',{typeopetions},'Name',maskparametername,'Prompt',curdiffbp.ParameterNames{j});
                                    end

                                catch ME
                                    DAStudio.warning(ME.identifier);
                                end
                            else
                                typeopetions=[blockfullname(length(refBlock)+2:end),'/',curdiffbp.ParameterNames{j}];

                                lastwarn('');
                                try
                                    no_of_rows_in_table=no_of_rows_in_table+1;
                                    maskobj.addParameter('Type','promote','TypeOptions',{typeopetions},'Name',maskparametername,'Prompt',curdiffbp.ParameterNames{j},'Container',['table',num2str(t_ind)]);
                                catch ME
                                    disp(ME.message);








                                    maskobj.addParameter('Type','promote','TypeOptions',{typeopetions},'Name',maskparametername,'Prompt',curdiffbp.ParameterNames{j});
                                end
                            end
                            maskableFlag=slEnginePir.CloneRefactor.movePromopteMask(this,maskobj,typeopetions,['table',num2str(ind(i))],maskparametername);
                            if~maskableFlag
                                return;
                            end
                            flag=true;
                        end
                    end
                    if(no_of_rows_in_table==0)
                        maskobj.removeDialogControl(['table',num2str(t_ind)]);
                    end
                    len=length(libBlockName);
                    for l=length(libBlockName):-1:1
                        if(strcmp(libBlockName(l),'/'))
                            break;
                        end
                        len=len-1;
                    end
                    temp=libBlockName(len+1:end);

                    len=length(curdiffbp.Block);
                    for l=length(curdiffbp.Block):-1:1
                        if(strcmp(curdiffbp.Block(l),'/'))
                            break;
                        end
                        len=len-1;
                    end
                    curdiffbp.Block=[curdiffbp.Block(1:len),temp];

                    for k=1:length(curdiffbp.MappedBlocks)
                        block=char(curdiffbp.MappedBlocks{k});
                        len=length(block);
                        for l=length(block):-1:1
                            if(strcmp(block(l),'/'))
                                break;
                            end
                            len=len-1;
                        end
                        curdiffbp.MappedBlocks{k}=[block(1:len),temp];
                    end
                    this.creator.differentBlockParamName(ind(u))=curdiffbp;
                    if flag
                        if strcmp(bdroot(refBlock),this.libname)
                            save_system(bdroot(refBlock),this.inputLibName,'SaveDirtyReferencedModels','on');
                        else
                            save_system(bdroot(refBlock));
                        end
                    end
                    return_curdiff_index=[return_curdiff_index,{curdiff_index}];
                end
                return_val(return_len).index=return_index;
                return_val(return_len).curdiff_index=return_curdiff_index;
                return_len=return_len+1;
            end
            if slfeature('NestedCloneRefactoring')~=0
                key=keys(replaceWithOriginal);
                this.cloneresult.dissimiliarty{cloneGroupIndex}=new_dissimilarity;


                for k=1:length(key)
                    key1=key{k};
                    if slEnginePir.isParent(existingLinkedSSInLibrary,key1)
                        key1=[refBlock,key1(length(existingLinkedSSInLibrary)+1:end)];
                        if slEnginePir.isParent(refBlock,key1)&&isKey(childSubsysSrt,key1)
                            p=Simulink.Mask.get(key1);
                            innermask=innerSubsysMask(key{k});
                            mask=childSubsysSrt(key1);
                            for j=1:length(p.Parameters)
                                for l=1:length(innermask)
                                    if(~strcmp(p.Parameters(j).Type,'promote')&&strcmp(p.Parameters(j).Value,char(innermask{l})))
                                        set_param(key1,p.Parameters(j).Value,char(mask{l}));
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        function maskableFlag=movePromopteMask(this,maskobj,typeopetions,tablename,maskparametername)
            [msgstr,msgid]=lastwarn;
            maskableFlag=true;
            if strcmp(msgid,'Simulink:Masking:Promote_Parameter_AlreadyPromoted')
                C=textscan(msgstr,'%s','Delimiter','''');




                masksub=C{1}{15};
            elseif strcmp(msgid,'Simulink:Masking:Promote_Parameter_CannotBePromoted_InsideMaskedSubsystem')
                C=textscan(msgstr,'%s','Delimiter','''');




                masksub=C{1}{13};
            elseif strcmp(msgid,'Simulink:Masking:Promote_Parameter_CannotBePromoted_InsideMaskedBlock')
                C=textscan(msgstr,'%s','Delimiter','''');
                C2=textscan(C{1}{2},'%s','Delimiter','/');
                masksub=[C{1}{7},'/',C2{1}{1}];
                maskobj.removeParameter(maskparametername);
                maskableFlag=false;
                return;
            else
                if~isempty(msgid)

                end
                return;
            end

            set_param(masksub,'LinkStatus','none');
            submask=Simulink.Mask.get(masksub);
            if isempty(submask)
                return;
            end


            ind=length(submask.Parameters);
            removedNum=0;
            for i=1:ind
                p=submask.Parameters(i-removedNum);

                pName=p.Name;
                pTypeOptions=p.TypeOptions;
                pPrompt=p.Prompt;
                pValue=p.Value;
                pEvaluate=p.Evaluate;
                pTunable=p.Tunable;
                pNeverSave=p.NeverSave;
                pHidden=p.Hidden;
                pReadOnly=p.ReadOnly;
                pEnabled=p.Enabled;
                pVisible=p.Visible;
                pShowTooltip=p.ShowTooltip;
                pCallback=p.Callback;
                pAlias=p.Alias;

                if strcmp(p.Type,'promote')
                    maskobj.removeParameter(pName);

                    removedNum=removedNum+1;
                    maskobj.addParameter('Type','promote',...
                    'TypeOptions',{typeopetions},...
                    'Name',pName,...
                    'Prompt',pPrompt,...
                    'Value',pValue,...
                    'Evaluate',pEvaluate,...
                    'Tunable',pTunable,...
                    'NeverSave',pNeverSave,...
                    'Hidden',pHidden,...
                    'ReadOnly',pReadOnly,...
                    'Enabled',pEnabled,...
                    'Visible',pVisible,...
                    'ShowTooltip',pShowTooltip,...
                    'Callback',pCallback,...
                    'Alias',pAlias,...
                    'Container',tablename);
                else
                    pConstraintName=p.ConstraintName;
                    if slEnginePir.CloneRefactor.isRepeated(this,maskobj,pName)
                        maskobj.removeParameter(pName);
                    end
                    maskobj.addParameter('Type','edit',...
                    'TypeOptions',pTypeOptions,...
                    'Name',pName,...
                    'Prompt',pPrompt,...
                    'Value',pValue,...
                    'Evaluate',pEvaluate,...
                    'Tunable',pTunable,...
                    'NeverSave',pNeverSave,...
                    'Hidden',pHidden,...
                    'ReadOnly',pReadOnly,...
                    'Enabled',pEnabled,...
                    'Visible',pVisible,...
                    'ShowTooltip',pShowTooltip,...
                    'Callback',pCallback,...
                    'Alias',pAlias,...
                    'ConstraintName',pConstraintName,...
                    'Container',tablename);


                end
            end
            submask.delete;
        end

        function flag=isRepeated(~,maskobj,pName)
            flag=false;

            for i=1:length(maskobj.Parameters)

                p=maskobj.Parameters(i);
                if strcmp(pName,p.Name)
                    flag=true;
                    return;
                end
            end
        end

        function flag=isExsitingMaskParam(~,v,maskParam)
            flag=false;

            for i=1:length(maskParam)
                if strcmp(v,maskParam(i).Name)&&~strcmp(maskParam(i).Type,'promote')
                    flag=true;
                    return;
                end
            end
        end


        function blockfullname=getblockfullname(~,refblocks,curdiffbp,clone_lib,uniqueLibBlock,j)

            blockfullname='';





            blkname=curdiffbp.Block;
            if slEnginePir.isParent(clone_lib,blkname)&&~isKey(uniqueLibBlock,[blkname,curdiffbp.ParameterNames{j}])
                blockfullname=[refblocks,blkname(length(clone_lib)+1:end)];
                uniqueLibBlock([blkname,curdiffbp.ParameterNames{j}])=1;
                return;
            end

            for i=1:length(curdiffbp.MappedBlocks)
                mappedblock=curdiffbp.MappedBlocks{i};
                if slEnginePir.isParent(clone_lib,mappedblock)&&~isKey(uniqueLibBlock,[mappedblock,curdiffbp.ParameterNames{j}])
                    uniqueLibBlock([mappedblock,curdiffbp.ParameterNames{j}])=1;
                    blockfullname=[refblocks,mappedblock(length(clone_lib)+1:end)];
                    return;
                end
            end





        end

        function blockfullname=getblockfullnameForClonesAnywhere(~,refblocks,curdiffbp,clone_lib,uniqueLibBlock,j)

            blockfullname='';





            blkname=curdiffbp.Block;
            for i=1:length(clone_lib)
                if(strcmp(clone_lib{i},blkname)||slEnginePir.isParent(clone_lib{i},blkname))...
                    &&~isKey(uniqueLibBlock,[blkname,curdiffbp.ParameterNames{j}])
                    parentNameLen=length(get_param(clone_lib{i},'parent'));
                    blockfullname=refblocks+blkname(parentNameLen+1:end);
                    uniqueLibBlock([blkname,curdiffbp.ParameterNames{j}])=1;
                    return;
                end

                for k=1:length(curdiffbp.MappedBlocks)
                    mappedblock=curdiffbp.MappedBlocks{k};
                    if(strcmp(clone_lib{i},mappedblock)||slEnginePir.isParent(clone_lib{i},mappedblock))...
                        &&~isKey(uniqueLibBlock,[mappedblock,curdiffbp.ParameterNames{j}])
                        parentNameLen=length(get_param(clone_lib{i},'parent'));
                        uniqueLibBlock([mappedblock,curdiffbp.ParameterNames{j}])=1;
                        blockfullname=refblocks+mappedblock(parentNameLen+1:end);
                        return;
                    end
                end
            end
        end

        function flag=hascsc(this,fname)
            flag=false;



            if~strcmp(get_param(fname,'Type'),'block_diagram')&&~strcmp(get_param(fname,'SFBlockType'),'NONE')
                return;
            end
            L=find_system(fname,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,'FindAll','on','LookUnderMasks','all','type','line');
            for i=1:length(L)
                ol=get_param(L(i),'Object');
                if ol.MustResolveToSignalObject||(this.considerSignalName&&~isempty(ol.Name))
                    flag=true;
                    return;
                end
            end



            blkset=find_system(fname,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,...
            'IncludeCommented','on','LookUnderMasks','all','FollowLinks','on');
            for i=2:length(blkset)
                if strcmp(get_param(blkset{i},'BlockType'),'SubSystem')&&strcmp(get_param(blkset{i},'SFBlockType'),'NONE')
                    flag=slEnginePir.CloneRefactor.hascsc(this,blkset{i});
                    if flag
                        return;
                    end
                end
            end
        end

        function[w,l]=getBlocksize(~,fname)
            if strcmp(get_param(fname,'Type'),'block_diagram')
                w=30;
                l=30;
                return;
            end
            pos=get_param(fname,'Position');
            w=pos(3)-pos(1);
            l=pos(4)-pos(2);
        end

        function[fname,setAuto]=getLibrarySubsystem(this,sysNames)
            hasNonReusable=false;
            hasInline=false;
            hasAuto=false;
            setAuto=false;

            for i=1:length(sysNames)
                if isKey(this.excluded_sysclone,sysNames{i})
                    continue;
                end
                prename=sysNames{i};
                break;
            end

            for i=1:length(sysNames)
                fname=sysNames{i};

                if isKey(this.excluded_sysclone,fname)||strcmp(get_param(fname,'Type'),'block_diagram')
                    fname=prename;
                    continue;
                end


                subtype=Simulink.SubsystemType(fname);
                if subtype.isSimulinkFunction
                    fname=prename;
                    continue;
                end

                fcnpacking=get_param(fname,'RTWSystemCode');
                if strcmp(fcnpacking,'Reusable function')
                    return;
                elseif strcmp(fcnpacking,'Nonreusable function')
                    hasNonReusable=true;
                elseif strcmp(fcnpacking,'Inline')
                    hasInline=true;
                elseif strcmp(fcnpacking,'Auto')
                    hasAuto=true;
                end
                prename=fname;
            end

            if(hasNonReusable+hasInline+hasAuto)>=2
                setAuto=true;
            end


            if~strcmp(get_param(fname,'Type'),'block_diagram')&&strcmp(get_param(fname,'TreatAsAtomicUnit'),'off')
                for i=1:length(sysNames)
                    if~strcmp(get_param(sysNames{i},'Type'),'block_diagram')&&strcmp(get_param(sysNames{i},'TreatAsAtomicUnit'),'on')...
                        &&~isKey(this.excluded_sysclone,sysNames{i})
                        fname=sysNames{i};
                        break;
                    end
                end
            end
        end

        function checkCSCinfor(this,result)
            for i=1:length(result)
                for j=1:length(result{i})
                    fname=result{i}{j};
                    if slEnginePir.CloneRefactor.hascsc(this,fname)
                        this.excluded_sysclone(fname)=DAStudio.message('sl_pir_cpp:creator:CSCAndSignalNameExclusionReason');
                    end
                end
            end
        end

        function ind=hasdifferparameter(this,blockcandName)

            diffbp=this.creator.differentBlockParamName;
            ind=[];

            for j=1:length(diffbp)
                flag=false;
                blockname=diffbp(j).Block;
                if slEnginePir.isParent(blockcandName,blockname)
                    flag=true;
                    ind=[ind,j];
                end
                if flag
                    continue;
                end

                for k=1:length(diffbp(j).MappedBlocks)
                    fname=diffbp(j).MappedBlocks{k};
                    if slEnginePir.isParent(blockcandName,fname)
                        flag=true;
                        break;
                    end
                end
                if flag
                    ind=[ind,j];
                end
            end
        end


        function checkSimulinkFunctionStruct(this,result)
            if strcmp(this.clonepattern,'StructuralParameters')
                return;
            end
            for i=1:length(result)
                flag=false;
                for j=1:length(result{i})
                    fname=result{i}{j};
                    subtype=Simulink.SubsystemType(fname);

                    if~subtype.isSimulinkFunction
                        break;
                    elseif~isempty(slEnginePir.CloneRefactor.hasdifferparameter(this,fname))
                        flag=true;
                        break;
                    end
                end
                if flag
                    for j=1:length(result{i})
                        fname=result{i}{j};

                        this.excluded_sysclone(fname)=' Simulink Function subsystem cannot be masked.';
                    end
                end
            end
        end


        function checkSubsystemDialogParameters(this,result)

            if~this.considerDialogParameters
                for i=1:length(result)
                    fname=result{i}{1};
                    if~strcmp(get_param(fname,'Type'),'block_diagram')&&...
                        ~isempty(get_param(fname,'Variants'))&&...
                        ~slEnginePir.CloneRefactor.hasSameSubsystemDialogParameters(this,result{i})
                        for j=1:length(result{i})
                            fname=result{i}{j};

                            this.excluded_sysclone(fname)=' Variant subsystems have different dialog parameters cannot be reused';
                        end
                    end
                end
                return;
            end

            for i=1:length(result)
                fname=result{i}{1};
                if~strcmp(get_param(fname,'Type'),'block_diagram')&&...
                    ~slEnginePir.CloneRefactor.hasSameSubsystemDialogParameters(this,result{i})
                    for j=1:length(result{i})
                        fname=result{i}{j};

                        this.excluded_sysclone(fname)='Subsystems have different dialog parameters cannot be reused';
                    end
                end
            end
        end

        function checkSubsystemPermission(this,result)
            for i=1:length(result)
                for j=1:length(result{i})
                    fname=result{i}{j};
                    if slEnginePir.CloneRefactor.isInsideReadOnlyorReadOnly(this,fname)

                        this.excluded_sysclone(fname)='Subsystems does not have ReadWrite Permissions cannot be reused';
                    end
                end
            end
        end


        function checkConfigurableSubsystem(this,result)
            for i=1:length(result)
                for j=1:length(result{i})
                    fname=result{i}{j};
                    if~strcmp(get_param(fname,'Type'),'block_diagram')&&...
                        (~isempty(get_param(fname,'MemberBlocks'))||...
                        ~isempty(get_param(fname,'BlockChoice')))

                        this.excluded_sysclone(fname)='Subsystem is a configurable subsystem';
                    end
                end
            end
        end


        function flag=isInsideReadOnlyorReadOnly(~,fname)
            flag=false;

            while~strcmp(get_param(fname,'Type'),'block_diagram')
                if~(strcmp(get_param(fname,'Permissions'),'ReadWrite'))
                    flag=true;
                end
                fname=get_param(fname,'Parent');
            end
        end

        function flag=hasSameSubsystemDialogParameters(~,onecloneGroup)

            flag=true;
            fname=onecloneGroup{1};
            op=get_param(fname,'dialogparameters');

            if isempty(op)
                return;
            end

            f=fieldnames(op);


            i=strcmp('TemplateBlock',f);f(i)=[];
            i=strcmp('MemberBlocks',f);f(i)=[];
            i=strcmp('ParameterArgumentNames',f);f(i)=[];
            i=strcmp('ParameterArgumentValues',f);f(i)=[];
            i=strcmp('AvailSigsDefaultProps',f);f(i)=[];


            i=strcmp('UpdateSigLoggingInfo',f);f(i)=[];



            idx_list=[];
            for i=1:length(f)
                cond1=~isempty(nonzeros(strcmp('read-only',op.(f{i}).Attributes)));
                cond2=~isempty(nonzeros(strcmp('write-only',op.(f{i}).Attributes)));
                if cond1||cond2
                    idx_list=[idx_list,i];
                end
            end
            f(idx_list)=[];




            idx_list=[];
            for i=1:length(f)
                cond1=isempty(nonzeros(strcmp('always-link-instance',op.(f{i}).Attributes)));
                cond2=isempty(nonzeros(strcmp('link-instance',op.(f{i}).Attributes)));
                hmask=hasmask(fname);
                if~((cond1&&~hmask)||(cond2&&hmask))
                    idx_list=[idx_list,i];
                end
            end
            f(idx_list)=[];


            v=cell(length(f),1);
            for i=1:length(f)
                v{i}=get_param(fname,f{i});
            end


            for i=2:length(onecloneGroup)
                fname=onecloneGroup{i};

                for j=1:length(f)
                    if~strcmp(get_param(fname,f{j}),v{j})
                        flag=false;
                        return;
                    end
                end
            end
        end


        function flag=inChart(~,fname)
            flag=false;
            if strcmp(get_param(fname,'Type'),'block_diagram')
                return;
            end

            parentfname=get_param(fname,'Parent');
            if~strcmp(get_param(parentfname,'Type'),'block_diagram')&&strcmp(get_param(parentfname,'SFBlockType'),'Chart')
                flag=true;
            end
        end

        function checkSLinChart(this,result)
            for i=1:length(result)
                for j=1:length(result{i})
                    fname=result{i}{j};
                    if slEnginePir.CloneRefactor.inChart(this,fname)
                        this.excluded_sysclone(fname)='Inside stateflow chart.';
                    end
                end
            end
        end




        function checkSampleTimeCallFcn(this,result)
            for i=1:length(result)
                for j=1:length(result{i})
                    fname=result{i}{j};
                    if~strcmp(get_param(fname,'Type'),'block_diagram')
                        if~strcmp(get_param(fname,'SystemSampleTime'),'-1')

                            this.excluded_sysclone(fname)='Has explicit sample time.';
                            continue;
                        end

                        if(this.considerCallbacks)

                            allFnames=find_system(fname,'MatchFilter',@Simulink.match.allVariants,...
                            'IncludeCommented','on','LookUnderMasks','all');
                            [flag,blkname,paraname]=slEnginePir.hasCallBackFcn(allFnames);
                            if flag

                                this.excluded_sysclone(fname)=['Has explicit callback functions: ',blkname,' : ',paraname];
                            end
                        end
                    end
                end
            end
        end






        function checkTriggerPortsInMdlRef(this,allCloneCandidates)
            for i=1:length(allCloneCandidates)
                for j=1:length(allCloneCandidates{i})
                    fCloneCandidate=allCloneCandidates{i}{j};
                    if strcmp(get_param(fCloneCandidate,'Type'),'block_diagram')
                        [this.excluded_sysclone,~]=slEnginePir.excludedSyswithTriggerPorts(this.excluded_sysclone,fCloneCandidate,fCloneCandidate);
                    end
                end
            end
        end


        function result=removeExcluded_sysclone(this,result)

            prefixname=this.genmodelprefix;
            dissimilarity=this.cloneresult.dissimiliarty;
            i=1;
            lenI=length(result);
            while i<=lenI
                j=1;
                lenJ=length(result{i});
                while j<=lenJ
                    fname=result{i}{j};
                    if isKey(this.excluded_sysclone,fname)
                        result{i}(j)=[];
                        lenJ=lenJ-1;
                    elseif~strcmp(get_param(slEnginePir.util.getValidBlockPath(prefixname,fname),'Type'),'block_diagram')&&...
                        (strcmp(get_param(slEnginePir.util.getValidBlockPath(prefixname,fname),'LinkStatus'),'resolved')||...
                        strcmp(get_param(slEnginePir.util.getValidBlockPath(prefixname,fname),'LinkStatus'),'implicit'))&&...
                        isempty(get_param(slEnginePir.util.getValidBlockPath(prefixname,fname),'linkdata'))
                        result{i}(j)=[];
                        lenJ=lenJ-1;
                    else
                        j=j+1;
                    end
                end

                if isempty(result{i})||(this.isReplaceExactCloneWithSubsysRef&&~isempty(dissimilarity{i}))
                    result(i)=[];
                    dissimilarity(i)=[];
                    lenI=lenI-1;
                else
                    i=i+1;
                end
            end
        end


        function fname=getmdlrefBlocks(this,fname)
            tmpfname=[];
            ind=1;
            for i=1:length(this.refBlocksModels)
                cur=this.refBlocksModels(i);
                if strcmp(fname,cur.refmdl{1})
                    tmpfname{ind}=cur.block;
                    ind=ind+1;
                end
            end
            if(ind>1)
                fname=tmpfname;
            end
        end



        function flag=hasSameInOutPortName(~,fname,refblocks)
            flag=true;
            srcInName=find_system(fname,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'regexp','on','blocktype','Inport');
            dstInName=find_system(refblocks,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'regexp','on','blocktype','Inport');

            if length(srcInName)~=length(dstInName)
                flag=false;
                return
            end

            if length(srcInName)>=1
                srcInName=get_param(srcInName,'Name');
                dstInName=get_param(dstInName,'Name');

                for i=1:length(srcInName)
                    name=srcInName{i};
                    if isempty(find(strcmp(name,dstInName(:)),1))
                        flag=false;
                        return;
                    end
                end
            end


            srcOutName=find_system(fname,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'regexp','on','blocktype','Outport');
            dstOutName=find_system(refblocks,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'regexp','on','blocktype','Outport');

            if length(srcOutName)~=length(dstOutName)
                flag=false;
                return
            end

            if length(srcOutName)>=1
                srcOutName=get_param(srcOutName,'Name');
                dstOutName=get_param(dstOutName,'Name');

                for i=1:length(srcOutName)
                    name=srcOutName{i};
                    if isempty(find(strcmp(name,dstOutName(:)),1))
                        flag=false;
                        return;
                    end
                end
            end
        end



        function isCloneReplaced=updateModelRef(this,aMdlName,aRefBlocks,aOrigMdlName,clonegroupID,replaceWithOriginal)

            isCloneReplaced=true;
            if~strcmp(this.clonepattern,'StructuralParameters')
                [parameterNames,parameterValue]=slEnginePir.CloneRefactor.getstructParameterNameValue(this,aOrigMdlName,clonegroupID,replaceWithOriginal);
            end


            list_of_block_in_subsystem=find_system(aMdlName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','BlockType','SubSystem');
            reflen=length(this.refBlocksModels);
            for m=1:reflen
                for n=1:length(this.refBlocksModels(m).refmdl)
                    refmodel=this.refBlocksModels(m).refmdl{n};
                    if strcmp(refmodel,aMdlName)
                        refBlock=char(this.refBlocksModels(m).refmdl{n});
                    end
                end
            end
            temporaryValidBlockPath=slEnginePir.util.getTemporaryValidBlockPath(this.genmodelprefix,refBlock);
            temp_blocks=find_system(temporaryValidBlockPath,'SearchDepth',1);
            bh=[];
            for i=2:length(temp_blocks)
                bh=[bh,get_param(temp_blocks{i},'handle')];
            end
            Simulink.BlockDiagram.createSubsystem(bh);
            temp_blocks=find_system(temporaryValidBlockPath,'SearchDepth',1,'BlockType','SubSystem');
            set_param(temp_blocks{1},'Name',get_param(aRefBlocks,'Name'));


            Simulink.BlockDiagram.deleteContents(aMdlName);


            mdlRefblock=add_block(aRefBlocks,[aMdlName,'/',get_param(aRefBlocks,'Name')]);


            if~strcmp(this.clonepattern,'StructuralParameters')
                for i=1:length(parameterNames)
                    try
                        set_param(mdlRefblock,parameterNames{i},parameterValue{i});
                    catch

                        this.excluded_sysclone(aMdlName)=[parameterNames{i},' cannot set the value as it is promoted, exclude for replacement.'];


                        slEnginePir.undoModelRefactor({aMdlName},this.genmodelprefix);
                        isCloneReplaced=false;
                        return;
                    end
                end
            end














            LGap=50;
            RGap=50;
            UpdowGap=50;
            pos=get_param(mdlRefblock,'Position');
            inpos=pos;
            inpos(3)=inpos(1)-LGap;



            prefixname=this.genmodelprefix;
            portsName=find_system(slEnginePir.util.getValidBlockPath(prefixname,aOrigMdlName),...
            'MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'regexp','on','blocktype','Inport');
            for i=1:length(portsName)
                [w,h]=slEnginePir.CloneRefactor.getBlocksize(this,portsName{i});
                inpos(1)=inpos(3)-w;
                inpos(4)=inpos(2)+h;
                mdlport=add_block(portsName{i},[aMdlName,'/',get_param(portsName{i},'Name')],'Position',inpos);
                inpos(2)=inpos(4)+UpdowGap;
                add_line(aMdlName,[get_param(mdlport,'Name'),'/','1'],[get_param(mdlRefblock,'Name'),'/',int2str(i)],'autorouting','on');
            end

            outpos=pos;
            outpos(1)=pos(3)+RGap;
            portsName=find_system(slEnginePir.util.getValidBlockPath(prefixname,aOrigMdlName),...
            'MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'regexp','on','blocktype','Outport');
            for i=1:length(portsName)
                [w,h]=slEnginePir.CloneRefactor.getBlocksize(this,portsName{i});
                outpos(3)=outpos(1)+w;
                outpos(4)=outpos(2)+h;
                mdlport=add_block(portsName{i},[aMdlName,'/',get_param(portsName{i},'Name')],'Position',outpos);
                outpos(2)=outpos(4)+UpdowGap;
                add_line(aMdlName,[get_param(mdlRefblock,'Name'),'/',int2str(i)],[get_param(mdlport,'Name'),'/','1'],'autorouting','on');
            end

            if slfeature('NestedCloneRefactoring')~=0


                list_of_block_in_subsystem1=find_system(aMdlName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','BlockType','SubSystem');
                temporaryValidBlockPath=slEnginePir.util.getTemporaryValidBlockPath(this.genmodelprefix,aMdlName);
                list_of_block_in_temp_subsystem=find_system(temporaryValidBlockPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','FollowLinks','on','BlockType','SubSystem');
                key=keys(replaceWithOriginal);
                for n=length(list_of_block_in_subsystem):-1:1
                    for m=1:length(replaceWithOriginal)
                        temp=replace(char(key(m)),list_of_block_in_subsystem{n},list_of_block_in_subsystem1{n+1});
                        val=replaceWithOriginal(char(key(m)));
                        remove(replaceWithOriginal,key(m));
                        replaceWithOriginal(temp)=val;
                    end
                    key=keys(replaceWithOriginal);
                end

                diffbp=this.creator.differentBlockParamName;
                for n=length(list_of_block_in_subsystem):-1:1
                    if(~strcmp(list_of_block_in_subsystem{n},list_of_block_in_subsystem1{n+1}))
                        for l=1:length(diffbp)
                            subStrPos=strfind(diffbp(l).Block,list_of_block_in_subsystem{n});
                            resN=diffbp(l).Block;
                            if~isempty(subStrPos)&&...
                                (length(list_of_block_in_subsystem{n})==length(diffbp(l).Block)||...
                                strcmp(resN(1+length(list_of_block_in_subsystem{n})),'/'))
                                diffbp(l).Block=replace(diffbp(l).Block,list_of_block_in_subsystem{n},list_of_block_in_subsystem1{n+1});
                            end
                            for k=1:length(diffbp(l).MappedBlocks)
                                subStrPos=strfind(diffbp(l).MappedBlocks{k},list_of_block_in_subsystem{n});
                                resN=diffbp(l).MappedBlocks{k};
                                if~isempty(subStrPos)&&...
                                    (length(list_of_block_in_subsystem{n})==length(diffbp(l).Block)||...
                                    strcmp(resN(1+length(list_of_block_in_subsystem{n})),'/'))
                                    diffbp(l).MappedBlocks{k}=replace(diffbp(l).MappedBlocks{k},list_of_block_in_subsystem{n},list_of_block_in_subsystem1{n+1});
                                end
                            end
                        end

                        newName=get_param(list_of_block_in_subsystem1{n+1},'Name');
                        set_param(list_of_block_in_temp_subsystem{n+1},'Name',newName);

                        for m=1:length(this.cloneresult.lib)
                            if(~isempty(this.cloneresult.lib{m}))
                                this.cloneresult.lib{m}=replace(this.cloneresult.lib{m},list_of_block_in_subsystem{n},list_of_block_in_subsystem1{n+1});
                            end
                        end
                        for m=1:length(this.cloneresult.Before)
                            res=this.cloneresult.Before{m};
                            for i=1:length(res)
                                subStrPos=strfind(char(res(i)),list_of_block_in_subsystem{n});
                                resN=char(res(i));
                                if~isempty(subStrPos)&&...
                                    (length(list_of_block_in_subsystem{n})==length(char(res(i)))||...
                                    strcmp(resN(1+length(list_of_block_in_subsystem{n})),'/'))
                                    res(i)={replace(char(res(i)),list_of_block_in_subsystem{n},list_of_block_in_subsystem1{n+1})};

                                end
                            end
                            this.cloneresult.Before{m}=res;
                        end
                    end
                end
                this.creator.differentBlockParamName=diffbp;

                if(~strcmp(this.clonepattern,'StructuralParameters')&&isempty(parameterValue))
                    diffbp=this.creator.differentBlockParamName;
                    key=keys(replaceWithOriginal);
                    for k=1:length(key)
                        if(slEnginePir.isParent(aMdlName,char(key(k))))
                            [parameterNames1,parameterValue1]=slEnginePir.CloneRefactor.getstructParameterNameValue(this,char(key(k)),replaceWithOriginal(char(key(k))),replaceWithOriginal);
                            for l=1:length(parameterNames1)
                                if(~strcmp(get_param(char(key(k)),parameterNames1{l}),parameterValue1{l}))
                                    try
                                        set_param(char(key(k)),parameterNames1{l},parameterValue1{l});
                                    catch
                                        this.excluded_sysclone(char(key(k)))=[parameterNames1{l},' cannot set the value as it is promoted.'];
                                        isCloneReplaced=false;
                                        slEnginePir.undoModelRefactor({aMdlName},this.genmodelprefix);
                                        for j=1:length(key)
                                            if(slEnginePir.isParent(aMdlName,char(key(j))))
                                                remove(replaceWithOriginal,key(j));
                                            end
                                        end
                                        for n=length(list_of_block_in_subsystem):-1:1
                                            if(~strcmp(list_of_block_in_subsystem{n},list_of_block_in_subsystem1{n+1}))
                                                for m=1:length(diffbp)
                                                    diffbp(m).Block=replace(diffbp(m).Block,list_of_block_in_subsystem1{n+1},list_of_block_in_subsystem{n});
                                                    for p=1:length(diffbp(m).MappedBlocks)
                                                        diffbp(m).MappedBlocks{p}=replace(char(diffbp(m).MappedBlocks{p}),list_of_block_in_subsystem1{n+1},list_of_block_in_subsystem{n});
                                                    end
                                                end
                                                for m=1:length(this.cloneresult.lib)
                                                    if(~isempty(this.cloneresult.lib{m}))
                                                        this.cloneresult.lib{m}=replace(this.cloneresult.lib{m},list_of_block_in_subsystem1{n+1},list_of_block_in_subsystem{n});
                                                    end
                                                end
                                            end
                                        end
                                        return;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end









