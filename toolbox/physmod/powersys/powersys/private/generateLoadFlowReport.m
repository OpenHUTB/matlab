function generateLoadFlowReport(Type,LF,VOLTS,WATTS,FileNameReport)




    if isempty(LF)
        Message='You need to first solve the load flow.';
        warndlg(Message,'Load flow Report')
        warning('SpecializedPowerSystems:LoadflowReport:CannotSaveReport',Message)
        return
    end
    if LF.status~=1
        Message='You need to first solve the load flow.';
        warndlg(Message,'Load flow Report')
        warning('SpecializedPowerSystems:LoadflowReport:CannotSaveReport',Message)
        return
    end
    if~exist('FileName','var')
        FileName=[];
    end
    switch VOLTS
    case{'V',1}
        Vx=1;
        VOLTS='V';
    otherwise
        Vx=1e3;
        VOLTS='kV';
    end
    switch WATTS
    case{'W',1}
        Px=1;
        WATTS='W';
        VARS='var';
    case{'kW',1e3}
        Px=1e3;
        VARS='kvar';
        WATTS='kW';
    otherwise
        Px=1e6;
        VARS='Mvar';
        WATTS='MW';
    end
    LF.Px=Px;
    switch Type
    case 'PositiveSequence'
        if LF.niter==1
            ShowText1=['The Load Flow converged in ',num2str(LF.niter),' iteration !'];
        else
            ShowText1=['The Load Flow converged in ',num2str(LF.niter),' iterations !'];
        end
        Nbus=size(LF.Ybus1,1);
        Ybus=LF.Ybus1asm;
        ShowText='';
        ShowText_SubnetDeleted='';
        nSubNetwork=0;

        for isubnet=1:LF.NbOfNetworks
            nSubNetwork=nSubNetwork+1;
            if~isempty(LF.Networks(isubnet).SwingBus)
                SgenTotal=0;
                SpqloadTotal=0;
                SshuntTotal=0;
                SasmTotal=0;
                ShowText_Subnet='';
                ShowText_summary='';
                no_bus=0;

                strmatID=char(LF.bus(LF.Networks(isubnet).busNumber).ID);
                [~,nbus_sort]=sortrows(strmatID);






                n_implicit=strmatch('*',strmatID(nbus_sort,:));
                if~isempty(n_implicit)
                    nbus_sort=[nbus_sort(max(n_implicit)+1:end);nbus_sort(1:max(n_implicit))];
                end
                for ib=LF.Networks(isubnet).busNumber(nbus_sort)
                    strBusInfo='';
                    if ib<=Nbus
                        no_bus=no_bus+1;
                        switch LF.bus(ib).TypeNumber
                        case 1
                            strBusInfo=' ; Swing bus';
                        case 2
                            if LF.bus(ib).QmaxReached
                                n=find(cell2mat(LF.sm.busNumber)==ib&strcmp('PV',LF.sm.busType));
                                if~isempty(n)
                                    strBusInfo=sprintf(' ; Qmax limit reached on PV generator (%.2f %s)',imag(LF.sm.S{n})*LF.Pbase/Px,VARS);
                                end
                                n=find(cell2mat(LF.vsrc.busNumber)==ib&strcmp('PV',LF.vsrc.busType));
                                if~isempty(n)
                                    strBusInfo=sprintf(' ; Qmax limit reached on PV voltage source (%.2f %s)',imag(LF.vsrc.S{n})*LF.Pbase/Px,VARS);
                                end
                            end
                            if LF.bus(ib).QminReached
                                n=find(cell2mat(LF.sm.busNumber)==ib&strcmp('PV',LF.sm.busType));
                                if~isempty(n)
                                    strBusInfo=sprintf(' ; Qmin limit reached on PV generator (%.2f %s)',imag(LF.sm.S{n})*LF.Pbase/Px,VARS);
                                end
                                n=find(cell2mat(LF.vsrc.busNumber)==ib&strcmp('PV',LF.vsrc.busType));
                                if~isempty(n)
                                    strBusInfo=sprintf(' ; Qmin limit reached on PV voltage source (%.2f %s)',imag(LF.vsrc.S{n})*LF.Pbase/Px,VARS);
                                end
                            end
                        end
                        ShowText_Subnet=char(ShowText_Subnet,' ',sprintf('%d : %s  V= %.3f pu/%g%s %.2f deg %10s ',...
                        no_bus,LF.bus(ib).ID,...
                        abs(LF.bus(ib).Vbus),LF.bus(ib).vbase/Vx,VOLTS,angle(LF.bus(ib).Vbus)*180/pi,strBusInfo));
                        ShowText_Subnet=char(ShowText_Subnet,sprintf('        Generation : P=%8.2f %s Q=%8.2f %s',...
                        real(LF.bus(ib).Sgen)*LF.Pbase/Px,WATTS,imag(LF.bus(ib).Sgen)*LF.Pbase/Px,VARS));
                        ShowText_Subnet=char(ShowText_Subnet,sprintf('        PQ_load    : P=%8.2f %s Q=%8.2f %s',...
                        real(LF.bus(ib).Spqload)*LF.Pbase/Px,WATTS,imag(LF.bus(ib).Spqload)*LF.Pbase/Px,VARS));
                        ntransfer=find(abs(Ybus(ib,:))~=0);

                        [~,nbus_sort2]=sortrows(char(LF.bus(ntransfer).ID));
                        ShowText_Transfer='';
                        v1=LF.bus(ib).Vbus;
                        Ishunt=v1*Ybus(ib,ib);
                        Pitotal=0;
                        Qitotal=0;
                        for n=ntransfer(nbus_sort2)
                            if n<=Nbus&&n~=ib

                                v2=LF.bus(n).Vbus;
                                phi=(angle(Ybus(n,ib))-angle(Ybus(n,ib)+Ybus(ib,n)));
                                VoltageRatio=LF.VoltageRatio(ib,n);










                                I=Ybus(ib,n)*(-v1*VoltageRatio*exp(1i*phi)+v2);


                                Ishunt=Ishunt+Ybus(ib,n)*v1*VoltageRatio*exp(1i*phi);

                                St=v1*conj(I)*LF.Pbase/Px;
                                P=real(St);
                                Q=imag(St);
                                [Pi,Qi]=CorrectionsPowerLines(LF,ib,n);
                                P=P+Pi;
                                Q=Q+Qi;
                                Pitotal=Pitotal+Pi;
                                Qitotal=Qitotal+Qi;
                                ShowText_Transfer=char(ShowText_Transfer,sprintf('   -->  %-10s : P=%8.2f %s Q=%8.2f %s',LF.bus(n).ID,P,WATTS,Q,VARS));

                            elseif n>Nbus

                                I=-Ybus(ib,n)*(LF.bus(ib).Vbus-LF.bus(n).Vbus);
                                St=LF.bus(ib).Vbus*conj(I);
                                SasmTotal=SasmTotal+St;
                                St=St*LF.Pbase/Px;

                                Ishunt=Ishunt+Ybus(ib,n)*v1;

                                ShowText_Transfer=char(ShowText_Transfer,sprintf('   -->  %-10s : P=%8.2f %s Q=%8.2f %s',...
                                'ASM',real(St),WATTS,imag(St),VARS));
                            end

                        end

                        LF.bus(ib).Sshunt=v1*conj(Ishunt);
                        P=real(LF.bus(ib).Sshunt)*LF.Pbase/Px;
                        Q=imag(LF.bus(ib).Sshunt)*LF.Pbase/Px;
                        P=P-Pitotal;
                        Q=Q-Qitotal;
                        ShowText_Subnet=char(ShowText_Subnet,sprintf('        Z_shunt    : P=%8.2f %s Q=%8.2f %s',P,WATTS,Q,VARS));

                        ShowText_Subnet=char(ShowText_Subnet,ShowText_Transfer(2:end,:));

                        SgenTotal=SgenTotal+LF.bus(ib).Sgen;
                        SpqloadTotal=SpqloadTotal+LF.bus(ib).Spqload;
                        SshuntTotal=SshuntTotal+LF.bus(ib).Sshunt;



                        SshuntTotal=SshuntTotal-(Pitotal+1i*Qitotal)*Px/LF.Pbase;

                    end
                end

                SlossTotal=SgenTotal-SpqloadTotal-SshuntTotal-SasmTotal;

                ShowText_summary=char(ShowText_summary,sprintf('  Total generation  : P=%10.2f %s Q=%10.2f %s',...
                real(SgenTotal)*LF.Pbase/Px,WATTS,imag(SgenTotal)*LF.Pbase/Px,VARS));

                ShowText_summary=char(ShowText_summary,sprintf('  Total PQ load     : P=%10.2f %s Q=%10.2f %s',...
                real(SpqloadTotal)*LF.Pbase/Px,WATTS,imag(SpqloadTotal)*LF.Pbase/Px,VARS));

                ShowText_summary=char(ShowText_summary,sprintf('  Total Zshunt load : P=%10.2f %s Q=%10.2f %s',...
                real(SshuntTotal)*LF.Pbase/Px,WATTS,imag(SshuntTotal)*LF.Pbase/Px,VARS));

                ShowText_summary=char(ShowText_summary,sprintf('  Total ASM load    : P=%10.2f %s Q=%10.2f %s',...
                real(SasmTotal)*LF.Pbase/Px,WATTS,imag(SasmTotal)*LF.Pbase/Px,VARS));

                ShowText_summary=char(ShowText_summary,sprintf('  Total losses      : P=%10.2f %s Q=%10.2f %s',...
                real(SlossTotal)*LF.Pbase/Px,WATTS,imag(SlossTotal)*LF.Pbase/Px,VARS));

                ShowText=char(ShowText,' ',sprintf('SUMMARY for subnetwork No %d',nSubNetwork),ShowText_summary,ShowText_Subnet);

            else
                ShowText_SubnetDeleted=char(ShowText_SubnetDeleted,sprintf('  Subnetwork No %d',nSubNetwork));
                for ib=LF.Networks(isubnet).busNumber
                    ShowText_SubnetDeleted=char(ShowText_SubnetDeleted,sprintf('    %s',LF.bus(ib).ID));
                end
            end
        end



        ShowTextSwing='';
        if isfield(LF.vsrc,'InternalBus')
            if~isempty(cell2mat(LF.vsrc.InternalBus))
                ShowTextSwing=' ';
                ShowTextSwing=char(ShowTextSwing,...
                'WARNING: At buses listed below, a Three-Phase Source set to swing type is connected in parallel');
                ShowTextSwing=char(ShowTextSwing,...
                '         with synchronous machines or voltage sources set to PV type:');
                for n=1:length(LF.vsrc.busNumber)
                    if~isempty(LF.vsrc.InternalBus{n})
                        ShowTextSwing=char(ShowTextSwing,sprintf('           --> %s',LF.vsrc.busID{n}));
                    end
                end
                ShowTextSwing=char(ShowTextSwing,...
                '         Since these buses cannot be both swing type and PV type, swing buses have been moved');
                ShowTextSwing=char(ShowTextSwing,...
                '         at the ideal voltage source node, behind the RL impedance.');
            end
        end

        if~isempty(ShowText_SubnetDeleted)
            ShowText_SubnetDeleted=char(' ',...
            sprintf('WARNING: The following subnetworks have been ignored because they contain no swing bus:'),ShowText_SubnetDeleted);
        end

        ShowText=char(ShowText1,ShowTextSwing,ShowText_SubnetDeleted,ShowText);

        if isempty(FileNameReport)
            [FileName,PathName,FilterIndex]=uiputfile('LoadFlow.rep','Save the report file');
            if FilterIndex==0

                return
            end
            LFFN=[PathName,FileName];
        else
            LFFN=strrep(FileNameReport,'.rep','');
            LFFN=[LFFN,'.rep'];
        end

        [fid,permission]=fopen(LFFN,'w+');

        if fid==-1||strcmp(permission,'Permission denied')
            Message='The directory you choose to save the report seems to be write protected. Consequently no report will be generated.';
            warndlg(Message,'Load flow Report')
            warning('SpecializedPowerSystems:LoadflowReport:CannotSaveReport',Message)
            return
        end

        for i=1:size(ShowText,1)
            fprintf(fid,'%s\n',ShowText(i,:));
        end

        if isempty(FileNameReport)
            edit(fullfile(PathName,FileName));
        end

        fclose(fid);

    case 'Unbalanced'







        Nbus=size(LF.Ybus,1);
        for i=1:Nbus
            LF.bus(i).Lines=[];
            LF.bus(i).Transfos=[];
        end

        for i=1:length(LF.Lines.BlockType)
            if~isempty(LF.Lines.LeftbusNumber{i})

                ib=min(LF.Lines.LeftbusNumber{i});
                LF.bus(ib).Lines=[LF.bus(ib).Lines,i];
            end
            if~isempty(LF.Lines.RightbusNumber{i})

                ib=min(LF.Lines.RightbusNumber{i});
                LF.bus(ib).Lines=[LF.bus(ib).Lines,i];
            end
        end


        for i=1:length(LF.Transfos.Type)
            if~isempty(LF.Transfos.W1busNumber)&&~any(isnan(LF.Transfos.W1busNumber{i}))
                if length(LF.Transfos.W1busNumber{i})==2

                    for ib=LF.Transfos.W1busNumber{i}
                        if ib>0
                            LF.bus(ib).Transfos=[LF.bus(ib).Transfos,i];
                        end
                    end
                elseif length(LF.Transfos.W1busNumber{i})==3


                    ib=min(LF.Transfos.W1busNumber{i});
                    LF.bus(ib).Transfos=[LF.bus(ib).Transfos,i];
                end
            end
            if~isempty(LF.Transfos.W2busNumber{i})&&~any(isnan(LF.Transfos.W2busNumber{i}))
                if length(LF.Transfos.W2busNumber{i})==2

                    for ib=LF.Transfos.W2busNumber{i}
                        if ib>0
                            LF.bus(ib).Transfos=[LF.bus(ib).Transfos,i];
                        end
                    end
                elseif length(LF.Transfos.W2busNumber{i})==3


                    ib=min(LF.Transfos.W2busNumber{i});
                    LF.bus(ib).Transfos=[LF.bus(ib).Transfos,i];
                end
            end
            if~isempty(LF.Transfos.W3busNumber{i})&&~any(isnan(LF.Transfos.W3busNumber{i}))
                if length(LF.Transfos.W3busNumber{i})==2

                    for ib=LF.Transfos.W3busNumber{i}
                        if ib>0
                            LF.bus(ib).Transfos=[LF.bus(ib).Transfos,i];
                        end
                    end
                elseif length(LF.Transfos.W3busNumber{i})==3


                    ib=min(LF.Transfos.W3busNumber{i});
                    LF.bus(ib).Transfos=[LF.bus(ib).Transfos,i];
                end
            end
        end


        if LF.niter==1
            ShowText1='The Load Flow converged in 1 iteration !';
        else
            ShowText1=['The Load Flow converged in ',num2str(LF.niter),' iterations !'];
        end

        Ybus=LF.Ybus;


        ShowText='';
        ShowText_SubnetDeleted='';
        nSubNetwork=0;
        BusesWithMissingPQTransfer=[];
        nBusesWithMissingPQTransfer=0;

        Links_Stransfer=[];
        Links_BusNos=[];
        Links_BusNor=[];
        Links_3WindingTransfoNumber=[];
        Links_3WTransferNumber=[];
        Links_WarningOn=[];
        a=exp(1i*2*pi/3);


        for i=1:length(LF.Lines.BlockType)
            LeftbusNumber=sort(LF.Lines.LeftbusNumber{i});
            RightbusNumber=sort(LF.Lines.RightbusNumber{i});
            Ybus(LeftbusNumber,RightbusNumber)=0;
            Ybus(RightbusNumber,LeftbusNumber)=0;
            if~isempty(LF.Lines.LeftbusNumber{i})&&~isempty(LF.Lines.RightbusNumber{i})
                for k=1:length(LeftbusNumber)
                    Ybus(LeftbusNumber(k),RightbusNumber(k))=1;
                    Ybus(RightbusNumber(k),LeftbusNumber(k))=1;
                end
            end
        end


        for i=1:length(LF.Transfos.Type)
            if strcmp(LF.Transfos.Type{i},'3SinglePhase')
                W1busNumber=sort(LF.Transfos.W1busNumber{i});
                W2busNumber=sort(LF.Transfos.W2busNumber{i});
                Ybus(W1busNumber,W2busNumber)=0;
                Ybus(W2busNumber,W1busNumber)=0;
                for k=1:3
                    if~isempty(LF.Transfos.W1busNumber{i})&&~isempty(LF.Transfos.W2busNumber{i})
                        Ybus(W1busNumber(k),W2busNumber(k))=1;
                        Ybus(W2busNumber(k),W1busNumber(k))=1;
                    end
                end

                if~isempty(LF.Transfos.W3busNumber{i})
                    W3busNumber=sort(LF.Transfos.W3busNumber{i});
                    Ybus(W1busNumber,W3busNumber)=0;
                    Ybus(W3busNumber,W1busNumber)=0;
                    Ybus(W2busNumber,W3busNumber)=0;
                    Ybus(W3busNumber,W2busNumber)=0;
                    for k=1:3
                        if~isempty(LF.Transfos.W1busNumber{i})&&~isempty(LF.Transfos.W3busNumber{i})
                            Ybus(W1busNumber(k),W3busNumber(k))=1;
                            Ybus(W3busNumber(k),W1busNumber(k))=1;
                        end
                        if~isempty(LF.Transfos.W2busNumber{i})&&~isempty(LF.Transfos.W3busNumber{i})
                            Ybus(W2busNumber(k),W3busNumber(k))=1;
                            Ybus(W3busNumber(k),W2busNumber(k))=1;
                        end
                    end
                end
            end
        end


        for isubnet=1:LF.NbOfNetworks
            nSubNetwork=nSubNetwork+1;
            if~isempty(LF.Networks(isubnet).SwingBus)
                SgenTotal=0;
                SpqloadTotal=0;
                SshuntTotal=0;
                ShowText_Subnet='';
                ShowText_summary='';
                no_bus=0;

                strmatID=char(LF.bus(LF.Networks(isubnet).busNumber).ID);
                [~,nbus_sort]=sortrows(strmatID);
                BusID_last='';
                Sgen_all_phases=0;
                SpqLoad_all_phases=0;
                Sshunt_all_phases=0;
                for ib=LF.Networks(isubnet).busNumber(nbus_sort)
                    strBusInfo='';
                    LF.bus(ib).Sshunt=0;
                    if ib<=Nbus
                        no_bus=no_bus+1;
                        switch LF.bus(ib).TypeNumber
                        case 1

                        case 2
                            if LF.bus(ib).QmaxReached



                                for iblock=1:length(LF.sm.blockType)
                                    if any(LF.sm.busNumber{iblock}==ib)
                                        strBusInfo=char(strBusInfo,sprintf('Qmax limit reached on PV generator connected at bus %s (%.2f %s)',...
                                        LF.bus(LF.sm.busNumber{iblock}(iphase)).ID(1:end-2),imag(LF.sm.S{iblock})*LF.Pbase/Px,VARS));
                                    end
                                end

                                for iblock=1:length(LF.vsrc.blockType)
                                    iphase=find(LF.vsrc.busNumber{iblock}==ib);
                                    if~isempty(iphase)
                                        strBusInfo=char(strBusInfo,sprintf('Qmax limit reached on PV voltage source connected at bus %s (%.2f %s)',...
                                        LF.bus(LF.vsrc.busNumber{iblock}(iphase)).ID,imag(LF.vsrc.S{iblock}(iphase))*LF.Pbase/Px,VARS));
                                    end
                                end
                            end
                            if LF.bus(ib).QminReached

                                for iblock=1:length(LF.sm.blockType)
                                    if any(LF.sm.busNumber{iblock}==ib)
                                        strBusInfo=char(strBusInfo,sprintf('Qmin limit reached on PV generator connected at bus %s (%.2f %s)',...
                                        LF.bus(LF.sm.busNumber{iblock}(iphase)).ID(1:end-2),imag(LF.sm.S{iblock})*LF.Pbase/Px,VARS));
                                    end
                                end

                                for iblock=1:length(LF.vsrc.blockType)
                                    iphase=find(LF.vsrc.busNumber{iblock}==ib);
                                    if~isempty(iphase)
                                        strBusInfo=char(strBusInfo,sprintf('Qmin limit reached on PV voltage source connected at bus %s (%.2f %s)',...
                                        LF.bus(LF.vsrc.busNumber{iblock}(iphase)).ID,imag(LF.vsrc.S{iblock}(iphase))*LF.Pbase/Px,VARS));
                                    end
                                end
                            end
                        end
                        if~strcmp(LF.bus(ib).ID(1:end-2),BusID_last)
                            strABC=sprintf('%-23s --------A--------     --------B--------     --------C--------     ---V1--PQtotal---',LF.bus(ib).ID(1:end-2));
                            strV='          V (pu deg.)                                                                        ';
                            strGen=sprintf('        Gen (%s %s)                                                                                          ',WATTS,VARS);
                            strPQ=sprintf('    PQ load (%s %s)                                                                                          ',WATTS,VARS);
                            strShunt=sprintf('    Z shunt (%s %s)                                                                                          ',WATTS,VARS);
                            NumberOfPhases=LF.bus(ib).NumberOfPhases;
                            nbus1ph=0;
                        end
                        switch LF.bus(ib).ID(end)
                        case 'a'
                            strV(23:41)=sprintf('%9.4f  %8.2f',abs(LF.bus(ib).Vbus),angle(LF.bus(ib).Vbus)*180/pi);
                            try
                                strGen(23:41)=sprintf('%9.2f %9.2f',real(LF.bus(ib).Sgen)*LF.Pbase/Px,imag(LF.bus(ib).Sgen)*LF.Pbase/Px);
                            catch
                                strGen(23:41)=sprintf('%9.3g %9.3g',real(LF.bus(ib).Sgen)*LF.Pbase/Px,imag(LF.bus(ib).Sgen)*LF.Pbase/Px);
                            end
                            try
                                strPQ(23:41)=sprintf('%9.2f %9.2f',real(LF.bus(ib).Spqload)*LF.Pbase/Px,imag(LF.bus(ib).Spqload)*LF.Pbase/Px);
                            catch
                                strPQ(23:41)=sprintf('%9.3g %9.3g',real(LF.bus(ib).Spqload)*LF.Pbase/Px,imag(LF.bus(ib).Spqload)*LF.Pbase/Px);
                            end
                            LF.bus(ib).Sshunt=LF.bus(ib).Sshunt+LF.bus(ib).Sgen;
                            LF.bus(ib).Sshunt=LF.bus(ib).Sshunt-LF.bus(ib).Spqload;
                            Sgen_all_phases=Sgen_all_phases+LF.bus(ib).Sgen*LF.Pbase/Px;
                            SpqLoad_all_phases=SpqLoad_all_phases+LF.bus(ib).Spqload*LF.Pbase/Px;
                            nbus1ph=nbus1ph+1;
                        case 'b'
                            strV(45:63)=sprintf('%9.4f  %8.2f',abs(LF.bus(ib).Vbus),angle(LF.bus(ib).Vbus)*180/pi);
                            try
                                strGen(45:63)=sprintf('%9.2f %9.2f',real(LF.bus(ib).Sgen)*LF.Pbase/Px,imag(LF.bus(ib).Sgen)*LF.Pbase/Px);
                            catch
                                strGen(45:63)=sprintf('%9.3g %9.3g',real(LF.bus(ib).Sgen)*LF.Pbase/Px,imag(LF.bus(ib).Sgen)*LF.Pbase/Px);
                            end
                            try
                                strPQ(45:63)=sprintf('%9.2f %9.2f',real(LF.bus(ib).Spqload)*LF.Pbase/Px,imag(LF.bus(ib).Spqload)*LF.Pbase/Px);
                            catch
                                strPQ(45:63)=sprintf('%9.3g %9.3g',real(LF.bus(ib).Spqload)*LF.Pbase/Px,imag(LF.bus(ib).Spqload)*LF.Pbase/Px);
                            end
                            LF.bus(ib).Sshunt=LF.bus(ib).Sshunt+LF.bus(ib).Sgen;
                            LF.bus(ib).Sshunt=LF.bus(ib).Sshunt-LF.bus(ib).Spqload;
                            Sgen_all_phases=Sgen_all_phases+LF.bus(ib).Sgen*LF.Pbase/Px;
                            SpqLoad_all_phases=SpqLoad_all_phases+LF.bus(ib).Spqload*LF.Pbase/Px;
                            nbus1ph=nbus1ph+1;
                        case 'c'
                            strV(67:85)=sprintf('%9.4f  %8.2f',abs(LF.bus(ib).Vbus),angle(LF.bus(ib).Vbus)*180/pi);
                            try
                                strGen(67:85)=sprintf('%9.2f %9.2f',real(LF.bus(ib).Sgen)*LF.Pbase/Px,imag(LF.bus(ib).Sgen)*LF.Pbase/Px);
                            catch
                                strGen(67:85)=sprintf('%9.3g %9.3g',real(LF.bus(ib).Sgen)*LF.Pbase/Px,imag(LF.bus(ib).Sgen)*LF.Pbase/Px);
                            end
                            try
                                strPQ(67:85)=sprintf('%9.2f %9.2f',real(LF.bus(ib).Spqload)*LF.Pbase/Px,imag(LF.bus(ib).Spqload)*LF.Pbase/Px);
                            catch
                                strPQ(67:85)=sprintf('%9.3g %9.3g',real(LF.bus(ib).Spqload)*LF.Pbase/Px,imag(LF.bus(ib).Spqload)*LF.Pbase/Px);
                            end
                            LF.bus(ib).Sshunt=LF.bus(ib).Sshunt+LF.bus(ib).Sgen;
                            LF.bus(ib).Sshunt=LF.bus(ib).Sshunt-LF.bus(ib).Spqload;
                            Sgen_all_phases=Sgen_all_phases+LF.bus(ib).Sgen*LF.Pbase/Px;
                            SpqLoad_all_phases=SpqLoad_all_phases+LF.bus(ib).Spqload*LF.Pbase/Px;
                            nbus1ph=nbus1ph+1;
                        end
                        BusID_last=LF.bus(ib).ID(1:end-2);
                        if NumberOfPhases==nbus1ph
                            ShowText_Subnet=char(ShowText_Subnet,' ');
                            ShowText_Subnet=char(ShowText_Subnet,strABC);
                            if NumberOfPhases==3

                                V1=sum([LF.bus(ib-2:ib).Vbus].*[1,a,a^2])/3;
                                strV(89:107)=sprintf('%9.4f  %8.2f',abs(V1),angle(V1)*180/pi);
                            end
                            ShowText_Subnet=char(ShowText_Subnet,strV);
                            try
                                strGen(89:107)=sprintf('%9.2f %9.2f',real(Sgen_all_phases),imag(Sgen_all_phases));
                            catch
                                strGen(89:107)=sprintf('%9.3g %9.3g',real(Sgen_all_phases),imag(Sgen_all_phases));
                            end
                            ShowText_Subnet=char(ShowText_Subnet,strGen);
                            try
                                strPQ(89:107)=sprintf('%9.2f %9.2f',real(SpqLoad_all_phases),imag(SpqLoad_all_phases));
                            catch
                                strPQ(89:107)=sprintf('%9.3g %9.3g',real(SpqLoad_all_phases),imag(SpqLoad_all_phases));
                            end
                            ShowText_Subnet=char(ShowText_Subnet,strPQ);
                            ShowText_Subnet=char(ShowText_Subnet,strShunt);
                            Sgen_all_phases=0;
                            SpqLoad_all_phases=0;
                            Sshunt_all_phases=0;
                        end

                        ntransfer=find(abs(Ybus(ib,:))>1e-6);

                        [~,nbus_sort2]=sortrows(char(LF.bus(ntransfer).ID));
                        v1=LF.bus(ib).Vbus;
                        if LF.bus(ib).NumberOfPhases>0
                            ShowText_Transfer='';
                            Warning=[];
                            for i=1:length(LF.Transfos.Type)
                                LF.Transfos.FlowDisplayed{i}=0;
                            end
                        end

                        for iLine=LF.bus(ib).Lines
                            if any(LF.Lines.LeftbusNumber{iLine}==ib)

                                if length(LF.Lines.RightbusNumber{iLine})<length(LF.Lines.rightnodes{iLine})
                                    BlockName=get(LF.Lines.handle{iLine},'Name');
                                    BlockName=strrep(BlockName,newline,char(32));
                                    Warning=char(Warning,sprintf('-> PQ flow %s -> ??? through Line or Series Impedance ''%s'' is not listed - Destination bus not specified',...
                                    LF.bus(ib).ID(1:end-2),BlockName));
                                end
                            else

                                if length(LF.Lines.LeftbusNumber{iLine})<length(LF.Lines.leftnodes{iLine})
                                    BlockName=get(LF.Lines.handle{iLine},'Name');
                                    BlockName=strrep(BlockName,newline,char(32));
                                    Warning=char(Warning,sprintf('-> PQ flow %s -> ??? through Line or Series Impedance ''%s'' is not listed - Destination bus not specified',...
                                    LF.bus(ib).ID(1:end-2),BlockName));
                                end
                            end
                        end

                        for iTr=LF.bus(ib).Transfos
                            if isempty(LF.Transfos.W3nodes{iTr})

                                if any(LF.Transfos.W1busNumber{iTr}==ib)

                                    if length(LF.Transfos.W2busNumber{iTr})<length(LF.Transfos.W2nodes{iTr})
                                        BlockName=get(LF.Transfos.handle{iTr},'Name');
                                        BlockName=strrep(BlockName,newline,char(32));
                                        Warning=char(Warning,sprintf('-> PQ flow %s -> ??? through Transformer ''%s'' is not listed - Destination bus not specified',...
                                        LF.bus(ib).ID(1:end-2),BlockName));
                                    end
                                else

                                    if length(LF.Transfos.W1busNumber{iTr})<length(LF.Transfos.W1nodes{iTr})
                                        BlockName=get(LF.Transfos.handle{iTr},'Name');
                                        BlockName=strrep(BlockName,newline,char(32));
                                        Warning=char(Warning,sprintf('-> PQ flow %s -> ??? through Transformer ''%s'' is not listed - Destination bus not specified',...
                                        LF.bus(ib).ID(1:end-2),BlockName));
                                    end
                                end
                            else

                            end
                        end

                        ntransfer_sorted=ntransfer(nbus_sort2);
                        for n=ntransfer_sorted
                            if n<=Nbus&&n~=ib
                                WarningOn=0;

                                v2=LF.bus(n).Vbus;
                                phi=(angle(Ybus(n,ib))-angle(Ybus(n,ib)+Ybus(ib,n)));
                                I=Ybus(ib,n)*(-v1*exp(1i*phi)+v2);
                                St=v1*conj(I)*LF.Pbase/Px;
                                P=real(St);
                                Q=imag(St);

                                index_LinesTransfos=find(Links_BusNos==ib&Links_BusNor==n);
                                if isempty(index_LinesTransfos)

                                    [Ss,BusNos,BusNor,LineNumber]=PowersIntoPowerLine(LF,ib,n);

                                    if~isempty(LineNumber)


                                        Links_Stransfer=[Links_Stransfer;Ss];%#ok
                                        Links_BusNos=[Links_BusNos;BusNos];%#ok sending buses
                                        Links_BusNor=[Links_BusNor;BusNor];%#ok receiving buses
                                        Links_3WindingTransfoNumber=[Links_3WindingTransfoNumber;zeros(length(BusNos),1)];%#ok
                                        Links_3WTransferNumber=[Links_3WTransferNumber;zeros(length(BusNos),1)];%#ok
                                        Links_WarningOn=[Links_WarningOn;zeros(length(BusNos),1)];%#ok
                                    end


                                    [Sst,BusNost,BusNort,TransfoNumber,WarningOn,Warning,LF]=PowersInto3phTransformer(LF,ib,n,Warning,WATTS,VARS,Px);

                                    if~isempty(TransfoNumber)&&~isempty(BusNost)



                                        Links_Stransfer=[Links_Stransfer;Sst];%#ok
                                        Links_BusNos=[Links_BusNos;BusNost];%#ok sending buses
                                        Links_BusNor=[Links_BusNor;BusNort];%#ok receiving buses
                                        if~isempty([LF.Transfos.W3nodes{TransfoNumber}])
                                            Links_3WindingTransfoNumber=[Links_3WindingTransfoNumber;ones(length(BusNost),1)*TransfoNumber];%#ok
                                            Links_3WTransferNumber=[Links_3WTransferNumber;ones(length(BusNost),1)];%#ok

                                        else
                                            Links_3WindingTransfoNumber=[Links_3WindingTransfoNumber;zeros(length(BusNost),1)];%#ok
                                            Links_3WTransferNumber=[Links_3WTransferNumber;ones(length(BusNost),1)*0];%#ok
                                        end
                                        Links_WarningOn=[Links_WarningOn;WarningOn*ones(length(BusNost),1)];%#ok
                                    end
                                    index_LinesTransfos=find(Links_BusNos==ib&Links_BusNor==n);
                                else
                                    if any(Links_WarningOn(index_LinesTransfos)),WarningOn=1;end
                                end
                                if LF.bus(n).ID(end)==LF.bus(ib).ID(end)

                                    if~isempty(index_LinesTransfos)







                                        P=sum(real(Links_Stransfer(index_LinesTransfos)))/Px;
                                        Q=sum(imag(Links_Stransfer(index_LinesTransfos)))/Px;
                                    end

                                    if abs(P)<LF.Pbase*LF.ErrMax/Px&&abs(Q)<LF.Pbase*LF.ErrMax/Px
                                        continue
                                    end


                                    switch LF.bus(n).ID(end)
                                    case 'a'
                                        k=strmatch(['-> ',LF.bus(n).ID(1:end-2),' '],ShowText_Transfer);
                                        if~WarningOn
                                            if isempty(k)
                                                try
                                                    strPQtransfer=sprintf('-> %-9s(%s %s) %9.2f %9.2f %-50s',LF.bus(n).ID(1:end-2),WATTS,VARS,P,Q,' ');
                                                catch
                                                    strPQtransfer=sprintf('-> %-9s(%s %s) %9.3g %9.3g %-50s',LF.bus(n).ID(1:end-2),WATTS,VARS,P,Q,' ');
                                                end
                                                ShowText_Transfer=char(ShowText_Transfer,strPQtransfer);
                                            else
                                                try
                                                    ShowText_Transfer(k,23:41)=sprintf('%9.2f %9.2f',P,Q);
                                                catch
                                                    ShowText_Transfer(k,23:41)=sprintf('%9.3g %9.3g',P,Q);
                                                end
                                            end
                                        end



                                        LF.bus(ib).Sshunt=LF.bus(ib).Sshunt-(P+1i*Q)/LF.Pbase*Px;

                                        TransfoNumber=Links_3WindingTransfoNumber(index_LinesTransfos);
                                        if TransfoNumber>0
                                            n_ib_W3=find(Links_BusNos==ib&Links_3WindingTransfoNumber==TransfoNumber&Links_3WTransferNumber>1,1);
                                            if~isempty(n_ib_W3)
                                                LF.bus(ib).Sshunt=LF.bus(ib).Sshunt+(P+1i*Q)/LF.Pbase*Px;
                                            else

                                                Links_3WTransferNumber(index_LinesTransfos)=Links_3WTransferNumber(index_LinesTransfos)+1;%#ok
                                            end
                                        end

                                    case 'b'
                                        k=strmatch(['-> ',LF.bus(n).ID(1:end-2),' '],ShowText_Transfer);
                                        if~WarningOn
                                            if isempty(k)
                                                try
                                                    strPQtransfer=sprintf('-> %-9s(%s %s)%-22s %9.2f %9.2f %-20s',LF.bus(n).ID(1:end-2),WATTS,VARS,' ',P,Q,' ');
                                                catch
                                                    strPQtransfer=sprintf('-> %-9s(%s %s)%-22s %9.3g %9.3g %-20s',LF.bus(n).ID(1:end-2),WATTS,VARS,' ',P,Q,' ');
                                                end
                                                ShowText_Transfer=char(ShowText_Transfer,strPQtransfer);
                                            else
                                                try
                                                    ShowText_Transfer(k,45:63)=sprintf('%9.2f %9.2f',P,Q);
                                                catch
                                                    ShowText_Transfer(k,45:63)=sprintf('%9.3g %9.3g',P,Q);
                                                end
                                            end
                                        end


                                        LF.bus(ib).Sshunt=LF.bus(ib).Sshunt-(P+1i*Q)/LF.Pbase*Px;

                                        TransfoNumber=Links_3WindingTransfoNumber(index_LinesTransfos);
                                        if TransfoNumber>0
                                            n_ib_W3=find(Links_BusNos==ib&Links_3WindingTransfoNumber==TransfoNumber&Links_3WTransferNumber>1,1);
                                            if~isempty(n_ib_W3)
                                                LF.bus(ib).Sshunt=LF.bus(ib).Sshunt+(P+1i*Q)/LF.Pbase*Px;
                                            else

                                                Links_3WTransferNumber(index_LinesTransfos)=Links_3WTransferNumber(index_LinesTransfos)+1;%#ok
                                            end
                                        end


                                    case 'c'
                                        k=strmatch(['-> ',LF.bus(n).ID(1:end-2),' '],ShowText_Transfer);
                                        if~WarningOn
                                            if isempty(k)
                                                try
                                                    strPQtransfer=sprintf('-> %-9s(%s %s)%-44s %9.2f %9.2f %1s',LF.bus(n).ID(1:end-2),WATTS,VARS,' ',P,Q,' ');
                                                catch
                                                    strPQtransfer=sprintf('-> %-9s(%s %s)%-44s %9.3g %9.3g %1s',LF.bus(n).ID(1:end-2),WATTS,VARS,' ',P,Q,' ');
                                                end
                                                ShowText_Transfer=char(ShowText_Transfer,strPQtransfer);
                                            else
                                                try
                                                    ShowText_Transfer(k,67:85)=sprintf('%9.2f %9.2f',P,Q);
                                                catch
                                                    ShowText_Transfer(k,67:85)=sprintf('%9.3g %9.3g',P,Q);
                                                end
                                            end
                                        end


                                        LF.bus(ib).Sshunt=LF.bus(ib).Sshunt-(P+1i*Q)/LF.Pbase*Px;

                                        TransfoNumber=Links_3WindingTransfoNumber(index_LinesTransfos);
                                        if TransfoNumber>0
                                            n_ib_W3=find(Links_BusNos==ib&Links_3WindingTransfoNumber==TransfoNumber&Links_3WTransferNumber>1,1);
                                            if~isempty(n_ib_W3)
                                                LF.bus(ib).Sshunt=LF.bus(ib).Sshunt+(P+1i*Q)/LF.Pbase*Px;
                                            else

                                                Links_3WTransferNumber(index_LinesTransfos)=Links_3WTransferNumber(index_LinesTransfos)+1;%#ok
                                            end
                                        end
                                    end

                                end
                            end
                        end
                        if~isempty(Warning)&&NumberOfPhases==nbus1ph
                            Warning=char(' ',Warning(2:end,:),' ');
                            ShowText_Transfer=char(ShowText_Transfer,Warning);
                            BusesWithMissingPQTransfer=[BusesWithMissingPQTransfer,' ',LF.bus(ib).ID(1:end-2)];%#ok
                            nBusesWithMissingPQTransfer=nBusesWithMissingPQTransfer+1;
                        end
                        if~isempty(strBusInfo)
                            ShowText_Transfer=char(ShowText_Transfer,strBusInfo);
                        end

                        if NumberOfPhases==nbus1ph

                            for i=ib-NumberOfPhases+1:ib
                                switch LF.bus(i).ID(end)
                                case 'a'
                                    P=real(LF.bus(i).Sshunt)*LF.Pbase/Px;
                                    Q=imag(LF.bus(i).Sshunt)*LF.Pbase/Px;
                                    Sshunt_all_phases=Sshunt_all_phases+(P+1i*Q);
                                    if isempty(Warning)
                                        try
                                            ShowText_Subnet(end,23:41)=sprintf('%9.2f %9.2f',P,Q);
                                        catch
                                            ShowText_Subnet(end,23:41)=sprintf('%9.3g %9.3g',P,Q);
                                        end
                                    end
                                case 'b'
                                    P=real(LF.bus(i).Sshunt)*LF.Pbase/Px;
                                    Q=imag(LF.bus(i).Sshunt)*LF.Pbase/Px;
                                    Sshunt_all_phases=Sshunt_all_phases+(P+1i*Q);
                                    if isempty(Warning)
                                        try
                                            ShowText_Subnet(end,45:63)=sprintf('%9.2f %9.2f',P,Q);
                                        catch
                                            ShowText_Subnet(end,45:63)=sprintf('%9.3g %9.3g',P,Q);
                                        end
                                    end
                                case 'c'
                                    P=real(LF.bus(i).Sshunt)*LF.Pbase/Px;
                                    Q=imag(LF.bus(i).Sshunt)*LF.Pbase/Px;
                                    Sshunt_all_phases=Sshunt_all_phases+(P+1i*Q);
                                    if isempty(Warning)
                                        try
                                            ShowText_Subnet(end,67:85)=sprintf('%9.2f %9.2f',P,Q);
                                        catch
                                            ShowText_Subnet(end,67:85)=sprintf('%9.3g %9.3g',P,Q);
                                        end
                                    end
                                end
                            end

                            if isempty(Warning)
                                try
                                    ShowText_Subnet(end,89:107)=sprintf('%9.2f %9.2f',real(Sshunt_all_phases),imag(Sshunt_all_phases));
                                catch
                                    ShowText_Subnet(end,89:107)=sprintf('%9.3g %9.3g',real(Sshunt_all_phases),imag(Sshunt_all_phases));
                                end
                            end

                            if isempty(Warning)

                                Mat_str=ShowText_Transfer(2:end,22:end);

                                for ntransfer=1:size(Mat_str,1)
                                    if all(Mat_str(ntransfer,1:20)==' ')
                                        Mat_str(ntransfer,1:20)=sprintf('%10.2f%10.2f',0,0);
                                    end
                                    if all(Mat_str(ntransfer,21:42)==' ')
                                        Mat_str(ntransfer,21:42)=sprintf('%11.2f%11.2f',0,0);
                                    end
                                    if all(Mat_str(ntransfer,43:63)==' ')
                                        Mat_str(ntransfer,43:64)=sprintf('%11.2f%11.2f',0,0);
                                    end
                                end
                                Mat_transfer=str2num(Mat_str);
                                Ptot=sum(Mat_transfer(:,1:2:end),2);
                                Qtot=sum(Mat_transfer(:,2:2:end),2);
                                for ntransfer=1:size(Mat_transfer,1)
                                    try
                                        ShowText_Transfer(ntransfer+1,89:107)=sprintf('%9.2f %9.2f',Ptot(ntransfer),Qtot(ntransfer));
                                    catch
                                        ShowText_Transfer(ntransfer+1,89:107)=sprintf('%9.3g %9.3g',Ptot(ntransfer),Qtot(ntransfer));
                                    end
                                end
                            end
                            ShowText_Subnet=char(ShowText_Subnet,ShowText_Transfer);
                        end
                        SgenTotal=SgenTotal+LF.bus(ib).Sgen;
                        SpqloadTotal=SpqloadTotal+LF.bus(ib).Spqload;
                        SshuntTotal=SshuntTotal+LF.bus(ib).Sshunt;
                    end
                end

                SlossTotal=SgenTotal-SpqloadTotal-SshuntTotal;
                ShowText_summary=char(ShowText_summary,sprintf('  Total generation  : P=%10.2f %s   Q=%10.2f %s',...
                real(SgenTotal)*LF.Pbase/Px,WATTS,imag(SgenTotal)*LF.Pbase/Px,VARS));

                ShowText_summary=char(ShowText_summary,sprintf('  Total PQ load     : P=%10.2f %s   Q=%10.2f %s',...
                real(SpqloadTotal)*LF.Pbase/Px,WATTS,imag(SpqloadTotal)*LF.Pbase/Px,VARS));

                ShowText_summary=char(ShowText_summary,sprintf('  Total Zshunt load : P=%10.2f %s   Q=%10.2f %s',...
                real(SshuntTotal)*LF.Pbase/Px,WATTS,imag(SshuntTotal)*LF.Pbase/Px,VARS));

                ShowText_summary=char(ShowText_summary,sprintf('  Total losses      : P=%10.2f %s   Q=%10.2f %s',...
                real(SlossTotal)*LF.Pbase/Px,WATTS,imag(SlossTotal)*LF.Pbase/Px,VARS));

                if~isempty(BusesWithMissingPQTransfer)
                    ShowText_summary=char(ShowText_summary,' ',...
                    sprintf('Warning : PQ flow could not be displayed for all links connected at the following %d buses:',nBusesWithMissingPQTransfer),...
                    sprintf('           %s',BusesWithMissingPQTransfer),...
                    '          See warnings below corresponding bus reports');
                end

                ShowText=char(ShowText,' ',sprintf('SUMMARY for subnetwork No %d',nSubNetwork),ShowText_summary,ShowText_Subnet);



            else
                ShowText_SubnetDeleted=char(ShowText_SubnetDeleted,sprintf('  Subnetwork No %d',nSubNetwork));
                for ib=LF.Networks(isubnet).busNumber
                    ShowText_SubnetDeleted=char(ShowText_SubnetDeleted,sprintf('    %s',LF.bus(ib).ID));
                end
            end
        end



        ShowTextSwing='';
        if isfield(LF.vsrc,'InternalBus')
            if~isempty(cell2mat(LF.vsrc.InternalBus))
                ShowTextSwing=' ';
                ShowTextSwing=char(ShowTextSwing,...
                'WARNING: At buses listed below, a Three-Phase Source set to swing type is connected in parallel');
                ShowTextSwing=char(ShowTextSwing,...
                '         with synchronous machines or voltage sources set to PV type:');
                for n=1:length(LF.vsrc.busNumber)
                    if~isempty(LF.vsrc.InternalBus{n})
                        ShowTextSwing=char(ShowTextSwing,sprintf('           --> %s',LF.vsrc.busID{n}));
                    end
                end
                ShowTextSwing=char(ShowTextSwing,...
                '         Since these buses cannot be both swing type and PV type, swing buses have been moved');
                ShowTextSwing=char(ShowTextSwing,...
                '         at the ideal voltage source node, behind the RL impedance.');
            end
        end

        if~isempty(ShowText_SubnetDeleted)
            ShowText_SubnetDeleted=char(' ',...
            sprintf('WARNING: The following subnetworks have been ignored because they contain no swing bus:'),ShowText_SubnetDeleted);
        end

        ShowText=char(ShowText1,ShowTextSwing,ShowText_SubnetDeleted,ShowText);

        if isempty(FileNameReport)
            [FileName,PathName,FilterIndex]=uiputfile('LoadFlow.rep','Save the report file');
            if FilterIndex==0

                return
            end
            LFFN=[PathName,FileName];
        else
            LFFN=strrep(FileNameReport,'.rep','');
            LFFN=[LFFN,'.rep'];
        end

        [fid,permission]=fopen(LFFN,'w+');

        if fid==-1||strcmp(permission,'Permission denied')
            Message='The directory you choose to save the report seems to be write protected. Consequently no report will be generated.';
            warndlg(Message,'Load flow Report')
            warning('SpecializedPowerSystems:LoadflowReport:CannotSaveReport',Message)
            return
        end

        for i=1:size(ShowText,1)
            fprintf(fid,'%s\n',ShowText(i,:));
        end

        if isempty(FileNameReport)
            edit(fullfile(PathName,FileName));
        end

        fclose(fid);

    case 'Excel'





        warning('off','MATLAB:xlswrite:AddSheet');

        try
            Excel=actxserver('Excel.Application');
            ExcelVersion=str2num(Excel.Version);%#ok<*ST2NM>
            Excel.Quit;
        catch
            errordlg('No version of Microsoft Excel detected');
            return
        end
        if ExcelVersion>=12
            filename_init=['LoadFlowResults_',LF.model,'.xlsx'];
        else
            filename_init=['LoadFlowResults_',LF.model,'.xls'];
        end
        if isempty(FileNameReport)
            [FileName,pathName,filterIndex]=uiputfile(filename_init,'Save the Excel load flow report');
            if filterIndex==0

                return
            end
            FileName=[pathName,FileName];
        else
            FileName=fullfile(pwd,FileNameReport);
        end


        if exist(FileName,'file')
            try
                xlswrite(FileName,' ',1,'A1');
            catch
                Ex1=actxGetRunningServer('Excel.Application');
                Openfiles=Ex1.WorkBooks;
                for i=1:Openfiles.Count
                    if strcmp(FileName,Openfiles.Item(i).FullName)
                        Openfiles.Item(i).Close;
                    end
                end
                Ex1.Quit;
            end
        end
        title={['Summary for ',LF.model,' : The load flow converged in ',num2str(LF.niter),' iterations !']};
        xlswrite(FileName,title,'Subnetwork 1','A1');
        Excel.Workbooks.Open(FileName);

        try

            Excel.ActiveWorkbook.Worksheets.Item('Sheet1').Delete;
            Excel.ActiveWorkbook.Worksheets.Item('Sheet2').Delete;
            Excel.ActiveWorkbook.Worksheets.Item('Sheet3').Delete;
        catch

        end

        Excel.ActiveWorkbook.Save;
        Excel.ActiveWorkbook.Close;

        Nbus=size(LF.Ybus1,1);
        Ybus=LF.Ybus1asm;
        nSubnetwork=0;
        nRow=1;
        nRowgeneration=3;
        nRowpq=3;
        nRowshunt=3;
        nRowasm=3;
        strPowerType={['P(',WATTS,')'],['Q(',VARS,')']};
        Pt=zeros(1e3,1);
        Qt=zeros(1e3,1);
        Stasm=zeros(1e3,1);
        GenerationReportTable=cell(0,4);
        PQloadReportTable=cell(0,4);
        ZshuntReportTable=cell(0,4);
        ASMReportTable=cell(0,4);

        for isubnet=1:LF.NbOfNetworks


            GenerationReportTable{nRowgeneration,1}=['Subnetwork ',num2str(isubnet)];
            nRowgeneration=nRowgeneration+1;
            GenerationReportTable{nRowgeneration,3}=strPowerType{1};
            GenerationReportTable{nRowgeneration,4}=strPowerType{2};
            nRowgeneration=nRowgeneration+1;

            PQloadReportTable{nRowpq,1}=['Subnetwork ',num2str(isubnet)];
            nRowpq=nRowpq+1;
            PQloadReportTable{nRowpq,3}=strPowerType{1};
            PQloadReportTable{nRowpq,4}=strPowerType{2};
            nRowpq=nRowpq+1;


            ZshuntReportTable{nRowshunt,1}=['Subnetwork ',num2str(isubnet)];
            nRowshunt=nRowshunt+1;
            ZshuntReportTable{nRowshunt,3}=strPowerType{1};
            ZshuntReportTable{nRowshunt,4}=strPowerType{2};
            nRowshunt=nRowshunt+1;


            ASMReportTable{nRowasm,1}=['Subnetwork ',num2str(isubnet)];
            nRowasm=nRowasm+1;
            ASMReportTable{nRowasm,3}=strPowerType{1};
            ASMReportTable{nRowasm,4}=strPowerType{2};
            nRowasm=nRowasm+1;

            nSubnetwork=nSubnetwork+1;
            sheet=['Subnetwork ',num2str(isubnet)];
            SubnetworkReportTable=cell(0,5);

            if~isempty(LF.Networks(isubnet).SwingBus)

                SgenTotal=0;
                SpqloadTotal=0;
                SshuntTotal=0;
                SasmTotal=0;
                no_bus=0;


                strmatID=char(LF.bus(LF.Networks(isubnet).busNumber).ID);
                [~,nbus_sort]=sortrows(strmatID);







                n_implicit=strmatch('*',strmatID(nbus_sort,:));%#ok<*MATCH2>

                if~isempty(n_implicit)
                    nbus_sort=[nbus_sort(max(n_implicit)+1:end);nbus_sort(1:max(n_implicit))];
                end


                for ib=LF.Networks(isubnet).busNumber(nbus_sort)

                    strBusInfo='';
                    if ib<=Nbus

                        no_bus=no_bus+1;

                        switch LF.bus(ib).TypeNumber

                        case 1
                            strBusInfo=' ; Swing bus';

                        case 2
                            if LF.bus(ib).QmaxReached
                                n=find(cell2mat(LF.sm.busNumber)==ib&strcmp('PV',LF.sm.busType));
                                if~isempty(n)
                                    strBusInfo=sprintf(' ; Qmax limit reached on PV generator (%.2f %s)',imag(LF.sm.S{n})*LF.Pbase/Px,VARS);
                                end
                                n=find(cell2mat(LF.vsrc.busNumber)==ib&strcmp('PV',LF.vsrc.busType));
                                if~isempty(n)
                                    strBusInfo=sprintf(' ; Qmax limit reached on PV voltage source (%.2f %s)',imag(LF.vsrc.S{n})*LF.Pbase/Px,VARS);
                                end
                            end
                            if LF.bus(ib).QminReached
                                n=find(cell2mat(LF.sm.busNumber)==ib&strcmp('PV',LF.sm.busType));
                                if~isempty(n)
                                    strBusInfo=sprintf(' ; Qmin limit reached on PV generator (%.2f %s)',imag(LF.sm.S{n})*LF.Pbase/Px,VARS);
                                end
                                n=find(cell2mat(LF.vsrc.busNumber)==ib&strcmp('PV',LF.vsrc.busType));
                                if~isempty(n)
                                    strBusInfo=sprintf(' ; Qmin limit reached on PV voltage source (%.2f %s)',imag(LF.vsrc.S{n})*LF.Pbase/Px,VARS);
                                end
                            end
                        end


                        strDetailsBus=[sprintf('%d : %s  V= %.3f pu/%g%s %.2f deg %10s ',...
                        no_bus,LF.bus(ib).ID,...
                        abs(LF.bus(ib).Vbus),LF.bus(ib).vbase/Vx,VOLTS,angle(LF.bus(ib).Vbus)*180/pi),strBusInfo];
                        SubnetworkReportTable{nRow,1}=strDetailsBus;
                        nRow=nRow+1;

                        SubnetworkReportTable{nRow,4}=strPowerType{1};
                        SubnetworkReportTable{nRow,5}=strPowerType{2};
                        nRow=nRow+1;


                        SubnetworkReportTable{nRow,2}='Generation';
                        SubnetworkReportTable{nRow,4}=real(LF.bus(ib).Sgen)*LF.Pbase/Px;
                        SubnetworkReportTable{nRow,5}=imag(LF.bus(ib).Sgen)*LF.Pbase/Px;
                        nRow=nRow+1;

                        if LF.bus(ib).Sgen~=0
                            GenerationReportTable{nRowgeneration,1}=LF.bus(ib).ID;
                            GenerationReportTable{nRowgeneration,3}=real(LF.bus(ib).Sgen)*LF.Pbase/Px;
                            GenerationReportTable{nRowgeneration,4}=imag(LF.bus(ib).Sgen)*LF.Pbase/Px;
                            nRowgeneration=nRowgeneration+1;
                        end

                        SubnetworkReportTable{nRow,2}='PQ Load';
                        SubnetworkReportTable{nRow,4}=(LF.bus(ib).Spqload)*LF.Pbase/Px;
                        SubnetworkReportTable{nRow,5}=imag(LF.bus(ib).Spqload)*LF.Pbase/Px;
                        nRow=nRow+1;
                        if LF.bus(ib).Spqload~=0
                            PQloadReportTable{nRowpq,1}=LF.bus(ib).ID;
                            PQloadReportTable{nRowpq,3}=real(LF.bus(ib).Spqload)*LF.Pbase/Px;
                            PQloadReportTable{nRowpq,4}=imag(LF.bus(ib).Spqload)*LF.Pbase/Px;
                            nRowpq=nRowpq+1;
                        end

                        ntransfer=find(abs(Ybus(ib,:))~=0);

                        [~,nbus_sort2]=sortrows(char(LF.bus(ntransfer).ID));
                        v1=LF.bus(ib).Vbus;
                        Ishunt=v1*Ybus(ib,ib);
                        Pitotal=0;
                        Qitotal=0;
                        it=0;
                        iasm=0;
                        for n=ntransfer(nbus_sort2)
                            if n<=Nbus&&n~=ib
                                it=it+1;

                                v2=LF.bus(n).Vbus;
                                phi=(angle(Ybus(n,ib))-angle(Ybus(n,ib)+Ybus(ib,n)));
                                VoltageRatio=LF.VoltageRatio(ib,n);










                                I=Ybus(ib,n)*(-v1*VoltageRatio*exp(1i*phi)+v2);


                                Ishunt=Ishunt+Ybus(ib,n)*v1*VoltageRatio*exp(1i*phi);
                                St=v1*conj(I)*LF.Pbase/Px;
                                Pt(it)=real(St);
                                Qt(it)=imag(St);
                                [Pi,Qi]=CorrectionsPowerLines(LF,ib,n);
                                Pt(it)=Pt(it)+Pi;
                                Qt(it)=Qt(it)+Qi;
                                Pitotal=Pitotal+Pi;
                                Qitotal=Qitotal+Qi;
                            elseif n>Nbus
                                iasm=iasm+1;

                                I=-Ybus(ib,n)*(LF.bus(ib).Vbus-LF.bus(n).Vbus);
                                Stasm(iasm)=LF.bus(ib).Vbus*conj(I);
                                SasmTotal=SasmTotal+Stasm(iasm);
                                Stasm(iasm)=Stasm(iasm)*LF.Pbase/Px;
                                Ishunt=Ishunt+Ybus(ib,n)*v1;
                            end
                        end
                        LF.bus(ib).Sshunt=v1*conj(Ishunt);
                        P=real(LF.bus(ib).Sshunt)*LF.Pbase/Px;
                        Q=imag(LF.bus(ib).Sshunt)*LF.Pbase/Px;
                        P=P-Pitotal;
                        Q=Q-Qitotal;

                        SubnetworkReportTable{nRow,2}='Z shunt';
                        SubnetworkReportTable{nRow,4}=P;
                        SubnetworkReportTable{nRow,5}=Q;
                        nRow=nRow+1;
                        if(P~=0||Q~=0)
                            ZshuntReportTable{nRowshunt,1}=LF.bus(ib).ID;
                            ZshuntReportTable{nRowshunt,3}=P;
                            ZshuntReportTable{nRowshunt,4}=Q;
                            nRowshunt=nRowshunt+1;
                        end
                        it=0;
                        iasm=0;
                        for n=ntransfer(nbus_sort2)
                            if n<=Nbus&&n~=ib
                                it=it+1;

                                SubnetworkReportTable{nRow,2}=LF.bus(n).ID;
                                SubnetworkReportTable{nRow,4}=Pt(it);
                                SubnetworkReportTable{nRow,5}=Qt(it);
                                nRow=nRow+1;
                            elseif n>Nbus
                                iasm=iasm+1;

                                SubnetworkReportTable{nRow,2}='ASM';
                                SubnetworkReportTable{nRow,4}=real(Stasm(iasm));
                                SubnetworkReportTable{nRow,5}=imag(Stasm(iasm));
                                nRow=nRow+1;
                                if(Stasm(iasm)~=0)
                                    ASMReportTable{nRowasm,1}=LF.bus(ib).ID;
                                    ASMReportTable{nRowasm,3}=real(Stasm(iasm));
                                    ASMReportTable{nRowasm,4}=imag(Stasm(iasm));
                                    nRowasm=nRowasm+1;
                                end
                            end
                        end
                        SgenTotal=SgenTotal+LF.bus(ib).Sgen;
                        SpqloadTotal=SpqloadTotal+LF.bus(ib).Spqload;
                        SshuntTotal=SshuntTotal+LF.bus(ib).Sshunt;


                        SshuntTotal=SshuntTotal-(Pitotal+1i*Qitotal)*Px/LF.Pbase;
                        nRow=nRow+1;
                    end
                end
            end

            Slosses=SgenTotal-SpqloadTotal-SshuntTotal-SasmTotal;
            summary={'Total generation';'Total PQ load';'Total Z shunt';'Total ASM';'Total losses'};
            xlswrite(FileName,summary,sheet,'B4');
            summaryPower={real(SgenTotal)*LF.Pbase/Px,imag(SgenTotal)*LF.Pbase/Px;
            real(SpqloadTotal)*LF.Pbase/Px,imag(SpqloadTotal)*LF.Pbase/Px;
            real(SshuntTotal)*LF.Pbase/Px,imag(SshuntTotal)*LF.Pbase/Px;
            real(SasmTotal)*LF.Pbase/Px,imag(SasmTotal)*LF.Pbase/Px;
            real(Slosses)*LF.Pbase/Px,imag(Slosses)*LF.Pbase/Px};
            xlswrite(FileName,{['P(',WATTS,')'],['Q(',VARS,')']},sheet,'D3');
            xlswrite(FileName,summaryPower,sheet,'D4');



            GenerationReportTable{nRowgeneration,1}='Total';
            GenerationReportTable{nRowgeneration,3}=real(SgenTotal)*LF.Pbase/Px;
            GenerationReportTable{nRowgeneration,4}=imag(SgenTotal)*LF.Pbase/Px;
            nRowgeneration=nRowgeneration+2;

            PQloadReportTable{nRowpq,1}='Total';
            PQloadReportTable{nRowpq,3}=real(SpqloadTotal)*LF.Pbase/Px;
            PQloadReportTable{nRowpq,4}=imag(SpqloadTotal)*LF.Pbase/Px;
            nRowpq=nRowpq+2;

            ZshuntReportTable{nRowshunt,1}='Total';
            ZshuntReportTable{nRowshunt,3}=real(SshuntTotal)*LF.Pbase/Px;
            ZshuntReportTable{nRowshunt,4}=imag(SshuntTotal)*LF.Pbase/Px;
            nRowshunt=nRowshunt+2;

            ASMReportTable{nRowasm,1}='Total';
            ASMReportTable{nRowasm,3}=real(SasmTotal)*LF.Pbase/Px;
            ASMReportTable{nRowasm,4}=imag(SasmTotal)*LF.Pbase/Px;
            nRowasm=nRowasm+2;
            xlswrite(FileName,SubnetworkReportTable,sheet,'A10');
        end

        xlswrite(FileName,GenerationReportTable,'Generation report','A1');
        xlswrite(FileName,PQloadReportTable,'PQ load report','A1');
        xlswrite(FileName,ZshuntReportTable,'Z shunt report','A1');
        xlswrite(FileName,ASMReportTable,'ASM report','A1');
        xlswrite(FileName,' ',1,'A2');
    end
    function[Ss,BusNos,BusNor,LineNumber]=PowersIntoPowerLine(LF,ib,n)









        Ss=[];
        BusNos=[];
        BusNor=[];
        LineNumber=[];

        Lh=LF.bus(ib).Lines;

        Ld=LF.bus(n).Lines;
        if isempty(Lh)

            return
        end
        if isempty(Ld)

            return
        end

        LineNumber_vec=[];
        for iline=Lh
            k=find(Ld==iline,1);
            if~isempty(k)
                LineNumber_vec=[LineNumber_vec,iline];%#ok
            end
        end
        if isempty(LineNumber_vec)
            LineNumber=[];
            return
        end
        for LineNumber=LineNumber_vec
            BusNos1=[];
            BusNor1=[];


            if any(LF.Lines.LeftbusNumber{LineNumber}==ib)


                NumberOfPhases=length(LF.Lines.LeftbusNumber{LineNumber});
                Vs=zeros(NumberOfPhases,1);
                Vr=zeros(NumberOfPhases,1);
                for ibus=sort(LF.Lines.LeftbusNumber{LineNumber})


                    NodeNumber=LF.bus(ibus).Busnode;
                    k=find(LF.Lines.leftnodes{LineNumber}==NodeNumber);
                    Vs(k)=LF.bus(ibus).Vbus*LF.bus(ibus).vbase;
                    ibusr=LF.Lines.RightbusNumber{LineNumber}(k);



                    Vr(k)=LF.bus(ibusr).Vbus*LF.bus(ibusr).vbase;
                    BusNos1=[BusNos1;ibus];%#ok
                    BusNor1=[BusNor1;ibusr];%#ok
                end
            else


                NumberOfPhases=length(LF.Lines.RightbusNumber{LineNumber});
                Vs=zeros(NumberOfPhases,1);
                Vr=zeros(NumberOfPhases,1);
                for ibus=sort(LF.Lines.RightbusNumber{LineNumber})


                    NodeNumber=LF.bus(ibus).Busnode;
                    k=find(LF.Lines.rightnodes{LineNumber}==NodeNumber);
                    Vs(k)=LF.bus(ibus).Vbus*LF.bus(ibus).vbase;
                    ibusr=LF.Lines.LeftbusNumber{LineNumber}(k);



                    Vr(k)=LF.bus(ibusr).Vbus*LF.bus(ibusr).vbase;
                    BusNos1=[BusNos1;ibus];%#ok
                    BusNor1=[BusNor1;ibusr];%#ok
                end
            end
            switch LF.Lines.BlockType{LineNumber}


            case 'Dist'
                freq=LF.freq;
                long=LF.Lines.long{LineNumber};
                r=LF.Lines.r{LineNumber};
                l=LF.Lines.l{LineNumber};
                c=LF.Lines.c{LineNumber};
                nphase=length(LF.Lines.LeftbusNumber{LineNumber});
                [Zmode,Rmode,Smode,Ti]=blmodlin(nphase,freq,r,l,c);
                [Hline]=DistributedParameterLine_H(Zmode,Rmode,Smode,Ti,long,freq);


                Is=Hline(1:nphase,:)*[Vs;Vr];

            case{'PI 1ph','PI 2ph','PI 3ph'}
                nphase=length(LF.Lines.LeftbusNumber{LineNumber});
                Z=LF.Lines.Zmatrix{LineNumber};
                Y_2=LF.Lines.Ymatrix{LineNumber};
                invZ=inv(Z);
                M=[invZ+Y_2,-invZ
                -invZ,invZ+Y_2];
                Is=M(1:nphase,:)*[Vs;Vr];

            case 'PI'
                freq=LF.freq;
                w=2*pi*freq;
                long=LF.Lines.long{LineNumber};
                nphase=3;
                r1=LF.Lines.r{LineNumber}(1);
                r0=LF.Lines.r{LineNumber}(2);
                l1=LF.Lines.l{LineNumber}(1);
                l0=LF.Lines.l{LineNumber}(2);
                c1=LF.Lines.c{LineNumber}(1);
                c0=LF.Lines.c{LineNumber}(2);
                z1=r1+1i*l1*w;
                z0=r0+1i*l0*w;
                y1=1i*c1*w;
                y0=1i*c0*w;
                Zc=sqrt(z1/y1);
                gammal=sqrt(z1*y1)*long;
                Z1=Zc*sinh(gammal);
                Y1_2=1/Zc*tanh(gammal/2);
                Y1_2=1i*imag(Y1_2);
                Zc=sqrt(z0/y0);
                gammal=sqrt(z0*y0)*long;
                Z0=Zc*sinh(gammal);
                Y0_2=1/Zc*tanh(gammal/2);
                Y0_2=1i*imag(Y0_2);


                Zs=(Z0+2*Z1)/3;
                Zm=(Z0-Z1)/3;
                Ys_2=(Y0_2+2*Y1_2)/3;
                Ym_2=(Y0_2-Y1_2)/3;
                Z=ones(3,3)*Zm;
                Y_2=ones(3,3)*Ym_2;
                for iph=1:nphase
                    Z(iph,iph)=Zs;
                    Y_2(iph,iph)=Ys_2;
                end
                invZ=inv(Z);
                M=[invZ+Y_2,-invZ
                -invZ,invZ+Y_2];


                Is=M(1:nphase,:)*[Vs;Vr];
            case 'Z1Z0'
                freq=LF.freq;
                w=2*pi*freq;
                r1=LF.Lines.r{LineNumber}(1);
                r0=LF.Lines.r{LineNumber}(2);
                l1=LF.Lines.l{LineNumber}(1);
                l0=LF.Lines.l{LineNumber}(2);
                nphase=3;




                Zs=(r0+2*r1)/3+(l0+2*l1)/3*1i*w;
                Zm=(r0-r1)/3+(l0-l1)/3*1i*w;
                Z=ones(3,3)*Zm;
                for iph=1:nphase
                    Z(iph,iph)=Zs;
                end
                Is=Z\(Vs-Vr);
            case 'Lmut'
                freq=LF.freq;
                w=2*pi*freq;
                Z=LF.Lines.r{LineNumber}+1i*LF.Lines.l{LineNumber}*w;
                Is=Z\(Vs-Vr);
            otherwise
                error('Line or series impedance No %d  Type ''%s'' is not allowed',LineNumber,LF.Lines.BlockType{LineNumber})
            end
            BusNos=[BusNos;sort(BusNos1)];%#ok
            BusNor=[BusNor;sort(BusNor1)];%#ok

            Scond=Vs.*conj(Is);

            Sphase=Scond*0;
            if any(LF.Lines.LeftbusNumber{LineNumber}==ib)

                nph=0;
                for ibus=sort(LF.Lines.LeftbusNumber{LineNumber})
                    nph=nph+1;
                    NodeNumber=LF.bus(ibus).Busnode;

                    k=LF.Lines.leftnodes{LineNumber}==NodeNumber;
                    Sphase(nph)=Scond(k);
                end
            else

                nph=0;
                for ibus=sort(LF.Lines.RightbusNumber{LineNumber})
                    nph=nph+1;
                    NodeNumber=LF.bus(ibus).Busnode;

                    k=LF.Lines.rightnodes{LineNumber}==NodeNumber;
                    Sphase(nph)=Scond(k);
                end
            end
            Ss=[Ss;Sphase];%#ok
        end
        LineNumber=LineNumber_vec;
        function[Ss,BusNos,BusNor,TransfoNumber,WarningOn,Warning,LF]=PowersInto3phTransformer(LF,ib,n,Warning,WATTS,VARS,Px)









            Ss=[];
            BusNos=[];
            BusNor=[];
            TransfoNumber=[];
            WarningOn=0;

            Trh=LF.bus(ib).Transfos;

            Trd=LF.bus(n).Transfos;
            if isempty(Trh)

                return
            end
            if isempty(Trd)

                return
            end

            TransfoNumber_vec=[];
            for i=Trh
                k=find(Trd==i,1);
                if~isempty(k)
                    TransfoNumber_vec=[TransfoNumber_vec,i];%#ok
                end
            end
            if isempty(TransfoNumber_vec)

                TransfoNumber=[];
                return
            end
            for TransfoNumber=TransfoNumber_vec
                if LF.bus(ib).ID(end)~=LF.bus(n).ID(end)
                    WarningOn=1;
                    return
                end

                if any(LF.Transfos.W1busNumber{TransfoNumber}==ib)
                    SendingWindingNumber=1;
                    BusNos=[BusNos;sort(LF.Transfos.W1busNumber{TransfoNumber})'];%#ok
                elseif any(LF.Transfos.W2busNumber{TransfoNumber}==ib)
                    SendingWindingNumber=2;
                    BusNos=[BusNos;sort(LF.Transfos.W2busNumber{TransfoNumber})'];%#ok
                elseif~isempty(LF.Transfos.W3nodes{TransfoNumber})
                    if any(LF.Transfos.W3busNumber{TransfoNumber}==ib)
                        SendingWindingNumber=3;
                        BusNos=[BusNos;sort(LF.Transfos.W3busNumber{TransfoNumber})'];%#ok
                    end
                end
                if LF.Transfos.FlowDisplayed{TransfoNumber}
                    BusNos=[];
                    WarningOn=1;
                    return
                end

                if any(LF.Transfos.W1busNumber{TransfoNumber}==n)
                    BusNor=[BusNor;sort(LF.Transfos.W1busNumber{TransfoNumber})'];%#ok
                elseif any(LF.Transfos.W2busNumber{TransfoNumber}==n)
                    BusNor=[BusNor;sort(LF.Transfos.W2busNumber{TransfoNumber})'];%#ok
                elseif~isempty(LF.Transfos.W3nodes{TransfoNumber})
                    if any(LF.Transfos.W3busNumber{TransfoNumber}==n)
                        BusNor=[BusNor;sort(LF.Transfos.W3busNumber{TransfoNumber})'];%#ok
                    end
                end
                Pnom=LF.Transfos.Pnom{TransfoNumber};
                switch LF.Transfos.Type{TransfoNumber}
                case{'3SinglePhase','3PhaseCoreType'}

                    Vabc_w1=[LF.bus(LF.Transfos.W1busNumber{TransfoNumber}).Vbus].';
                    Vabc_w2=[LF.bus(LF.Transfos.W2busNumber{TransfoNumber}).Vbus].';
                    if isempty(LF.Transfos.conW3{TransfoNumber})
                        Nwinding=2;
                        conex_windings={LF.Transfos.conW1{TransfoNumber},LF.Transfos.conW2{TransfoNumber}};
                    else
                        Nwinding=3;
                        conex_windings={LF.Transfos.conW1{TransfoNumber},LF.Transfos.conW2{TransfoNumber},LF.Transfos.conW3{TransfoNumber}};
                        Vabc_w3=[LF.bus(LF.Transfos.W3busNumber{TransfoNumber}).Vbus].';
                    end
                    Pbase=3*LF.Pbase;
                    vnomLG1=LF.Transfos.W1{TransfoNumber}(1)/sqrt(3);
                    vbaseLG1=LF.bus(LF.Transfos.W1busNumber{TransfoNumber}(1)).vbase;
                    r1=LF.Transfos.W1{TransfoNumber}(2);
                    x1=LF.Transfos.W1{TransfoNumber}(3);
                    vnomLG2=LF.Transfos.W2{TransfoNumber}(1)/sqrt(3);
                    vbaseLG2=LF.bus(LF.Transfos.W2busNumber{TransfoNumber}(1)).vbase;
                    r2=LF.Transfos.W2{TransfoNumber}(2);
                    x2=LF.Transfos.W2{TransfoNumber}(3);
                    rm=LF.Transfos.RmLm{TransfoNumber}(1);
                    xm=LF.Transfos.RmLm{TransfoNumber}(2);
                    if Nwinding==3
                        vnomLG3=LF.Transfos.W3{TransfoNumber}(1)/sqrt(3);
                        vbaseLG3=LF.bus(LF.Transfos.W3busNumber{TransfoNumber}(1)).vbase;
                        r3=LF.Transfos.W3{TransfoNumber}(2);
                        x3=LF.Transfos.W3{TransfoNumber}(3);
                    else
                        r3=0;
                        x3=0;
                    end

                    if strcmp(LF.Transfos.Type{TransfoNumber},'3PhaseCoreType')
                        Nwadd=1;
                        x0add=LF.Transfos.L0{TransfoNumber};
                        conex_windings{end+1}='Delta (D1)';%#ok
                    else
                        Nwadd=0;
                    end

                    if strcmp(LF.Transfos.Units{TransfoNumber},'SI')
                        Fnom=LF.Transfos.Fnom{TransfoNumber};

                        vnom=vnomLG1*sqrt(3);
                        zbase=vnom^2/Pnom;
                        if strcmp(LF.Transfos.conW1{TransfoNumber}(1),'D')
                            zbase=zbase*3;
                        end
                        r1=r1/zbase;
                        x1=x1*2*pi*Fnom/zbase;
                        rm=rm/zbase;
                        xm=xm*2*pi*Fnom/zbase;

                        vnom=vnomLG2*sqrt(3);
                        zbase=vnom^2/Pnom;
                        if strcmp(LF.Transfos.conW2{TransfoNumber}(1),'D')
                            zbase=zbase*3;
                        end
                        r2=r2/zbase;
                        x2=x2*2*pi*Fnom/zbase;

                        if Nwinding==3
                            vnom=vnomLG3*sqrt(3);
                            zbase=vnom^2/Pnom;
                            if strcmp(LF.Transfos.conW3{TransfoNumber}(1),'D')
                                zbase=zbase*3;
                            end
                            r3=r3/zbase;
                            x3=x3*2*pi*Fnom/zbase;
                        end
                        if Nwadd==1
                            vnom=vnomLG1*sqrt(3);
                            zbase=vnom^2/Pnom;
                            zbase=zbase*3;
                            x0add=x0add*2*pi*Fnom/zbase;
                        end
                    end
                    z1=(r1+1i*x1)*Pbase/Pnom*(vnomLG1/vbaseLG1)^2;
                    z2=(r2+1i*x2)*Pbase/Pnom*(vnomLG2/vbaseLG2)^2;
                    if Nwinding==3
                        z3=(r3+1i*x3)*Pbase/Pnom*(vnomLG3/vbaseLG3)^2;
                    else
                        z3=0;
                    end
                    zm=1/(1/rm+1/(1i*xm))*Pbase/Pnom*(vnomLG1/vbaseLG1)^2;
                    z_windings=[z1,z2];
                    if Nwinding==3
                        z_windings=[z_windings,z3];%#ok
                    end
                    if Nwadd==1
                        z_windings=[z_windings,1i*x0add*Pbase/Pnom*(vnomLG1/vbaseLG1)^2];%#ok
                    end
































                    NowindingYg=[];
                    NowindingD=[];
                    phaseshift_windings=zeros(1,Nwinding+Nwadd);
                    Z1=ones(Nwinding+Nwadd,Nwinding+Nwadd)*zm;
                    Z0=zeros(Nwinding+Nwadd,Nwinding+Nwadd)*zm;
                    for i=1:length(conex_windings)
                        Z1(i,i)=zm+z_windings(i);
                        switch conex_windings{i}
                        case 'Yg'
                            NowindingYg=[NowindingYg,i];%#ok windings connected in Yg
                        case 'Delta (D1)'
                            Z0(i,i)=1e5;
                            phaseshift_windings(i)=-pi/6;
                            NowindingD=[NowindingD,i];%#ok
                        case 'Delta (D11)'
                            Z0(i,i)=1e5;
                            phaseshift_windings(i)=pi/6;
                            NowindingD=[NowindingD,i];%#ok
                        otherwise

                            BlockName=get(LF.Transfos.handle{TransfoNumber},'Name');
                            BlockName=strrep(BlockName,newline,char(32));
                            Warning=char(Warning,sprintf('-> PQ flow %s -> %s through transformer ''%s'' is not listed - Winding %d connection ''%s'' not supported in LF report',...
                            LF.bus(ib).ID(1:end-2),LF.bus(n).ID(1:end-2),BlockName,i,conex_windings{i}));
                            WarningOn=1;
                            Ss=zeros(length(BusNos),1);
                            return
                        end
                    end
                    Z2=Z1;
                    Zcorrection=1/(1/zm+sum(1./z_windings(NowindingD)));

                    Z0(NowindingYg,NowindingYg)=Zcorrection;

                    for i=NowindingYg
                        Z0(i,i)=z_windings(i)+Zcorrection;
                    end

                    a=exp(1i*2*pi/3);
                    T=1/3*[...
                    1,a,a^2
                    1,a^2,a
                    1,1,1];

                    V1_w1=[1,a,a^2]/3*Vabc_w1;
                    V1_w2=[1,a,a^2]/3*Vabc_w2;
                    V1_windings=[V1_w1;V1_w2];

                    V2_w1=[1,a^2,a]/3*Vabc_w1;
                    V2_w2=[1,a^2,a]/3*Vabc_w2;
                    V2_windings=[V2_w1;V2_w2];

                    V0_w1=[1,1,1]/3*Vabc_w1;
                    V0_w2=[1,1,1]/3*Vabc_w2;
                    V0_windings=[V0_w1;V0_w2];
                    if Nwinding==3
                        V1_w3=[1,a,a^2]/3*Vabc_w3;
                        V2_w3=[1,a^2,a]/3*Vabc_w3;
                        V0_w3=[1,1,1]/3*Vabc_w3;%#ok
                        V1_windings=[V1_windings;V1_w3];%#ok
                        V2_windings=[V2_windings;V2_w3];%#ok
                        V0_windings=[V0_windings;V0_w2];%#ok
                    end

                    NowindingD1=NowindingD(NowindingD<=Nwinding);
                    for i=NowindingD1
                        V1_windings(i)=V1_windings(i)*exp(-1i*phaseshift_windings(i));
                        V2_windings(i)=V2_windings(i)*exp(1i*phaseshift_windings(i));
                    end
















                    if strcmp(LF.Transfos.Type{TransfoNumber},'3PhaseCoreType')
                        V1_wD=Z1(Nwinding+1,1:Nwinding)*inv(Z1(1:Nwinding,1:Nwinding))*V1_windings;%#ok
                        V2_wD=Z2(Nwinding+1,1:Nwinding)*inv(Z2(1:Nwinding,1:Nwinding))*V2_windings;%#ok
                        V0_wD=Z0(Nwinding+1,1:Nwinding)*inv(Z0(1:Nwinding,1:Nwinding))*V0_windings;%#ok

                        V1_windings=[V1_windings;V1_wD];%#ok
                        V2_windings=[V2_windings;V2_wD];%#ok
                        V0_windings=[V0_windings;V0_wD];%#ok
                    end
                    I1_windings=Z1\V1_windings;
                    I2_windings=Z2\V2_windings;
                    I0_windings=Z0\V0_windings;

                    for i=NowindingD
                        I1_windings(i)=I1_windings(i)*exp(1i*phaseshift_windings(i));
                        I2_windings(i)=I2_windings(i)*exp(-1i*phaseshift_windings(i));
                    end

                    Is=inv(T)*[I1_windings(SendingWindingNumber);I2_windings(SendingWindingNumber);I0_windings(SendingWindingNumber)];%#ok


                    nph=0;
                    Scond=zeros(3,1);%#ok
                    Sphase=zeros(3,1);
                    switch SendingWindingNumber
                    case 1
                        Scond=Vabc_w1.*conj(Is)*LF.Pbase;
                        for ibus=sort(LF.Transfos.W1busNumber{TransfoNumber})
                            nph=nph+1;
                            NodeNumber=LF.bus(ibus).Busnode;

                            k=LF.Transfos.W1nodes{TransfoNumber}==NodeNumber;
                            Sphase(nph)=Scond(k);
                        end
                    case 2
                        Scond=Vabc_w2.*conj(Is)*LF.Pbase;
                        for ibus=sort(LF.Transfos.W2busNumber{TransfoNumber})
                            nph=nph+1;
                            NodeNumber=LF.bus(ibus).Busnode;

                            k=LF.Transfos.W2nodes{TransfoNumber}==NodeNumber;
                            Sphase(nph)=Scond(k);
                        end
                    case 3
                        Scond=Vabc_w3.*conj(Is)*LF.Pbase;
                        for ibus=sort(LF.Transfos.W3busNumber{TransfoNumber})
                            nph=nph+1;
                            NodeNumber=LF.bus(ibus).Busnode;

                            k=LF.Transfos.W3nodes{TransfoNumber}==NodeNumber;
                            Sphase(nph)=Scond(k);
                        end
                    end
                    Ss=[Ss;Sphase];%#ok
                case 'SinglePhase'



                    n_ground=find(LF.Transfos.W1busNumber{TransfoNumber}==0);
                    if isempty(n_ground)

                        V_w1=LF.bus(LF.Transfos.W1busNumber{TransfoNumber}(1)).Vbus-LF.bus(LF.Transfos.W1busNumber{TransfoNumber}(2)).Vbus;
                        vbaseLG1=LF.bus(LF.Transfos.W1busNumber{TransfoNumber}(1)).vbase;
                    else
                        if n_ground==1

                            V_w1=-LF.bus(LF.Transfos.W1busNumber{TransfoNumber}(2)).Vbus;
                            vbaseLG1=LF.bus(LF.Transfos.W1busNumber{TransfoNumber}(2)).vbase;
                        else

                            V_w1=LF.bus(LF.Transfos.W1busNumber{TransfoNumber}(1)).Vbus;
                            vbaseLG1=LF.bus(LF.Transfos.W1busNumber{TransfoNumber}(1)).vbase;
                        end
                    end

                    n_ground=find(LF.Transfos.W2busNumber{TransfoNumber}==0);
                    if isempty(n_ground)

                        V_w2=LF.bus(LF.Transfos.W2busNumber{TransfoNumber}(1)).Vbus-LF.bus(LF.Transfos.W2busNumber{TransfoNumber}(2)).Vbus;
                        vbaseLG2=LF.bus(LF.Transfos.W2busNumber{TransfoNumber}(1)).vbase;
                    else
                        if n_ground==1

                            V_w2=-LF.bus(LF.Transfos.W2busNumber{TransfoNumber}(2)).Vbus;
                            vbaseLG2=LF.bus(LF.Transfos.W2busNumber{TransfoNumber}(2)).vbase;
                        else

                            V_w2=LF.bus(LF.Transfos.W2busNumber{TransfoNumber}(1)).Vbus;
                            vbaseLG2=LF.bus(LF.Transfos.W2busNumber{TransfoNumber}(1)).vbase;
                        end
                    end

                    if isempty(LF.Transfos.W3busNumber{TransfoNumber})
                        Nwinding=2;
                    else
                        Nwinding=3;
                        n_ground=find(LF.Transfos.W3busNumber{TransfoNumber}==0);
                        if isempty(n_ground)

                            V_w3=LF.bus(LF.Transfos.W3busNumber{TransfoNumber}(1)).Vbus-LF.bus(LF.Transfos.W3busNumber{TransfoNumber}(2)).Vbus;
                            vbaseLG3=LF.bus(LF.Transfos.W3busNumber{TransfoNumber}(1)).vbase;
                        else
                            if n_ground==1

                                V_w3=-LF.bus(LF.Transfos.W3busNumber{TransfoNumber}(2)).Vbus;
                                vbaseLG3=LF.bus(LF.Transfos.W3busNumber{TransfoNumber}(2)).vbase;
                            else

                                V_w3=LF.bus(LF.Transfos.W3busNumber{TransfoNumber}(1)).Vbus;
                                vbaseLG3=LF.bus(LF.Transfos.W3busNumber{TransfoNumber}(1)).vbase;
                            end
                        end
                    end
                    Pbase=LF.Pbase;
                    vnom1=LF.Transfos.W1{TransfoNumber}(1);
                    r1=LF.Transfos.W1{TransfoNumber}(2);
                    x1=LF.Transfos.W1{TransfoNumber}(3);
                    vnom2=LF.Transfos.W2{TransfoNumber}(1);
                    r2=LF.Transfos.W2{TransfoNumber}(2);
                    x2=LF.Transfos.W2{TransfoNumber}(3);
                    rm=LF.Transfos.RmLm{TransfoNumber}(1);
                    xm=LF.Transfos.RmLm{TransfoNumber}(2);
                    if Nwinding==3
                        vnom3=LF.Transfos.W3{TransfoNumber}(1);
                        r3=LF.Transfos.W3{TransfoNumber}(2);
                        x3=LF.Transfos.W3{TransfoNumber}(3);
                    end

                    if strcmp(LF.Transfos.Units{TransfoNumber},'SI')
                        Fnom=LF.Transfos.Fnom{TransfoNumber};

                        zbase=vnom1^2/Pnom;
                        r1=r1/zbase;
                        x1=x1*2*pi*Fnom/zbase;
                        rm=rm/zbase;
                        xm=xm*2*pi*Fnom/zbase;

                        zbase=vnom2^2/Pnom;
                        r2=r2/zbase;
                        x2=x2*2*pi*Fnom/zbase;
                        if Nwinding==3

                            zbase=vnom3^2/Pnom;
                            r3=r3/zbase;
                            x3=x3*2*pi*Fnom/zbase;
                        end
                    end

                    z1=(r1+1i*x1);
                    z2=(r2+1i*x2);
                    zm=1/(1/rm+1/(1i*xm));

                    zs1=(z1+zm)*Pbase/Pnom*(vnom1/vbaseLG1)^2;
                    zs2=(z2+zm)*Pbase/Pnom*(vnom2/vbaseLG2)^2;
                    zm12=zm*Pbase/Pnom*vnom1*vnom2/(vbaseLG1*vbaseLG2);
                    Z=[zs1,zm12
                    zm12,zs2];
                    Vw=[V_w1;V_w2];
                    if Nwinding==3
                        z3=(r3+1i*x3);
                        zs3=(z3+zm)*Pbase/Pnom*(vnom3/vbaseLG3)^2;
                        zm13=zm*Pbase/Pnom*vnom1*vnom3/(vbaseLG1*vbaseLG3);
                        zm23=zm*Pbase/Pnom*vnom2*vnom3/(vbaseLG2*vbaseLG3);
                        Z(3,3)=zs3;
                        Z(1,3)=zm13;Z(3,1)=zm13;
                        Z(2,3)=zm23;Z(3,2)=zm23;
                        Vw=[Vw;V_w3];%#ok
                    end
                    Iw=Z\Vw;
                    Sw=Vw.*conj(Iw);

                    BlockName=get(LF.Transfos.handle{TransfoNumber},'Name');
                    BlockName=strrep(BlockName,newline,char(32));
                    Warning=char(Warning,sprintf('PQ flow into windings of single-phase transformer ''%s'':',BlockName));
                    for i=1:length(Sw)
                        Warning=char(Warning,sprintf('-> w%d (%s %s)   %9.2f %9.2f ',...
                        i,WATTS,VARS,real(Sw(i))*LF.Pbase/Px,imag(Sw(i))*LF.Pbase/Px));
                    end
                    WarningOn=1;
                    LF.Transfos.FlowDisplayed{TransfoNumber}=1;
                    Ss=zeros(length(BusNos),1);
                otherwise

                    BlockName=get(LF.Transfos.handle{TransfoNumber},'Name');
                    BlockName=strrep(BlockName,newline,char(32));
                    Warning=char(Warning,sprintf('-> PQ flow %s -> %s through transformer ''%s'' is not listed - Tranformer type ''%s'' not supported in LF report',...
                    LF.bus(ib).ID(1:end-2),LF.bus(n).ID(1:end-2),BlockName,LF.Transfos.Type{TransfoNumber}));
                    WarningOn=1;
                    Ss=zeros(length(BusNos),1);
                end
            end
            TransfoNumber=TransfoNumber_vec;
            function[Hline]=DistributedParameterLine_H(Zmode,Rmode,Smode,Ti,long,freq)



















                w=2*pi*freq;
                nphase=length(Zmode);

                n1=nphase+1;n2=2*nphase;
                DD=zeros(n2,n2);
                DD(1:nphase,1:nphase)=-eye(nphase,nphase);
                DD(n1:n2,n1:n2)=eye(nphase,nphase);
                TTi=zeros(n2,n2);
                TTi(1:nphase,1:nphase)=Ti;TTi(n1:n2,n1:n2)=Ti;
                Ym=zeros(1,n2);
                for imode=1:nphase
                    gamal=1i*w/Smode(imode)*long/2;
                    A1=cosh(gamal);B1=Zmode(imode)*sinh(gamal);
                    C1=1/Zmode(imode)*sinh(gamal);D1=A1;
                    ML=[A1,B1;C1,D1];
                    MR1=[1,Rmode(imode)*long/4;0,1];
                    MR2=[1,Rmode(imode)*long/2;0,1];
                    M=MR1*ML*MR2*ML*MR1;
                    Ym(imode,imode)=M(1,1)/M(1,2);
                    Ym(imode+nphase,imode+nphase)=-M(1,1)/M(1,2);
                    Ym(imode,imode+nphase)=-1/M(1,2);
                    Ym(imode+nphase,imode)=+1/M(1,2);
                end


                Hline=-DD*TTi*Ym*TTi';
                function[P,Q]=CorrectionsPowerLines(LF,ib,n)
                    P=0;
                    Q=0;

                    Lh=LF.bus(ib).Lines;

                    Ld=LF.bus(n).Lines;
                    if isempty(Lh)

                        return
                    end
                    if isempty(Ld)

                        return
                    end
                    for i=1:length(Lh)
                        if find(Ld==Lh(i))


                            r=LF.Lines.r{Lh(i)};
                            l=LF.Lines.l{Lh(i)};
                            c=LF.Lines.c{Lh(i)};
                            long=LF.Lines.long{Lh(i)};
                            freq=LF.Lines.freq{Lh(i)};
                            Vbase=LF.bus(ib).vbase;
                            Vbus=abs(LF.bus(ib).Vbus);
                            Px=LF.Px;

                            if size(r,1)==3&&size(r,2)==3
                                a=exp(1i*2*pi/3);T=1/3*[1,1,1;1,a,a^2;1,a^2,a];
                                w=2*pi*freq;
                                zser=r+1i*l*w;
                                Zseq=(T*zser)/(T);
                                Cseq=(T*c)/(T);
                                r=real(Zseq(2,2));
                                l=imag(Zseq(2,2))/w;
                                c=Cseq(2,2);
                            end


                            w=2*pi*freq;
                            z=r+1i*w*l;
                            y=1i*w*c;
                            Zc=sqrt(z/y);
                            gammal=sqrt(z*y)*long;
                            Y_2=1/Zc*tanh(gammal/2);

                            if LF.Lines.isPI{Lh(i)}
                                Y_2=1i*imag(Y_2);
                            end
                            PQ_Y_2=(Vbase*Vbus)^2*conj(Y_2)/Px;
                            Pi=real(PQ_Y_2);
                            Qi=imag(PQ_Y_2);


                            P=P+Pi;
                            Q=Q+Qi;
                        end
                    end