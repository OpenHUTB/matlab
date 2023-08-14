classdef SeedHandler<handle




    properties(Access=private,Hidden=true)
        userVirtStartToActSrc=[];
        userVirtStartToActDst=[];
        srcInportToActualSrcMap=[];
        userStarts=struct('handle',{},'busElementPath',{});
        userExclusions=[];
    end

    methods(Access=public)
        function[elements,invalidHandle]=getUserStarts(this)




            import slslicer.internal.*
            [elements,invalidHandle]=...
            convertToStartFormat(this.userStarts);
        end



        function[elements,invalidHandle]=getUserExclusions(this)

            elementsHandle=this.userExclusions;
            [elements,invalidHandle]=slslicer.internal.convertToExclusionFormat(elementsHandle);
        end


        function bh=getVirtualStarts(this,sc)




            allMaps=this.getVirtualToDFGMap(sc);
            bh=allMaps.keys;
            if iscell(bh)
                bh=[bh{:}];
            end
        end


        function[status,mex]=updateUserStartsFromStruct(this,elements,sc)










            sc.dirty=true;
            sc.clearAllStartingPoints();
            status=false;
            mex=[];
            invalidBlk=[];
            invalidSig=[];
            mdl=sc.modelSlicer.model;
            for i=1:length(elements)
                sig=elements(i);
                busElemPath=[];
                if isfield(sig,'BusElementPath')
                    busElemPath=sig.BusElementPath;
                end
                SID=slslicer.internal.addTopModelNameInSID(sig.SID,mdl);
                try
                    switch sig.Type
                    case 'signal'
                        ph=get_param(slslicer.internal.getBlkHFromID(SID),'PortHandles');
                        sig.Handle=ph.Outport(sig.PortNumber);
                        [out,msg]=this.addStart(sc,sig.Handle,busElemPath);
                        if~out&&ismember(msg,{'InvalidVirtualPort'})
                            invalidSig(end+1)=sig.Handle;%#ok<AGROW>
                        end
                    case 'block'
                        bh=slslicer.internal.getBlkHFromID(SID);
                        [out,msg]=this.addStart(sc,bh,busElemPath);
                        if~out&&ismember(msg,{'InvalidVirtualBlock'})
                            invalidBlk(end+1)=bh;%#ok<AGROW>
                        end
                    otherwise
                        error('SliceCriterion:UnknownType',...
                        getString(message('Sldv:ModelSlicer:gui:UnknownElementType')));
                    end
                catch Mex %#ok<NASGU>

                end
                this.handleInvalidStartingPoints(sc,invalidBlk,invalidSig)
            end
        end


        function[validelements,invalidelements]=updateUserExclusionsFromStruct(this,exelements,sc)



            excls=[];
            invalidelements=[];
            validelements=[];
            mdl=sc.modelSlicer.model;
            for i=1:length(exelements)
                ex=exelements(i);
                SID=slslicer.internal.addTopModelNameInSID(ex.SID,mdl);
                try
                    bh=slslicer.internal.getBlkHFromID(SID);
                    excls(end+1)=bh;%#ok<AGROW>
                    validelements(end+1)=i;%#ok<AGROW>
                catch Mex %#ok<NASGU>

                    invalidelements(end+1)=i;%#ok<AGROW>
                end
            end
            sc.dirty=true;
            this.userExclusions=excls;
        end
    end


    methods(Access=private)

        function removeStartUsingDFGIR(this,sc,objH)

            allMaps=this.getVirtualToDFGMap(sc);
            for index=1:length(objH)
                tempobjh=objH(index);
                if isKey(allMaps,tempobjh)

                    remove(this.userVirtStartToActDst,tempobjh);
                    remove(this.userVirtStartToActSrc,tempobjh);
                end
            end
        end

        function[status,msg]=addBusElementStart(this,...
            sc,startHandle,busElementPath)
            busElementStarts=this.getUserBusElementStarts;
            numOfBusElementStarts=length(busElementStarts);

            for i=1:numOfBusElementStarts
                busElement=busElementStarts(i);
                if busElement.handle==startHandle&&...
                    strcmp(busElement.busElementPath,busElementPath)
                    status=false;
                    msg={'StartAddedAlready'};
                    return;
                end
            end


            busElementStart=struct('handle',startHandle,...
            'busElementPath',busElementPath);
            this.userStarts=[this.userStarts,busElementStart];
            msg={'ValidDFGBlock'};
            sc.dirty=true;
            status=true;
        end

        function[status,msg]=addStartUsingDFGIREq(this,...
            sc,startHandle,busElementPath)
            if~isempty(startHandle)&&~isempty(busElementPath)
                [status,msg]=this.addBusElementStart(sc,...
                startHandle,busElementPath);
                return;
            end
            status=true;
            msg=cell(1,length(startHandle));
            currentUserExclusion=this.userExclusions;
            for i=1:length(startHandle)
                handle=startHandle(i);
                if strcmpi(get(startHandle(i),'type'),'line')
                    handle=get(handle,'SrcPortHandle');
                end
                if ismember(handle,this.getFullElementStartHandles)
                    status=false;
                    msg{i}='StartAddedAlready';
                elseif ismember(handle,currentUserExclusion)
                    status=false;
                    msg{i}='ExclusionCannotBeAddedAsStart';
                elseif isOwnerInactive(handle,sc.modelSlicer)



                    status=false;
                    msg{i}='InactiveHandle';
                else
                    msg{i}='ValidDFGBlock';

                    userStart=struct('handle',handle,...
                    'busElementPath',[]);
                    this.userStarts=[this.userStarts,userStart];
                    sc.dirty=true;
                end
            end
        end

        function[status,msg]=addStartUsingDFGIR(this,sc,startHandle)
            status=true;
            msg=cell(1,length(startHandle));
            currentUserExclusion=this.userExclusions;
            for i=1:length(startHandle)
                currentUserStarts=this.getFullElementStartHandles;
                if~ishandle(startHandle(i))
                    status=false;
                    msg{i}='InvalidHandle';
                    continue;
                end
                startH=startHandle(i);
                if strcmpi(get(startH,'type'),'line')

                    expectStart=get(startH,'SrcPortHandle');
                else
                    expectStart=startH;
                end

                if ismember(expectStart,currentUserStarts)
                    status=false;
                    msg{i}='StartAddedAlready';
                elseif ismember(expectStart,currentUserExclusion)
                    status=false;
                    msg{i}='ExclusionCannotBeAddedAsStart';
                else
                    [oStartH,info,suggest]=slslicer.internal.checkStart(sc.modelSlicer,startH,sc.direction);
                    msg{i}=info;
                    if ishandle(oStartH)
                        userStart=struct('handle',oStartH,...
                        'busElementPath',[]);
                        this.userStarts=[this.userStarts,userStart];
                        if strcmpi(msg{i},'ValidVirtualBlock')||strcmpi(msg{i},'ValidVirtualSignal')
                            this.updateVirtualMapping(startH,suggest);
                        end
                        sc.dirty=true;
                    else
                        status=false;
                    end
                end
            end
        end



        function elementsHandle=getDFGStartsFromUserStarts(this,sc)


            allMaps=this.getVirtualToDFGMap(sc);
            allVirtualStarts=allMaps.keys;
            allvirtualSeeds=[allVirtualStarts{:}];
            allnonvirtualStarts=...
            setdiff(this.getFullElementStartHandles,allvirtualSeeds);
            allDFGStarts=allMaps.values;
            allDFGStarts=cell2mat(allDFGStarts(:));
            allDFGStarts=reshape(allDFGStarts,[],1);
            elementsHandle=unique([allnonvirtualStarts';allDFGStarts]);
        end


        function busElementStarts=getUserBusElementStarts(this)

            import slslicer.internal.*
            allelements=this.userStarts;
            busElementStarts=allelements(...
            arrayfun(@(x)isBusElementSignal(x),allelements));

            function yesno=isBusElementSignal(element)
                yesno=~isempty(element.busElementPath);
            end
        end


        function startHandles=...
            getFullElementStartHandles(this)

            startHandles=[];
            allelements=this.userStarts;
            nonBusElementStarts=allelements(...
            arrayfun(@(x)~isBusElementSignal(x),allelements));

            if isempty(nonBusElementStarts)
                return;
            end

            startHandles=[nonBusElementStarts.handle];

            function yesno=isBusElementSignal(element)
                yesno=~isempty(element.busElementPath);
            end
        end



        function[elements,invalidHandle]=getDFGExclusions(this)




            elementsHandle=getDFGExclusionsFromUserExclusions(this);
            [elements,invalidHandle]=slslicer.internal.convertToExclusionFormat(elementsHandle);
        end


        function bh=getExclusionHandles(this)

            allterminals=this.getDFGExclusions;
            bh=[allterminals.Handle];
            bh=reshape(bh,numel(bh),1);
        end


        function elementsHandles=getDFGExclusionsFromUserExclusions(this)



            elementsHandles=this.userExclusions;
        end
    end

    methods(Access=public,Hidden=true)
        function out=getExclusionBlks(this)
            out=this.getExclusionHandles;
        end


        function yesno=hasValidStarts(this,sc)
            yesno=~isempty(this.getDFGStarts(sc));
        end


        function[elements,invalidHandle]=getDFGStarts(this,sc)


            import slslicer.internal.*
            elementsHandle=this.getDFGStartsFromUserStarts(sc);
            [elements,invalidHandle]=convertToStartFormat(elementsHandle);

            userBusElStarts=this.getUserBusElementStarts;
            elements=[elements,convertToStartFormat(userBusElStarts)];
        end


        function handleInvalidStartingPoints(this,sc,invalidBlk,invalidSig)









            this.removeStart([invalidBlk;invalidSig],sc);


            if sc.hasDialog
                modelslicerprivate('MessageHandler','open',sc.modelSlicer.model)
                Mex=MException('ModelSlicer:InvalidStartingPointIgnored',getString(message('Sldv:ModelSlicer:gui:InvalidStartingPoint')));
                for i=1:length(invalidBlk)
                    validHandle=true;
                    try
                        msg=['''',getfullname(invalidBlk(i)),''''];
                    catch ex
                        validHandle=false;
                        if strcmp(ex.identifier,'Simulink:Commands:InvSimulinkObjHandle')
                            msg=getString(message('Sldv:ModelSlicer:gui:DeletedBlock'));
                        else
                            msg=getString(message('Sldv:ModelSlicer:gui:UnknownReason'));
                        end
                    end
                    if validHandle&&~sc.modelSlicer.isTerminalBlock(invalidBlk(i))
                        subMex=MException('ModelSlicer:InvalidStartingPointBlock',msg);
                        Mex=Mex.addCause(subMex);
                    end
                end
                for i=1:length(invalidSig)
                    validHandle=true;
                    try
                        bPath=get(invalidSig(i),'Parent');
                        portNum=get(invalidSig(i),'PortNumber');
                        blockOwner=get(invalidSig(i),'ParentHandle');
                        msg=['''',bPath,':',portNum,''''];
                    catch ex
                        validHandle=false;
                        if strcmp(ex.identifier,'Simulink:Commands:InvSimulinkObjHandle')||strcmp(ex.identifier,'MATLAB:class:InvalidHandle')
                            msg=getString(message('Sldv:ModelSlicer:gui:DeletedSignal'));
                        else
                            msg=getString(message('Sldv:ModelSlicer:gui:UnknownReason'));
                        end
                    end
                    if validHandle&&~sc.modelSlicer.isTerminalBlock(blockOwner)
                        subMex=MException('ModelSlicer:InvalidStartingPointSignal',msg);
                        Mex=Mex.addCause(subMex);
                    end
                end
                if~isempty(Mex.cause)
                    modelslicerprivate('MessageHandler','warning',Mex,sc.modelSlicer.model)
                end
            else
                for i=1:length(invalidBlk)
                    validHandle=true;
                    try
                        msg=getString(message('Sldv:ModelSlicer:gui:InvalidStartingPointWarnBlk',getfullname(invalidBlk(i))));
                    catch ex %#ok<NASGU>
                        validHandle=false;
                        msg=getString(message('Sldv:ModelSlicer:gui:InvalidStartingPoint'));
                    end
                    if validHandle&&~sc.modelSlicer.isTerminalBlock(invalidBlk(i))
                        warning('ModelSlicer:InvalidStartingPointBlock',msg);
                    end
                end
                for i=1:length(invalidSig)
                    validHandle=true;
                    try
                        validHandle=false;
                        blockOwner=get(invalidSig(i),'ParentHandle');
                        msg=getString(message('Sldv:ModelSlicer:gui:InvalidStartingPointWarnSig',...
                        get(invalidSig(i),'PortNumber'),get(invalidSig(i),'Parent')));
                    catch ex %#ok<NASGU>
                        msg=getString(message('Sldv:ModelSlicer:gui:InvalidStartingPoint'));
                    end
                    if validHandle&&~sc.modelSlicer.isTerminalBlock(blockOwner)
                        warning('ModelSlicer:InvalidStartingPointSignal',msg);
                    end
                end
            end
        end

        function updateVirtualMapping(this,blkH,suggest)




            blkObj=get(blkH,'Object');
            if isa(blkObj,'Simulink.Segment')
                return;
            end
            this.userVirtStartToActSrc(blkH)=suggest.actSrc;
            this.userVirtStartToActDst(blkH)=suggest.actDst;

            if isfield(suggest,'srcInportToActualSrcMap')
                this.srcInportToActualSrcMap(blkH)=suggest.srcInportToActualSrcMap;
            end
        end


        function[bh,invalidHandle]=getStartBlockHandles(this,sc)

            [allelements,invalidHandle]=this.getDFGStarts(sc);
            blocks=arrayfun(@(x)strcmp(allelements(x).Type,'block'),...
            1:numel(allelements));
            bh=[allelements(blocks).Handle];
            bh=reshape(bh,numel(bh),1);
        end


        function[ph,invalidHandle]=getStartSignalHandles(this,sc)

            [allelements,invalidHandle]=this.getDFGStarts(sc);
            sigs=arrayfun(@(x)isNonBusElementSignal(x),allelements);
            bh=[allelements(sigs).Handle];
            ph=reshape(bh,numel(bh),1);

            function yesno=isNonBusElementSignal(element)
                yesno=strcmp(element.Type,'signal')&&...
                isempty(element.BusElementPath);
            end
        end


        function busElementStarts=getStartBusElements(this,sc)

            [allelements,~]=this.getDFGStarts(sc);
            busElementStarts=allelements(...
            arrayfun(@(x)isBusElementSignal(x),allelements));

            function yesno=isBusElementSignal(element)
                yesno=strcmp(element.Type,'signal')&&...
                ~isempty(element.BusElementPath);
            end
        end


        function out=getVirtualToDFGMap(this,sc)



            assert(ismember(lower(sc.direction),{'back','either','forward'}));

            switch lower(sc.direction)
            case{'back','either'}
                out=this.userVirtStartToActSrc;
            case 'forward'
                out=this.userVirtStartToActDst;
            otherwise

            end
        end


        function out=getSrcInportToActualSrcMap(this,vStartH)


            out=this.srcInportToActualSrcMap(vStartH);
        end
    end

    methods
        function obj=SeedHandler()
            obj.userVirtStartToActSrc=containers.Map('KeyType','double','ValueType','any');
            obj.userVirtStartToActDst=containers.Map('KeyType','double','ValueType','any');
            obj.srcInportToActualSrcMap=containers.Map('KeyType','double','ValueType','any');
            obj.userStarts=struct('handle',{},'busElementPath',{});
            obj.userExclusions=[];
        end

        function that=clone(this)
            that=slslicer.internal.SeedHandler();
            that.userStarts=this.userStarts;
            that.userExclusions=this.userExclusions;
        end


        function yesno=addConstraint(~,blockHandle,portNumbers,sc)




            blockSid=Simulink.ID.getSID(blockHandle);



            ph=get(blockHandle,'PortHandles');
            totalPorts=numel(ph.Inport);


            if(sc.constraints.isKey(blockSid))
                constrainedPorts=sc.constraints(blockSid);
                existingPortNumbers=constrainedPorts.PortNumbers;
                existingTotalPorts=constrainedPorts.TotalPorts;



                diff1=setdiff(existingPortNumbers,portNumbers);
                diff2=setdiff(portNumbers,existingPortNumbers);

                if isempty(diff1)&&isempty(diff2)&&...
                    (existingTotalPorts==totalPorts)

                    yesno=false;
                    return;
                end
            end


            yesno=true;
            sc.dirty=true;

            constrainedPorts=struct('PortNumbers',portNumbers,...
            'TotalPorts',totalPorts);
            sc.constraints(blockSid)=constrainedPorts;
        end


        function[status,msg]=addStart(this,sc,startHandle,varargin)





















            if nargin>3
                busElementPath=varargin{1};
            else
                busElementPath={};
            end
            if slfeature('NewSlicerBackend')
                [status,msg]=this.addStartUsingDFGIREq(sc,...
                startHandle,busElementPath);
            else
                [status,msg]=this.addStartUsingDFGIR(sc,startHandle);
            end
        end


        function out=getUserExclusionFromDFGSeed(dfgseed,sc)



            out=[];
            allmaps=this.getVirtualToDFGMap(sc);
            allkeys=allmaps.keys;
            for index=1:length(allkeys)
                ckey=allkeys{index};
                if ismember(dfgseed,allmaps(ckey))
                    out=[out,ckey];%#ok<AGROW>
                end
            end
        end


        function out=getUserStartFromDFGSeed(dfgseed,sc)



            out=[];
            allmaps=this.getVirtualToDFGMap(sc);
            allkeys=allmaps.keys;
            for index=1:length(allkeys)
                ckey=allkeys{index};
                if ismember(dfgseed,allmaps(ckey))
                    out=[out,ckey];%#ok<AGROW>
                end
            end
        end


        function changed=removeStart(this,objH,sc)



            changed=false;

            if isempty(objH)
                return;
            end

            idx=find(arrayfun(@(x)...
            ismember(x.handle,objH)&&isempty(x.busElementPath),...
            this.userStarts));

            changed=~isempty(idx);

            if changed
                this.userStarts(idx)=[];
                sc.dirty=true;
                if~slfeature('NewSlicerBackend')
                    this.removeStartUsingDFGIR(sc,objH);
                end
            end
        end


        function removeAllBusElementStarts(this,objH,sc)
            this.deleteBusElementStart(objH,'removeAll',sc);
        end


        function changed=removeExclusion(this,objH,sc)
            changed=false;
            bh=this.userExclusions;
            idx=ismember(bh,objH);

            if any(idx)
                this.userExclusions(idx)=[];
                sc.dirty=true;
                changed=true;
            end
        end


        function yesno=addExclusion(this,blockHandle,sc)
            bh=this.userExclusions;
            if~isempty(bh)&&(any(bh==blockHandle)||...
                isOwnerInactive(blockHandle,sc.modelSlicer))
                yesno=false;
            else
                this.userExclusions(end+1)=blockHandle;
                yesno=true;
                sc.dirty=true;
            end
        end

        function changed=removeConstraint(~,blockHandle,sc)
            blockSID=Simulink.ID.getSID(blockHandle);

            if(sc.constraints.isKey(blockSID))
                sc.dirty=true;
                changed=true;
                sc.constraints.remove(blockSID);
            else
                changed=false;
            end
        end


        function checkDeletedItems(this,sc)


            delIdxS=[];
            allelements=this.getDFGStarts(sc);
            for i=1:length(allelements)
                try
                    switch allelements(i).Type
                    case 'signal'
                        lh=get(allelements(i).Handle,'line');
                        if lh==-1
                            delIdxS(end+1)=i;%#ok<AGROW>
                        end
                    case 'block'
                        get(allelements(i).Handle,'type');
                    end
                catch Mex %#ok<NASGU>
                    delIdxS(end+1)=i;%#ok<AGROW>
                end
            end
            if~isempty(delIdxS)
                allelements(delIdxS)=[];
            end
            delIdxT=[];
            allexclusions=this.getUserExclusions();
            for i=1:length(allexclusions)
                try
                    get(allexclusions(i).Handle,'type');
                catch Mex %#ok<NASGU>
                    delIdxT(end+1)=i;%#ok<AGROW>
                end
            end
            if~isempty(delIdxT)
                sc.deleteExclusion(delIdxT);
            end
        end


        function[portBlks,allSrcP,allDstP]=utilForVirtualSubsystemHighlight(this,allSrcP,allDstP,sc)
            portBlks=[];
            if~isempty(this.getSubsystemInDFGStarts(sc))
                [portBlks,subsrcP,subdstP]=...
                slslicer.internal.virtual.getVirtualInfoInSubsys(sc,this.getDFGStartsFromUserStarts(sc));
                allSrcP=[allSrcP,subsrcP'];
                allDstP=[allDstP,subdstP'];
            end
        end


        function tf=hasVirtualStarts(this,sc)


            allmaps=this.userVirtStartToActSrc;
            tf=sc.modelSlicer.compiled&&allmaps.Count>0;
        end


        function[invalidblock,invalidline]=validateStarts(this,sc)
            startHandles=this.getFullElementStartHandles;
            [invalidblock,invalidline]=this.validateStartHandle(sc,startHandles);
        end

        function[invalidblock,invalidline]=validateStartHandle(this,sc,startHandle)







            invalidindex=[];
            invalidblock=[];
            invalidline=[];
            if sc.modelSlicer.compiled
                for index=1:length(startHandle)
                    [startH,blkinfo,suggest]=slslicer.internal.checkStart(sc.modelSlicer,startHandle(index),sc.direction);
                    if ishandle(startH)
                        if strcmpi(blkinfo,'ValidVirtualBlock')||strcmpi(blkinfo,'ValidVirtualSignal')
                            sc.dirty=true;
                            this.updateVirtualMapping(startHandle(index),suggest);
                        end
                    else
                        invalidindex(end+1)=index;%#ok<AGROW>
                        if ismember(blkinfo,{'InvalidVirtualBlock','InvalidHandle'})
                            invalidblock(end+1)=startHandle(index);%#ok<AGROW>
                        elseif strcmpi(blkinfo,'InvalidVirtualPort')
                            invalidline(end+1)=startHandle(index);%#ok<AGROW>
                        end
                        sc.dirty=true;
                    end
                end
                this.userStarts(invalidindex)=[];
            end
        end


        function out=getSubsystemInDFGStarts(this,sc)
            allstarts=this.getDFGStarts(sc);
            subsysIndex=...
            arrayfun(@(x)or(isa(get(x,'Object'),'Simulink.SubSystem'),isa(get(x,'Object'),'Simulink.ModelReference')),...
            [allstarts.Handle]);
            out=[allstarts(subsysIndex).Handle];
        end


        function removeSeeds(this,seedsToBeRemoved,sc)
            if~isempty(seedsToBeRemoved)

                allMaps=this.getVirtualToDFGMap(sc);
                for index=1:length(seedsToBeRemoved)
                    tempobjh=seedsToBeRemoved(index);
                    if isKey(allMaps,tempobjh)

                        remove(this.userVirtStartToActDst,tempobjh);
                        remove(this.userVirtStartToActSrc,tempobjh);
                    end
                end
            end
        end


        function deleteStart(this,i,sc)


            assert(max(i)<=length(this.userStarts));
            filt=true(1,length(this.userStarts));
            filt(i)=false;
            seedsToBeRemoved=this.userStarts(~filt);
            this.userStarts=this.userStarts(filt);
            this.removeSeeds([seedsToBeRemoved.handle],sc);
            sc.dirty=true;
        end

        function deleteBusElementStart(this,portH,busElementPath,sc)
            idx=arrayfun(@(x)loc_shouldRemove(x),this.userStarts);
            changed=~isempty(idx);

            if changed
                this.userStarts(idx)=[];
                sc.dirty=true;
            end

            function yesno=loc_shouldRemove(curStart)
                yesno=false;
                if curStart.handle==portH...
                    &&~isempty(curStart.busElementPath)&&...
                    (strcmp(busElementPath,'removeAll')||...
                    curStart.busElementPath==busElementPath)
                    yesno=true;
                end
            end
        end


        function deleteExclusion(this,i,sc)
            assert(max(i)<=length(this.getUserExclusions));
            this.userExclusions(i)=[];
            sc.dirty=true;
        end


        function clearUserStarts(this,sc)
            this.userStarts=struct('handle',{},'busElementPath',{});
            this.userVirtStartToActSrc=containers.Map('KeyType','double','ValueType','any');
            this.userVirtStartToActDst=containers.Map('KeyType','double','ValueType','any');
        end


        function clearUserExclusions(this,~)
            this.userExclusions=[];
        end


        function setStartingPoints(this,sc)

            items=this.getFullElementStartHandles;
            sc.startingPoints=getBlockHandles(items);
        end


        function setExclusionPoints(this,sc)
            terminals=this.userExclusions;
            constraintsH=getIds(sc.constraints.keys);
            sc.stateConstraints=getIds(sc.covConstraints.keys);
            sc.exclusionPoints=[getBlockHandles(terminals),constraintsH,sc.stateConstraints];

            function cIds=getIds(cSIDs)
                cIds=zeros(size(cSIDs));
                for i=1:length(cSIDs)
                    h=Simulink.ID.getHandle(cSIDs{i});
                    if isnumeric(h)
                        cIds(i)=h;
                    elseif isa(h,'Stateflow.Object')
                        cIds(i)=h.Id;
                    end
                end
            end
        end

    end
end

function blks=getBlockHandles(handles)
    blks=[];
    for i=1:length(handles)
        item=handles(i);
        if strcmp(get(item,'Type'),'block')
            blks=[blks;item];%#ok<AGROW>
        else
            bh=get(item,'ParentHandle');
            blks=[blks;bh];%#ok<AGROW>
        end
    end
    blks=unique(blks);
end

function yesno=isOwnerInactive(h,ms)
    if strcmpi(get_param(h,'type'),'port')
        h=get_param(h,'ParentHandle');
    end

    yesno=strcmpi(get_param(h,'CompiledIsActive'),'off')||...
    ~strcmp(get_param(h,'Commented'),'off');
    if~yesno


        yesno=(ms.compiled&&...
        strcmpi(get_param(bdroot(h),'SimulationStatus'),'stopped'));
    end
end
