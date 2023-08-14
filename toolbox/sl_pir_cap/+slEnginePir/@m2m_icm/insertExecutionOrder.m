
function errMsg=insertExecutionOrder(this)



    subsysWithFcnCallers=keys(this.fSS2FcnCallMap);
    touchedMdls={};
    for sIdx=1:length(subsysWithFcnCallers)
        fcnCallers=this.fSS2FcnCallMap(subsysWithFcnCallers{sIdx});
        sortedFcnCallers=sortExecutionOrder(fcnCallers);
        if this.fTestMode==1
            ori_sortedFcnCallers=sortedFcnCallers;
            if isKey(this.tSortedFcnCallerMap,subsysWithFcnCallers)
                sortedFcnCallers=this.tSortedFcnCallerMap(subsysWithFcnCallers{sIdx});
            else
                sortedFcnCallers={};
            end
            this.tSortedFcnCallerMap(subsysWithFcnCallers{sIdx})=ori_sortedFcnCallers;
        end
        if length(sortedFcnCallers)>1
            touchedMdls=[touchedMdls,bdroot(subsysWithFcnCallers)];%#ok
            specifyOrder(subsysWithFcnCallers{sIdx},sortedFcnCallers);
        end
    end
    touchedMdls=unique(touchedMdls);
    for mIdx=1:length(touchedMdls)
        save_system(touchedMdls{mIdx},[this.fXformDir,touchedMdls{mIdx}],'SaveDirtyReferencedModels','on');
    end
end

function sortedFcnCallers=sortExecutionOrder(aFcnCallers)
    sortedFcnCallers={};
    seq2FcnCallMap=containers.Map('KeyType','double','ValueType','char');
    for fIdx=1:length(aFcnCallers)
        tag=get_param(aFcnCallers{fIdx},'Tag');
        tagElements=strsplit(tag,';');
        seqIdx=find(contains(tagElements,'sequenceNumber='),1);
        if~isempty(seqIdx)
            tagInfo=strsplit(tagElements{seqIdx},'''');
            seqInfo=strsplit(tagInfo{2},':');
            base=1;
            seqID=0;
            for sIdx=1:length(seqInfo)
                seqID=seqID+str2num(seqInfo{sIdx})*base;
                base=base*0.001;
            end
            seq2FcnCallMap(seqID)=aFcnCallers{fIdx};
        end
    end

    seqIDs=cell2mat(keys(seq2FcnCallMap));
    while~isempty(seqIDs)
        minID=min(seqIDs);
        sortedFcnCallers=[sortedFcnCallers,seq2FcnCallMap(minID)];%#ok
        seqIDs(seqIDs==minID)=[];
    end
end

function specifyOrder(aSubsystem,aSortedFcnCallers)
    for fIdx=1:length(aSortedFcnCallers)
        ssName=get_param(aSortedFcnCallers{fIdx},'Name');
        sid=Simulink.ID.getSID(aSortedFcnCallers{fIdx});
        Simulink.BlockDiagram.createSubsystem(get_param(aSortedFcnCallers{fIdx},'handle'));
        scheduleSS=get_param(sid,'Parent');
        set_param(scheduleSS,'TreatAsAtomicUnit','on');
        set_param(scheduleSS,'RTWSystemCode','Inline');
        set_param(scheduleSS,'Name',ssName);
        scheduleSS=aSortedFcnCallers{fIdx};
        pos=get_param(sid,'Position');
        add_block('built-in/Inport',[scheduleSS,'/scheduleIn'],...
        'Position',[pos(1),pos(4)+50,pos(1)+30,pos(4)+65]);
        add_block('built-in/Outport',[scheduleSS,'/scheduleOut'],...
        'Position',[pos(3)-30,pos(4)+50,pos(3),pos(4)+65]);
        add_line(scheduleSS,'scheduleIn/1','scheduleOut/1');
        ports=get_param(scheduleSS,'PortHandles');
        pIdxI=length(ports.Inport);
        pIdxO=length(ports.Outport);
        posSchedIn=get_param(ports.Inport(end),'Position');
        posSchedOut=get_param(ports.Outport(end),'Position');

        posFrom=[posSchedIn(1)-40,posSchedIn(2)-15,posSchedIn(1)-10,posSchedIn(2)+15];
        posGoto=[posSchedOut(1)+10,posSchedOut(2)-15,posSchedOut(1)+40,posSchedOut(2)+15];
        pathFrom=[aSubsystem,'/initCaller',num2str(fIdx)];
        pathGoto=[aSubsystem,'/endCaller',num2str(fIdx)];
        tag=['activateCaller',num2str(fIdx)];
        if fIdx==1
            add_block('built-in/Ground',pathFrom,'Position',posFrom);
        else
            add_block('built-in/From',pathFrom,'GotoTag',tag,'Position',posFrom);
        end
        add_line(aSubsystem,['initCaller',num2str(fIdx),'/1'],[ssName,'/',num2str(pIdxI)]);

        tag=['activateCaller',num2str(fIdx+1)];
        if fIdx==length(aSortedFcnCallers)
            add_block('built-in/Terminator',pathGoto,'Position',posGoto);
        else
            add_block('built-in/Goto',pathGoto,'GotoTag',tag,'Position',posGoto);
        end
        add_line(aSubsystem,[ssName,'/',num2str(pIdxO)],['endCaller',num2str(fIdx),'/1']);
    end
end
