function varargout=simrfV2antenna(block,action)







    top_sys=bdroot(block);

    isRunningorPaused=any(strcmpi(get_param(top_sys,'SimulationStatus'),...
    {'running','paused'}));




    MaskWSValues=simrfV2getblockmaskwsvalues(block);
    if~isRunningorPaused&&~isfield(MaskWSValues,'antParams')
        evalin('caller',['antParams.gammaAnt = sparameters(0,1e9,50);',...
        'antParams.CarrierFreqInc = 1e9;',...
        'antParams.CarrierFreqRad = 1e9;',...
        'antParams.normFI_freqs = 1e9;',...
        'antParams.normFI_theta = 1/sqrt(2);',...
        'antParams.normFI_phi = 1/sqrt(2);',...
        'antParams.normhV_theta = sqrt(2);',...
        'antParams.normhV_phi = -sqrt(2);']);
    end
    varargout={};
    if strcmpi(top_sys,'simrfV2elements')
        if nargout>0
            antParams=defaultAntParams(1);
            varargout={antParams};
        end
        return
    end




    switch(action)
    case 'simrfInit'
        antParams=defaultAntParams(1);


        if isRunningorPaused
            if nargout>0
                varargout={antParams};
            end
            return
        end




        MaskVals=get_param(block,'MaskValues');
        idxMaskNames=simrfV2getblockmaskparamsindex(block);

        internalGrounding=lower(MaskVals{idxMaskNames.InternalGrounding});
        gndOn=strcmpi(internalGrounding,'on');
        InputIncWaveOn=strcmp(get_param(block,'InputIncWave'),'on');
        OutputRadWaveOn=strcmp(get_param(block,'OutputRadWave'),'on');
        isUpdating=regexpi(get_param(top_sys,'SimulationStatus'),...
        '^(updating|initializing)$');
        antSrc=get_param(block,'AntennaSource');
        isWkSpcObj=strcmp(antSrc,'Antenna object');
        isAntDesgn=strcmp(antSrc,'Antenna Designer');
        prevAntSrc=get_param(block,'PrevAppliedAntSource');
        cacheData=simrfV2_antcachefit(block,MaskWSValues);
        if~strcmp(antSrc,prevAntSrc)
            set_param(block,'PrevAppliedAntSource',antSrc);
        end
        ports=1;
        if isWkSpcObj||isAntDesgn
            transBlkName='TransAntIinMeasurement';
            recBlkName='RecAntVoc';
            auxData=get_param([block,'/AuxData'],'UserData');
            if isfield(auxData,'sparam')&&~isempty(auxData.sparam)
                antParams.gammaAnt=auxData.sparam;
            else
                antParams.gammaAnt=sparameters(0,1e9,50);
            end
            if isWkSpcObj
                antFieldName='OrigAntenna';
            else
                antFieldName='IntAntenna';
            end
            if isfield(cacheData,antFieldName)&&...
                ~isempty(cacheData.(antFieldName))
                antObj=cacheData.(antFieldName);
                if isprop(antObj,'FeedLocation')
                    ports=size(antObj.FeedLocation,1);
                end
                [isAntValid,FPortFldName,FFieldFldName]=isValidAnt(antObj);
                missingFIData=(OutputRadWaveOn&&...
                isempty(cacheData.normFIthetaDep))||...
                (InputIncWaveOn&&isempty(cacheData.normFIthetaArr));
                if isAntValid&&~missingFIData&&...
                    strcmp(antObj.info.IsSolved,'true')&&...
                    ~(isempty(antObj.info.(FPortFldName))&&...
                    isempty(antObj.info.(FFieldFldName)))&&...
                    isfield(auxData,'sparam')&&...
                    ~isempty(auxData.sparam)
                    antParams.normFI_freqs=unique(antObj.info.(FPortFldName));



                    if~isempty(cacheData.normFIthetaDep)
                        shiftDir=-1-(auxData.sparam.NumPorts==1);



                        convFI=shiftdim(-cacheData.normFIthetaDep,shiftDir);
                        convFI(1,1,:)=2*convFI(1,1,:)-0.5;
                        antParams.normFI_theta=...
                        cat(1,convFI,repmat(zeros(size(convFI)),...
                        [size(convFI,2)-1,1,1]));



                        convFI=shiftdim(-cacheData.normFIphiDep,shiftDir);
                        convFI(1,1,:)=2*convFI(1,1,:)-0.5;
                        antParams.normFI_phi=...
                        cat(1,convFI,repmat(zeros(size(convFI)),...
                        [size(convFI,2)-1,1,1]));
                    end






                    if~isempty(cacheData.normFIthetaArr)
                        perm=[1,3,2]+(auxData.sparam.NumPorts==1)*...
                        [1,0,-1];
                        convFI=permute(cacheData.normFIthetaArr,perm);
                        convFI(1,1,:)=0.5-2*convFI(1,1,:);
                        antParams.normhV_theta=...
                        cat(2,2*convFI,repmat(zeros(size(convFI)),...
                        [1,size(convFI,1)-1,1]));
                        convFI=permute(cacheData.normFIphiArr,perm);
                        convFI(1,1,:)=0.5-2*convFI(1,1,:);
                        antParams.normhV_phi=...
                        cat(2,2*convFI,repmat(zeros(size(convFI)),...
                        [1,size(convFI,1)-1,1]));
                    end
                else
                    antParams=defaultAntParams(ports);
                end
            else
                antParams=defaultAntParams(1);
            end
            if~isempty(auxData)&&isfield(auxData,'sparam')&&...
                auxData.sparam.NumPorts>65
                error(message(['simrf:simrfV2errors:'...
                ,'AntennaMustHaveLessThan65Port']));
            end
        else
            transBlkName='TransAntIinMeasurementIso';
            recBlkName='RecAntVocIso';
        end


        mo=Simulink.Mask.get(block);
        if ports==1
            mo.BlockDVGIcon='RFBlksIcons.antenna';
        else
            mo.BlockDVGIcon='RFBlksIcons.antennaarray';
        end


        if InputIncWaveOn
            m=['port_label(''Input'',1,''\bf{RX}'','...
            ,'''texmode'', ''on'')',newline];
        else
            m='';
        end
        if OutputRadWaveOn
            m=sprintf(['%sport_label(''Output'',1,'''...
            ,'\\bf{TX}'',''texmode'', ''on'')'],m);
        end
        switch internalGrounding
        case 'on'
            if ports==1
                m=sprintf('%s\nport_label(''LConn'',1,''RF'')',m);
            else
                m=sprintf('%s\nfor portInd = 1:%d',m,ports);
                m=sprintf(['%s\nport_label(''LConn'',portInd,'...
                ,'[''RF'' num2str(portInd)]);'],m);
                m=sprintf('%s\nend',m);
            end
        case 'off'
            if ports==1
                m=sprintf('%s\nport_label(''LConn'',1,''RF+'')',m);
                m=sprintf('%s\nport_label(''LConn'',2,''RF-'')',m);
            else
                m=sprintf('%s\nfor portInd = 1:%d',m,ports);
                m=sprintf(['%s\nport_label(''LConn'',portInd*2-1,'...
                ,'[''RF'' num2str(portInd) ''+'']);'],m);
                m=sprintf(['%s\nport_label(''LConn'',portInd*2,'...
                ,'[''RF'' num2str(portInd) ''-'']);'],m);
                m=sprintf('%s\nend',m);
            end
        end
        m=sprintf('%s\nsimrfV2antenna(gcb, ''SimRFmaskDisplay'');',m);
        simrfV2_set_param(block,'MaskDisplay',m)



        freqs=getCarrierFreqs(MaskWSValues,InputIncWaveOn,OutputRadWaveOn);
        if~isempty(freqs)
            designFreq=extractFirstNonDc(freqs);
            cacheData.DesignFreq=designFreq;
            cacheData.DesignFreqSrc='AntennaBlk';
            set_param(block,'UserData',cacheData);
        elseif isfield(cacheData,'DesignFreqSrc')&&...
            ~strcmp(cacheData.DesignFreqSrc,'AntennaBlk')







            s=settings;
            if hasGroup(s,'antenna')
                if isprop(s.antenna,'Decaf')&&s.antenna.Decaf.ActiveValue
                    auxData=get_param([block,'/AuxData'],'UserData');
                    if isfield(auxData,'App')&&~isempty(auxData.App)
                        ad=auxData.App;
                    else
                        ad=[];
                    end
                    if~isempty(ad)&&isa(ad,...
                        'em.internal.antennaExplorer.AntennaDesigner')&&...
                        isvalid(ad)&&isvalid(ad.App.AppContainer)&&...
                        ad.App.AppContainer.State~="TERMINATED"&&...
                        ad.App.AppContainer.WindowState~="CLOSED"
                        cacheData=GetDesignFreqFromSolver(block,cacheData);
                        set_param(block,'UserData',cacheData);
                    end
                else
                    md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;%#ok<JAPIMATHWORKS>
                    gr=md.getGroup(cacheData.appToolGrpName);
                    if~isempty(gr)
                        cacheData=GetDesignFreqFromSolver(block,cacheData);
                        set_param(block,'UserData',cacheData);
                    end
                end
            end
        end

        oldInputIncWaveOn=~isempty(simrfV2_find_repblk(block,'^RX$'));
        diffInputIncWave=xor(oldInputIncWaveOn,InputIncWaveOn);
        oldOutputRadWaveOn=~isempty(simrfV2_find_repblk(block,'^TX$'));
        diffOutputRadWave=xor(oldOutputRadWaveOn,OutputRadWaveOn);
        rfMinus=simrfV2_find_repblk(block,'RF-');

        if isempty(rfMinus)
            oldInternalGrounding='on';
        else
            oldInternalGrounding='off';
        end
        sameGrounding=strcmpi(internalGrounding,oldInternalGrounding);
        hPorts=find_system(block,'LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'FindAll','on',...
        'RegExp','on','Name',...
        'RF[1-9]\d*\+');
        portNum=length(hPorts)+1;


        recBlockChanged=false;
        assignin('caller','antParams',antParams);
        currentRecBlk=simrfV2_find_repblk(block,'RecAntVoc\w*');
        if diffInputIncWave
            if~InputIncWaveOn
                replace_block_if_diff(block,'RX',...
                'simulink','simulink/Sources/Ground',...
                'noInput');
                newRecBlk='RecAntNoVoc';
                ph=get_param([block,'/',currentRecBlk],'PortHandles');
                delete(get(ph.Inport,'Line'));
                recBlockChanged=simrfV2repblk(struct(...
                'RepBlk',currentRecBlk,...
                'SrcBlk',['simrfV2private/',newRecBlk],...
                'SrcLib','simrfV2private',...
                'DstBlk',newRecBlk,...
                'Param',{{'Orientation','down',...
                'PortNum',num2str(ports)}}),block);
            else
                replace_block_if_diff(block,'noInput',...
                'simulink','simulink/Sources/In1','RX');
                newRecBlk=recBlkName;
                ph=get_param([block,'/RecAntNoVoc'],'PortHandles');
                delete(get(ph.Inport,'Line'));
                recBlockChanged=simrfV2repblk(struct(...
                'RepBlk','RecAntNoVoc',...
                'SrcBlk',['simrfV2private/',recBlkName],...
                'SrcLib','simrfV2private',...
                'DstBlk',recBlkName,...
                'Param',{{'Orientation','down',...
                'CarrierFreq','antParams.CarrierFreqInc',...
                'normhVFreq','antParams.normFI_freqs',...
                'normhV_theta','antParams.normhV_theta',...
                'normhV_phi','antParams.normhV_phi',...
                'PortNum',num2str(ports)}}),block);
            end
        elseif~isempty(currentRecBlk)&&~strcmp(currentRecBlk,recBlkName)
            newRecBlk=recBlkName;
            ph=get_param([block,'/',currentRecBlk],'PortHandles');
            delete(get(ph.Inport,'Line'));
            recBlockChanged=simrfV2repblk(struct(...
            'RepBlk',currentRecBlk,...
            'SrcBlk',['simrfV2private/',recBlkName],...
            'SrcLib','simrfV2private',...
            'DstBlk',recBlkName,...
            'Param',{{'Orientation','down',...
            'CarrierFreq','antParams.CarrierFreqInc',...
            'normhVFreq','antParams.normFI_freqs',...
            'normhV_theta','antParams.normhV_theta',...
            'normhV_phi','antParams.normhV_phi',...
            'PortNum',num2str(ports)}}),block);
        end
        if recBlockChanged

            if strcmp(newRecBlk,'RecAntNoVoc')
                SLBlkIn='noInput';
            else
                SLBlkIn='RX';
            end
            add_line(block,[SLBlkIn,'/1'],[newRecBlk,'/1'],...
            'autorouting','on');
        end

        currentTransBlk=simrfV2_find_repblk(block,...
        'TransAntIinMeasurement\w*');
        transBlockChanged=false;
        if diffOutputRadWave
            if~OutputRadWaveOn
                replace_block_if_diff(block,'TX',...
                'simulink','simulink/Sinks/Terminator',...
                'noOutput');
                newtTransBlk='TransAntNoIinMeasurement';
                ph=get_param([block,'/',currentTransBlk],'PortHandles');
                delete(get(ph.Outport,'Line'));
                transBlockChanged=simrfV2repblk(struct(...
                'RepBlk',currentTransBlk,...
                'SrcBlk',['simrfV2private/',newtTransBlk],...
                'SrcLib','simrfV2private',...
                'DstBlk',newtTransBlk,...
                'Param',{{'Orientation','up',...
                'PortNum',num2str(ports)}}),block);
            else
                replace_block_if_diff(block,'noOutput',...
                'simulink','simulink/Sinks/Out1','TX');
                newtTransBlk=transBlkName;
                ph=get_param([block,'/TransAntNoIinMeasurement'],'PortHandles');
                delete(get(ph.Outport,'Line'));
                transBlockChanged=simrfV2repblk(struct(...
                'RepBlk','TransAntNoIinMeasurement',...
                'SrcBlk',['simrfV2private/',newtTransBlk],...
                'SrcLib','simrfV2private',...
                'DstBlk',newtTransBlk,...
                'Param',{{'Orientation','up',...
                'CarrierFreq','antParams.CarrierFreqRad',...
                'normFIFreq','antParams.normFI_freqs',...
                'normFI_theta','antParams.normFI_theta',...
                'normFI_phi','antParams.normFI_phi',...
                'PortNum',num2str(ports)}}),block);
            end
        elseif~isempty(currentTransBlk)&&...
            ~strcmp(currentTransBlk,transBlkName)
            newtTransBlk=transBlkName;
            ph=get_param([block,'/',currentTransBlk],'PortHandles');
            delete(get(ph.Outport,'Line'));
            transBlockChanged=simrfV2repblk(struct(...
            'RepBlk',currentTransBlk,...
            'SrcBlk',['simrfV2private/',newtTransBlk],...
            'SrcLib','simrfV2private',...
            'DstBlk',newtTransBlk,...
            'Param',{{'Orientation','up',...
            'CarrierFreq','antParams.CarrierFreqRad',...
            'normFIFreq','antParams.normFI_freqs',...
            'normFI_theta','antParams.normFI_theta',...
            'normFI_phi','antParams.normFI_phi',...
            'PortNum',num2str(ports)}}),block);
        end
        if transBlockChanged

            if strcmp(newtTransBlk,'TransAntNoIinMeasurement')
                SLBlkOut='noOutput';
            else
                SLBlkOut='TX';
            end
            add_line(block,[newtTransBlk,'/1'],[SLBlkOut,'/1'],...
            'autorouting','on');
        end

        if~sameGrounding

            for portInd=1:portNum
                if portInd==1
                    negPort='';
                else
                    negPort=num2str(portInd);
                end
                portOdd=mod(portInd,2);

                if~portOdd
                    DstBlkPort2='RConn';
                    DstBlkPortIdx2=2*floor(portInd/2);
                    dirPort='left';
                    dirGnd='right';
                else
                    DstBlkPort2='LConn';
                    DstBlkPortIdx2=2*floor(portInd/2)+2;
                    dirPort='right';
                    dirGnd='left';
                end
                if gndOn

                    negDstBlk=['Gnd',negPort];
                    replace_gnd_complete=simrfV2repblk(struct(...
                    'RepBlk',['RF',negPort,'-'],...
                    'SrcBlk','simrfV2elements/Gnd',...
                    'SrcLib','simrfV2elements',...
                    'DstBlk',negDstBlk,...
                    'Param',{{'Orientation',dirGnd}}),block);
                    negDstBlkPortStr='LConn';
                else

                    negDstBlk=['RF',negPort,'-'];
                    replace_gnd_complete=simrfV2repblk(struct(...
                    'RepBlk',['Gnd',negPort],...
                    'SrcBlk','nesl_utility_internal/Connection Port',...
                    'SrcLib','nesl_utility_internal',...
                    'DstBlk',negDstBlk,...
                    'Param',...
                    {{'Side','Left','Orientation',dirPort,...
                    'Port',num2str(portInd*2)}}),block);
                    negDstBlkPortStr='RConn';
                end
                if replace_gnd_complete

                    SrcBlk='Zin';
                    simrfV2connports(struct(...
                    'DstBlk',SrcBlk,...
                    'DstBlkPortStr',DstBlkPort2,...
                    'DstBlkPortIdx',DstBlkPortIdx2,...
                    'SrcBlk',negDstBlk,...
                    'SrcBlkPortStr',negDstBlkPortStr,...
                    'SrcBlkPortIdx',1),block)
                end
            end
        end

        if MaskWSValues.AddNoise
            simrfV2_set_param([block,'/Zin'],'AddNoise','on');
        else
            simrfV2_set_param([block,'/Zin'],'AddNoise','off');
        end

        FitTolImp=MaskWSValues.FitTolImp;

        if isWkSpcObj||isAntDesgn
            SparamRepresentationImp=MaskWSValues.SparamRepresentationImp;
            AutoImpulseLengthImp=get_param(block,'AutoImpulseLengthImp');
            impulse_length=simrfV2convert2baseunit(...
            MaskWSValues.ImpulseLengthImp,...
            MaskWSValues.ImpulseLengthImp_unit);
        else
            SparamRepresentationImp='Frequency domain';
            AutoImpulseLengthImp='off';
            impulse_length=0;
        end





        simrfV2_set_param([block,'/Zin'],'SparamRepresentation',...
        'Frequency domain');
        simrfV2_set_param([block,'/Zin'],'SparamRepresentation',...
        SparamRepresentationImp);
        simrfV2_set_param([block,'/Zin'],'FitTol',num2str(FitTolImp));
        simrfV2_set_param([block,'/Zin'],'ImpulseLength',...
        num2str(impulse_length));

        if OutputRadWaveOn
            transBlk=[block,'/',transBlkName];
            simrfV2_set_param(transBlk,'AutoImpulseLength',...
            AutoImpulseLengthImp);
            simrfV2_set_param(transBlk,'FitTol',num2str(FitTolImp));
            simrfV2_set_param(transBlk,'ImpulseLength',...
            num2str(impulse_length));





            simrfV2_set_param(transBlk,'SparamRepresentation',...
            'Frequency domain');
            simrfV2_set_param(transBlk,'SparamRepresentation',...
            SparamRepresentationImp);
        end
        if InputIncWaveOn
            recBlk=[block,'/',recBlkName];
            simrfV2_set_param(recBlk,'AutoImpulseLength',...
            AutoImpulseLengthImp);
            simrfV2_set_param(recBlk,'FitTol',num2str(FitTolImp));
            simrfV2_set_param(recBlk,'ImpulseLength',...
            num2str(impulse_length));





            simrfV2_set_param(recBlk,'SparamRepresentation',...
            'Frequency domain');
            simrfV2_set_param(recBlk,'SparamRepresentation',...
            SparamRepresentationImp);
        end

        if~isRunningorPaused
            if ports~=portNum||recBlockChanged||transBlockChanged

                load_system('simrfV2elements');
                antBlk='simrfV2elements/Antenna';
                phZin=get_param([antBlk,'/Zin'],'PortHandles');
                ConnPosZin=get(phZin.LConn(1),'Position');
                LConn2posZin=get(phZin.LConn(2),'Position');
                posRF1=get_param([antBlk,'/RF+'],'Position');
                posZin=get_param([antBlk,'/Zin'],'Position');
                portDist=posZin(1)-posRF1(1);
                PortWidthZin=LConn2posZin(2)-ConnPosZin(2);
                addSize=PortWidthZin*floor((ports+1)/2)*2;
                posZin(3)=posZin(1)+addSize;
                posZin(4)=posZin(2)+addSize;

                phRecBlk=get_param([antBlk,'/RecAntNoVoc'],'PortHandles');
                RConn1pos=get(phRecBlk.RConn(1),'Position');
                RConn2pos=get(phRecBlk.RConn(2),'Position');
                PortWidth=abs(RConn2pos(1)-RConn1pos(1));
                posRecBlk=get_param([antBlk,'/RecAntNoVoc'],'Position');
                addSize=PortWidth*ports*2;
                posRecBlk(3)=posRecBlk(1)+addSize;

                phTrnBlk=get_param([antBlk,'/TransAntIinMeasurementIso'],'PortHandles');
                LConn1pos=get(phTrnBlk.LConn(1),'Position');
                LConn2pos=get(phTrnBlk.LConn(2),'Position');
                PortWidth=abs(LConn1pos(1)-LConn2pos(1));
                posTrnBlk=get_param([antBlk,'/TransAntIinMeasurementIso'],'Position');
                addSize=PortWidth*ports*2;
                posTrnBlk(3)=posTrnBlk(1)+addSize;
                set_param([block,'/Zin'],'Position',posZin);
                recBlk=simrfV2_find_repblk(block,'RecAnt\w*');
                set_param([block,'/',recBlk],'Position',posRecBlk);
                trnBlk=simrfV2_find_repblk(block,'TransAnt\w*');
                set_param([block,'/',trnBlk],'Position',posTrnBlk);



                set_param([block,'/Zin'],'Sparam','antParams.gammaAnt.Parameters+1');
                set_param([block,'/Zin'],'Sparam','antParams.gammaAnt.Parameters');



                set_param([block,'/',recBlk],'PortNum',num2str(ports));





                set_param([block,'/',trnBlk],'PortNum',num2str(ports));




                OldElems=find_system(block,'LookUnderMasks','all',...
                'FollowLinks','on','SearchDepth',1,'FindAll','on',...
                'RegExp','on','Name',...
                'RF[1-9]\d*[\+-]|conn[1-9]\d*[rec|tran|zin]\d*|Gnd[1-9]\d*');
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

                phZin=get_param([block,'/Zin'],'PortHandles');
                posZin=get_param([block,'/Zin'],'Position');
                phRecBlk=get_param([block,'/',recBlk],'PortHandles');
                phTrnBlk=get_param([block,'/',trnBlk],'PortHandles');

                if get(phTrnBlk.LConn(2),'Line')==-1
                    ll=get(phZin.LConn(1),'Line');
                    if ll~=-1
                        delete_line(ll);
                    end
                    add_line(block,phTrnBlk.LConn(2),phZin.LConn(1),...
                    'autorouting','on');
                end

                if get(phTrnBlk.LConn(1),'Line')==-1
                    ll=get(phRecBlk.RConn(2),'Line');
                    if ll~=-1
                        delete_line(ll);
                    end
                    add_line(block,phTrnBlk.LConn(1),phRecBlk.RConn(2),...
                    'autorouting','on');
                elseif get(phRecBlk.RConn(2),'Line')==-1
                    ll=get(phTrnBlk.LConn(1),'Line');
                    delete_line(ll);
                    add_line(block,phRecBlk.RConn(2),phTrnBlk.LConn(1),...
                    'autorouting','on');
                end

                if get(phRecBlk.RConn(1),'Line')==-1
                    phRFPlus=get_param([block,'/RF+'],'PortHandles');
                    ll=get(phRFPlus.RConn(1),'Line');
                    if ll~=-1
                        delete_line(ll);
                    end
                    add_line(block,phRecBlk.RConn(1),phRFPlus.RConn(1),...
                    'autorouting','on');
                end

                for portInd=2:ports
                    portOdd=mod(portInd,2);
                    zinDir=2*portOdd-1;
                    phRecBlkPorts=phRecBlk.RConn([2*portInd-1,2*portInd]);
                    phTrnBlkPorts=phTrnBlk.LConn([2*portInd-1,2*portInd]);

                    if~portOdd
                        phZinPorts=phZin.RConn([2*floor(portInd/2)-1,2*floor(portInd/2)]);
                        dirPort='left';
                        dirConn='right';
                    else
                        phZinPorts=phZin.LConn([2*floor(portInd/2)+1,2*floor(portInd/2)+2]);
                        dirPort='right';
                        dirConn='left';
                    end
                    ConnPosZin=get(phZinPorts(1),'Position');
                    connPortX=posZin(3-2*portOdd)-zinDir*portDist;
                    connPortY=ConnPosZin(2)-floor(connPortHeight/2);
                    connPortp=[block,'/RF',num2str(portInd),'+'];
                    addConOrSetBlock(portInd>portNum,[],...
                    'simrfV2util1/Connection Port',...
                    connPortp,'Orientation',dirPort,...
                    'Position',...
                    [connPortX,connPortY,...
                    connPortX+connPortWidth,connPortY+connPortHeight]);

                    connLabelX=connPortX+7*zinDir*connLabelWidth;
                    connLabelYport=connPortY+floor(connPortHeight/2)-floor(connLabelHeight/2);
                    labelRec=['conn',num2str(portInd),'rec'];
                    connLabelRec=[block,'/',labelRec];
                    phConnPortp=get_param(connPortp,'PortHandles');
                    addConOrSetBlock(portInd>portNum,phConnPortp.RConn,...
                    'simrfV2util1/Connection Label',...
                    connLabelRec,'Label',labelRec,...
                    'Orientation',dirPort,...
                    'Position',...
                    [connLabelX,connLabelYport,connLabelX+connPortWidth,connLabelYport+connPortHeight]);

                    ConnPosRecBlk=get(phRecBlkPorts(1),'Position');
                    connLabelX=ConnPosRecBlk(1)-floor(connPortHeight/2);
                    connLabelY=ConnPosRecBlk(2)+connPortWidth;
                    connLabelRec=[block,'/',labelRec,'1'];
                    addConOrSetBlock(portInd>portNum,phRecBlkPorts(1),...
                    'simrfV2util1/Connection Label',...
                    connLabelRec,'Label',labelRec,...
                    'Orientation','down',...
                    'Position',...
                    [connLabelX,connLabelY,connLabelX+connPortHeight,connLabelY+connPortWidth]);

                    labelTrn=['conn',num2str(portInd),'tran'];
                    connLabelTrn=[block,'/',labelTrn];
                    ConnNegRecBlk=get(phRecBlkPorts(2),'Position');
                    connLabelX=ConnNegRecBlk(1)-floor(connPortHeight/2);
                    addConOrSetBlock(portInd>portNum,phRecBlkPorts(2),...
                    'simrfV2util1/Connection Label',...
                    connLabelTrn,'Label',labelTrn,...
                    'Orientation','down',...
                    'Position',...
                    [connLabelX,connLabelY,connLabelX+connPortHeight,connLabelY+connPortWidth]);

                    connLabelTrn=[block,'/',labelTrn,'1'];
                    ConnPosRecBlk=get(phTrnBlkPorts(1),'Position');
                    connLabelX=ConnPosRecBlk(1)-floor(connPortHeight/2);
                    connLabelY=ConnPosRecBlk(2)+connPortWidth;
                    addConOrSetBlock(portInd>portNum,phTrnBlkPorts(1),...
                    'simrfV2util1/Connection Label',...
                    connLabelTrn,'Label',labelTrn,...
                    'Orientation','down',...
                    'Position',...
                    [connLabelX,connLabelY,connLabelX+connPortHeight,connLabelY+connPortWidth]);

                    labelZin=['conn',num2str(portInd),'zin'];
                    connLabelZin=[block,'/',labelZin];
                    ConnNegRecBlk=get(phTrnBlkPorts(2),'Position');
                    connLabelX=ConnNegRecBlk(1)-floor(connPortHeight/2);
                    connLabelY=ConnNegRecBlk(2)+connPortWidth;
                    addConOrSetBlock(portInd>portNum,phTrnBlkPorts(2),...
                    'simrfV2util1/Connection Label',...
                    connLabelZin,'Label',labelZin,...
                    'Orientation','down',...
                    'Position',...
                    [connLabelX,connLabelY,connLabelX+connPortHeight,connLabelY+connPortWidth]);

                    connLabelZin=[block,'/',labelZin,'1'];
                    connLabelX=ConnPosZin(1)-zinDir*(1+portOdd)*connLabelWidth;
                    addConOrSetBlock(portInd>portNum,phZinPorts(1),...
                    'simrfV2util1/Connection Label',...
                    connLabelZin,'Label',labelZin,...
                    'Orientation',dirConn,...
                    'Position',...
                    [connLabelX,connLabelYport,connLabelX+connPortHeight,connLabelYport+connPortWidth]);

                    ConnPosZin=get(phZinPorts(2),'Position');
                    connPortY=ConnPosZin(2)-floor(connPortHeight/2);
                    if gndOn
                        connPortn=[block,'/Gnd',num2str(portInd)];
                        addConOrSetBlock(portInd>portNum,phZinPorts(2),...
                        'simrfV2elements/Gnd',...
                        connPortn,'Orientation',dirConn,...
                        'Position',...
                        [connPortX,connPortY,connPortX+connPortWidth,connPortY+connPortHeight]);
                    else
                        connPortn=[block,'/RF',num2str(portInd),'-'];
                        addConOrSetBlock(portInd>portNum,phZinPorts(2),...
                        'simrfV2util1/Connection Port',...
                        connPortn,'Orientation',dirPort,...
                        'Position',...
                        [connPortX,connPortY,connPortX+connPortWidth,connPortY+connPortHeight]);
                    end
                end
            end
        end

        maskObj=get_param(block,'MaskObject');

        if isAntDesgn
            antIcon=maskObj.getDialogControl('AntennaIcon');
            iconFile=cacheData.IntAntennaData.AntennaIcon;
            if~strcmp(iconFile,'GeneralAntennaIcon.png')
                iconFilePath=fullfile(matlabroot,'toolbox',...
                'antenna','antenna','+em','+internal',...
                '+antennaExplorer','+src',...
                '+galleryIcons',iconFile);
                if~exist(iconFilePath,'file')
                    iconFilePath=fullfile(matlabroot,'toolbox',...
                    'simrf','simrfV2masks','GeneralAntennaIcon.png');
                end
            else
                iconFilePath=fullfile(matlabroot,'toolbox',...
                'simrf','simrfV2masks',iconFile);
            end
            antIcon.FilePath=iconFilePath;
            antTypeTxt=maskObj.getDialogControl('AntennTypeText');
            antTypeTxt.Prompt=cacheData.IntAntennaData.AntennTypeText;
        end
        if isWkSpcObj||isAntDesgn
            update_modeling_pane(block,maskObj,idxMaskNames,...
            MaskWSValues);
        end

        if isUpdating


            antParams.CarrierFreqInc=simrfV2checkfreqs(...
            MaskWSValues.CarrierFreqInc,'gtez');
            antParams.CarrierFreqInc=simrfV2convert2baseunit(...
            antParams.CarrierFreqInc,...
            MaskVals{idxMaskNames.CarrierFreqInc_unit});

            antParams.CarrierFreqRad=simrfV2checkfreqs(...
            MaskWSValues.CarrierFreqRad,'gtez');
            antParams.CarrierFreqRad=simrfV2convert2baseunit(...
            antParams.CarrierFreqRad,...
            MaskVals{idxMaskNames.CarrierFreqRad_unit});
            if isWkSpcObj||isAntDesgn
                if InputIncWaveOn
                    validateattributes(MaskWSValues.rArr,{'numeric'},...
                    {'nonempty','numel',2,'real','finite'},'',...
                    'Direction of arrival');
                end
                if OutputRadWaveOn
                    validateattributes(MaskWSValues.rDep,{'numeric'},...
                    {'nonempty','numel',2,'real','finite'},'',...
                    'Direction of departure');
                end
            end
            if isWkSpcObj
                if isvarname(MaskVals{idxMaskNames.AntennaObj})
                    antObj=MaskWSValues.AntennaObj;
                    [isAntValid,FPortFldName,FFieldFldName]=...
                    isValidAnt(antObj);
                    if~isAntValid
                        antObjVar=get_param(block,'AntennaObj');
                        error(message(['simrf:simrfV2errors:'...
                        ,'InvalidAntennaObj'],['''',antObjVar,'''']));
                    end


                    if strcmp(antObj.info.IsSolved,'false')||...
                        (isempty(antObj.info.(FPortFldName))&&...
                        isempty(antObj.info.(FFieldFldName)))
                        error(message(['simrf:simrfV2errors:'...
                        ,'AntennaObjShouldBePreSolved']));
                    end


                    auxData=get_param([block,'/AuxData'],'UserData');
                    if~isfield(auxData,'Antenna')||...
                        isempty(auxData.Antenna)
                        error(message(['simrf:simrfV2errors:'...
                        ,'InvalidAntennaObj']));
                    end
                else
                    error(message(['simrf:simrfV2errors:'...
                    ,'InvalidAntObjVarName']));
                end
            elseif isAntDesgn
                antObj=cacheData.IntAntenna;
                if~isempty(antObj)
                    [isAntValid,FPortFldName,FFieldFldName]=...
                    isValidAnt(antObj);
                    if~isAntValid
                        error(message(['simrf:simrfV2errors:'...
                        ,'InvalidDesignedAnt']));
                    end


                    if strcmp(antObj.info.IsSolved,'false')||...
                        (isempty(antObj.info.(FPortFldName))&&...
                        isempty(antObj.info.(FFieldFldName)))
                        error(message(['simrf:simrfV2errors:'...
                        ,'AntennaDesignShouldBePreSolved']));
                    end


                    auxData=get_param([block,'/AuxData'],'UserData');
                    if~isfield(auxData,'Antenna')||...
                        isempty(auxData.Antenna)
                        error(message(['simrf:simrfV2errors:'...
                        ,'InvalidDesignedAnt']));
                    end
                else
                    error(message(['simrf:simrfV2errors:'...
                    ,'AntennaNotSpecified']));
                end
            else


                Z=MaskWSValues.Zin;
                Z0=50;
                simrfV2constants=simrfV2_constants();
                Rmin=value(simrfV2constants.Rmin,'Ohm');

                if OutputRadWaveOn||InputIncWaveOn
                    if OutputRadWaveOn
                        if~InputIncWaveOn
                            freq=antParams.CarrierFreqRad;
                        else
                            freq=freqUnique([antParams.CarrierFreqInc...
                            ,antParams.CarrierFreqRad],1e-8);
                        end
                    else
                        freq=antParams.CarrierFreqInc;
                    end
                    if numel(Z)==1
                        Z=Z*ones(1,numel(freq));
                    else
                        Z=reshape(Z,1,[]);
                        if(numel(Z)~=numel(freq))||...
                            (InputIncWaveOn&&OutputRadWaveOn&&...
                            ((numel(antParams.CarrierFreqRad)~=...
                            numel(antParams.CarrierFreqInc))||...
                            any(antParams.CarrierFreqRad~=...
                            antParams.CarrierFreqInc)))
                            error(message(['simrf:simrfV2errors:'...
                            ,'NeitherScalarNorSameVectorLength'],...
                            'Antenna impedance',['incident '...
                            ,'carrier frequencies'],['radiated '...
                            ,'carrier frequencies']));
                        end
                    end
                    validateattributes(Z,{'numeric'},...
                    {'nonempty','vector','finite'},'',...
                    'Antenna impedance');

                    index_dc=find(freq==0,1);


                    if isempty(index_dc)
                        [val,ind]=min(Z);
                        if real(val)<Rmin
                            Z_dc=Rmin;
                        else
                            Z_dc=real(Z(ind));
                        end
                        freq=[0,freq];
                        Z=[Z_dc,Z];
                    else

                        validateattributes(abs(imag(Z(index_dc))),...
                        {'numeric'},{'<=',1e-10},mfilename,...
                        'impedance to be real for zero frequency');
                        Z(index_dc)=real(Z(index_dc));
                    end

                    gamma=(Z-Z0)./(Z+Z0);


                    index_Gammainf=find(gamma==-Inf,1);
                    if~isempty(index_Gammainf)
                        gamma(index_Gammainf)=1e9;
                    end


                    [freq,ind]=sort(freq);
                    Z=Z(ind);
                    gamma=gamma(ind);


                    Gr=MaskWSValues.Gr;
                    if strcmp(MaskVals{idxMaskNames.Gr_unit},'dBi')
                        validateattributes(Gr,{'numeric'},...
                        {'nonempty','vector','finite','real'},...
                        '','Antenna Gain in dBi');
                        Gr=10.^(Gr/10);
                    else
                        validateattributes(Gr,{'numeric'},...
                        {'nonempty','vector','finite',...
                        'positive'},'','Antenna Gain');
                    end
                    if numel(Gr)==1
                        Gr=Gr*ones(1,numel(freq));
                    else
                        Gr=reshape(Gr,1,[]);
                        if isempty(index_dc)
                            Gr=[Gr(1),Gr];
                        end
                        if(numel(Gr)~=numel(freq))||...
                            (InputIncWaveOn&&OutputRadWaveOn&&...
                            (numel(antParams.CarrierFreqRad)~=...
                            numel(antParams.CarrierFreqInc)))
                            error(message(['simrf:simrfV2errors:'...
                            ,'NeitherScalarNorSameVectorLength'],...
                            'Antenna gain','incident',['radiated '...
                            ,'carrier frequencies']));
                        end
                    end
                    Gr=Gr(ind);
                else
                    Gr=1;
                    if numel(Z)>1
                        error(message(['simrf:simrfV2errors:'...
                        ,'AntImpNotScalar'],'Antenna impedance'));
                    else
                        validateattributes(Z,{'numeric'},...
                        {'nonempty','vector','finite'},'',...
                        'Antenna impedance');
                    end

                    freq=[0,2.1e9];
                    if real(Z)<Rmin
                        Z_dc=Rmin;
                    else
                        Z_dc=real(Z);
                    end

                    Z=[Z_dc,Z];
                    gamma=(Z-Z0)./(Z+Z0);


                    index_Gammainf=find(gamma==-Inf,1);
                    if~isempty(index_Gammainf)
                        gamma(index_Gammainf)=1e9;
                    end

                end

                antParams.gammaAnt=sparameters(gamma,freq,Z0);

                antParams.normFI_freqs=freq;




                antParams.normFI_theta=reshape(-sqrt(Gr.*real(Z)),1,...
                1,[]);
                antParams.normFI_phi=antParams.normFI_theta;
                antParams.normhV_theta=...
                reshape(-2*sqrt(Gr.*real(Z)),1,1,[]);
                antParams.normhV_phi=-antParams.normhV_theta;
            end
        end
        if nargout>0
            varargout={antParams};
        end
        return

    case 'AntennaDesignerCallback'
        cacheData=get_param(block,'UserData');


        OutputRadWaveOn=strcmp(get_param(block,'OutputRadWave'),'on');
        InputIncWaveOn=strcmp(get_param(block,'InputIncWave'),'on');
        freqs=getCarrierFreqs(MaskWSValues,InputIncWaveOn,OutputRadWaveOn);
        designFreq=extractFirstNonDc(freqs);
        if~isempty(designFreq)
            cacheData.DesignFreq=designFreq;
            cacheData.DesignFreqSrc='AntennaBlk';
        end
        s=settings;
        if hasGroup(s,'antenna')
            if isprop(s.antenna,'Decaf')&&s.antenna.Decaf.ActiveValue
                auxData=get_param([block,'/AuxData'],'UserData');
                if isfield(auxData,'App')&&~isempty(auxData.App)
                    ad=auxData.App;
                else
                    ad=[];
                end
                if isempty(ad)||~isa(ad,...
                    'em.internal.antennaExplorer.AntennaDesigner')||...
                    ~isvalid(ad)||~isvalid(ad.App.AppContainer)||...
                    ad.App.AppContainer.State=="TERMINATED"||...
                    ad.App.AppContainer.WindowState=="CLOSED"



                    if isempty(designFreq)
                        cacheData=GetDesignFreqFromSolver(block,cacheData);
                    end
                    set_param(block,'UserData',cacheData);
                    auxData.App=...
                    em.internal.antennaExplorer.AntennaDesigner(...
                    'SourceBlock',block,'UseAppContainer',true);
                    set_param([block,'/AuxData'],'UserData',auxData);
                else








                    if isempty(designFreq)&&...
                        isfield(cacheData,'DesignFreqSrc')&&...
                        ~strcmp(cacheData.DesignFreqSrc,'AntennaBlk')
                        cacheData=GetDesignFreqFromSolver(block,...
                        cacheData);
                    end
                    set_param(block,'UserData',cacheData);
                    bringToFront(ad.App.AppContainer);
                end
            else
                if isempty(cacheData.appToolGrpName)


                    if isempty(designFreq)
                        cacheData=GetDesignFreqFromSolver(block,cacheData);
                    end
                    set_param(block,'UserData',cacheData);
                    viewObj=em.internal.antennaExplorer.AntennaDesigner(...
                    'SourceBlock',block);
                    cacheData.appToolGrpName=viewObj.App.AppToolGroup.Name;
                    set_param(block,'UserData',cacheData);
                else
                    md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;%#ok<JAPIMATHWORKS>
                    gr=md.getGroup(cacheData.appToolGrpName);
                    if~isempty(gr)








                        if isempty(designFreq)&&...
                            isfield(cacheData,'DesignFreqSrc')&&...
                            ~strcmp(cacheData.DesignFreqSrc,'AntennaBlk')
                            cacheData=GetDesignFreqFromSolver(block,...
                            cacheData);
                        end
                        set_param(block,'UserData',cacheData);
                        gr.setSelected(true);
                    else






                        if isempty(designFreq)
                            cacheData=GetDesignFreqFromSolver(block,...
                            cacheData);
                        end
                        set_param(block,'UserData',cacheData);
                        viewObj=...
                        em.internal.antennaExplorer.AntennaDesigner(...
                        'SourceBlock',block);
                        cacheData.appToolGrpName=...
                        viewObj.App.AppToolGroup.Name;
                        set_param(block,'UserData',cacheData);
                    end
                end
            end
        end
        return

    case 'AntennaSourceCallback'
        if(~isRunningorPaused)
            haveAntTbx=builtin('license','test','Antenna_Toolbox')&&...
            ~isempty(ver('antenna'));
            MaskVis=get_param(block,'MaskVisibilities');
            idxMaskNames=simrfV2getblockmaskparamsindex(block);
            maskObj=get_param(block,'MaskObject');
            AntSrcInd=idxMaskNames.AntennaSource;
            if haveAntTbx
                if strcmp(maskObj.Parameters(AntSrcInd).Enabled,'off')
                    maskObj.Parameters(AntSrcInd).Enabled='on';
                    maskObj.Parameters(AntSrcInd).TypeOptions=...
                    {'Isotropic radiator';'Antenna Designer';...
                    'Antenna object'};
                end
            elseif strcmp(maskObj.Parameters(AntSrcInd).Enabled,'on')
                maskObj.Parameters(AntSrcInd).Value='Isotropic radiator';
                maskObj.Parameters(AntSrcInd).TypeOptions=...
                {'Isotropic radiator'};
                maskObj.Parameters(AntSrcInd).Enabled='off';
            end
            AntDialogControl(block,maskObj,MaskVis,idxMaskNames);
        end
        return

    case 'InputIncWaveCallback'
        if(~isRunningorPaused)
            MaskVis=get_param(block,'MaskVisibilities');
            idxMaskNames=simrfV2getblockmaskparamsindex(block);
            maskObj=get_param(block,'MaskObject');
            AntDialogControl(block,maskObj,MaskVis,idxMaskNames);
        end
        return

    case 'OutputRadWaveCallback'
        if(~isRunningorPaused)
            MaskVis=get_param(block,'MaskVisibilities');
            idxMaskNames=simrfV2getblockmaskparamsindex(block);
            maskObj=get_param(block,'MaskObject');
            AntDialogControl(block,maskObj,MaskVis,idxMaskNames);
        end
        return

    case 'SparamRepresentationCallback'
        maskObj=get_param(block,'MaskObject');
        idxMaskNames=simrfV2getblockmaskparamsindex(block);
        SparamRepresentationImp=maskObj.Parameters(...
        idxMaskNames.SparamRepresentationImp).Value;
        if(~isRunningorPaused)
            MaskVis=get_param(block,'MaskVisibilities');
            dlgChanged=AntDialogControl(block,maskObj,MaskVis,...
            idxMaskNames);
            AntennaSource=...
            maskObj.Parameters(idxMaskNames.AntennaSource).Value;

            if~strcmp(AntennaSource,'Isotropic radiator')
                if dlgChanged
                    simrfV2_set_param([block,'/Zin'],...
                    'SparamRepresentation',SparamRepresentationImp);
                    hBlkTrans=getSimulinkBlockHandle([block...
                    ,'/TransAntIinMeasurement']);
                    if hBlkTrans~=-1
                        simrfV2_set_param(hBlkTrans,...
                        'SparamRepresentation',...
                        SparamRepresentationImp);
                    end
                    hBlkRec=getSimulinkBlockHandle([block,'/RecAntVoc']);
                    if hBlkRec~=-1
                        simrfV2_set_param(hBlkRec,...
                        'SparamRepresentation',...
                        SparamRepresentationImp);
                    end
                end
                update_modeling_pane(block,maskObj,idxMaskNames);
            end
        end
        return

    case 'AutoImpulseLengthImpCallback'
        if(~isRunningorPaused)
            MaskVis=get_param(block,'MaskVisibilities');
            idxMaskNames=simrfV2getblockmaskparamsindex(block);
            maskObj=get_param(block,'MaskObject');
            dlgChanged=AntDialogControl(block,maskObj,MaskVis,...
            idxMaskNames);
            if dlgChanged
                AntennaSource=maskObj.Parameters(...
                idxMaskNames.AntennaSource).Value;
                if~strcmp(AntennaSource,'Isotropic radiator')
                    AutoImpulseLengthImp=maskObj.Parameters(...
                    idxMaskNames.AutoImpulseLengthImp).Value;
                    simrfV2_set_param([block,'/Zin'],...
                    'AutoImpulseLength',...
                    AutoImpulseLengthImp);
                    hBlkTrans=getSimulinkBlockHandle([block...
                    ,'/TransAntIinMeasurement']);
                    if hBlkTrans~=-1
                        simrfV2_set_param(hBlkTrans,...
                        'AutoImpulseLength',...
                        AutoImpulseLengthImp);
                    end
                    hBlkRec=getSimulinkBlockHandle([block,'/RecAntVoc']);
                    if hBlkRec~=-1
                        simrfV2_set_param(hBlkRec,'AutoImpulseLength',...
                        AutoImpulseLengthImp);
                    end
                end
            end
        end
        return

    case 'simrfDelete'
        s=settings;
        if hasGroup(s,'antenna')
            if isprop(s.antenna,'Decaf')&&s.antenna.Decaf.ActiveValue
                auxData=get_param([block,'/AuxData'],'UserData');
                if isfield(auxData,'App')&&~isempty(auxData.App)
                    ad=auxData.App;
                else
                    ad=[];
                end
                if~isempty(ad)&&isa(ad,...
                    'em.internal.antennaExplorer.AntennaDesigner')&&...
                    isvalid(ad)&&isvalid(ad.App.AppContainer)&&...
                    ad.App.AppContainer.State~="TERMINATED"&&...
                    ad.App.AppContainer.WindowState~="CLOSED"


                    ad.App.Model.SourceBlock=[];
                    close(ad.App.AppContainer);
                    auxData.App=[];
                    set_param([block,'/AuxData'],'UserData',auxData.App);
                end
            else
                cacheData=get_param(block,'UserData');
                if~isempty(cacheData.appToolGrpName)
                    md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;%#ok<JAPIMATHWORKS>
                    md.closeGroup(cacheData.appToolGrpName);
                end
            end
        end
        return
    case 'simrfCopy'


        cacheData=get_param(block,'UserData');
        s=settings;
        sDecafExists=hasGroup(s,'antenna')&&isprop(s.antenna,'Decaf');
        if~sDecafExists||~s.antenna.Decaf.ActiveValue
            cacheData.appToolGrpName=[];
        end
        if~isempty(cacheData.OrigAntenna)
            cacheData.OrigAntenna=copy(cacheData.OrigAntenna);
        end
        if~isempty(cacheData.IntAntenna)
            cacheData.IntAntenna=copy(cacheData.IntAntenna);
        end
        set_param(block,'UserData',cacheData);


        auxData=get_param([block,'/AuxData'],'UserData');
        auxDataChanged=false;
        if isfield(auxData,'Antenna')&&~isempty(auxData.Antenna)
            auxData.Antenna=copy(auxData.Antenna);
            auxDataChanged=true;
        end
        if sDecafExists&&s.antenna.Decaf.ActiveValue
            if isfield(auxData,'App')&&~isempty(auxData.App)
                auxData.App=[];
                auxDataChanged=true;
            end
        end
        if auxDataChanged
            set_param([block,'/AuxData'],'UserData',auxData);
        end
        return
    case 'SimRFmaskDisplay'
        m1=1;
        return
    case 'simrfDefault'

    end

    function[nport,npoles,single_sparam,achieved_error]=...
        get_fit_result(this)
        nport=NaN;
        npoles=NaN;
        achieved_error=NaN;
        single_sparam=false;
        if~isfield(this.Block.UserData,'RationalModel')
            return;
        end

        if isempty(this.Block.UserData.RationalModel.C)
            single_sparam=true;
            return;
        end

        nport=this.Block.UserData.NumPorts;

        if isfield(this.Block.UserData,'RationalModel')&&...
            ~isempty(this.Block.UserData.RationalModel.A)
            npoles=max(cellfun(@length,this.Block.UserData.RationalModel.A));
        end
        if isempty(this.Block.UserData.FitErrorAchieved)
            if isempty(this.Block.UserData.timestamp)&&...
                this.Block.UserData.hashcode==0
                achieved_error=-inf;
            end
        else
            achieved_error=this.Block.UserData.FitErrorAchieved;
        end
    end

    function dlgChanged=AntDialogControl(block,maskObj,MaskVis,idxMaskNames)
        dlgChanged=false;
        antennaSource=get_param(block,'AntennaSource');
        if strcmp(antennaSource,'Isotropic radiator')
            maskObj.getDialogControl('ImpModelingTab').Visible='off';
            maskObj.getDialogControl('AntennaObjContainer').Visible='off';
            maskObj.getDialogControl('DesButtonContainer').Visible='off';
            maskObj.getDialogControl('AntennaIconContainer').Visible='off';
            maskObj.getDialogControl('AntennaTypeContainer').Visible='off';
            maskObj.getDialogControl('DesBtnIntContainer').Visible='off';
            maskObj.getDialogControl('IsotropicContainer').Visible='on';
            maskObj.getDialogControl('rArrContainer').Visible='off';
            maskObj.getDialogControl('rDepContainer').Visible='off';
            if(strcmp(MaskVis{idxMaskNames.Zin},'off'))
                MaskVis{idxMaskNames.Zin}='on';
                MaskVis{idxMaskNames.AntennaObj}='off';
                MaskVis{idxMaskNames.rDep}='off';
                MaskVis{idxMaskNames.rDep_unit}='off';
                MaskVis{idxMaskNames.rArr}='off';
                MaskVis{idxMaskNames.rArr_unit}='off';
                MaskVis{idxMaskNames.SparamRepresentationImp}='off';
                dlgChanged=true;
            end
            showGr=false;
            if strcmp(get_param(block,'InputIncWave'),'on')
                maskObj.getDialogControl('IncidentWaveGroup').Visible='on';
                if(strcmp(MaskVis{idxMaskNames.CarrierFreqInc},'off'))
                    MaskVis{idxMaskNames.CarrierFreqInc}='on';
                    MaskVis{idxMaskNames.CarrierFreqInc_unit}='on';
                    dlgChanged=true;
                end
                showGr=true;
            else
                maskObj.getDialogControl('IncidentWaveGroup').Visible='off';
                if(strcmp(MaskVis{idxMaskNames.CarrierFreqInc},'on'))
                    MaskVis{idxMaskNames.CarrierFreqInc}='off';
                    MaskVis{idxMaskNames.CarrierFreqInc_unit}='off';
                    dlgChanged=true;
                end
            end
            if strcmp(get_param(block,'OutputRadWave'),'on')
                maskObj.getDialogControl('RadiatedWaveGroup').Visible='on';
                if(strcmp(MaskVis{idxMaskNames.CarrierFreqRad},'off'))
                    MaskVis{idxMaskNames.CarrierFreqRad}='on';
                    MaskVis{idxMaskNames.CarrierFreqRad_unit}='on';
                    dlgChanged=true;
                end
                showGr=true;
            else
                maskObj.getDialogControl('RadiatedWaveGroup').Visible='off';
                if(strcmp(MaskVis{idxMaskNames.CarrierFreqRad},'on'))
                    MaskVis{idxMaskNames.CarrierFreqRad}='off';
                    MaskVis{idxMaskNames.CarrierFreqRad_unit}='off';
                    dlgChanged=true;
                end
            end
            if showGr
                if(strcmp(MaskVis{idxMaskNames.Gr},'off'))
                    MaskVis{idxMaskNames.Gr}='on';
                    MaskVis{idxMaskNames.Gr_unit}='on';
                    dlgChanged=true;
                end
            elseif(strcmp(MaskVis{idxMaskNames.Gr},'on'))
                MaskVis{idxMaskNames.Gr}='off';
                MaskVis{idxMaskNames.Gr_unit}='off';
                dlgChanged=true;
            end
            if dlgChanged
                set_param(block,'MaskVisibilities',MaskVis)
            end
        else
            maskObj.getDialogControl('ImpModelingTab').Visible='on';
            maskObj.getDialogControl('IsotropicContainer').Visible='off';
            if(strcmp(MaskVis{idxMaskNames.Gr},'on'))
                MaskVis{idxMaskNames.Gr}='off';
                MaskVis{idxMaskNames.Gr_unit}='off';
                MaskVis{idxMaskNames.Zin}='off';
                MaskVis{idxMaskNames.SparamRepresentationImp}='on';
                isSparamRepImpTD=strcmp(maskObj.Parameters(...
                idxMaskNames.SparamRepresentationImp).Value,...
                'Time domain (rationalfit)');
                dlgChanged=true;
            else
                isSparamRepImpTD=strcmp(get_param(block,...
                'SparamRepresentationImp'),'Time domain (rationalfit)');
            end
            if strcmp(antennaSource,'Antenna object')
                maskObj.getDialogControl('DesButtonContainer').Visible='off';
                maskObj.getDialogControl('AntennaIconContainer').Visible='off';
                maskObj.getDialogControl('AntennaTypeContainer').Visible='off';
                maskObj.getDialogControl('DesBtnIntContainer').Visible='off';
                maskObj.getDialogControl('AntennaObjContainer').Visible='on';
                if(strcmp(MaskVis{idxMaskNames.AntennaObj},'off'))
                    MaskVis{idxMaskNames.AntennaObj}='on';
                    dlgChanged=true;
                end
            else
                if isempty(get_param(block,'UserData').IntAntenna)
                    maskObj.getDialogControl(...
                    'AntennaIconContainer').Visible='off';
                    maskObj.getDialogControl(...
                    'AntennaTypeContainer').Visible='off';
                    maskObj.getDialogControl('AntennDesButton').Prompt=...
                    '      Create Antenna...      ';
                else
                    maskObj.getDialogControl(...
                    'AntennaIconContainer').Visible='on';
                    maskObj.getDialogControl(...
                    'AntennaTypeContainer').Visible='on';
                    maskObj.getDialogControl('AntennDesButton').Prompt=...
                    '       Edit Antenna...       ';
                end
                maskObj.getDialogControl('AntennaObjContainer').Visible='off';
                maskObj.getDialogControl('DesButtonContainer').Visible='on';
                maskObj.getDialogControl('DesBtnIntContainer').Visible='on';

                if(strcmp(MaskVis{idxMaskNames.AntennaObj},'on'))
                    MaskVis{idxMaskNames.AntennaObj}='off';
                    dlgChanged=true;
                end
            end
            if strcmp(get_param(block,'InputIncWave'),'on')
                maskObj.getDialogControl('IncidentWaveGroup').Visible='on';
                if(strcmp(MaskVis{idxMaskNames.CarrierFreqInc},'off'))
                    MaskVis{idxMaskNames.CarrierFreqInc}='on';
                    MaskVis{idxMaskNames.CarrierFreqInc_unit}='on';
                    dlgChanged=true;
                end
                maskObj.getDialogControl('rArrContainer').Visible='on';
                if strcmp(MaskVis{idxMaskNames.rArr},'off')
                    MaskVis{idxMaskNames.rArr}='on';
                    MaskVis{idxMaskNames.rArr_unit}='on';
                    dlgChanged=true;
                end
            else
                maskObj.getDialogControl('IncidentWaveGroup').Visible='off';
                if(strcmp(MaskVis{idxMaskNames.CarrierFreqInc},'on'))
                    MaskVis{idxMaskNames.CarrierFreqInc}='off';
                    MaskVis{idxMaskNames.CarrierFreqInc_unit}='off';
                    dlgChanged=true;
                end
                maskObj.getDialogControl('rArrContainer').Visible='off';
                if strcmp(MaskVis{idxMaskNames.rArr},'on')
                    MaskVis{idxMaskNames.rArr}='off';
                    MaskVis{idxMaskNames.rArr_unit}='off';
                    dlgChanged=true;
                end

            end
            if strcmp(get_param(block,'OutputRadWave'),'on')
                maskObj.getDialogControl('RadiatedWaveGroup').Visible='on';
                if(strcmp(MaskVis{idxMaskNames.CarrierFreqRad},'off'))
                    MaskVis{idxMaskNames.CarrierFreqRad}='on';
                    MaskVis{idxMaskNames.CarrierFreqRad_unit}='on';
                    dlgChanged=true;
                end
                maskObj.getDialogControl('rDepContainer').Visible='on';
                if strcmp(MaskVis{idxMaskNames.rDep},'off')
                    MaskVis{idxMaskNames.rDep}='on';
                    MaskVis{idxMaskNames.rDep_unit}='on';
                    dlgChanged=true;
                end
            else
                maskObj.getDialogControl('RadiatedWaveGroup').Visible='off';
                if(strcmp(MaskVis{idxMaskNames.CarrierFreqRad},'on'))
                    MaskVis{idxMaskNames.CarrierFreqRad}='off';
                    MaskVis{idxMaskNames.CarrierFreqRad_unit}='off';
                    dlgChanged=true;
                end
                maskObj.getDialogControl('rDepContainer').Visible='off';
                if strcmp(MaskVis{idxMaskNames.rDep},'on')
                    MaskVis{idxMaskNames.rDep}='off';
                    MaskVis{idxMaskNames.rDep_unit}='off';
                    dlgChanged=true;
                end
            end
            if isSparamRepImpTD
                maskObj.getDialogControl(...
                'ContainerForFreqDomImp').Visible='off';
                maskObj.getDialogControl(...
                'ContainerForTimeDomImp').Visible='on';
                maskObj.getDialogControl(...
                'ImpulseLengthImpContainer').Visible='off';
                if(strcmp(MaskVis{idxMaskNames.FitTolImp},'off'))
                    MaskVis{idxMaskNames.FitTolImp}='on';
                    MaskVis{idxMaskNames.AutoImpulseLengthImp}='off';
                    MaskVis{idxMaskNames.ImpulseLengthImp}='off';
                    MaskVis{idxMaskNames.ImpulseLengthImp_unit}='off';
                    dlgChanged=true;
                end
            else
                maskObj.getDialogControl(...
                'ContainerForTimeDomImp').Visible='off';
                maskObj.getDialogControl(...
                'ContainerForFreqDomImp').Visible='on';
                maskObj.getDialogControl(...
                'ImpulseLengthImpContainer').Visible='on';
                if(strcmp(MaskVis{idxMaskNames.FitTolImp},'on'))
                    MaskVis{idxMaskNames.FitTolImp}='off';
                    MaskVis{idxMaskNames.AutoImpulseLengthImp}='on';
                    dlgChanged=true;
                end
                if strcmp(get_param(block,'AutoImpulseLengthImp'),'off')
                    maskObj.getDialogControl(...
                    'ImpulseLengthImpContainer').Visible='on';
                    if(strcmp(MaskVis{idxMaskNames.ImpulseLengthImp},'off'))
                        MaskVis{idxMaskNames.ImpulseLengthImp}='on';
                        MaskVis{idxMaskNames.ImpulseLengthImp_unit}='on';
                        dlgChanged=true;
                    end
                else
                    maskObj.getDialogControl(...
                    'ImpulseLengthImpContainer').Visible='off';
                    if(strcmp(MaskVis{idxMaskNames.ImpulseLengthImp},'on'))
                        MaskVis{idxMaskNames.ImpulseLengthImp}='off';
                        MaskVis{idxMaskNames.ImpulseLengthImp_unit}='off';
                        dlgChanged=true;
                    end
                end
            end
            if dlgChanged
                set_param(block,'MaskVisibilities',MaskVis)
            end
        end
    end

end

function replace_block_if_diff(block,RepBlk,SrcLib,SrcBlk,newName,...
    params)
    if nargin<6
        params={};
    end
    RepBlkFullPath=find_system(block,'LookUnderMasks','all',...
    'FollowLinks','on','SearchDepth',1,'Name',RepBlk);
    if((~isempty(RepBlkFullPath))&&...
        (~strcmpi(get_param(RepBlkFullPath{1},'ReferenceBlock'),SrcBlk)))
        load_system(SrcLib)
        replace_block(block,'LookUnderMasks','all','FollowLinks','on',...
        'SearchDepth',1,'Name',RepBlk,SrcBlk,'noprompt');
        params=[params,{'Name',newName}];
        set_param(RepBlkFullPath{1},params{:});
    end
end

function antParams=defaultAntParams(ports)
    antParams.gammaAnt=sparameters(zeros(ports),1e9,50);
    antParams.CarrierFreqInc=1e9;
    antParams.CarrierFreqRad=1e9;
    antParams.normFI_freqs=1e9;
    antParams.normFI_theta=1/sqrt(2)*[ones(1,ports);zeros(ports-1,ports)];
    antParams.normFI_phi=1/sqrt(2)*[ones(1,ports);zeros(ports-1,ports)];
    antParams.normhV_theta=sqrt(2)*[ones(1,ports);zeros(ports-1,ports)];
    antParams.normhV_phi=-sqrt(2)*[ones(1,ports);zeros(ports-1,ports)];
end



function[npoles,single_sparam,achieved_error]=get_fit_result(block,...
    levels)

    npoles=NaN;
    achieved_error=inf;
    single_sparam=false;

    if getSimulinkBlockHandle(block)==-1
        return
    end
    cacheData=simrfV2_getcachedata(block,levels,false);
    if~isfield(cacheData,'RationalModel')
        return;
    end

    if isempty(cacheData.RationalModel.C)
        single_sparam=true;
        npoles=0;
        achieved_error=-inf;
        return;
    end

    if isfield(cacheData,'RationalModel')&&...
        ~isempty(cacheData.RationalModel.A)
        npoles=max(cellfun(@length,cacheData.RationalModel.A));
    end
    if isempty(cacheData.FitErrorAchieved)
        if isempty(cacheData.timestamp)&&cacheData.hashcode==0
            achieved_error=-inf;
        end
    else
        achieved_error=cacheData.FitErrorAchieved;
    end

end

function update_modeling_pane(block,maskObj,idxMaskNames,MaskWSValues)
    if nargin==3


        SparamRepresentationImp=maskObj.Parameters(...
        idxMaskNames.SparamRepresentationImp).Value;
        reqFitTol=str2double(maskObj.Parameters(...
        idxMaskNames.FitTolImp).Value);
        InputIncWave=strcmp(maskObj.Parameters(...
        idxMaskNames.InputIncWave).Value,'on');
        OutputRadWave=strcmp(maskObj.Parameters(...
        idxMaskNames.OutputRadWave).Value,'on');
    else


        SparamRepresentationImp=MaskWSValues.SparamRepresentationImp;
        reqFitTol=MaskWSValues.FitTolImp;
        InputIncWave=MaskWSValues.InputIncWave;
        OutputRadWave=MaskWSValues.OutputRadWave;
    end
    if strcmpi(SparamRepresentationImp,'Time domain (rationalfit)')
        [npoles,single_sparam,achieved_error]=get_fit_result([block...
        ,'/Zin'],1);

        if single_sparam
            maxNpolesImp='0';
            acterrImp='-inf';

        elseif~single_sparam&&isnan(npoles)
            maxNpolesImp='N/A';
            acterrImp='N/A';
        else
            maxNpolesImp=num2str(npoles);
            acterrImp=num2str(achieved_error,'%4.2f');
        end
        warningImp=~isnan(reqFitTol)&&achieved_error>reqFitTol;

        NPolesText_Imp=maskObj.getDialogControl('NPolesText_Imp');
        newInstText=['        Number of required poles:    ',maxNpolesImp];
        if(~strcmp(NPolesText_Imp.Prompt,newInstText))
            NPolesText_Imp.Prompt=newInstText;
        end
        AchdErrText_Imp=maskObj.getDialogControl('AchievedErrorText_Imp');
        newInstText=['        Relative error achieved (dB): ',acterrImp];
        if(~strcmp(AchdErrText_Imp.Prompt,newInstText))
            AchdErrText_Imp.Prompt=newInstText;
        end
        warning_Imp=maskObj.getDialogControl('warning_Imp');
        if warningImp
            warning_Imp.Visible='on';
        else
            warning_Imp.Visible='off';
        end

        if InputIncWave
            [npoles,single_sparam,achieved_error]=...
            get_fit_result([block,'/RecAntVoc/normhV_theta'],2);
            [npoles(2),single_sparam(2),achieved_error(2)]=...
            get_fit_result([block,'/RecAntVoc/normhV_phi'],2);
        else
            npoles(1:2)=0;
            single_sparam(1:2)=true;
            achieved_error(1:2)=-inf;
        end
        if OutputRadWave
            [npoles(3),single_sparam(3),achieved_error(3)]=...
            get_fit_result([block...
            ,'/TransAntIinMeasurement/normFI_theta'],2);
            [npoles(4),single_sparam(4),achieved_error(4)]=...
            get_fit_result([block,'/TransAntIinMeasurement/normFI_phi'],2);
        else
            npoles(3:4)=0;
            single_sparam(3:4)=true;
            achieved_error(3:4)=-inf;
        end
        [~,maxInd]=max(achieved_error);

        if single_sparam(maxInd)
            maxNpolesnVEL='0';
            acterrnVEL='-inf';

        elseif~single_sparam(maxInd)&&isnan(npoles(maxInd))
            maxNpolesnVEL='N/A';
            acterrnVEL='N/A';
        else
            maxNpolesnVEL=num2str(npoles(maxInd));
            acterrnVEL=num2str(achieved_error(maxInd),'%4.2f');
        end
        warningnVEL=~isnan(reqFitTol)&&achieved_error(maxInd)>reqFitTol;

        NPolesText_nVEL=maskObj.getDialogControl('NPolesText_nVEL');
        newInstText=['        Number of required poles:    ',maxNpolesnVEL];
        if(~strcmp(NPolesText_nVEL.Prompt,newInstText))
            NPolesText_nVEL.Prompt=newInstText;
        end
        AchdErrText_nVEL=maskObj.getDialogControl('AchievedErrorText_nVEL');
        newInstText=['        Relative error achieved (dB): ',acterrnVEL];
        if(~strcmp(AchdErrText_nVEL.Prompt,newInstText))
            AchdErrText_nVEL.Prompt=newInstText;
        end
        warning_nVEL=maskObj.getDialogControl('warning_nVEL');
        if warningnVEL
            warning_nVEL.Visible='on';
        else
            warning_nVEL.Visible='off';
        end
    end
end
function[res,FPortFldName,FFieldFldName]=isValidAnt(ant)


    supClasses=superclasses(ant);
    isEmStruct=any(strcmp(supClasses,'em.EmStructures'));
    if~isEmStruct
        isWrStruct=any(strcmp(supClasses,'em.WireStructures'));
        FPortFldName='Frequency';
        FFieldFldName=FPortFldName;
    else

        isWrStruct=false;
        FPortFldName='PortFrequency';
        FFieldFldName='FieldFrequency';
    end
    res=(isEmStruct||isWrStruct)&&...
    any(strcmp(methods(ant),'info'))&&...
    any(strcmp(methods(ant),'sparameters'))&&...
    any(strcmp(methods(ant),'EHfields'));
end


function res=freqIsEq(A,B,relTol,absTol)
    if nargin==3
        res=abs(A-B)<relTol*max(abs(A),abs(B))+relTol;
    else
        res=abs(A-B)<relTol*max(abs(A),abs(B))+absTol;
    end
end
function[isMem,memInd]=freqIsMember(A,B,varargin)
    memInd=arrayfun(@(Ael)find(freqIsEq(Ael,[B(:);Ael],...
    varargin{:}),1),A);
    memInd(memInd>length(B))=0;
    isMem=logical(memInd);
end
function res=freqUnique(A,varargin)
    [~,memInd]=freqIsMember(A,A,varargin{:});
    res=A(unique(memInd));
end

function designFreq=extractFirstNonDc(freq)
    if~isempty(freq)
        freq=freqUnique(freq,1e-8);
        if abs(freq(1))<1e-3
            if length(freq)>1
                designFreq=freq(2);
            else
                designFreq=[];
            end
        else
            designFreq=freq(1);
        end
    else
        designFreq=[];
    end
end
function freqs=getCarrierFreqs(MaskWSValues,InputIncWaveOn,OutputRadWaveOn)
    if OutputRadWaveOn
        if isfield(MaskWSValues,'CarrierFreqRad')
            freqs=simrfV2convert2baseunit(...
            MaskWSValues.CarrierFreqRad,...
            MaskWSValues.CarrierFreqRad_unit);
            if InputIncWaveOn
                if isfield(MaskWSValues,'CarrierFreqInc')
                    freqs=[freqs,simrfV2convert2baseunit(...
                    MaskWSValues.CarrierFreqInc,...
                    MaskWSValues.CarrierFreqInc_unit)];
                else
                    freqs=[];
                end
            end
        else
            freqs=[];
        end
    else
        if InputIncWaveOn&&isfield(MaskWSValues,'CarrierFreqInc')
            freqs=...
            simrfV2convert2baseunit(MaskWSValues.CarrierFreqInc,...
            MaskWSValues.CarrierFreqInc_unit);
        else
            freqs=[];
        end
    end
end
function cacheData=GetDesignFreqFromSolver(block,cacheData)
    try
        [~,~,~,~,~,~,~,fundTones]=...
        simrfV2_find_solverparams(bdroot(block),block);
        cacheData.DesignFreq=extractFirstNonDc(fundTones);
        cacheData.DesignFreqSrc='SolverBlk';
    catch
        cacheData.DesignFreq=[];
        cacheData.DesignFreqSrc='None';
    end
end
function addConOrSetBlock(toAdd,hConnTo,srcBlk,varargin)

    if toAdd
        add_block(srcBlk,varargin{:});
    else
        set_param(varargin{:});
    end


    if~isempty(hConnTo)&&get(hConnTo,'Line')==-1
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

end