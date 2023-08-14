function[blks,sigs]=filterHighlightPath(sliceSubsystemH,blks,sigs,dir,sliceIR)









    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    srcP=[];
    dstP=[];

    if Simulink.SubsystemType.isModelBlock(sliceSubsystemH)
        sysH=get_param(get_param(sliceSubsystemH,'ModelName'),'Handle');
    else
        sysH=sliceSubsystemH;
    end

    if any(strcmp(dir,{'back','either'}))
        inpBlkH=find_system(sysH,'FindAll','on','LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'RegExp','on','BlockType','Inport|InportShadow');

        for n=1:length(inpBlkH)
            ph=get_param(inpBlkH(n),'PortHandles');
            [pHs,bHs]=getActualBlockAndPortHandle(ph.Outport(1),'dst');
            for m=1:length(pHs)
                if ismember(bHs(m),blks)
                    srcP(end+1)=ph.Outport(1);%#ok<AGROW>
                    dstP(end+1)=pHs(m);%#ok<AGROW>
                end
            end
        end
    end
    if any(strcmp(dir,{'forward','either'}))
        outpBlkH=find_system(sysH,'FindAll','on','LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'BlockType','Outport');
        for n=1:length(outpBlkH)
            ph=get_param(outpBlkH(n),'PortHandles');
            [pHs,bHs]=getActualBlockAndPortHandle(ph.Inport(1),'src');
            for m=1:length(pHs)
                if ismember(bHs(m),blks)
                    srcP(end+1)=pHs(m);%#ok<AGROW>
                    dstP(end+1)=ph.Inport(1);%#ok<AGROW>
                end
            end
        end
    end
    sigs.src=[sigs.src,srcP];
    sigs.dst=[sigs.dst,dstP];

    function[pHs,bHs]=getActualBlockAndPortHandle(inph,dir)



        pHs=[];
        bHs=[];
        ppObj=get(inph,'Object');
        if strcmpi(dir,'src')
            aSrc=ppObj.getActualSrc;
            pph=aSrc(:,1);
        else
            aaDst=ppObj.getActualDst;
            pph=aaDst(:,1);
        end
        for k=1:length(pph)
            parentBH=get(pph(k),'ParentHandle');
            parentBObj=get(parentBH,'Object');
            if parentBObj.isSynthesized


                pHs_rec=[];
                bHs_rec=[];
                if strcmpi(dir,'src')
                    if~isempty(parentBObj.PortHandles.Inport)
                        [pHs_rec,bHs_rec]=getActualBlockAndPortHandle(parentBObj.PortHandles.Inport(1),dir);
                    end
                else
                    if~isempty(parentBObj.PortHandles.Outport)
                        [pHs_rec,bHs_rec]=getActualBlockAndPortHandle(parentBObj.PortHandles.Outport(1),dir);
                    end
                end
                pHs=[pHs,pHs_rec];%#ok<AGROW>
                bHs=[bHs,bHs_rec];%#ok<AGROW>
            else
                pHs(end+1)=pph(k);%#ok<AGROW>
                bHs(end+1)=parentBH;%#ok<AGROW>
                if strcmpi(dir,'dst')&&Simulink.SubsystemType.isModelBlock(parentBH)




                    [succPHs,succBlks]=getSuccessorFromIR(pph(k));
                    pHs=[pHs,succPHs];%#ok<AGROW>
                    bHs=[bHs,succBlks];%#ok<AGROW>
                end
            end
        end
    end
    function[succPHs,succBlks]=getSuccessorFromIR(inpH)
        id=sliceIR.dfgInportHToInputIdx(inpH);
        succV=sliceIR.dfg.succ(MSUtils.graphVertices(id));
        succPHs=[];
        for i=1:length(succV)
            v=succV(i);
            if isKey(sliceIR.dfgInputIdxToInportH,v.vId)

                succPHs(end+1)=sliceIR.dfgInputIdxToInportH(v.vId);%#ok<AGROW>
            end
        end
        succBlks=arrayfun(@(p)get_param(p,'ParentHandle'),succPHs);
    end
end
