function CCCVBatteryChargerCback(block,Parameter,varargin)






    switch Parameter

    case 'PlotCurves'

        CCCV_Param(block,1);

    case 'PlotCycles'

        CCCV_Param(block,2);

    case 'MaskParamUpdate'



        mValues=get_param(block,'MaskValues');
        sPreset=mValues{1};
        sS_type=mValues{3};
        bEff_en=strcmp(mValues{9},'on');
        bThd_en=strcmp(mValues{12},'on');
        bPf_en=strcmp(mValues{17},'on');
        sOut_mode=mValues{20};
        bDynint=strcmp(mValues{21},'on');
        bAbs_en=strcmp(mValues{24},'on');
        sAbs_end=mValues{26};
        bVoltcomp=strcmp(mValues{33},'on');

        switch sPreset
        case 'Custom specifications'
            ME={'on','on','on','on','on','on','on','on'...
            ,'on','on','on','on','on','on','on','on','on'...
            ,'on','on','on','on','on','on','on','on','on'...
            ,'on','on','on','on','on','on','on','on','on'};
        case 'Primax P4500F-3-125-10'
            ME={'on','off','off','off','off','off','off','off'...
            ,'on','off','off','on','off','off','off','off','on'...
            ,'off','off','off','off','off','off','off','off','off'...
            ,'off','off','off','off','off','off','off','off','off'};
        case 'Transtronic 020-0085-00'
            ME={'on','off','off','off','off','off','off','off'...
            ,'on','off','off','on','off','off','off','off','on'...
            ,'off','off','off','off','off','off','off','off','off'...
            ,'off','off','off','off','off','off','off','off','off'};
        end

        handleMask=Simulink.Mask.get(block);
        MV=get_param(block,'MaskVisibilities');

        switch sS_type
        case '3-phases AC (wye)'
            MV{4}='on';
            MV{6}='on';
            MV{7}='off';
            MV{8}='off';
            p=handleMask.getDialogControl('THDContainer');
            p.Visible='on';
            p=handleMask.getDialogControl('PFContainer');
            p.Visible='on';
        case '3-phases AC (delta)'
            MV{4}='off';
            MV{6}='on';
            MV{7}='off';
            MV{8}='off';
            p=handleMask.getDialogControl('THDContainer');
            p.Visible='on';
            p=handleMask.getDialogControl('PFContainer');
            p.Visible='on';
        case '1-phase AC'
            MV{4}='off';
            MV{6}='on';
            MV{7}='off';
            MV{8}='off';
            p=handleMask.getDialogControl('THDContainer');
            p.Visible='on';
            p=handleMask.getDialogControl('PFContainer');
            p.Visible='on';
        case 'DC'
            p=handleMask.getDialogControl('THDContainer');
            p.Visible='off';
            p=handleMask.getDialogControl('PFContainer');
            p.Visible='off';
            MV{4}='off';
            MV{6}='off';
            MV{7}='on';
            MV{8}='on';
        end

        switch sOut_mode
        case 'Constant Current - Constant Voltage (CCCV)'
            MV{22}='on';
            MV{23}='on';
            if bDynint
                MV{24}='off';
                MV{25}='off';
                MV{26}='off';
                MV{27}='off';
                MV{28}='off';
            else
                MV{24}='on';
                if bAbs_en
                    MV{25}='on';
                    MV{26}='on';
                    switch sAbs_end
                    case 'Time based'
                        MV{27}='on';
                        MV{28}='off';
                    case 'Current based'
                        MV{27}='off';
                        MV{28}='on';
                    end
                else
                    MV{25}='off';
                    MV{26}='off';
                    MV{27}='off';
                    MV{28}='off';
                end
            end
        case 'Constant Current only (CC)'
            MV{22}='on';
            MV{23}='off';
            MV{24}='off';
            MV{25}='off';
            MV{26}='off';
            MV{27}='off';
            MV{28}='off';
        case 'Constant Voltage only (CV)'
            MV{22}='off';
            MV{23}='on';
            MV{24}='off';
            MV{25}='off';
            MV{26}='off';
            MV{27}='off';
            MV{28}='off';
        end

        if bVoltcomp
            MV{34}='on';
            MV{35}='on';
        else
            MV{34}='off';
            MV{35}='off';
        end

        if bEff_en
            MV{10}='on';
            MV{11}='on';
        else
            MV{10}='off';
            MV{11}='off';
        end

        if bThd_en
            MV{13}='on';
            MV{14}='on';
            MV{15}='on';
            MV{16}='on';
        else
            MV{13}='off';
            MV{14}='off';
            MV{15}='off';
            MV{16}='off';
        end

        if bPf_en
            MV{18}='on';
            MV{19}='on';
        else
            MV{18}='off';
            MV{19}='off';
        end

        if~bdIsLibrary(bdroot(block))
            if strcmp(get_param(bdroot(block),'EditingMode'),'Restricted')
                ME{1}='off';ME{3}='off';ME{4}='off';ME{9}='off';ME{12}='off';
                ME{17}='off';ME{20}='off';ME{21}='off';ME{24}='off';ME{26}='off';ME{33}='off';
            end
        end

        set_param(block,'MaskVisibilities',MV);
        set_param(block,'MaskEnables',ME);

    case 'BlkPortUpdate'




        mValues=get_param(block,'MaskValues');
        vP_nom=getSPSmaskvalues(block,{'P_nom'});
        sS_type=mValues{3};
        vIn_freq=getSPSmaskvalues(block,{'in_freq'});
        bThd_en=strcmp(mValues{12},'on');
        sOut_mode=mValues{20};
        bDynint=strcmp(mValues{21},'on');
        vI_cst=getSPSmaskvalues(block,{'I_cst'});
        vV_cst=getSPSmaskvalues(block,{'V_cst'});
        bAbs_en=strcmp(mValues{24},'on');
        sAbs_end=mValues{26};
        bVoltcomp=strcmp(mValues{33},'on');


        blockName=[block,'/','Ta'];
        BlkType=get_param(blockName,'BlockType');
        Temp_block={[block,'/Model/DC current command/Temp. Comp.']};
        if bVoltcomp
            if strcmp(BlkType,'Constant')
                replace_block(blockName,'Name','Ta','Inport','noprompt');
                set_param(blockName,'Port','1');
                set_param(Temp_block{1},'LabelModeActiveChoice','Enabled');
            end
        else
            if strcmp(BlkType,'Inport')
                replace_block(blockName,'Name','Ta','Constant','noprompt');
                set_param(Temp_block{1},'LabelModeActiveChoice','Disabled');
            end
            set_param(blockName,'Value','nom_temp');
        end


        ABS_block={[block,'/Model/DC current command/ABS phase']};
        bcond=strcmp(sOut_mode,'Constant Current - Constant Voltage (CCCV)');
        if bcond&&~bDynint&&bAbs_en
            switch sAbs_end
            case 'Time based'
                set_param(ABS_block{1},'LabelModeActiveChoice','Timer');
            case 'Current based'
                set_param(ABS_block{1},'LabelModeActiveChoice','Current');
            end
        else
            set_param(ABS_block{1},'LabelModeActiveChoice','None');
        end


        blockName1=[block,'/','CC'];
        BlkType1=get_param(blockName1,'BlockType');
        blockName2=[block,'/','CV'];
        BlkType2=get_param(blockName2,'BlockType');
        if bDynint
            switch sOut_mode
            case 'Constant Current - Constant Voltage (CCCV)'
                if strcmp(BlkType1,'Constant')
                    replace_block(blockName1,'Name','CC','Inport','noprompt');
                end
                if strcmp(BlkType2,'Constant')
                    replace_block(blockName2,'Name','CV','Inport','noprompt');
                end
                if bVoltcomp
                    set_param(blockName1,'Port','2');
                    set_param(blockName2,'Port','3');
                else
                    set_param(blockName1,'Port','1');
                    set_param(blockName2,'Port','2');
                end
                h=2*vV_cst/100;
            case 'Constant Current only (CC)'
                if strcmp(BlkType1,'Constant')
                    replace_block(blockName1,'Name','CC','Inport','noprompt');
                end
                if strcmp(BlkType2,'Inport')
                    replace_block(blockName2,'Name','CV','Constant','noprompt');
                end
                set_param(blockName2,'Value','2*P_nom/I_cst');
                if bVoltcomp
                    set_param(blockName1,'Port','2');
                else
                    set_param(blockName1,'Port','1');
                end
                h=2*vP_nom/vI_cst/100;
            case 'Constant Voltage only (CV)'
                if strcmp(BlkType1,'Inport')
                    replace_block(blockName1,'Name','CC','Constant','noprompt');
                end
                set_param(blockName1,'Value','P_nom/V_cst');
                if strcmp(BlkType2,'Constant')
                    replace_block(blockName2,'Name','CV','Inport','noprompt');
                end
                if bVoltcomp
                    set_param(blockName2,'Port','2');
                else
                    set_param(blockName2,'Port','1');
                end
                h=2*vV_cst/100;
            end
        else
            if strcmp(BlkType1,'Inport')
                replace_block(blockName1,'Name','CC','Constant','noprompt');
            end
            bcond=strcmp(sOut_mode,'Constant Voltage only (CV)');
            if bcond
                set_param(blockName1,'Value','P_nom/V_cst');
            else
                set_param(blockName1,'Value','I_cst');
            end
            if strcmp(BlkType2,'Inport')
                replace_block(blockName2,'Name','CV','Constant','noprompt');
            end
            bcond=strcmp(sOut_mode,'Constant Current only (CC)');
            if bcond
                set_param(blockName2,'Value','P_nom/I_cst');
                h=vP_nom/vI_cst/100;
            else
                set_param(blockName2,'Value','V_cst');
                h=vV_cst/100;
            end
        end
        blockName=[block,'/Model/DC current command/Mode Selection/','Relay'];
        set_param(blockName,'OnSwitchValue',num2str(h));



        load_system('powerlib');
        MainPortUpdate(block);


        CCCV=varargin{1};
        blockName=[block,'/Model/AC current command/HARMS'];
        allblocks=get_param(blockName,'blocks');

        if contains([allblocks{:}],'sum')
            h=get_param([blockName,'/sum'],'LineHandles');
        elseif contains([allblocks{:}],'constant')
            h=get_param([blockName,'/constant'],'LineHandles');
        end
        delete_line(h.Inport);
        delete_line(h.Outport);

        ToKeep='HARMS';
        ToDelete=setdiff(allblocks,ToKeep);

        for i=1:length(ToDelete);delete_block([blockName,'/',ToDelete{i}]);end

        bcond=strcmp(sS_type,'DC');
        if bcond||~bThd_en
            block_add=[blockName,'/constant'];
            add_block('simulink/Commonly Used Blocks/Constant',block_add);
            set_param(block_add,'Position',[300,330,330,360]);
            set_param(block_add,'Value','0');
            add_line(blockName,['constant','/1'],['HARMS','/1']);
        else
            n=length(CCCV.ac.c_HARMS.f);
            add_str=blanks(n);
            for i=1:n
                add_str(i)='+';
            end

            block_add=[blockName,'/sum'];
            add_block('simulink/Math Operations/Add',block_add);
            set_param(block_add,'Position',[300,200,330,230+50*(length(CCCV.ac.c_HARMS.f)-1)]);
            set_param(block_add,'Inputs',add_str);
            add_line(blockName,['sum','/1'],['HARMS','/1']);

            d=(200+230+50*(length(CCCV.ac.c_HARMS.f)-1)-7.5)/2;
            set_param([blockName,'/HARMS'],'Position',[400,d,430,d+15]);
            for i=1:length(CCCV.ac.c_HARMS.f)
                b_name=['sine',num2str(CCCV.ac.c_HARMS.f(i)/(2*pi*vIn_freq))];
                block_sine=[blockName,'/',b_name];
                add_block('simulink/Sources/Sine Wave',block_sine);
                set_param(block_sine,'Position',[200,200+50*(i-1),230,230+50*(i-1)]);
                add_line(blockName,[b_name,'/1'],['sum','/',num2str(i)]);
                aString=['CCCV.ac.c_HARMS.a(',num2str(i),')'];
                set_param(block_sine,'Amplitude',aString);
                fString=['CCCV.ac.c_HARMS.f(',num2str(i),')'];
                set_param(block_sine,'Frequency',fString);
            end
        end


        blockName=[block,'/Model/AC current command/fcnTHD'];
        set_param(blockName,'Expression',CCCV.ac.s_THD);


        blockName=[block,'/Model/AC current command/fcnEFF'];
        set_param(blockName,'Expression',CCCV.ac.s_EFF);


        blockName=[block,'/Model/AC current command/fcnPF'];
        set_param(blockName,'Expression',CCCV.ac.s_PF);


        tfI=[block,'/Model/DC current command/','TFI'];
        tfV=[block,'/Model/DC current command/','TFV'];
        tpD=[block,'/Model/AC current command/','TPD'];
        uD=[block,'/Model/DC current command/','UD'];
        tpDb=[block,'/Model/AC current command/I_AC/3-phase AC/cA/delta/','tpDb'];
        tpDc=[block,'/Model/AC current command/I_AC/3-phase AC/cA/delta/','tpDc'];
        tpDB=[block,'/Model/AC current command/I_AC/3-phase AC/','tpDB'];
        tpDC=[block,'/Model/AC current command/I_AC/3-phase AC/','tpDC'];
        if CCCV.WantDiscreteModel
            bcond=strcmp(get_param(tfI,'BlockType'),'TransferFcn');
            if bcond
                replace_block(tfI,'Name','TFI','simulink/Discrete/Discrete Transfer Fcn','noprompt');
                set_param(tfI,'Denominator','CCCV.I.Denominator{1}');
                set_param(tfI,'Numerator','CCCV.I.Numerator{1}');
            end
            bcond=strcmp(get_param(tfV,'BlockType'),'TransferFcn');
            if bcond
                replace_block(tfV,'Name','TFV','simulink/Discrete/Discrete Transfer Fcn','noprompt');
                set_param(tfV,'Denominator','CCCV.V.Denominator{1}');
                set_param(tfV,'Numerator','CCCV.V.Numerator{1}');
            end
            bcond=strcmp(get_param(tpD,'BlockType'),'TransportDelay');
            if bcond
                replace_block(tpD,'Name','TPD','simulink/Discrete/Unit Delay','noprompt');
                set_param(tpD,'InitialCondition','eff_volt');
            end
            bcond=strcmp(get_param(uD,'BlockType'),'Gain');
            if bcond
                replace_block(uD,'Name','UD','simulink/Discrete/Unit Delay','noprompt');
            end
            bcond=strcmp(sS_type,'3-phases AC (wye)');
            bcond2=strcmp(sS_type,'3-phases AC (delta)');
            if bcond||bcond2
                bcond=strcmp(get_param(tpDB,'BlockType'),'TransportDelay');
                if bcond
                    replace_block(tpDB,'Name','tpDB','simulink/Discrete/Delay','noprompt');
                    set_param(tpDB,'DelayLength','round(1/(3*in_freq*CCCV.Ts))');
                end
                bcond=strcmp(get_param(tpDC,'BlockType'),'TransportDelay');
                if bcond
                    replace_block(tpDC,'Name','tpDC','simulink/Discrete/Delay','noprompt');
                    set_param(tpDC,'DelayLength','round(2/(3*in_freq*CCCV.Ts))');
                end
                if bcond2
                    bcond=strcmp(get_param(tpDb,'BlockType'),'TransportDelay');
                    if bcond
                        replace_block(tpDb,'Name','tpDb','simulink/Discrete/Delay','noprompt');
                        set_param(tpDb,'DelayLength','round(1/(3*in_freq*CCCV.Ts))');
                    end
                    bcond=strcmp(get_param(tpDc,'BlockType'),'Transport Delay');
                    if bcond
                        replace_block(tpDc,'Name','tpDc','simulink/Discrete/Delay','noprompt');
                        set_param(tpDc,'DelayLength','round(2/(3*in_freq*CCCV.Ts))');
                    end
                end
            end
        else
            bcond=strcmp(get_param(tfI,'BlockType'),'DiscreteTransferFcn');
            if bcond
                replace_block(tfI,'Name','TFI','simulink/Continuous/Transfer Fcn','noprompt');
                set_param(tfI,'Denominator','CCCV.I.Denominator{1}');
                set_param(tfI,'Numerator','CCCV.I.Numerator{1}');
            end
            bcond=strcmp(get_param(tfV,'BlockType'),'DiscreteTransferFcn');
            if bcond
                replace_block(tfV,'Name','TFV','simulink/Continuous/Transfer Fcn','noprompt');
                set_param(tfV,'Denominator','CCCV.V.Denominator{1}');
                set_param(tfV,'Numerator','CCCV.V.Numerator{1}');
            end
            bcond=strcmp(get_param(tpD,'BlockType'),'UnitDelay');
            if bcond
                replace_block(tpD,'Name','TPD','simulink/Continuous/Transport Delay','noprompt');
                bcond=strcmp(sS_type,'DC');
                if bcond
                    set_param(tpD,'DelayTime','0.2/in_I_freq');
                else
                    set_param(tpD,'DelayTime','0.2/in_freq');
                end
                set_param(tpD,'InitialOutput','eff_volt');
            end
            bcond=strcmp(get_param(uD,'BlockType'),'UnitDelay');
            if bcond
                replace_block(uD,'Name','UD','simulink/Commonly Used Blocks/Gain','noprompt');
            end
            bcond=strcmp(sS_type,'3-phases AC (wye)');
            bcond2=strcmp(sS_type,'3-phases AC (delta)');
            if bcond
                bcond=strcmp(get_param(tpDB,'BlockType'),'Delay');
                if bcond
                    replace_block(tpDB,'Name','tpDB','simulink/Continuous/Transport Delay','noprompt');
                    set_param(tpDB,'DelayTime','1/(3*in_freq)');
                end
                bcond=strcmp(get_param(tpDC,'BlockType'),'Delay');
                if bcond
                    replace_block(tpDC,'Name','tpDC','simulink/Continuous/Transport Delay','noprompt');
                    set_param(tpDC,'DelayTime','2/(3*in_freq)');
                end
                if bcond2
                    bcond=strcmp(get_param(tpDb,'BlockType'),'Delay');
                    if bcond
                        replace_block(tpDb,'Name','tpDb','simulink/Continuous/Transport Delay','noprompt');
                        set_param(tpDb,'DelayTime','1/(3*in_freq)');
                    end
                    bcond=strcmp(get_param(tpDc,'BlockType'),'Delay');
                    if bcond
                        replace_block(tpDc,'Name','tpDc','simulink/Continuous/Transport Delay','noprompt');
                        set_param(tpDc,'DelayTime','2/(3*in_freq)');
                    end
                end
            end
        end
    end
end




function MainPortUpdate(block)

    ports=get_param(block,'ports');
    Type=get_param(block,'s_type');

    NEUTRE=strcmp(get_param(block,'n_connect'),'on');

    Input=[block,'/Input'];
    PowerM=[block,'/Input/PowerM'];
    BridgeD=[block,'/Input/BridgeD'];
    I_AC=[block,'/Model/AC current command/I_AC'];
    p3=[block,'/Input/in_3'];
    p3Top=[block,'/in_3'];

    Add3=false;
    Remove3=false;
    AddN=false;
    RemoveN=false;

    switch ports(6)

    case 2

        switch Type
        case '3-phases AC (wye)'
            Add3=true;
            if NEUTRE
                AddN=true;
            end
        case '3-phases AC (delta)'
            Add3=true;
        end

    case 3

        switch Type
        case '3-phases AC (wye)'
            if NEUTRE
                AddN=true;
            end
        case{'1-phase AC','DC'}
            Remove3=true;
        end

    case 4

        switch Type
        case '3-phases AC (wye)'
            if~NEUTRE
                RemoveN=true;
            end
        case '3-phases AC (delta)'
            RemoveN=true;
        case{'1-phase AC','DC'}
            Remove3=true;
            RemoveN=true;
        end

    end

    if Add3

        add_block('built-in/PMIOPort',p3);
        set_param(p3,'Position',[0,150,40,180],'orientation','right');
        set_param(p3,'port','3');
        set_param(p3,'side','Left');

        add_block('built-in/PMIOPort',p3Top);
        set_param(p3Top,'Position',[0,140,40,170],'orientation','right');
        set_param(p3Top,'port','5');
        set_param(p3Top,'side','Left');

        pconnect=get_param(PowerM,'PortHandles');
        p3connect=get_param([block,'/Input/in_3'],'PortHandles');
        add_line([block,'/Input'],p3connect.RConn,pconnect.LConn(3));

        iconnect=get_param(Input,'PortHandles');
        p3Tconnect=get_param(p3Top,'PortHandles');
        add_line(block,p3Tconnect.RConn,iconnect.LConn(3));

    end

    if AddN

        pN=[block,'/Input/in_4'];
        pNTop=[block,'/in_4'];

        add_block('built-in/PMIOPort',pN);
        set_param(pN,'Position',[200,195,240,225],'orientation','right');
        set_param(pN,'port','4');
        set_param(pN,'side','Left');

        add_block('built-in/PMIOPort',pNTop);
        set_param(pNTop,'Position',[0,145,40,175],'orientation','right');
        set_param(pNTop,'port','6');
        set_param(pNTop,'side','Left');

        pNconnect=get_param(pN,'PortHandles');
        bconnect=get_param(BridgeD,'PortHandles');
        add_line([block,'/Input'],pNconnect.RConn,bconnect.LConn(4));
        pNTconnect=get_param(pNTop,'PortHandles');
        iconnect=get_param(Input,'PortHandles');
        add_line(block,pNTconnect.RConn,iconnect.LConn(4));

    end

    if RemoveN
        iconnect=get_param(Input,'PortHandles');
        Ldelete=get_param(iconnect.LConn,'line');
        if size(Ldelete,1)==4
            if Ldelete{4}~=-1
                delete_line(Ldelete{4});
                delete_block([block,'/Input/in_4']);
            end
        end

        pconnect=get_param(BridgeD,'PortHandles');
        Ldelete=get_param(pconnect.LConn,'line');
        if size(Ldelete,1)==4
            if Ldelete{4}~=-1
                delete_line(Ldelete{4});
                delete_block([block,'/in_4']);
            end
        end
    end

    if Remove3
        iconnect=get_param(Input,'PortHandles');
        Ldelete=get_param(iconnect.LConn,'line');
        if size(Ldelete,1)==3
            if Ldelete{3}~=-1
                delete_line(Ldelete{3});
                delete_block([block,'/Input/in_3']);
            end
        end

        pconnect=get_param(PowerM,'PortHandles');
        Ldelete=get_param(pconnect.LConn,'line');
        if size(Ldelete,1)==3
            if Ldelete{3}~=-1
                delete_line(Ldelete{3});
                delete_block([block,'/in_3']);
            end
        end

    end

    switch Type
    case '3-phases AC (wye)'

        if NEUTRE
            set_param(BridgeD,'LabelModeActiveChoice','triVariantWN');
        else
            set_param(BridgeD,'LabelModeActiveChoice','triVariantW');
        end
        set_param(PowerM,'LabelModeActiveChoice','triVariantWye');
        set_param(I_AC,'LabelModeActiveChoice','triVariant');

        pS=[block,'/Model/AC current command/I_AC/3-phase AC/phaseShift'];
        cA=[block,'/Model/AC current command/I_AC/3-phase AC/cA'];
        set_param(pS,'LabelModeActiveChoice','wye');
        set_param(cA,'LabelModeActiveChoice','wye');

    case '3-phases AC (delta)'

        set_param(PowerM,'LabelModeActiveChoice','triVariantDelta');
        set_param(BridgeD,'LabelModeActiveChoice','triVariantD');
        set_param(I_AC,'LabelModeActiveChoice','triVariant');
        pS=[block,'/Model/AC current command/I_AC/3-phase AC/phaseShift'];
        cA=[block,'/Model/AC current command/I_AC/3-phase AC/cA'];
        set_param(pS,'LabelModeActiveChoice','delta');
        set_param(cA,'LabelModeActiveChoice','delta');

    case '1-phase AC'

        set_param(PowerM,'LabelModeActiveChoice','monoVariant');
        set_param(BridgeD,'LabelModeActiveChoice','monoVariant');
        set_param(I_AC,'LabelModeActiveChoice','monoVariant');

    case 'DC'

        set_param(PowerM,'LabelModeActiveChoice','dcVariant');
        set_param(BridgeD,'LabelModeActiveChoice','dcVariant');
        set_param(I_AC,'LabelModeActiveChoice','dcVariant');
    end

end