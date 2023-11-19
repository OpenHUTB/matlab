function rfModMaskParams=simrfV2rfmod(block,action)

    switch(action)
    case{'simrfInit','simrfInitForced','simrfInitForcedExp'}
        top_sys=bdroot(block);

        if any(strcmpi(get_param(top_sys,'SimulationStatus'),...
            {'running','paused'}))
            return
        end

        mwsv=get_param(block,'MaskWSVariables');
        if~ismember({mwsv.Name},'rfModParams')
            evalin('caller',['rfModParams.Mixer.Gain=0;',...
            'rfModParams.Mixer.Zin=50;',...
            'rfModParams.Mixer.Zout=50;',...
            'rfModParams.Mixer.Poly_Coeffs=[0 1];',...
            'rfModParams.Mixer.IP2=inf;',...
            'rfModParams.Mixer.IP3=inf;',...
            'rfModParams.Mixer.P1dB=inf;',...
            'rfModParams.Mixer.Psat=inf;',...
            'rfModParams.Mixer.Gcomp=inf;',...
            'rfModParams.Mixer.NF=0;',...
            'rfModParams.LO.CarrierFreq=0;',...
            'rfModParams.LO.PhaseNoiseOffset=1;',...
            'rfModParams.LO.PhaseNoiseLevel=-Inf;']);
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
                SrcBlk='InterRFModGrounded';
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
                dx2Mixer=235;
                InPosPos(3)=MixerPos(1)-dx2Mixer;
                InPosPos(1)=InPosPos(3)-InPosPos_dx;
                set_param([block,'/In+'],'Position',InPosPos);

                dx2Mixer=380;
                OutPosPos=get_param([block,'/Out+'],'Position');
                OutPosPos_dx=OutPosPos(3)-OutPosPos(1);
                OutPosPos(1)=MixerPos(3)+dx2Mixer;
                OutPosPos(3)=OutPosPos(1)+OutPosPos_dx;
                set_param([block,'/Out+'],'Position',OutPosPos);

                phtemp=get_param([block,'/Mixer'],'PortHandles');
                simrfV2deletelines(get(phtemp.LConn(1),'Line'));
                simrfV2connports(struct('DstBlk','Mixer',...
                'DstBlkPortStr','LConn','DstBlkPortIdx',1,...
                'SrcBlk','In+','SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block);

                notConLine=find_system(block,'LookUnderMasks',...
                'all','FollowLinks','on','SearchDepth',1,...
                'FindAll','on','Type','Line',...
                'Connected','off');
                origLinePoints=get(notConLine,'Points');
                phtemp=get_param([block,'/Out+'],'PortHandles');
                [~,RightMostPoint]=max(origLinePoints(:,1));
                origLinePoints(RightMostPoint,:)=...
                get(phtemp.RConn,'Position');
                set(notConLine,'Points',origLinePoints);
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
                SrcBlk='InterRFMod';
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
                dx2Mixer=235;

                InPosPos=get_param([block,'/In+'],'Position');
                InPosPos_dx=InPosPos(3)-InPosPos(1);
                InPosPos(3)=MixerPos(1)-dx2Mixer;
                InPosPos(1)=InPosPos(3)-InPosPos_dx;
                set_param([block,'/In+'],'Position',InPosPos);

                InNegPos=get_param([block,'/In-'],'Position');
                InPosPos_dx=InNegPos(3)-InNegPos(1);
                InNegPos(3)=MixerPos(1)-dx2Mixer;
                InNegPos(1)=InNegPos(3)-InPosPos_dx;
                set_param([block,'/In-'],'Position',InNegPos);

                dx2Mixer=380;
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
                simrfV2deletelines(get(phtemp.LConn([1,2]),'Line'));
                simrfV2connports(struct('DstBlk','Mixer',...
                'DstBlkPortStr','LConn','DstBlkPortIdx',1,...
                'SrcBlk','In+','SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block);
                simrfV2connports(struct('DstBlk','Mixer',...
                'DstBlkPortStr','LConn','DstBlkPortIdx',2,...
                'SrcBlk','In-','SrcBlkPortStr','RConn',...
                'SrcBlkPortIdx',1),block);



                notConLine=find_system(block,'LookUnderMasks',...
                'all','FollowLinks','on','SearchDepth',1,...
                'FindAll','on','Type','Line',...
                'Connected','off');
                origLinePoints=get(notConLine,'Points');


                [~,UpperLineInd]=min([max(origLinePoints{1}(1,2))...
                ,max(origLinePoints{2}(1,2))]);

                LowerLineInd=mod(UpperLineInd,2)+1;
                phtemp=get_param([block,'/Out+'],'PortHandles');
                [~,LeftMostPoint]=...
                min(origLinePoints{UpperLineInd}(:,1));
                phPoint=get(phtemp.RConn,'Position');
                edgePoint=...
                origLinePoints{UpperLineInd}(LeftMostPoint,:);
                midX=(phPoint(1)+edgePoint(1))/2;
                midPoint1=[midX,edgePoint(2)];
                midPoint2=[midX,phPoint(2)];
                if(LeftMostPoint==1)
                    set(notConLine(UpperLineInd),'Points',...
                    [edgePoint;midPoint1;midPoint2;phPoint]);
                else
                    set(notConLine(UpperLineInd),'Points',...
                    [phPoint;midPoint2;midPoint1;edgePoint]);
                end
                phtemp=get_param([block,'/Out-'],'PortHandles');
                [~,LeftMostPoint]=...
                min(origLinePoints{LowerLineInd}(:,1));
                phPoint=get(phtemp.RConn,'Position');
                edgePoint=...
                origLinePoints{LowerLineInd}(LeftMostPoint,:);
                midPoint1=[midX,edgePoint(2)];
                midPoint2=[midX,phPoint(2)];
                if(LeftMostPoint==1)
                    set(notConLine(LowerLineInd),'Points',...
                    [edgePoint;midPoint1;midPoint2;phPoint]);
                else
                    set(notConLine(LowerLineInd),'Points',...
                    [phPoint;midPoint2;midPoint1;edgePoint]);
                end
            end
        end
        simrfV2_set_param(block,'MaskDisplay',MaskDisplay);

        rfModMaskParams=createMaskParamsStruct(block,...
        strcmp(action,'simrfInitForcedExp'));

        mo=Simulink.Mask.get(block);
        if isempty(rfModMaskParams.NF)||...
            ~isscalar(rfModMaskParams.NF)||...
            ~isnumeric(rfModMaskParams.NF)||...
            rfModMaskParams.NF<=0
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
            rfModMaskParams.Source_linear_gain)

            MaskParamsStructValidations(rfModMaskParams);

            if any(strcmpi(rfModMaskParams.Source_linear_gain,...
                {'Available power gain','Open circuit voltage gain'}))
                simrfV2_set_param([block,'/Mixer'],'Source_Poly',...
                rfModMaskParams.Source_Poly)
                simrfV2_set_param([block,'/Mixer'],'IPType',...
                rfModMaskParams.IPType)
            end


            repCSFiltBlkFullPath=find_system(block,'LookUnderMasks',...
            'all','FollowLinks','on','SearchDepth',1,'Name',...
            'CSFilter');
            if(rfModMaskParams.AddCSFilter)
                if isempty(repCSFiltBlkFullPath)

                    posMixerBlk=get_param([block,'/Mixer'],'Position');
                    phOutPosBlk=get_param([block,'/Out+'],'PortHandles');
                    PosOutPortBlk=get_param([block,'/Out+'],'Position');
                    posMixerBlk_dx=posMixerBlk(3)-posMixerBlk(1);
                    posMixerBlk_dy=posMixerBlk(4)-posMixerBlk(2);
                    PosOutPortBlk_x_mid=(PosOutPortBlk(1)+...
                    PosOutPortBlk(3))/2;
                    PosOutPortBlk_y_mid=(PosOutPortBlk(2)+...
                    PosOutPortBlk(4))/2;
                    Blks_halfway=1*(PosOutPortBlk(1)-posMixerBlk(1))/5;
                    add_block('simrfV2elements/Filter',...
                    [block,'/CSFilter'],...
                    'Position',[PosOutPortBlk_x_mid-...
                    posMixerBlk_dx/2-Blks_halfway...
                    ,PosOutPortBlk_y_mid-posMixerBlk_dy/2...
                    ,PosOutPortBlk_x_mid+posMixerBlk_dx/2-...
                    Blks_halfway,PosOutPortBlk_y_mid+...
                    posMixerBlk_dy/2],...
                    'InternalGrounding',grounded,...
                    'Orientation','right',...
                    'NamePlacement','Alternate');
                    lineFromInPos=get(phOutPosBlk.RConn,'Line');
                    phCSFilter=get_param([block,'/CSFilter'],...
                    'PortHandles');
                    PointsLineFromInPos=get(lineFromInPos,'Points');
                    [~,minInd]=min(PointsLineFromInPos(:,1));
                    delete_line(lineFromInPos);
                    phPoint=get(phCSFilter.LConn(1),'Position');
                    hAddedLine=add_line(block,...
                    [phPoint;PointsLineFromInPos(minInd,:)]);
                    if(strcmpi(get(hAddedLine,'Connected'),'off'))




                        delete_line(hAddedLine);
                        IsolationBlkFullPath=find_system(block,...
                        'LookUnderMasks','all','FollowLinks',...
                        'on','SearchDepth',1,'RegExp','on',...
                        'Name','\w*Isolation');
                        [~,IsolationBlk]=...
                        fileparts(IsolationBlkFullPath{1});
                        simrfV2connports(struct('SrcBlk',...
                        'CSFilter','SrcBlkPortStr','RConn',...
                        'SrcBlkPortIdx',1,'DstBlk',IsolationBlk,...
                        'DstBlkPortStr','LConn','DstBlkPortIdx',...
                        1),block);
                    end
                    simrfV2connports(struct('SrcBlk','CSFilter',...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk','Out+','DstBlkPortStr','RConn',...
                    'DstBlkPortIdx',1),block);
                    if(strcmp(grounded,'off'))



                        negOutPortBlk=get_param([block,'/Out-'],...
                        'Position');
                        OutPortBlks_y_mid=(negOutPortBlk(2)+...
                        PosOutPortBlk(4))/2;
                        set_param([block,'/CSFilter'],'Position',...
                        [PosOutPortBlk_x_mid-posMixerBlk_dx/2-...
                        Blks_halfway,OutPortBlks_y_mid-...
                        posMixerBlk_dy/2,PosOutPortBlk_x_mid+...
                        posMixerBlk_dx/2-Blks_halfway...
                        ,OutPortBlks_y_mid+posMixerBlk_dy/2]);
                        phOutNegBlk=get_param([block,'/Out-'],...
                        'PortHandles');
                        lineFromInNeg=get(phOutNegBlk.RConn,'Line');
                        phCSFilter=get_param([block,'/CSFilter'],...
                        'PortHandles');
                        PointsLineFromInNeg=get(lineFromInNeg,'Points');
                        delete_line(lineFromInNeg);
                        [~,maxInd]=max(PointsLineFromInNeg(:,1));
                        phPoint=get(phCSFilter.LConn(2),'Position');
                        PointsLineFromInNeg(maxInd,:)=phPoint;
                        hAddedLine=add_line(block,PointsLineFromInNeg);
                        if(strcmpi(get(hAddedLine,'Connected'),'off'))




                            delete_line(hAddedLine);
                            simrfV2connports(struct('SrcBlk',...
                            'CSFilter','SrcBlkPortStr','RConn',...
                            'SrcBlkPortIdx',2,'DstBlk',...
                            'LO','DstBlkPortStr',...
                            'RConn','DstBlkPortIdx',1),block);
                        end
                        simrfV2connports(struct('SrcBlk','CSFilter',...
                        'SrcBlkPortStr','RConn','SrcBlkPortIdx',2,...
                        'DstBlk','Out-','DstBlkPortStr','RConn',...
                        'DstBlkPortIdx',1),block);
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

                fnames=fieldnames(rfModMaskParams);
                CSfnames=fnames(cellfun(@(x)~isempty(x),...
                regexp(fnames,'CS$')));
                paramNameValPair={};
                for CSfnameInd=1:length(CSfnames)
                    CSfname=CSfnames{CSfnameInd};
                    ParamVal=rfModMaskParams.(CSfname);
                    if isnumeric(ParamVal)
                        ParamVal=mat2str(ParamVal);
                    end
                    paramNameValPair(:,end+1)=...
                    {CSfname(1:end-2);ParamVal};%#ok<AGROW>
                end
                set_param([block,'/CSFilter'],paramNameValPair{:});
            else
                if~isempty(repCSFiltBlkFullPath)


                    phCSFiltBlk=get_param(repCSFiltBlkFullPath,...
                    'PortHandles');
                    phOutPosBlk=get_param([block,'/Out+'],'PortHandles');

                    simrfV2deletelines(get(phCSFiltBlk{1}.RConn,'Line'));
                    if(strcmp(grounded,'off'))


                        phOutNegBlk=get_param([block,'/Out-'],...
                        'PortHandles');
                        simrfV2deletelines(get(phOutNegBlk.RConn,'Line'));
                    end

                    lineFromCSFilter=get(phCSFiltBlk{1}.LConn,'Line');
                    delete_block(repCSFiltBlkFullPath);
                    phPoint=get(phOutPosBlk.RConn,'Position');
                    if(~iscell(lineFromCSFilter))
                        origLinePoints=get(lineFromCSFilter,'Points');
                        [~,maxInd]=max(origLinePoints(:,1));
                        origLinePoints(maxInd,:)=phPoint;
                        set(lineFromCSFilter,'Points',origLinePoints);
                    else
                        origLinePoints=get(lineFromCSFilter{1},'Points');
                        [~,maxInd]=max(origLinePoints(:,1));
                        origLinePoints(maxInd,:)=phPoint;
                        set(lineFromCSFilter{1},'Points',origLinePoints);
                        origLinePoints=get(lineFromCSFilter{2},'Points');
                        [~,maxInd]=max(origLinePoints(:,1));
                        phOutNegBlk=get_param([block,'/Out-'],...
                        'PortHandles');
                        phPoint=get(phOutNegBlk.RConn,'Position');
                        origLinePoints(maxInd,:)=phPoint;
                        set(lineFromCSFilter{2},'Points',origLinePoints);
                    end
                end
            end


            repIRFiltIBlkFullPath=find_system(block,'LookUnderMasks',...
            'all','FollowLinks','on','SearchDepth',1,'Name',...
            'IRFilter');
            if(rfModMaskParams.AddIRFilter)
                if isempty(repIRFiltIBlkFullPath)

                    posMixerBlk=get_param([block,'/Mixer'],...
                    'Position');
                    phInPosBlk=get_param([block,'/In+'],'PortHandles');
                    simrfV2deletelines(get(phInPosBlk.RConn,'Line'));
                    posInPortBlk=get_param([block,'/In+'],'Position');
                    posMixerBlk_dx=posMixerBlk(3)-posMixerBlk(1);
                    posMixerBlk_dy=posMixerBlk(4)-posMixerBlk(2);
                    posInPortBlk_x_mid=(posInPortBlk(1)+...
                    posInPortBlk(3))/2;
                    posInPortBlk_y_mid=(posInPortBlk(2)+...
                    posInPortBlk(4))/2;
                    Blks_halfway=1*(posMixerBlk(1)-posInPortBlk(1))/3;
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
                    simrfV2connports(struct('SrcBlk','IRFilter',...
                    'SrcBlkPortStr','LConn','SrcBlkPortIdx',1,...
                    'DstBlk','In+','DstBlkPortStr',...
                    'RConn','DstBlkPortIdx',1),block);
                    simrfV2connports(struct('SrcBlk','IRFilter',...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk','Mixer','DstBlkPortStr','LConn',...
                    'DstBlkPortIdx',1),block);
                    if(strcmp(grounded,'off'))





                        negInPortBlk=get_param([block,'/In-'],...
                        'Position');
                        InPortBlks_y_mid=(negInPortBlk(2)+...
                        posInPortBlk(4))/2;
                        set_param([block,'/IRFilter'],'Position',...
                        [posInPortBlk_x_mid-...
                        posMixerBlk_dx/2+Blks_halfway...
                        ,InPortBlks_y_mid-posMixerBlk_dy/2...
                        ,posInPortBlk_x_mid+posMixerBlk_dx/2+...
                        Blks_halfway,InPortBlks_y_mid+...
                        posMixerBlk_dy/2]);
                        phtemp=get_param([block,'/In-'],'PortHandles');
                        simrfV2deletelines(get(phtemp.RConn(1),'Line'));
                        simrfV2connports(struct('SrcBlk','IRFilter',...
                        'SrcBlkPortStr','LConn','SrcBlkPortIdx',...
                        2,'DstBlk','In-','DstBlkPortStr',...
                        'RConn','DstBlkPortIdx',1),block);
                        simrfV2connports(struct('SrcBlk','IRFilter',...
                        'SrcBlkPortStr','RConn','SrcBlkPortIdx',...
                        2,'DstBlk','Mixer','DstBlkPortStr',...
                        'LConn','DstBlkPortIdx',2),block);
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

                fnames=fieldnames(rfModMaskParams);
                IRfnames=fnames(cellfun(@(x)~isempty(x),...
                regexp(fnames,'IR$')));
                paramNameValPair={};
                for IRfnameInd=1:length(IRfnames)
                    IRfname=IRfnames{IRfnameInd};
                    ParamVal=rfModMaskParams.(IRfname);
                    if isnumeric(ParamVal)
                        ParamVal=mat2str(ParamVal);
                    end
                    paramNameValPair(:,end+1)=...
                    {IRfname(1:end-2);ParamVal};%#ok<AGROW>
                end
                set_param([block,'/IRFilter'],paramNameValPair{:});
            else
                if~isempty(repIRFiltIBlkFullPath)


                    phIRFiltIBlk=get_param(repIRFiltIBlkFullPath,...
                    'PortHandles');

                    simrfV2deletelines(get(phIRFiltIBlk{1}.LConn,'Line'));

                    simrfV2deletelines(get(phIRFiltIBlk{1}.RConn,'Line'));
                    delete_block(repIRFiltIBlkFullPath);
                    simrfV2connports(struct('SrcBlk','In+',...
                    'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                    'DstBlk','Mixer','DstBlkPortStr',...
                    'LConn','DstBlkPortIdx',1),block);
                    if(strcmp(grounded,'off'))



                        phInNegBlk=get_param([block,'/In-'],...
                        'PortHandles');
                        simrfV2deletelines(get(phInNegBlk.RConn,'Line'));
                        simrfV2connports(struct('SrcBlk','In-',...
                        'SrcBlkPortStr','RConn','SrcBlkPortIdx',1,...
                        'DstBlk','Mixer','DstBlkPortStr',...
                        'LConn','DstBlkPortIdx',2),block);
                    end
                end
            end



            evalin('caller',['rfModParams.LO.CarrierFreq=0;',...
            'rfModParams.LO.PhaseNoiseOffset=1;',...
            'rfModParams.LO.PhaseNoiseLevel=-Inf;']);
            set_param([block,'/LO'],'AddPhaseNoise',...
            rfModMaskParams.AddPhaseNoise);
            set_param([block,'/LO'],'AutoImpulseLength',...
            rfModMaskParams.AutoImpulseLengthPN);
            if ischar(rfModMaskParams.ImpulseLengthPN)
                set_param([block,'/LO'],'ImpulseLength',...
                rfModMaskParams.ImpulseLengthPN);
            else
                set_param([block,'/LO'],'ImpulseLength',...
                mat2str(rfModMaskParams.ImpulseLengthPN));
            end
            set_param([block,'/LO'],'ImpulseLength_unit',...
            rfModMaskParams.ImpulseLength_unitPN);


            if isinf(rfModMaskParams.Isolation)
                Z_Isolation_str='ZisInf_Isolation';
                srcBlk='simrfV2_lib/Elements/OPEN_RF';
            elseif isreal(rfModMaskParams.Zout)
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
                'rfModParams.Z_Isolation.Impedance=50;');
                simrfV2_set_param([block,'/',Z_Isolation_str],...
                'Impedance','rfModParams.Z_Isolation.Impedance');
            elseif strcmp(Z_Isolation_str,'R_Isolation')
                evalin('caller',...
                'rfModParams.R_Isolation.Resistance=50;');
                simrfV2_set_param([block,'/',Z_Isolation_str],...
                'Resistance','rfModParams.R_Isolation.Resistance');

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
        rfModMaskParams=createMaskParamsStruct(block,false);
        MaskParamsStructValidations(rfModMaskParams);

    case 'simrfDelete'

    case 'simrfCopy'

    case 'simrfDefault'

    end

end

function MaskParamsStruct=createMaskParamsStruct(block,copyInvisible)
    mwsv=get_param(block,'MaskWSVariables');
    rfModParmNames={mwsv.Name};
    rfModParmValues={mwsv.Value};
    rfModParmUnitsIdxs=zeros(1,length(rfModParmNames));
    for rfModParmIdx=1:length(rfModParmNames)
        rfModParmName=rfModParmNames{rfModParmIdx};
        Inval=rfModParmValues{rfModParmIdx};
        rfModParmUnitInx=ismember(rfModParmNames,...
        [rfModParmName,'_unit']);
        if any(rfModParmUnitInx)

            UnitVal=rfModParmValues{rfModParmUnitInx};
            if strcmpi(UnitVal,'None')
                Source_linear_gain=...
                rfModParmValues(strcmpi(rfModParmNames,...
                'Source_linear_gain'));


                if strcmpi(Source_linear_gain,'Available power gain')
                    Outval=10*log10(rfModParmValues{rfModParmIdx});
                else
                    Outval=20*log10(rfModParmValues{rfModParmIdx});
                end
            elseif strcmpi(UnitVal,'Rad')
                Outval=rfModParmValues{rfModParmIdx}*180/pi;
            elseif strcmpi(UnitVal,'W')
                Outval=10*...
                log10(rfModParmValues{rfModParmIdx})+30;
            elseif strcmpi(UnitVal,'mW')
                Outval=10*log10(rfModParmValues{rfModParmIdx});
            elseif strcmpi(UnitVal,'dBW')
                Outval=rfModParmValues{rfModParmIdx}+30;
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
            rfModParmValues{rfModParmIdx}=Outval;
            rfModParmUnitsIdxs=or(rfModParmUnitsIdxs,...
            rfModParmUnitInx);
        end




        keepFieldsEmpty={'IP2','IP3','P1dB','Psat'};
        if isempty(rfModParmValues{rfModParmIdx})
            MaskNames=get_param(block,'MaskNames');
            idxMaskParams=cell2struct(num2cell(1:length(MaskNames)),...
            MaskNames,2);
            maskVis=get_param(block,'MaskVisibilities');
            if(copyInvisible&&~strcmpi(maskVis{idxMaskParams.(...
                rfModParmNames{rfModParmIdx})},'on')&&...
                ~any(strcmpi(rfModParmNames{rfModParmIdx},...
                keepFieldsEmpty)))
                rfModParmValues{rfModParmIdx}=...
                get_param(block,rfModParmNames{rfModParmIdx});
            end
        end
    end

    rfModParmRemoveInx=or(rfModParmUnitsIdxs,...
    ismember(rfModParmNames,'InternalGrounding'));

    rfModParmRemoveInx=or(rfModParmRemoveInx,...
    ismember(rfModParmNames,'classname'));

    rfModParmRemoveInx=or(rfModParmRemoveInx,...
    ismember(rfModParmNames,'rfModParams'));

    rfModParmRemoveInx=or(rfModParmRemoveInx,...
    ismember(rfModParmNames,'rfModMaskParams'));

    MaskParamsStruct=cell2struct(rfModParmValues(...
    not(rfModParmRemoveInx)),...
    rfModParmNames(not(rfModParmRemoveInx)),2);

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
    'LO to Out isolation');
    validateattributes(MaskParamsStruct.NF,{'numeric'},...
    {'nonempty','scalar','real','nonnegative','finite'},...
    '','Modulator Noise figure');
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