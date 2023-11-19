function rfDemodMaskParams=simrfV2rfdemod(block,action)

    switch(action)
    case{'simrfInit','simrfInitForced','simrfInitForcedExp'}
        top_sys=bdroot(block);

        if any(strcmpi(get_param(top_sys,'SimulationStatus'),...
            {'running','paused'}))
            return
        end
        mwsv=get_param(block,'MaskWSVariables');
        if~ismember({mwsv.Name},'rfDemodParams')
            evalin('caller',['rfDemodParams.Mixer.Gain=0;',...
            'rfDemodParams.Mixer.Zin=50;',...
            'rfDemodParams.Mixer.Zout=50;',...
            'rfDemodParams.Mixer.Poly_Coeffs=[0 1];',...
            'rfDemodParams.Mixer.IP2=inf;',...
            'rfDemodParams.Mixer.IP3=inf;',...
            'rfDemodParams.Mixer.P1dB=inf;',...
            'rfDemodParams.Mixer.Psat=inf;',...
            'rfDemodParams.Mixer.Gcomp=inf;',...
            'rfDemodParams.Mixer.NF=0;',...
            'rfDemodParams.LO.CarrierFreq=0;',...
            'rfDemodParams.LO.PhaseNoiseOffset=1;',...
            'rfDemodParams.LO.PhaseNoiseLevel=-Inf;']);
        end


        MaskVals=get_param(block,'MaskValues');
        idxMaskNames=simrfV2getblockmaskparamsindex(block);
        MaskDisplay_3term=simrfV2_add_portlabel('',...
        1,{'In'},1,{'Out'},true);
        MaskDisplay_6term=simrfV2_add_portlabel('',...
        2,{'In'},2,{'Out'},false);
        currentMaskDisplay=get_param(block,'MaskDisplay');
        if isequal(currentMaskDisplay,MaskDisplay_6term)&&...
            strcmpi(MaskVals{idxMaskNames.InternalGrounding},'on')
            set_param(block,'MaskDisplay',MaskDisplay_3term)
        end

        wasGrounded=strcmp(get_param([block,'/LO'],...
        'InternalGrounding'),'on');

        grounded=lower(MaskVals{idxMaskNames.InternalGrounding});
        switch grounded
        case 'on'
            MaskDisplay=MaskDisplay_3term;
            if(~wasGrounded)


                action='simrfInitForced';
                OldElems=find_system(block,'LookUnderMasks',...
                'all','FollowLinks','on','SearchDepth',1,...
                'FindAll','on','RegExp','on',...
                'Name','.[^+]$');
                [~,blkname]=fileparts(block);
                OldElems=...
                OldElems(~strcmp(get(OldElems,'Name'),blkname));
                if~isempty(OldElems)
                    OldLines=find_system(block,'LookUnderMasks',...
                    'all','FollowLinks','on','SearchDepth',...
                    1,'FindAll','on','Type','Line');
                    delete_line(OldLines)
                    delete(OldElems)
                end
                libMod='simrfV2private';
                load_system(libMod);
                SrcBlk='InterRFDemodGrounded';
                add_block([libMod,'/',SrcBlk],[block,'/',SrcBlk],...
                'Position',[195,207,780,603],'LinkStatus',...
                'breakWithoutHierarchy','Mask','off')
                Simulink.BlockDiagram.expandSubsystem([block,'/'...
                ,SrcBlk]);
                ah=find_system(block,'LookUnderMasks','all',...
                'FollowLinks','on','SearchDepth',1,...
                'FindAll','on','type','annotation');
                ao=get_param(ah(1),'Object');
                ao.Selected='on';
                ao.delete;



                MixerPos=get_param([block,'/Mixer'],'Position');

                InPosPos=get_param([block,'/In+'],'Position');
                InPosPos_dx=InPosPos(3)-InPosPos(1);
                dx2PhShift=380;
                InPosPos(3)=MixerPos(1)-dx2PhShift;
                InPosPos(1)=InPosPos(3)-InPosPos_dx;
                set_param([block,'/In+'],'Position',InPosPos);

                dx2Mixer=235;
                OutPosPos=get_param([block,'/Out+'],'Position');
                OutPosPos_dx=OutPosPos(3)-OutPosPos(1);
                OutPosPos(1)=MixerPos(3)+dx2Mixer;
                OutPosPos(3)=OutPosPos(1)+OutPosPos_dx;
                set_param([block,'/Out+'],'Position',OutPosPos);

                phtemp=get_param([block,'/Mixer'],'PortHandles');
                simrfV2deletelines(get(phtemp.RConn(1),'Line'));
                simrfV2connports(struct('DstBlk','Mixer',...
                'DstBlkPortStr','RConn','DstBlkPortIdx',1,...
                'SrcBlk','Out+','SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block);

                notConLine=find_system(block,'LookUnderMasks',...
                'all','FollowLinks','on','SearchDepth',1,...
                'FindAll','on','Type','Line',...
                'Connected','off');
                origLinePoints=get(notConLine,'Points');
                phtemp=get_param([block,'/In+'],'PortHandles');
                set(notConLine,'Points',[get(phtemp.RConn,...
                'Position');origLinePoints(end,:)])
            end

        case 'off'
            MaskDisplay=MaskDisplay_6term;
            if(wasGrounded)


                action='simrfInitForced';

                OldElems=find_system(block,'LookUnderMasks',...
                'all','FollowLinks','on','SearchDepth',1,...
                'FindAll','on','RegExp','on',...
                'Name','.[^+]$');

                [~,blkname]=fileparts(block);
                OldElems=...
                OldElems(~strcmp(get(OldElems,'Name'),blkname));
                if~isempty(OldElems)
                    OldLines=find_system(block,'LookUnderMasks',...
                    'all','FollowLinks','on','SearchDepth',...
                    1,'FindAll','on','Type','Line');
                    delete_line(OldLines)
                    delete(OldElems)
                end


                libMod='simrfV2util1';
                load_system(libMod);
                SrcBlk='Connection Port';
                posTermPorts=find_system(block,'LookUnderMasks',...
                'all','FollowLinks','on','SearchDepth',1,...
                'FindAll','on','RegExp','on','Name','+$');
                for posTermPortInd=1:length(posTermPorts)
                    PortName=...
                    get_param(posTermPorts(posTermPortInd),'Name');
                    PortName(end)='-';
                    PortPosDelta=[0,40,0,40];
                    PortSide='Right';
                    PortOrient='Left';
                    switch(PortName(1:end-1))
                    case 'In'
                        PortSide='Left';
                        PortOrient='Right';
                    end
                    add_block([libMod,'/',SrcBlk],...
                    [block,'/',PortName],'Position',...
                    get_param(posTermPorts(posTermPortInd),...
                    'Position')+PortPosDelta,'LinkStatus',...
                    'breakWithoutHierarchy','Side',PortSide,...
                    'Orientation',PortOrient);
                end
                libMod='simrfV2private';
                load_system(libMod);
                SrcBlk='InterRFDemod';
                add_block([libMod,'/',SrcBlk],[block,'/',SrcBlk],...
                'Position',[195,207,780,603],'LinkStatus',...
                'breakWithoutHierarchy','Mask','off')
                Simulink.BlockDiagram.expandSubsystem([block,'/'...
                ,SrcBlk]);
                ah=find_system(block,'LookUnderMasks','all',...
                'FollowLinks','on','SearchDepth',1,...
                'FindAll','on','type','annotation');
                ao=get_param(ah(1),'Object');
                ao.delete;



                MixerPos=get_param([block,'/Mixer'],'Position');
                dx2PhShift=380;

                InPosPos=get_param([block,'/In+'],'Position');
                InPosPos_dx=InPosPos(3)-InPosPos(1);
                InPosPos(3)=MixerPos(1)-dx2PhShift;
                InPosPos(1)=InPosPos(3)-InPosPos_dx;
                set_param([block,'/In+'],'Position',InPosPos);

                InNegPos=get_param([block,'/In-'],'Position');
                InPosPos_dx=InNegPos(3)-InNegPos(1);
                InNegPos(3)=MixerPos(1)-dx2PhShift;
                InNegPos(1)=InNegPos(3)-InPosPos_dx;
                set_param([block,'/In-'],'Position',InNegPos);

                dx2Mixer=235;
                OutPosPos=get_param([block,'/Out+'],'Position');
                OutPosPos_dx=OutPosPos(3)-OutPosPos(1);
                OutPosPos(1)=MixerPos(3)+dx2Mixer;
                OutPosPos(3)=OutPosPos(1)+OutPosPos_dx;
                set_param([block,'/Out+'],'Position',OutPosPos);

                OutNegPos=get_param([block,'/Out-'],'Position');
                OutNegPos_dx=OutNegPos(3)-OutNegPos(1);
                OutNegPos(1)=MixerPos(3)+dx2Mixer;
                OutNegPos(3)=OutNegPos(1)+OutNegPos_dx;
                set_param([block,'/Out-'],'Position',OutNegPos);

                phtemp=get_param([block,'/Mixer'],'PortHandles');
                simrfV2deletelines(get(phtemp.RConn([1,2]),'Line'));
                simrfV2connports(struct('DstBlk','Mixer',...
                'DstBlkPortStr','RConn','DstBlkPortIdx',1,...
                'SrcBlk','Out+','SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block);
                simrfV2connports(struct('DstBlk','Mixer',...
                'DstBlkPortStr','RConn','DstBlkPortIdx',2,...
                'SrcBlk','Out-','SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block);



                notConLine=find_system(block,'LookUnderMasks',...
                'all','FollowLinks','on','SearchDepth',1,...
                'FindAll','on','Type','Line',...
                'Connected','off');
                origLinePoints=get(notConLine,'Points');


                [~,UpperLineInd]=min([max(origLinePoints{1}(1,2))...
                ,max(origLinePoints{2}(1,2))]);

                LowerLineInd=mod(UpperLineInd,2)+1;
                phtemp=get_param([block,'/In+'],'PortHandles');
                [~,RightMostPoint]=...
                max(origLinePoints{UpperLineInd}(:,1));
                phPoint=get(phtemp.RConn,'Position');
                edgePoint=...
                origLinePoints{UpperLineInd}(RightMostPoint,:);
                midX=(phPoint(1)+edgePoint(1))/2;
                midPoint1=[midX,edgePoint(2)];
                midPoint2=[midX,phPoint(2)];
                if(RightMostPoint==1)
                    set(notConLine(UpperLineInd),'Points',...
                    [edgePoint;midPoint1;midPoint2;phPoint]);
                else
                    set(notConLine(UpperLineInd),'Points',...
                    [phPoint;midPoint2;midPoint1;edgePoint]);
                end
                phtemp=get_param([block,'/In-'],'PortHandles');
                [~,RightMostPoint]=...
                max(origLinePoints{LowerLineInd}(:,1));
                phPoint=get(phtemp.RConn,'Position');
                edgePoint=...
                origLinePoints{LowerLineInd}(RightMostPoint,:);
                midPoint1=[midX,edgePoint(2)];
                midPoint2=[midX,phPoint(2)];
                if(RightMostPoint==1)
                    set(notConLine(LowerLineInd),'Points',...
                    [edgePoint;midPoint1;midPoint2;phPoint]);
                else
                    set(notConLine(LowerLineInd),'Points',...
                    [phPoint;midPoint2;midPoint1;edgePoint]);
                end
            end
        end
        simrfV2_set_param(block,'MaskDisplay',MaskDisplay);

        rfDemodMaskParams=createMaskParamsStruct(block,...
        strcmp(action,'simrfInitForcedExp'));

        mo=Simulink.Mask.get(block);
        if isempty(rfDemodMaskParams.NF)||...
            ~isscalar(rfDemodMaskParams.NF)||...
            ~isnumeric(rfDemodMaskParams.NF)||...
            rfDemodMaskParams.NF<=0
            mo.BlockDVGIcon='RFBlksIcons.modulator';
        else
            mo.BlockDVGIcon='RFBlksIcons.modulatornfon';
        end


        if strcmpi(top_sys,'simrfV2systems')
            return
        end


        current_zIsolation=simrfV2_find_repblk(block,...
        '^(R_Isolation|Z_Isolation|ZisInf_Isolation)$');




        if strcmpi(MaskVals{idxMaskNames.ForceNextInit},'on')
            action='simrfInitForced';
            set_param(block,'ForceNextInit','Off');
        end

        if(any(strcmp(action,{'simrfInitForced',...
            'simrfInitForcedExp'}))||...
            (~isempty(regexpi(get_param(top_sys,...
            'SimulationStatus'),'^(updating|initializing)$','once'))))


            simrfV2_set_param([block,'/Mixer'],'Source_linear_gain',...
            rfDemodMaskParams.Source_linear_gain)

            MaskParamsStructValidations(rfDemodMaskParams);

            if any(strcmpi(rfDemodMaskParams.Source_linear_gain,...
                {'Available power gain','Open circuit voltage gain'}))
                simrfV2_set_param([block,'/Mixer'],'Source_Poly',...
                rfDemodMaskParams.Source_Poly)
                simrfV2_set_param([block,'/Mixer'],'IPType',...
                rfDemodMaskParams.IPType)
            end


            repIRFiltBlkFullPath=find_system(block,'LookUnderMasks',...
            'all','FollowLinks','on','SearchDepth',1,'Name',...
            'IRFilter');
            if(rfDemodMaskParams.AddIRFilter)
                if isempty(repIRFiltBlkFullPath)

                    posMixerBlk=get_param([block,'/Mixer'],'Position');
                    phInPosBlk=get_param([block,'/In+'],'PortHandles');
                    posInPortBlk=get_param([block,'/In+'],'Position');
                    posMixerBlk_dx=posMixerBlk(3)-posMixerBlk(1);
                    posMixerBlk_dy=posMixerBlk(4)-posMixerBlk(2);
                    posInPortBlk_x_mid=(posInPortBlk(1)+...
                    posInPortBlk(3))/2;
                    posInPortBlk_y_mid=(posInPortBlk(2)+...
                    posInPortBlk(4))/2;
                    Blks_halfway=1*(posMixerBlk(1)-posInPortBlk(1))/5;
                    add_block('simrfV2elements/Filter',...
                    [block,'/IRFilter'],...
                    'Position',[posInPortBlk_x_mid-...
                    posMixerBlk_dx/2+Blks_halfway...
                    ,posInPortBlk_y_mid-posMixerBlk_dy/2...
                    ,posInPortBlk_x_mid+posMixerBlk_dx/2+...
                    Blks_halfway,posInPortBlk_y_mid+...
                    posMixerBlk_dy/2],...
                    'InternalGrounding',grounded,...
                    'Orientation','right',...
                    'NamePlacement','Alternate');
                    lineFromInPos=get(phInPosBlk.RConn,'Line');
                    phIRFilter=get_param([block,'/IRFilter'],...
                    'PortHandles');
                    PointsLineFromInPos=get(lineFromInPos,'Points');
                    [~,maxInd]=max(PointsLineFromInPos(:,1));
                    delete_line(lineFromInPos);
                    phPoint=get(phIRFilter.RConn(1),'Position');
                    midX=(phPoint(1)+PointsLineFromInPos(maxInd,1))/2;
                    midPoint1=[midX,phPoint(2)];
                    midPoint2=[midX,PointsLineFromInPos(maxInd,2)];
                    hAddedLine=add_line(block,...
                    [phPoint;midPoint1;midPoint2;...
                    PointsLineFromInPos(maxInd,:)]);
                    if(strcmpi(get(hAddedLine,'Connected'),'off'))




                        delete_line(hAddedLine);
                        IsolationBlkFullPath=find_system(block,...
                        'LookUnderMasks','all','FollowLinks',...
                        'on','SearchDepth',1,'RegExp','on',...
                        'Name','\w*Isolation');
                        [~,IsolationBlk]=...
                        fileparts(IsolationBlkFullPath{1});
                        simrfV2connports(struct('SrcBlk',...
                        'IRFilter','SrcBlkPortStr','RConn',...
                        'SrcBlkPortIdx',1,'DstBlk',IsolationBlk,...
                        'DstBlkPortStr','LConn','DstBlkPortIdx',...
                        1),block);
                    end
                    simrfV2connports(struct('SrcBlk','IRFilter',...
                    'SrcBlkPortStr','LConn','SrcBlkPortIdx',1,...
                    'DstBlk','In+','DstBlkPortStr','RConn',...
                    'DstBlkPortIdx',1),block);
                    if(strcmp(grounded,'off'))



                        negInPortBlk=get_param([block,'/In-'],...
                        'Position');
                        InPortBlks_y_mid=(negInPortBlk(2)+...
                        posInPortBlk(4))/2;
                        set_param([block,'/IRFilter'],'Position',...
                        [posInPortBlk_x_mid-posMixerBlk_dx/2+...
                        Blks_halfway,InPortBlks_y_mid-...
                        posMixerBlk_dy/2,posInPortBlk_x_mid+...
                        posMixerBlk_dx/2+Blks_halfway...
                        ,InPortBlks_y_mid+posMixerBlk_dy/2]);
                        phInPosBlk=get_param([block,'/In-'],...
                        'PortHandles');
                        lineFromInNeg=get(phInPosBlk.RConn,'Line');
                        phIRFilter=get_param([block,'/IRFilter'],...
                        'PortHandles');
                        PointsLineFromInNeg=get(lineFromInNeg,'Points');
                        delete_line(lineFromInNeg);
                        [~,maxInd]=max(PointsLineFromInNeg(:,1));
                        phPoint=get(phIRFilter.RConn(2),'Position');
                        midPoint1=[midX,phPoint(2)];
                        midPoint2=[midX,PointsLineFromInNeg(maxInd,2)];
                        hAddedLine=add_line(block,...
                        [phPoint;midPoint1;midPoint2;...
                        PointsLineFromInNeg(maxInd,:)]);
                        if(strcmpi(get(hAddedLine,'Connected'),'off'))




                            delete_line(hAddedLine);
                            simrfV2connports(struct('SrcBlk',...
                            'IRFilter','SrcBlkPortStr','RConn',...
                            'SrcBlkPortIdx',2,'DstBlk',...
                            'LO','DstBlkPortStr',...
                            'RConn','DstBlkPortIdx',1),block);
                        end
                        simrfV2connports(struct('SrcBlk','IRFilter',...
                        'SrcBlkPortStr','LConn','SrcBlkPortIdx',2,...
                        'DstBlk','In-','DstBlkPortStr','RConn',...
                        'DstBlkPortIdx',1),block);
                        phBlk=get_param([block,'/IRFilter'],...
                        'PortHandles');
                        hLine=add_line(block,phBlk.RConn(2),...
                        phBlk.LConn(2));
                        linePts=get(hLine,'Points');
                        if(size(linePts,1)==2)
                            linePts=[linePts(1,:);linePts(1,:);...
                            linePts(2,:);linePts(2,:)];
                            linePts(2,2)=linePts(2,2)+posMixerBlk_dy/2;
                            linePts(3,2)=linePts(3,2)+posMixerBlk_dy/2;
                            set(hLine,'Points',linePts);
                        end
                    end
                end

                fnames=fieldnames(rfDemodMaskParams);
                IRfnames=fnames(cellfun(@(x)~isempty(x),...
                regexp(fnames,'IR$')));
                paramNameValPair={};
                for IRfnameInd=1:length(IRfnames)
                    IRfname=IRfnames{IRfnameInd};
                    ParamVal=rfDemodMaskParams.(IRfname);
                    if isnumeric(ParamVal)
                        ParamVal=mat2str(ParamVal);
                    end
                    paramNameValPair(:,end+1)=...
                    {IRfname(1:end-2);ParamVal};%#ok<AGROW>
                end
                set_param([block,'/IRFilter'],paramNameValPair{:});
            else
                if~isempty(repIRFiltBlkFullPath)


                    phIRFiltBlk=get_param(repIRFiltBlkFullPath,...
                    'PortHandles');
                    phInPosBlk=get_param([block,'/In+'],'PortHandles');

                    simrfV2deletelines(get(phIRFiltBlk{1}.LConn,...
                    'Line'));
                    if(strcmp(grounded,'off'))


                        phInNegBlk=get_param([block,'/In-'],...
                        'PortHandles');
                        simrfV2deletelines(get(phInNegBlk.RConn,'Line'));
                    end

                    lineFromIRFilter=get(phIRFiltBlk{1}.RConn,'Line');
                    delete_block(repIRFiltBlkFullPath);
                    phPoint=get(phInPosBlk.RConn,'Position');
                    if(~iscell(lineFromIRFilter))
                        origLinePoints=get(lineFromIRFilter,'Points');
                        [~,maxInd]=max(origLinePoints(:,1));
                        midX=(phPoint(1)+origLinePoints(maxInd,1))/2;
                        midPoint1=[midX,phPoint(2)];
                        midPoint2=[midX,origLinePoints(maxInd,2)];
                        set(lineFromIRFilter,'Points',...
                        [phPoint;midPoint1;midPoint2;...
                        origLinePoints(maxInd,:)]);
                    else
                        origLinePoints=get(lineFromIRFilter{1},'Points');
                        [~,maxInd]=max(origLinePoints(:,1));
                        midX=(phPoint(1)+origLinePoints(maxInd,1))/2;
                        midPoint1=[midX,phPoint(2)];
                        midPoint2=[midX,origLinePoints(maxInd,2)];
                        set(lineFromIRFilter{1},'Points',...
                        [phPoint;midPoint1;midPoint2;...
                        origLinePoints(maxInd,:)]);
                        origLinePoints=get(lineFromIRFilter{2},'Points');
                        [~,maxInd]=max(origLinePoints(:,1));
                        phInNegBlk=get_param([block,'/In-'],...
                        'PortHandles');
                        phPoint=get(phInNegBlk.RConn,'Position');
                        midPoint1=[midX,phPoint(2)];
                        midPoint2=[midX,origLinePoints(maxInd,2)];
                        set(lineFromIRFilter{2},'Points',...
                        [phPoint;midPoint1;midPoint2;...
                        origLinePoints(maxInd,:)]);
                    end
                end
            end


            repCSFiltIBlkFullPath=find_system(block,'LookUnderMasks',...
            'all','FollowLinks','on','SearchDepth',1,'Name',...
            'CSFilter');
            if(rfDemodMaskParams.AddCSFilter)
                if isempty(repCSFiltIBlkFullPath)

                    posMixerBlk=get_param([block,'/Mixer'],...
                    'Position');
                    phOutPosBlk=get_param([block,'/Out+'],'PortHandles');
                    simrfV2deletelines(get(phOutPosBlk.RConn,'Line'));
                    posOutPortBlk=get_param([block,'/Out+'],'Position');
                    posMixerBlk_dx=posMixerBlk(3)-posMixerBlk(1);
                    posMixerBlk_dy=posMixerBlk(4)-posMixerBlk(2);
                    posOutPortBlk_x_mid=(posOutPortBlk(1)+...
                    posOutPortBlk(3))/2;
                    posMixerBlk_y_mid=(posMixerBlk(2)+...
                    posMixerBlk(4))/2;
                    Blks_halfway=1*(posMixerBlk(1)-posOutPortBlk(1))/3;
                    add_block('simrfV2elements/Filter',...
                    [block,'/CSFilter'],...
                    'Position',[posOutPortBlk_x_mid-...
                    posMixerBlk_dx/2+Blks_halfway...
                    ,posMixerBlk_y_mid-posMixerBlk_dy/2...
                    ,posOutPortBlk_x_mid+posMixerBlk_dx/2+...
                    Blks_halfway,posMixerBlk_y_mid+...
                    posMixerBlk_dy/2],...
                    'InternalGrounding',grounded,...
                    'Orientation','right',...
                    'NamePlacement','Alternate');
                    simrfV2connports(struct('SrcBlk','CSFilter',...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk','Out+','DstBlkPortStr',...
                    'RConn','DstBlkPortIdx',1),block);
                    simrfV2connports(struct('SrcBlk','CSFilter',...
                    'SrcBlkPortStr','LConn','SrcBlkPortIdx',1,...
                    'DstBlk','Mixer','DstBlkPortStr','RConn',...
                    'DstBlkPortIdx',1),block);
                    if(strcmp(grounded,'off'))





                        negOutPortBlk=get_param([block,'/Out-'],...
                        'Position');
                        OutPortBlks_y_mid=(negOutPortBlk(2)+...
                        posOutPortBlk(4))/2;
                        set_param([block,'/CSFilter'],'Position',...
                        [posOutPortBlk_x_mid-...
                        posMixerBlk_dx/2+Blks_halfway...
                        ,OutPortBlks_y_mid-posMixerBlk_dy/2...
                        ,posOutPortBlk_x_mid+posMixerBlk_dx/2+...
                        Blks_halfway,OutPortBlks_y_mid+...
                        posMixerBlk_dy/2]);
                        phtemp=get_param([block,'/Out-'],'PortHandles');
                        simrfV2deletelines(get(phtemp.RConn(1),'Line'));
                        simrfV2connports(struct('SrcBlk','CSFilter',...
                        'SrcBlkPortStr','RConn','SrcBlkPortIdx',...
                        2,'DstBlk','Out-',...
                        'DstBlkPortStr','RConn','DstBlkPortIdx',...
                        1),block);
                        simrfV2connports(struct('SrcBlk','CSFilter',...
                        'SrcBlkPortStr','LConn','SrcBlkPortIdx',...
                        2,'DstBlk','Mixer','DstBlkPortStr',...
                        'RConn','DstBlkPortIdx',2),block);
                        phBlk=get_param([block,'/CSFilter'],...
                        'PortHandles');
                        hLine=add_line(block,phBlk.RConn(2),...
                        phBlk.LConn(2));
                        linePts=get(hLine,'Points');
                        if(size(linePts,1)==2)
                            linePts=[linePts(1,:);linePts(1,:);...
                            linePts(2,:);linePts(2,:)];
                            linePts(2,2)=linePts(2,2)+posMixerBlk_dy/2;
                            linePts(3,2)=linePts(3,2)+posMixerBlk_dy/2;
                            set(hLine,'Points',linePts);
                        end
                    end
                end

                fnames=fieldnames(rfDemodMaskParams);
                CSfnames=fnames(cellfun(@(x)~isempty(x),...
                regexp(fnames,'CS$')));
                paramNameValPair={};
                for CSfnameInd=1:length(CSfnames)
                    CSfname=CSfnames{CSfnameInd};
                    ParamVal=rfDemodMaskParams.(CSfname);
                    if isnumeric(ParamVal)
                        ParamVal=mat2str(ParamVal);
                    end
                    paramNameValPair(:,end+1)=...
                    {CSfname(1:end-2);ParamVal};%#ok<AGROW>
                end
                set_param([block,'/CSFilter'],paramNameValPair{:});
            else
                if~isempty(repCSFiltIBlkFullPath)


                    phCSFiltIBlk=get_param(repCSFiltIBlkFullPath,...
                    'PortHandles');

                    simrfV2deletelines(get(phCSFiltIBlk{1}.LConn,'Line'));

                    simrfV2deletelines(get(phCSFiltIBlk{1}.RConn,'Line'));
                    delete_block(repCSFiltIBlkFullPath);
                    simrfV2connports(struct('SrcBlk','Out+',...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk','Mixer','DstBlkPortStr',...
                    'RConn','DstBlkPortIdx',1),block);
                    if(strcmp(grounded,'off'))



                        phOutNegBlk=get_param([block,'/Out-'],...
                        'PortHandles');
                        simrfV2deletelines(get(phOutNegBlk.RConn,'Line'));
                        simrfV2connports(struct('SrcBlk','Out-',...
                        'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                        'DstBlk','Mixer','DstBlkPortStr',...
                        'RConn','DstBlkPortIdx',2),block);
                    end
                end
            end



            evalin('caller',['rfDemodParams.LO.CarrierFreq=0;',...
            'rfDemodParams.LO.PhaseNoiseOffset=1;',...
            'rfDemodParams.LO.PhaseNoiseLevel=-Inf;']);
            set_param([block,'/LO'],'AddPhaseNoise',...
            rfDemodMaskParams.AddPhaseNoise);
            set_param([block,'/LO'],'AutoImpulseLength',...
            rfDemodMaskParams.AutoImpulseLengthPN);
            if ischar(rfDemodMaskParams.ImpulseLengthPN)
                set_param([block,'/LO'],'ImpulseLength',...
                rfDemodMaskParams.ImpulseLengthPN);
            else
                set_param([block,'/LO'],'ImpulseLength',...
                mat2str(rfDemodMaskParams.ImpulseLengthPN));
            end
            set_param([block,'/LO'],'ImpulseLength_unit',...
            rfDemodMaskParams.ImpulseLength_unitPN);


            if isinf(rfDemodMaskParams.Isolation)
                Z_Isolation_str='ZisInf_Isolation';
                srcBlk='simrfV2_lib/Elements/OPEN_RF';
            elseif isreal(rfDemodMaskParams.Zin)
                Z_Isolation_str='R_Isolation';
                srcBlk='simrfV2elements/R';
            else
                Z_Isolation_str='Z_Isolation';
                srcBlk='simrfV2elements/Z';
            end
            if~strcmpi(current_zIsolation,Z_Isolation_str)
                replacedBlk=replace_block(block,'FollowLinks',...
                'on','SearchDepth','1','name',...
                current_zIsolation,srcBlk,'noprompt');
                if~isempty(replacedBlk)
                    set_param(replacedBlk{1},'NamePlacement',...
                    'Alternate');
                    set_param(replacedBlk{1},'name',Z_Isolation_str);
                end
            end

            if strcmp(Z_Isolation_str,'Z_Isolation')




                evalin('caller',...
                'rfDemodParams.Z_Isolation.Impedance=50;');
                simrfV2_set_param([block,'/',Z_Isolation_str],...
                'Impedance','rfDemodParams.Z_Isolation.Impedance');
            elseif strcmp(Z_Isolation_str,'R_Isolation')
                evalin('caller',...
                'rfDemodParams.R_Isolation.Resistance=50;');
                simrfV2_set_param([block,'/',Z_Isolation_str],...
                'Resistance','rfDemodParams.R_Isolation.Resistance');

                simrfV2_set_param([block,'/',Z_Isolation_str],...
                'AddNoise','off');
            end
        end

    case 'simrfInitValidateOnly'
        top_sys=bdroot(block);

        if any(strcmpi(get_param(top_sys,'SimulationStatus'),...
            {'running','paused'}))
            return
        end

        if strcmpi(top_sys,'simrfV2systems')
            return
        end
        rfDemodMaskParams=createMaskParamsStruct(block,false);
        MaskParamsStructValidations(rfDemodMaskParams);

    case 'simrfDelete'

    case 'simrfCopy'

    case 'simrfDefault'

    end

end

function MaskParamsStruct=createMaskParamsStruct(block,copyInvisible)
    mwsv=get_param(block,'MaskWSVariables');
    rfDemodParmNames={mwsv.Name};
    rfDemodParmValues={mwsv.Value};
    rfDemodParmUnitsIdxs=zeros(1,length(rfDemodParmNames));
    for rfDemodParmIdx=1:length(rfDemodParmNames)
        rfDemodParmName=rfDemodParmNames{rfDemodParmIdx};
        Inval=rfDemodParmValues{rfDemodParmIdx};
        rfDemodParmUnitInx=ismember(rfDemodParmNames,...
        [rfDemodParmName,'_unit']);
        if any(rfDemodParmUnitInx)

            UnitVal=rfDemodParmValues{rfDemodParmUnitInx};
            if strcmpi(UnitVal,'None')
                Source_linear_gain=...
                rfDemodParmValues(strcmpi(rfDemodParmNames,...
                'Source_linear_gain'));


                if strcmpi(Source_linear_gain,'Available power gain')
                    Outval=10*log10(rfDemodParmValues{rfDemodParmIdx});
                else
                    Outval=20*log10(rfDemodParmValues{rfDemodParmIdx});
                end
            elseif strcmpi(UnitVal,'Rad')
                Outval=rfDemodParmValues{rfDemodParmIdx}*180/pi;
            elseif strcmpi(UnitVal,'W')
                Outval=10*...
                log10(rfDemodParmValues{rfDemodParmIdx})+30;
            elseif strcmpi(UnitVal,'mW')
                Outval=10*log10(rfDemodParmValues{rfDemodParmIdx});
            elseif strcmpi(UnitVal,'dBW')
                Outval=rfDemodParmValues{rfDemodParmIdx}+30;
            else
                first_letter_of_unit=UnitVal(1);
                switch first_letter_of_unit
                case 'k'
                    Outval=1e3*Inval;
                case 'M'
                    Outval=1e6*Inval;
                case 'G'
                    Outval=1e9*Inval;
                case 'T'
                    Outval=1e12*Inval;
                case 'm'
                    Outval=1e-3*Inval;
                case 'u'
                    Outval=1e-6*Inval;
                case 'n'
                    Outval=1e-9*Inval;
                case 'p'
                    Outval=1e-12*Inval;
                otherwise
                    Outval=Inval;
                end
            end
            rfDemodParmValues{rfDemodParmIdx}=Outval;
            rfDemodParmUnitsIdxs=or(rfDemodParmUnitsIdxs,...
            rfDemodParmUnitInx);
        end




        keepFieldsEmpty={'IP2','IP3','P1dB','Psat'};
        if isempty(rfDemodParmValues{rfDemodParmIdx})
            MaskNames=get_param(block,'MaskNames');
            idxMaskParams=cell2struct(num2cell(1:length(MaskNames)),...
            MaskNames,2);
            maskVis=get_param(block,'MaskVisibilities');
            if(copyInvisible&&~strcmpi(maskVis{idxMaskParams.(...
                rfDemodParmNames{rfDemodParmIdx})},'on')&&...
                ~any(strcmpi(rfDemodParmNames{rfDemodParmIdx},...
                keepFieldsEmpty)))
                rfDemodParmValues{rfDemodParmIdx}=...
                get_param(block,rfDemodParmNames{rfDemodParmIdx});
            end
        end
    end

    rfDemodParmRemoveInx=or(rfDemodParmUnitsIdxs,...
    ismember(rfDemodParmNames,'InternalGrounding'));

    rfDemodParmRemoveInx=or(rfDemodParmRemoveInx,...
    ismember(rfDemodParmNames,'classname'));

    rfDemodParmRemoveInx=or(rfDemodParmRemoveInx,...
    ismember(rfDemodParmNames,'rfDemodParams'));

    rfDemodParmRemoveInx=or(rfDemodParmRemoveInx,...
    ismember(rfDemodParmNames,'rfDemodMaskParams'));

    MaskParamsStruct=cell2struct(rfDemodParmValues(...
    not(rfDemodParmRemoveInx)),...
    rfDemodParmNames(not(rfDemodParmRemoveInx)),2);

end

function MaskParamsStructValidations(MaskParamsStruct)
    if any(strcmpi(MaskParamsStruct.Source_linear_gain,...
        {'Available power gain','Open circuit voltage gain'}))
        validateattributes(MaskParamsStruct.linear_gain,...
        {'numeric'},{'nonempty','scalar','real','finite'},...
        '',MaskParamsStruct.Source_linear_gain);
        validateattributes(MaskParamsStruct.IP3,{'numeric'},...
        {'nonempty','scalar','real'},'','IP3');
        if strcmpi(MaskParamsStruct.Source_Poly,...
            'Even and odd order')
            validateattributes(MaskParamsStruct.IP2,...
            {'numeric'},{'nonempty','scalar','real'},'',...
            'IP2');
        else
            validateattributes(MaskParamsStruct.P1dB,...
            {'numeric'},{'nonempty','scalar','real'},'',...
            '1-dB gain compression power');
            validateattributes(MaskParamsStruct.Psat,...
            {'numeric'},{'nonempty','scalar','real'},'',...
            'Output saturation power');
            validateattributes(MaskParamsStruct.Gcomp,...
            {'numeric'},{'nonempty','scalar','real'},'',...
            'Gain compression at saturation');
        end
    else
        validateattributes(MaskParamsStruct.Poly_Coeffs,...
        {'numeric'},{'nonempty','vector','real','finite'},...
        '','Polynomial coefficients');
    end
    validateattributes(MaskParamsStruct.LOFreq,{'numeric'},...
    {'nonempty','scalar','finite','real','nonnegative'},...
    '','Local Oscillator frequency');
    [~]=simrfV2checkimpedance(MaskParamsStruct.Zin,0,...
    'Input impedance of mixer',0,1);
    [~]=simrfV2checkimpedance(MaskParamsStruct.Zout,0,...
    'Output impedance of mixer',1,0);
    validateattributes(MaskParamsStruct.Isolation,{'numeric'},...
    {'nonempty','nonnan','scalar','real','positive'},'',...
    'LO to In isolation');
    validateattributes(MaskParamsStruct.NF,{'numeric'},...
    {'nonempty','scalar','real','nonnegative','finite'},...
    '','Demodulator Noise figure');
    if(strcmpi(MaskParamsStruct.AddPhaseNoise,'on'))


        validateattributes(MaskParamsStruct.PhaseNoiseOffset,...
        {'numeric'},{'nonempty','vector','positive','finite'},'',...
        'Phase noise frequency offsets');
        validateattributes(MaskParamsStruct.PhaseNoiseLevel,...
        {'numeric'},{'nonempty','vector','real'},'',...
        'Phase noise level');
        if any(size(MaskParamsStruct.PhaseNoiseOffset)~=...
            size(MaskParamsStruct.PhaseNoiseLevel))
            error(message('simrf:simrfV2errors:MatrixSizeNotSameAs',...
            'Phase noise frequency offsets','Phase noise level'));
        end
        if(strcmpi(MaskParamsStruct.AutoImpulseLengthPN,'off'))
            validateattributes(MaskParamsStruct.ImpulseLengthPN,...
            {'numeric'},...
            {'nonempty','scalar','real','finite','positive'},'',...
            'Phase noise impulse response duration');
        end
    end
end