


classdef(ConstructOnLoad)MWMAC<eda.internal.component.WhiteBox








    properties
rxclk
rxclk_en
txclk
txclk_en

gmii_rxd
gmii_rx_dv
gmii_rx_er

gmii_txd
gmii_tx_en
gmii_tx_er
gmii_col
gmii_crs

RxData
RxDataValid
RxEOP
RxCRCOK
RxCRCBad
RxDstPort
RxReset

TxData
TxDataValid
TxReady
TxEOP
TxDataLength
TxSrcPort
TxReset

        generic=generics('MWMACADDR1','integer','0',...
        'MWMACADDR2','integer','10',...
        'MWMACADDR3','integer','53',...
        'MWMACADDR4','integer','2',...
        'MWMACADDR5','integer','33',...
        'MWMACADDR6','integer','138',...
        'MWIPADDR1','integer','192',...
        'MWIPADDR2','integer','168',...
        'MWIPADDR3','integer','0',...
        'MWIPADDR4','integer','2',...
        'ONEUDP','integer','1',...
        'BUFFERADDRWIDTH','integer','12');

    end

    methods
        function this=MWMAC(varargin)

            this.setGenerics(varargin);

            this.rxclk=eda.internal.component.ClockPort;
            this.rxclk_en=eda.internal.component.Inport('FiType','boolean');
            this.RxReset=eda.internal.component.Inport('FiType','boolean');
            this.txclk=eda.internal.component.ClockPort;
            this.txclk_en=eda.internal.component.Inport('FiType','boolean');
            this.TxReset=eda.internal.component.Inport('FiType','boolean');

            this.gmii_rxd=eda.internal.component.Inport('FiType','std8');
            this.gmii_rx_dv=eda.internal.component.Inport('FiType','boolean');
            this.gmii_rx_er=eda.internal.component.Inport('FiType','boolean');

            this.gmii_txd=eda.internal.component.Outport('FiType','std8');
            this.gmii_tx_en=eda.internal.component.Outport('FiType','boolean');
            this.gmii_tx_er=eda.internal.component.Outport('FiType','boolean');
            this.gmii_col=eda.internal.component.Inport('FiType','boolean');
            this.gmii_crs=eda.internal.component.Inport('FiType','boolean');

            this.RxData=eda.internal.component.Outport('FiType','uint8');
            this.RxDataValid=eda.internal.component.Outport('FiType','boolean');
            this.RxEOP=eda.internal.component.Outport('FiType','boolean');
            this.RxCRCOK=eda.internal.component.Outport('FiType','boolean');
            this.RxCRCBad=eda.internal.component.Outport('FiType','boolean');
            this.RxDstPort=eda.internal.component.Outport('FiType','std2');
            this.TxData=eda.internal.component.Inport('FiType','uint8');
            this.TxDataValid=eda.internal.component.Inport('FiType','boolean');
            this.TxEOP=eda.internal.component.Inport('FiType','boolean');
            this.TxReady=eda.internal.component.Outport('FiType','boolean');
            this.TxDataLength=eda.internal.component.Inport('FiType','std13');
            this.TxSrcPort=eda.internal.component.Inport('FiType','std2');

            this.flatten=false;
        end

        function implement(this)

            hostmacaddr1=this.signal('Name','hostmacaddr1','FiType','std8');
            hostmacaddr2=this.signal('Name','hostmacaddr2','FiType','std8');
            hostmacaddr3=this.signal('Name','hostmacaddr3','FiType','std8');
            hostmacaddr4=this.signal('Name','hostmacaddr4','FiType','std8');
            hostmacaddr5=this.signal('Name','hostmacaddr5','FiType','std8');
            hostmacaddr6=this.signal('Name','hostmacaddr6','FiType','std8');

            hostipaddr1=this.signal('Name','hostipaddr1','FiType','std8');
            hostipaddr2=this.signal('Name','hostipaddr2','FiType','std8');
            hostipaddr3=this.signal('Name','hostipaddr3','FiType','std8');
            hostipaddr4=this.signal('Name','hostipaddr4','FiType','std8');

            udpsrcport0_1=this.signal('Name','udpsrcport0_1','FiType','std8');
            udpsrcport0_2=this.signal('Name','udpsrcport0_2','FiType','std8');
            udpdstport0_1=this.signal('Name','udpdstport0_1','FiType','std8');
            udpdstport0_2=this.signal('Name','udpdstport0_2','FiType','std8');

            udpsrcport1_1=this.signal('Name','udpsrcport1_1','FiType','std8');
            udpsrcport1_2=this.signal('Name','udpsrcport1_2','FiType','std8');
            udpdstport1_1=this.signal('Name','udpdstport1_1','FiType','std8');
            udpdstport1_2=this.signal('Name','udpdstport1_2','FiType','std8');

            udpsrcport2_1=this.signal('Name','udpsrcport2_1','FiType','std8');
            udpsrcport2_2=this.signal('Name','udpsrcport2_2','FiType','std8');
            udpdstport2_1=this.signal('Name','udpdstport2_1','FiType','std8');
            udpdstport2_2=this.signal('Name','udpdstport2_2','FiType','std8');

            udpsrcport3_1=this.signal('Name','udpsrcport3_1','FiType','std8');
            udpsrcport3_2=this.signal('Name','udpsrcport3_2','FiType','std8');
            udpdstport3_1=this.signal('Name','udpdstport3_1','FiType','std8');
            udpdstport3_2=this.signal('Name','udpdstport3_2','FiType','std8');

            rxaddrvalid=this.signal('Name','rxaddrvalid','FiType','boolean');
            replyping=this.signal('Name','replyping','FiType','boolean');
            replyarp=this.signal('Name','replyarp','FiType','boolean');

            pingrdaddr=this.signal('Name','pingrdaddr','FiType','std9');
            pingrddata=this.signal('Name','pingrddata','FiType','std8');

            pingwraddr=this.signal('Name','pingwraddr','FiType','std9');
            pingwrdata=this.signal('Name','pingwrdata','FiType','std8');
            pingwren=this.signal('Name','pingwren','FiType','boolean');



            h=this.component(...
            'UniqueName','mwrxmac',...
            'InstName','mwrxmac',...
            'HDLFileDir',{fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWMAC')},...
            'HDLFiles',{'mwrxmac.vhd'},...
            'Component',eda.internal.component.BlackBox(...
            {'rxclk','INPUT','boolean',...
            'rxclk_en','INPUT','boolean',...
            'rxreset','INPUT','boolean',...
            'rxdata','OUTPUT','std8',...
            'rxdatavalid','OUTPUT','boolean',...
            'rxeop','OUTPUT','boolean',...
            'rxcrcok','OUTPUT','boolean',...
            'rxcrcbad','OUTPUT','boolean',...
            'rxdstport','OUTPUT','std2',...
            'hostmacaddr1','OUTPUT','std8',...
            'hostmacaddr2','OUTPUT','std8',...
            'hostmacaddr3','OUTPUT','std8',...
            'hostmacaddr4','OUTPUT','std8',...
            'hostmacaddr5','OUTPUT','std8',...
            'hostmacaddr6','OUTPUT','std8',...
            'hostipaddr1','OUTPUT','std8',...
            'hostipaddr2','OUTPUT','std8',...
            'hostipaddr3','OUTPUT','std8',...
            'hostipaddr4','OUTPUT','std8',...
            'udpsrcport0_1','OUTPUT','std8',...
            'udpsrcport0_2','OUTPUT','std8',...
            'udpdstport0_1','OUTPUT','std8',...
            'udpdstport0_2','OUTPUT','std8',...
            'udpsrcport1_1','OUTPUT','std8',...
            'udpsrcport1_2','OUTPUT','std8',...
            'udpdstport1_1','OUTPUT','std8',...
            'udpdstport1_2','OUTPUT','std8',...
            'udpsrcport2_1','OUTPUT','std8',...
            'udpsrcport2_2','OUTPUT','std8',...
            'udpdstport2_1','OUTPUT','std8',...
            'udpdstport2_2','OUTPUT','std8',...
            'udpsrcport3_1','OUTPUT','std8',...
            'udpsrcport3_2','OUTPUT','std8',...
            'udpdstport3_1','OUTPUT','std8',...
            'udpdstport3_2','OUTPUT','std8',...
            'pingwraddr','OUTPUT','std9',...
            'pingwrdata','OUTPUT','std8',...
            'pingwren','OUTPUT','boolean',...
            'rxaddrvalid','OUTPUT','boolean',...
            'replyping','OUTPUT','boolean',...
            'replyarp','OUTPUT','boolean',...
            'gmii_rxd','INPUT','std8',...
            'gmii_rx_dv','INPUT','boolean',...
            'gmii_rx_er','INPUT','boolean'}),...
            'rxclk',this.rxclk,...
            'rxclk_en',this.rxclk_en,...
            'rxreset',this.RxReset,...
            'rxdata',this.RxData,...
            'rxdatavalid',this.RxDataValid,...
            'rxeop',this.RxEOP,...
            'rxcrcok',this.RxCRCOK,...
            'rxcrcbad',this.RxCRCBad,...
            'rxdstport',this.RxDstPort,...
            'hostmacaddr1',hostmacaddr1,...
            'hostmacaddr2',hostmacaddr2,...
            'hostmacaddr3',hostmacaddr3,...
            'hostmacaddr4',hostmacaddr4,...
            'hostmacaddr5',hostmacaddr5,...
            'hostmacaddr6',hostmacaddr6,...
            'hostipaddr1',hostipaddr1,...
            'hostipaddr2',hostipaddr2,...
            'hostipaddr3',hostipaddr3,...
            'hostipaddr4',hostipaddr4,...
            'udpsrcport0_1',udpsrcport0_1,...
            'udpsrcport0_2',udpsrcport0_2,...
            'udpdstport0_1',udpdstport0_1,...
            'udpdstport0_2',udpdstport0_2,...
            'udpsrcport1_1',udpsrcport1_1,...
            'udpsrcport1_2',udpsrcport1_2,...
            'udpdstport1_1',udpdstport1_1,...
            'udpdstport1_2',udpdstport1_2,...
            'udpsrcport2_1',udpsrcport2_1,...
            'udpsrcport2_2',udpsrcport2_2,...
            'udpdstport2_1',udpdstport2_1,...
            'udpdstport2_2',udpdstport2_2,...
            'udpsrcport3_1',udpsrcport3_1,...
            'udpsrcport3_2',udpsrcport3_2,...
            'udpdstport3_1',udpdstport3_1,...
            'udpdstport3_2',udpdstport3_2,...
            'pingwraddr',pingwraddr,...
            'pingwrdata',pingwrdata,...
            'pingwren',pingwren,...
            'rxaddrvalid',rxaddrvalid,...
            'replyping',replyping,...
            'replyarp',replyarp,...
            'gmii_rxd',this.gmii_rxd,...
            'gmii_rx_dv',this.gmii_rx_dv,...
            'gmii_rx_er',this.gmii_rx_er);

            h.addprop('CopyHDLFiles');

            h.addprop('generic');

            h.generic=generics('MWMACADDR1','integer','0',...
            'MWMACADDR2','integer','10',...
            'MWMACADDR3','integer','53',...
            'MWMACADDR4','integer','2',...
            'MWMACADDR5','integer','33',...
            'MWMACADDR6','integer','138',...
            'MWIPADDR1','integer','192',...
            'MWIPADDR2','integer','168',...
            'MWIPADDR3','integer','0',...
            'MWIPADDR4','integer','2',...
            'ONEUDP','integer','1');

            h.setGenerics({'MWMACADDR1',this.generic.MWMACADDR1,...
            'MWMACADDR2',this.generic.MWMACADDR2,...
            'MWMACADDR3',this.generic.MWMACADDR3,...
            'MWMACADDR4',this.generic.MWMACADDR4,...
            'MWMACADDR5',this.generic.MWMACADDR5,...
            'MWMACADDR6',this.generic.MWMACADDR6,...
            'MWIPADDR1',this.generic.MWIPADDR1,...
            'MWIPADDR2',this.generic.MWIPADDR2,...
            'MWIPADDR3',this.generic.MWIPADDR3,...
            'MWIPADDR4',this.generic.MWIPADDR4,...
            'ONEUDP',this.generic.ONEUDP});

            h=this.component(...
            'UniqueName','mwtxmac',...
            'InstName','mwtxmac',...
            'HDLFileDir',{fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWMAC')},...
            'HDLFiles',{'mwtxmac.vhd'},...
            'Component',eda.internal.component.BlackBox(...
            {'txclk','INPUT','boolean',...
            'txclk_en','INPUT','boolean',...
            'txreset','INPUT','boolean',...
            'txdata','INPUT','std8',...
            'txdatavalid','INPUT','boolean',...
            'txeop','INPUT','boolean',...
            'txready','OUTPUT','boolean',...
            'txdatalength','INPUT','std13',...
            'txsrcport','INPUT','std2',...
            'hostmacaddr1','INPUT','std8',...
            'hostmacaddr2','INPUT','std8',...
            'hostmacaddr3','INPUT','std8',...
            'hostmacaddr4','INPUT','std8',...
            'hostmacaddr5','INPUT','std8',...
            'hostmacaddr6','INPUT','std8',...
            'hostipaddr1','INPUT','std8',...
            'hostipaddr2','INPUT','std8',...
            'hostipaddr3','INPUT','std8',...
            'hostipaddr4','INPUT','std8',...
            'udpsrcport0_1','INPUT','std8',...
            'udpsrcport0_2','INPUT','std8',...
            'udpdstport0_1','INPUT','std8',...
            'udpdstport0_2','INPUT','std8',...
            'udpsrcport1_1','INPUT','std8',...
            'udpsrcport1_2','INPUT','std8',...
            'udpdstport1_1','INPUT','std8',...
            'udpdstport1_2','INPUT','std8',...
            'udpsrcport2_1','INPUT','std8',...
            'udpsrcport2_2','INPUT','std8',...
            'udpdstport2_1','INPUT','std8',...
            'udpdstport2_2','INPUT','std8',...
            'udpsrcport3_1','INPUT','std8',...
            'udpsrcport3_2','INPUT','std8',...
            'udpdstport3_1','INPUT','std8',...
            'udpdstport3_2','INPUT','std8',...
            'pingrdaddr','OUTPUT','std9',...
            'pingrddata','INPUT','std8',...
            'rxaddrvalid','INPUT','boolean',...
            'replyping','INPUT','boolean',...
            'replyarp','INPUT','boolean',...
            'gmii_txd','OUTPUT','std8',...
            'gmii_tx_en','OUTPUT','boolean',...
            'gmii_tx_er','OUTPUT','boolean',...
            'gmii_col','INPUT','boolean',...
            'gmii_crs','INPUT','boolean'}),...
            'txclk',this.txclk,...
            'txclk_en',this.txclk_en,...
            'txreset',this.TxReset,...
            'txdata',this.TxData,...
            'txdatavalid',this.TxDataValid,...
            'txeop',this.TxEOP,...
            'txready',this.TxReady,...
            'txdatalength',this.TxDataLength,...
            'txsrcport',this.TxSrcPort,...
            'hostmacaddr1',hostmacaddr1,...
            'hostmacaddr2',hostmacaddr2,...
            'hostmacaddr3',hostmacaddr3,...
            'hostmacaddr4',hostmacaddr4,...
            'hostmacaddr5',hostmacaddr5,...
            'hostmacaddr6',hostmacaddr6,...
            'hostipaddr1',hostipaddr1,...
            'hostipaddr2',hostipaddr2,...
            'hostipaddr3',hostipaddr3,...
            'hostipaddr4',hostipaddr4,...
            'udpsrcport0_1',udpsrcport0_1,...
            'udpsrcport0_2',udpsrcport0_2,...
            'udpdstport0_1',udpdstport0_1,...
            'udpdstport0_2',udpdstport0_2,...
            'udpsrcport1_1',udpsrcport1_1,...
            'udpsrcport1_2',udpsrcport1_2,...
            'udpdstport1_1',udpdstport1_1,...
            'udpdstport1_2',udpdstport1_2,...
            'udpsrcport2_1',udpsrcport2_1,...
            'udpsrcport2_2',udpsrcport2_2,...
            'udpdstport2_1',udpdstport2_1,...
            'udpdstport2_2',udpdstport2_2,...
            'udpsrcport3_1',udpsrcport3_1,...
            'udpsrcport3_2',udpsrcport3_2,...
            'udpdstport3_1',udpdstport3_1,...
            'udpdstport3_2',udpdstport3_2,...
            'pingrdaddr',pingrdaddr,...
            'pingrddata',pingrddata,...
            'rxaddrvalid',rxaddrvalid,...
            'replyping',replyping,...
            'replyarp',replyarp,...
            'gmii_txd',this.gmii_txd,...
            'gmii_tx_en',this.gmii_tx_en,...
            'gmii_tx_er',this.gmii_tx_er,...
            'gmii_col',this.gmii_col,...
            'gmii_crs',this.gmii_crs);

            h.addprop('CopyHDLFiles');

            h.addprop('generic');

            h.generic=generics('MWMACADDR1','integer','0',...
            'MWMACADDR2','integer','10',...
            'MWMACADDR3','integer','53',...
            'MWMACADDR4','integer','2',...
            'MWMACADDR5','integer','33',...
            'MWMACADDR6','integer','138',...
            'MWIPADDR1','integer','192',...
            'MWIPADDR2','integer','168',...
            'MWIPADDR3','integer','0',...
            'MWIPADDR4','integer','2',...
            'ONEUDP','integer','1',...
            'BUFFERADDRWIDTH','integer','12');


            h.setGenerics({'MWMACADDR1',this.generic.MWMACADDR1,...
            'MWMACADDR2',this.generic.MWMACADDR2,...
            'MWMACADDR3',this.generic.MWMACADDR3,...
            'MWMACADDR4',this.generic.MWMACADDR4,...
            'MWMACADDR5',this.generic.MWMACADDR5,...
            'MWMACADDR6',this.generic.MWMACADDR6,...
            'MWIPADDR1',this.generic.MWIPADDR1,...
            'MWIPADDR2',this.generic.MWIPADDR2,...
            'MWIPADDR3',this.generic.MWIPADDR3,...
            'MWIPADDR4',this.generic.MWIPADDR4,...
            'ONEUDP',this.generic.ONEUDP,...
            'BUFFERADDRWIDTH',this.generic.BUFFERADDRWIDTH});

            h=this.component(...
            'UniqueName','mwpingram',...
            'InstName','mwpingram',...
            'HDLFileDir',{fullfile(matlabroot,'toolbox','shared','eda','fpgabase',...
            '+eda','+internal','+component','@MWMAC')},...
            'HDLFiles',{'mwpingram.vhd'},...
            'Component',eda.internal.component.BlackBox(...
            {'txclk','INPUT','boolean',...
            'txclk_en','INPUT','boolean',...
            'rxclk','INPUT','boolean',...
            'pingrdaddr','INPUT','std9',...
            'pingrddata','OUTPUT','std8',...
            'pingwraddr','INPUT','std9',...
            'pingwrdata','INPUT','std8',...
            'pingwren','INPUT','boolean'}),...
            'txclk',this.txclk,...
            'txclk_en',this.txclk_en,...
            'rxclk',this.rxclk,...
            'pingrdaddr',pingrdaddr,...
            'pingrddata',pingrddata,...
            'pingwraddr',pingwraddr,...
            'pingwrdata',pingwrdata,...
            'pingwren',pingwren);

            h.addprop('CopyHDLFiles');
        end
    end

end

