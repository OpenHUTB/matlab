function simrfV2recantvoc(block,action)







    top_sys=bdroot(block);

    isRunningorPaused=any(strcmpi(get_param(top_sys,'SimulationStatus'),...
    {'running','paused'}));

    if strcmpi(top_sys,'simrfV2private')
        return
    end




    switch(action)
    case 'simrfInit'


        if isRunningorPaused
            return
        end




        MaskWSValues=simrfV2getblockmaskwsvalues(block);

        ports=MaskWSValues.PortNum;
        hPorts=find_system(block,'LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'FindAll','on',...
        'RegExp','on','Name',...
        'RF[1-9]\d*\+');
        portNum=length(hPorts)+1;
        if ports~=portNum
            load_system('simrfV2_lib');
            posCurComb=get_param('simrfV2_lib/Elements/Signal Combiner_RF',...
            'Position');
            CurCombWidth=floor((posCurComb(3)-posCurComb(1))/2);
            CurCombHeight=posCurComb(4)-posCurComb(2);

            SThetaBlk=[block,'/normhV_theta'];


            set_param(SThetaBlk,'Sparam','2*normhV_theta');
            set_param(SThetaBlk,'Sparam','normhV_theta');
            posSTheta=get_param(SThetaBlk,'Position');
            posSTheta(3)=posSTheta(1)+CurCombWidth*floor((ports+1)/2)*8;
            set_param(SThetaBlk,'Position',posSTheta);
            phSTheta=get_param(SThetaBlk,'PortHandles');

            SPhiBlk=[block,'/normhV_phi'];


            set_param(SPhiBlk,'Sparam','2*normhV_phi');
            set_param(SPhiBlk,'Sparam','normhV_phi');
            posSPhi=get_param(SPhiBlk,'Position');
            posSPhi(3)=posSTheta(3);
            set_param(SPhiBlk,'Position',posSPhi);
            phSPhi=get_param(SPhiBlk,'PortHandles');

            midY=floor((posSPhi(2)+posSTheta(4))/2);
            OldElems=find_system(block,'LookUnderMasks','all',...
            'FollowLinks','on','SearchDepth',1,'FindAll','on',...
            'RegExp','on','Name','comb\d*|RF[1-9]\d*[\+-]|conn[1-9]\d*[theta|phi|neg]\d*');
            if~isempty(OldElems)
                OldElems2Rm=OldElems(str2double(regexp(get(OldElems,'name'),'[0-9]+','match','once'))>ports);
                delete(OldElems2Rm)
                unconnLines=find_system(block,'LookUnderMasks','all',...
                'FollowLinks','on','SearchDepth',1,'FindAll','on',...
                'Type','Line','Connected','off');
                delete_line(unconnLines)
            end

            load_system('simrfV2util1');
            posConnPort=get_param('simrfV2util1/Connection Port','Position');
            connPortWidth=posConnPort(3)-posConnPort(1);
            connPortHeight=posConnPort(4)-posConnPort(2);

            posConnLabel=get_param('simrfV2util1/Connection Label','Position');
            connLabelWidth=posConnLabel(3)-posConnLabel(1);
            connLabelHeight=posConnLabel(4)-posConnLabel(2);

            for portInd=2:ports

                portOdd=mod(portInd,2);
                combDir=2*portOdd-1;
                Yfar=midY-combDir*floor(CurCombHeight*1.5);
                Ynear=midY-combDir*(floor(CurCombHeight*1.5)-CurCombHeight);
                addConOrSetBlock(portInd>portNum,[],...
                'simrfV2_lib/Elements/Signal Combiner_RF',...
                [block,'/comb',num2str(portInd)],...
                'Position',[posSPhi(1)+CurCombWidth*4*(0.875+(portInd+portOdd-2)),...
                min(Ynear,Yfar),...
                posSPhi(1)+CurCombWidth*4*(1.125+(portInd+portOdd-2)),...
                max(Ynear,Yfar)],'Orientation','left');

                phComb=get_param([block,'/comb',num2str(portInd)],'PortHandles');
                if portInd>portNum
                    add_line(block,phComb.RConn(2),phComb.LConn(4),'autorouting','on');
                    add_line(block,phComb.LConn(4),phComb.LConn(2),'autorouting','off');
                end
                LConn1pos=get(phComb.RConn(1),'Position');
                connPortX=LConn1pos(1)-2*connPortWidth;
                connPortY=LConn1pos(2)-floor(connPortHeight/2);
                connPortp=[block,'/RF',num2str(portInd),'+'];
                addConOrSetBlock(portInd>portNum,phComb.RConn(1),...
                'simrfV2util1/Connection Port',...
                connPortp,'Position',...
                [connPortX,connPortY,connPortX+connPortWidth,...
                connPortY+connPortHeight],'Side','Right');

                LConn2pos=get(phComb.RConn(2),'Position');
                connPortY=LConn2pos(2)-floor(connPortHeight/2);
                connPortn=[block,'/RF',num2str(portInd),'-'];
                addConOrSetBlock(portInd>portNum,phComb.RConn(2),...
                'simrfV2util1/Connection Port',...
                connPortn,'Position',...
                [connPortX,connPortY,connPortX+connPortWidth,...
                connPortY+connPortHeight],'Side','Right');

                RConn1pos=get(phComb.LConn(1),'Position');
                connLabelX=RConn1pos(1)+2*connLabelWidth;
                connLabelY=RConn1pos(2)-floor(connLabelHeight/2);
                labelTheta=['conn',num2str(portInd),'theta'];
                connLabelTheta=[block,'/',labelTheta];
                addConOrSetBlock(portInd>portNum,phComb.LConn(1),...
                'simrfV2util1/Connection Label',...
                connLabelTheta,'Label',labelTheta,...
                'Position',...
                [connLabelX,connLabelY,connLabelX+connPortWidth,connLabelY+connPortHeight]);

                if portOdd
                    phSThetaPorts=phSTheta.LConn([2*floor(portInd/2)+1,2*floor(portInd/2)+2]);
                    phSPhiPorts=phSPhi.LConn([2*floor(portInd/2)+1,2*floor(portInd/2)+2]);
                    dirTheta='down';
                    dirPhi='up';
                else
                    phSThetaPorts=phSTheta.RConn([2*floor(portInd/2)-1,2*floor(portInd/2)]);
                    phSPhiPorts=phSPhi.RConn([2*floor(portInd/2)-1,2*floor(portInd/2)]);
                    dirTheta='up';
                    dirPhi='down';
                end
                ConnSThetapos=get(phSThetaPorts(1),'Position');
                connLabel1X=ConnSThetapos(1)-floor(connLabelHeight/2);
                connLabel1Y=ConnSThetapos(2)+(3*portOdd-2)*connLabelWidth;
                connLabelTheta=[block,'/',labelTheta,'1'];
                addConOrSetBlock(portInd>portNum,phSThetaPorts(1),...
                'simrfV2util1/Connection Label',...
                connLabelTheta,'Label',labelTheta,...
                'Orientation',dirTheta,...
                'Position',...
                [connLabel1X,connLabel1Y,connLabel1X+connPortWidth,connLabel1Y+connPortHeight]);

                labelPhi=['conn',num2str(portInd),'phi'];
                connLabelPhi=[block,'/',labelPhi];
                RConn3pos=get(phComb.LConn(3),'Position');
                connLabelY=RConn3pos(2)-floor(connLabelHeight/2);
                addConOrSetBlock(portInd>portNum,phComb.LConn(3),...
                'simrfV2util1/Connection Label',...
                connLabelPhi,'Label',labelPhi,...
                'Position',...
                [connLabelX,connLabelY,connLabelX+connPortWidth,connLabelY+connPortHeight]);

                ConnSPhipos=get(phSPhiPorts(1),'Position');
                connLabel1X=ConnSPhipos(1)-floor(connLabelHeight/2);
                connLabel1Y=ConnSPhipos(2)-(3*portOdd-1)*connLabelWidth;
                connLabelPhi=[block,'/',labelPhi,'1'];
                addConOrSetBlock(portInd>portNum,phSPhiPorts(1),...
                'simrfV2util1/Connection Label',...
                connLabelPhi,'Label',labelPhi,...
                'Orientation',dirPhi,...
                'Position',...
                [connLabel1X,connLabel1Y,connLabel1X+connPortWidth,connLabel1Y+connPortHeight]);

                labelNeg=['conn',num2str(portInd),'neg'];
                connLabelNeg=[block,'/',labelNeg];
                RConn4pos=get(phComb.LConn(4),'Position');
                connLabelY=RConn4pos(2)+floor(connLabelHeight/2);
                addConOrSetBlock(portInd>portNum,phComb.LConn(4),...
                'simrfV2util1/Connection Label',...
                connLabelNeg,'Label',labelNeg,...
                'Position',...
                [connLabelX,connLabelY,connLabelX+connPortWidth,connLabelY+connPortHeight]);

                ConnSThetaneg=get(phSThetaPorts(2),'Position');
                connLabel1X=ConnSThetaneg(1)-floor(connLabelHeight/2);
                connLabel1Y=ConnSThetaneg(2)+(3*portOdd-2)*connLabelWidth;
                connLabelNeg=[block,'/',labelNeg,'1'];
                addConOrSetBlock(portInd>portNum,phSThetaPorts(2),...
                'simrfV2util1/Connection Label',...
                connLabelNeg,'Label',labelNeg,...
                'Orientation',dirTheta,...
                'Position',...
                [connLabel1X,connLabel1Y,connLabel1X+connPortWidth,connLabel1Y+connPortHeight]);

                ConnSPhineg=get(phSPhiPorts(2),'Position');
                connLabel1X=ConnSPhineg(1)-floor(connLabelHeight/2);
                connLabel1Y=ConnSPhineg(2)-(3*portOdd-1)*connLabelWidth;
                connLabelNeg=[block,'/',labelNeg,'2'];
                addConOrSetBlock(portInd>portNum,phSPhiPorts(2),...
                'simrfV2util1/Connection Label',...
                connLabelNeg,'Label',labelNeg,...
                'Orientation',dirPhi,...
                'Position',...
                [connLabel1X,connLabel1Y,connLabel1X+connPortWidth,connLabel1Y+connPortHeight]);
            end
        end
        return

    end
end
function addConOrSetBlock(toAdd,hConnTo,srcBlk,varargin)
    if toAdd
        add_block(srcBlk,varargin{:});
        if~isempty(hConnTo)
            phConn=get_param(varargin{1},'PortHandles');
            BlkParent=get_param(varargin{1},'Parent');
            if strcmp(srcBlk,'simrfV2util1/Connection Port')
                add_line(BlkParent,hConnTo,phConn.RConn,...
                'autorouting','on');
            else
                add_line(BlkParent,hConnTo,phConn.LConn,...
                'autorouting','on');
            end

        end
    else
        set_param(varargin{:});
    end
end