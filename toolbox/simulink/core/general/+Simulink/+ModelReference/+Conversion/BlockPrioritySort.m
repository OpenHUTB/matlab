classdef BlockPrioritySort<handle
    properties(SetAccess=private,GetAccess=public)
sortedBlockNames
Systems
isExportedFcn
isSS2mdlForPLC
    end
    properties(SetAccess=private,GetAccess=private,Hidden,Transient=true)
blkVec
blkSortedNames
    end

    methods(Access=public)
        function this=BlockPrioritySort(Systems,isExportedFcn,isSS2mdlForPLC)
            this.Systems=Systems;
            this.isExportedFcn=isExportedFcn;
            this.isSS2mdlForPLC=isSS2mdlForPLC;
        end

        function sort(this)
            arrayfun(@(block_hdl)this.getSortedBlockNames(block_hdl),this.Systems);
            assert(numel(this.blkVec)==numel(this.blkSortedNames));
            if~isempty(this.blkVec)
                this.sortedBlockNames=containers.Map(this.blkVec,this.blkSortedNames);
            end
        end

        function[error_occ,mExc]=resetBlockPriority(this,block_hdl,mdl_hdl,isCopyContent)
            newModelName=get_param(mdl_hdl,'Name');
            parentPath=get_param(block_hdl,'Parent');
            sourceSubsystemName=getfullname(block_hdl);
            error_occ=0;
            mExc=[];
            sortedBlkNames=this.sortedBlockNames(block_hdl);
            sortedBlkNames=sortedBlkNames{:};
            if~this.isExportedFcn&&(length(sortedBlkNames)>1)
                pathLength=length(sourceSubsystemName)+1;
                if isCopyContent
                    newPath=newModelName;
                else
                    newBlkH=find_system(newModelName,'SearchDepth','1','BlockType','SubSystem');
                    assert(numel(newBlkH)==1&&iscell(newBlkH));
                    newBlkH=newBlkH{:};
                    newPath=[newModelName,'/',strrep(get_param(newBlkH,'Name'),'/','//')];
                end
                newBlkNames=cellfun(@(blkName)([newPath,blkName(pathLength:end)]),...
                sortedBlkNames,'UniformOutput',false);
                [error_occ,mExc]=this.setBlockListPriority(newBlkNames);
            end
        end
    end

    methods(Access=private)
        function[error_occ,mExc]=getSortedBlockNames(this,block_hdl)
            if~this.isExportedFcn

                [sortedBlksInVSS,error_occ,mExc]=this.getBlockList(block_hdl);












                nonVirtualSubsystem=slprivate('getNonVirtualSystem',block_hdl);

                sortedBlks=get_param(nonVirtualSubsystem,'SortedList');



                sortedBlkNames=[];
                for bIdx=1:length(sortedBlks)
                    sortedBlock=sortedBlks(bIdx);
                    if~slprivate('blockShouldNotHavePriority',sortedBlock)


                        inVSS=false;
                        for k=1:length(sortedBlksInVSS)
                            if sortedBlock==get_param(sortedBlksInVSS{k},'Handle')
                                inVSS=true;
                                break;
                            end
                        end
                        if inVSS
                            sortedBlkNames{end+1}=getfullname(sortedBlock);
                        end
                    end
                end
                assert(length(sortedBlkNames)<=length(sortedBlks));
                this.blkVec(end+1)=block_hdl;
                this.blkSortedNames{end+1}=sortedBlkNames;
            end
        end



        function[sortedNames,error_occ,mExc]=getBlockList(this,block_hdl)
            error_occ=0;
            mExc=[];
            sortedNames={};

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            c1=onCleanup(@()delete(sess));
            try
                obj=get_param(block_hdl,'Object');
                ssPath=[obj.parent(),'/',obj.name(),'/'];
                ssType=Simulink.SubsystemType(block_hdl);
                if~ssType.isVirtualSubsystem()&&~this.isSS2mdlForPLC
                    return;
                end
                while ssType.isVirtualSubsystem()&&~strcmp('on',obj.get('Commented'))
                    ssH=obj.getCompiledParent();
                    ssType=Simulink.SubsystemType(ssH);
                    obj=get_param(ssH,'Object');
                end
                if~strcmp('block',obj.get('Type'))||~strcmp('on',obj.get('Commented'))

                    blks=get_param(obj.Handle,'SortedList');
                    inParent=arrayfun(@(blk)(this.localIsChildOf(blk,ssPath)),blks);
                    blks=blks(inParent);
                    includedBlks=arrayfun(@(blk)(...
                    this.includeInSortedList(blk,ssPath)),blks);
                    blks=unique(blks(includedBlks),'stable');
                    sortedNames=arrayfun(...
                    @(blk)([get_param(blk,'Parent'),'/',...
                    strrep(get_param(blk,'Name'),'/','//')]),...
                    blks,'UniformOutput',false);
                end
            catch mExc
                error_occ=1;
            end
        end



        function retValue=localIsChildOf(~,aBlkH,aSysPath)
            blockPath=[get_param(aBlkH,'Parent'),'/'];
            sysPathLengh=length(aSysPath);
            if length(blockPath)>=sysPathLengh
                retValue=strncmp(blockPath,aSysPath,sysPathLengh);
            else
                retValue=false;
            end
        end







        function retValue=includeInSortedList(this,aBlkH,aSysPat)
            blkObj=get_param(aBlkH,'Object');
            retValue=(~blkObj.isSynthesized()...
            &&strcmp(blkObj.virtual,'off')...
            &&(~blkObj.isa('Simulink.RateTransition')...
            ||strcmp(blkObj.Integrity,'on')));
            blkT={'DataStoreRead','DataStoreWrite'};
            if retValue&&~this.isSS2mdlForPLC&&~any(strcmp(blkObj.BlockType,blkT))
                ports=get(aBlkH,'Ports');
                numOutputPorts=ports(2);
                retValue=numOutputPorts>0&&this.drivesRootOutput(aBlkH,aSysPat);
            end
        end




        function result=drivesRootOutput(this,aBlkH,aSysPat)
            ph=get_param(aBlkH,'PortHandles');
            result=false;
            for i=1:length(ph.Outport)
                pO=get_param(ph.Outport(i),'Object');
                dst=pO.getActualDst;
                for j=1:size(dst,1)
                    dstP=dst(j,1);
                    sysB=get_param(dstP,'ParentHandle');
                    if~this.localIsChildOf(sysB,aSysPat)
                        result=true;
                        return;
                    end
                end
            end
        end




        function[error_occ,mExc]=setBlockListPriority(~,aBlockNames)
            error_occ=0;
            mExc=[];
            oldf=slfeature('SetParamOnLinks',0);
            c1=onCleanup(@()slfeature('SetParamOnLinks',oldf));
            try
                numSortedBlks=length(aBlockNames);
                if numSortedBlks>1
                    slRoot=Simulink.Root();
                    for blkIdx=1:numSortedBlks
                        blkName=aBlockNames{blkIdx};
                        if slRoot.isValidSlObject(blkName)
                            blkH=get_param(blkName,'Handle');
                            assert(strcmp('block',get_param(blkH,'Type')));
                            if~slprivate('blockShouldNotHavePriority',blkH)
                                set_param(blkH,'Priority',int2str(blkIdx));
                            end
                        end
                    end
                end
            catch mExc
                error_occ=1;
            end
        end
    end
end
