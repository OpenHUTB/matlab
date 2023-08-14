classdef(ConstructOnLoad)DUT<eda.internal.component.WhiteBox








    properties
SimulinkHandle
    end

    methods
        function this=DUT(portInfo,portConn,buildInfo)
            if nargin>0
                if~isempty(portInfo)
                    for i=1:3:length(portInfo)
                        this.addprop(portInfo{i});
                        if strcmpi(portInfo{i+2},'ClockPort')
                            this.(portInfo{i})=eda.internal.component.ClockPort;
                        elseif strcmpi(portInfo{i+2},'ResetPort')
                            this.(portInfo{i})=eda.internal.component.ResetPort;
                        elseif strcmpi(portInfo{i+2},'ClockEnablePort')
                            this.(portInfo{i})=eda.internal.component.ResetPort;
                        elseif strcmpi(portInfo{i+1},'INPUT')
                            this.(portInfo{i})=eda.internal.component.Inport('FiType',portInfo{i+2});
                        elseif strcmpi(portInfo{i+1},'OUTPUT')
                            this.(portInfo{i})=eda.internal.component.Outport('FiType',portInfo{i+2});
                        elseif strcmpi(portInfo{i+1},'INOUT')
                            this.(portInfo{i})=eda.internal.component.InOutport('FiType',portInfo{i+2});
                        else
                            error(message('EDALink:DUT:DUT:InvalidPort'))
                        end
                    end

                end
                this.addprop('portInfo');
                this.portInfo=portInfo;
                this.addprop('portConn');
                this.portConn=portConn;
                this.addprop('buildInfo');
                this.buildInfo=buildInfo;
                this.addprop('enableCodeGen');
                this.flatten=false;
                topLeveFileIdx=this.buildInfo.TopLevelIndex;
                this.Partition.Lang=cell2mat(this.buildInfo.SourceFiles.FileType(topLeveFileIdx));
            end
        end

        function implement(this)
            [files,directory]=this.getHDLFiles(this.buildInfo);
            portInfo=this.getPortInfo(this.buildInfo,true);
            if~isempty(this.buildInfo.getClockPortName)
                if isempty(this.buildInfo.getClockEnablePortName)
                    dutEnb=this.signal('Name','dutEnb','FiType','boolean');
                    this.assign('~ this.clock_enb',dutEnb);
                else
                    dutEnb=this.(this.buildInfo.getClockEnablePortName);
                end
                dutClk=this.(this.buildInfo.getClockPortName);
                dutReset=this.(this.buildInfo.getResetPortName);
            else
                dutEnb='';
                dutClk='';
                dutReset='';
            end
            [portConn,~,~,~,~,~]=this.getPortConn(this,dutEnb,dutClk,dutReset,'','','','',true);

            UserDUT=this.component(...
            'UniqueName',this.buildInfo.DUTName,...
            'InstName',this.buildInfo.DUTName,...
            'Component',eda.internal.component.BlackBox(portInfo),...
            'HDLFiles',files,...
            'HDLFileDir',directory,...
            portConn{:});

            UserDUT.addprop('NoHDLFiles');
        end




        function portInfo=getPortInfo(this,buildInfo,internal)%#ok<INUSL>
            oldPropSet=PersistentHDLPropSet;
            oldCodeGen=hdlcodegenmode;
            hdlcodegenmode('filtercoder');
            hprop=hdlcoderprops.HDLProps;
            PersistentHDLPropSet(hprop);
            hdlsetparameter('target_language','vhdl');
            if nargin<3
                internal=false;
            end
            bInfo=buildInfo;
            if~isempty(bInfo.getClockPortName)
                if~isempty(bInfo.getClockEnablePortName)
                    portInfo={...
                    bInfo.getClockPortName,'INPUT','ClockPort',...
                    bInfo.getResetPortName,'INPUT','ResetPort',...
                    bInfo.getClockEnablePortName,'INPUT','ClockEnablePort'};
                elseif internal
                    portInfo={...
                    bInfo.getClockPortName,'INPUT','ClockPort',...
                    bInfo.getResetPortName,'INPUT','ResetPort'};
                else
                    portInfo={...
                    hdllegalnamersvd(bInfo.getClockPortName),'INPUT','ClockPort',...
                    hdllegalnamersvd(bInfo.getResetPortName),'INPUT','ResetPort',...
                    'clock_enb','INPUT','ClockEnablePort'};
                end
            else
                portInfo={};
            end
            dutPorts=bInfo.DUTPorts;
            for i=1:length(dutPorts.PortName)
                dutPortName_i=hdllegalnamersvd(dutPorts.PortName{i});
                if~strcmpi(dutPorts.PortType{i},'Clock')&&~strcmpi(dutPorts.PortType{i},'Reset')&&~strcmpi(dutPorts.PortType{i},'Clock enable')
                    if strcmpi(dutPorts.PortDirection{i},'In')
                        if dutPorts.PortWidth{i}==1
                            if internal
                                portInfo{end+1}=dutPorts.PortName{i};%#ok<*AGROW>
                            else
                                portInfo{end+1}=dutPortName_i;
                            end
                            portInfo{end+1}='INPUT';
                            portInfo{end+1}='boolean';
                        else
                            if internal
                                portInfo{end+1}=dutPorts.PortName{i};
                            else
                                portInfo{end+1}=dutPortName_i;
                            end
                            portInfo{end+1}='INPUT';
                            if internal
                                portInfo{end+1}=[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})];
                            else
                                portInfo{end+1}=['std',num2str(dutPorts.PortWidth{i})];
                            end
                        end
                    elseif strcmpi(dutPorts.PortDirection{i},'Out')
                        if dutPorts.PortWidth{i}==1
                            if internal
                                portInfo{end+1}=dutPorts.PortName{i};
                            else
                                portInfo{end+1}=dutPortName_i;
                            end
                            portInfo{end+1}='OUTPUT';
                            portInfo{end+1}='boolean';
                        else
                            if internal
                                portInfo{end+1}=dutPorts.PortName{i};
                            else
                                portInfo{end+1}=dutPortName_i;
                            end
                            portInfo{end+1}='OUTPUT';
                            if internal
                                portInfo{end+1}=[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})];
                            else
                                portInfo{end+1}=['std',num2str(dutPorts.PortWidth{i})];
                            end
                        end
                    end
                elseif strcmpi(dutPorts.PortConnectivity{i},'APB_CLOCK')
                    if internal
                        portInfo{end+1}=dutPorts.PortName{i};
                    else
                        portInfo{end+1}=dutPortName_i;
                    end

                    portInfo{end+1}='INPUT';
                    portInfo{end+1}='ClockPort';
                elseif strcmpi(dutPorts.PortConnectivity{i},'APB_RESET')
                    if internal
                        portInfo{end+1}=dutPorts.PortName{i};
                    else
                        portInfo{end+1}=dutPortName_i;
                    end

                    portInfo{end+1}='INPUT';
                    portInfo{end+1}='ResetPort';
                else

                end
            end
            PersistentHDLPropSet(oldPropSet);
            hdlcodegenmode(oldCodeGen);
        end


        function[portConn,inputSignal,outputSignal,outStrobe,externalIOSignal,APBSignal]=getPortConn(this,comp,dutEnb,dutClk,dutReset,doutvld,apb_ready,apb_rdata,dut_sel,varargin)
            oldPropSet=PersistentHDLPropSet;
            oldCodeGen=hdlcodegenmode;
            hdlcodegenmode('filtercoder');
            hprop=hdlcoderprops.HDLProps;
            PersistentHDLPropSet(hprop);
            hdlsetparameter('target_language','vhdl');

            inputSignal={};
            outputSignal={};
            externalIOSignal={};
            APBSignal={};
            outStrobe={};

            switch(length(varargin))
            case 0
                internal=false;
                bInfo=comp.buildInfo;
            case 1
                internal=varargin{1};
                bInfo=comp.buildInfo;
            case 2
                internal=varargin{1};
                bInfo=varargin{2};
            end


            if~isempty(bInfo.getClockPortName)
                if internal
                    dutClk=comp.(bInfo.getClockPortName);
                end
                if~isempty(bInfo.getClockEnablePortName)
                    portConn={...
                    bInfo.getClockPortName,dutClk,...
                    bInfo.getResetPortName,dutReset,...
                    bInfo.getClockEnablePortName,dutEnb};
                elseif internal
                    portConn={...
                    bInfo.getClockPortName,dutEnb,...
                    bInfo.getResetPortName,dutReset};
                else
                    portConn={...
                    hdllegalnamersvd(bInfo.getClockPortName),dutClk,...
                    hdllegalnamersvd(bInfo.getResetPortName),dutReset,...
                    'clock_enb',dutEnb};
                end
            else
                portConn={};
            end
            dutPorts=bInfo.DUTPorts;
            for i=1:length(dutPorts.PortName)
                dutPortName_i=hdllegalnamersvd(dutPorts.PortName{i});
                if~strcmpi(dutPorts.PortType{i},'Clock')&&~strcmpi(dutPorts.PortType{i},'Reset')&&~strcmpi(dutPorts.PortType{i},'Clock enable')
                    if strcmpi(dutPorts.PortDirection{i},'In')
                        if~isfield(dutPorts,'PortConnectivity')||(isempty(dutPorts.PortConnectivity{i})||strcmpi(dutPorts.PortConnectivity{i},'Drive'))
                            if dutPorts.PortWidth{i}==1
                                inputSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType','boolean');
                            elseif internal
                                inputSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType',[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})]);
                            else
                                inputSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType',['std',num2str(dutPorts.PortWidth{i})]);
                            end
                            inputSignal{end}.width=dutPorts.PortWidth{i};
                            signal2Add=inputSignal{end}.handle;
                        elseif strcmpi(dutPorts.PortConnectivity{i},'ExternalIO')
                            if internal
                                if dutPorts.PortWidth{i}==1
                                    externalIOSignal{end+1}.handle=comp.signal('Name',dutPortName_i,'FiType','boolean');%#ok<*AGROW,*AGROW>
                                elseif internal
                                    externalIOSignal{end+1}.handle=comp.signal('Name',dutPortName_i,'FiType',[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})]);
                                else
                                    externalIOSignal{end+1}.handle=comp.signal('Name',dutPortName_i,'FiType',['std',num2str(dutPorts.PortWidth{i})]);
                                end
                            else
                                addprop(comp,dutPortName_i);
                                comp.(dutPortName_i)=eda.internal.component.Inport('FiType',['std',num2str(dutPorts.PortWidth{i})]);
                                externalIOSignal{end+1}.handle=comp.(dutPortName_i);
                            end
                            externalIOSignal{end}.Name=dutPortName_i;
                            externalIOSignal{end}.Type='ADC';
                            externalIOSignal{end}.width=dutPorts.PortWidth{i};
                            signal2Add=externalIOSignal{end}.handle;
                        elseif strfind(dutPorts.PortConnectivity{i},'APB')
                            if internal
                                if dutPorts.PortWidth{i}==1
                                    APBSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType','boolean');%#ok<*AGROW,*AGROW>
                                elseif internal
                                    APBSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType',[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})]);
                                else
                                    APBSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType',['std',num2str(dutPorts.PortWidth{i})]);
                                end
                            elseif strcmpi(dutPorts.PortConnectivity{i},'APB_SEL')
                                APBSignal{end+1}.handle=dut_sel;
                            else
                                APBSignal{end+1}.handle=this.findAPBSignal(comp.ChildEdge,dutPorts.PortConnectivity{i});
                            end
                            APBSignal{end}.width=dutPorts.PortWidth{i};
                            APBSignal{end}.BUS=dutPorts.PortConnectivity{i};
                            signal2Add=APBSignal{end}.handle;
                        end


                        if internal
                            portConn{end+1}=dutPorts.PortName{i};
                            comp.assign(comp.(dutPortName_i),signal2Add);
                        else
                            portConn{end+1}=dutPortName_i;
                        end
                        portConn{end+1}=signal2Add;%#ok<*AGROW>

                    elseif strcmpi(dutPorts.PortDirection{i},'Out')
                        if~isfield(dutPorts,'PortConnectivity')||(isempty(dutPorts.PortConnectivity{i})||strcmpi(dutPorts.PortConnectivity{i},'Capture'))
                            if dutPorts.PortWidth{i}==1
                                outputSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType','boolean');
                            elseif internal
                                outputSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType',[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})]);
                            else
                                outputSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType',['std',num2str(dutPorts.PortWidth{i})]);
                            end
                            outputSignal{end}.width=dutPorts.PortWidth{i};
                            signal2Add=outputSignal{end}.handle;
                        elseif strcmpi(dutPorts.PortConnectivity{i},'Strobe')
                            if internal
                                outStrobe=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType','boolean');
                            else
                                outStrobe=doutvld;
                            end
                            signal2Add=outStrobe;
                        elseif strcmpi(dutPorts.PortConnectivity{i},'ExternalIO')
                            if internal
                                if dutPorts.PortWidth{i}==1
                                    externalIOSignal{end+1}.handle=comp.signal('Name',dutPortName_i,'FiType','boolean');
                                elseif internal
                                    externalIOSignal{end+1}.handle=comp.signal('Name',dutPortName_i,'FiType',[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})]);
                                else
                                    externalIOSignal{end+1}.handle=comp.signal('Name',dutPortName_i,'FiType',['std',num2str(dutPorts.PortWidth{i})]);
                                end
                            else
                                addprop(comp,dutPortName_i);
                                comp.(dutPortName_i)=eda.internal.component.Outport('FiType',['std',num2str(dutPorts.PortWidth{i})]);
                                externalIOSignal{end+1}.handle=comp.(dutPortName_i);
                            end
                            externalIOSignal{end}.Name=dutPortName_i;
                            externalIOSignal{end}.Type='ADC';
                            externalIOSignal{end}.width=dutPorts.PortWidth{i};
                            signal2Add=externalIOSignal{end}.handle;
                        elseif strfind(dutPorts.PortConnectivity{i},'APB')
                            if internal
                                if dutPorts.PortWidth{i}==1
                                    APBSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType','boolean');%#ok<*AGROW,*AGROW>
                                elseif internal
                                    APBSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType',[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})]);
                                else
                                    APBSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType',['std',num2str(dutPorts.PortWidth{i})]);
                                end
                            elseif strcmpi(dutPorts.PortConnectivity{i},'APB_READY')
                                APBSignal{end+1}.handle=apb_ready;
                            elseif strcmpi(dutPorts.PortConnectivity{i},'APB_RDATA')
                                APBSignal{end+1}.handle=apb_rdata;
                            elseif dutPorts.PortWidth{i}==1
                                APBSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType','boolean');%#ok<*AGROW,*AGROW>
                            elseif internal
                                APBSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType',[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})]);
                            else
                                APBSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType',['std',num2str(dutPorts.PortWidth{i})]);
                            end
                            APBSignal{end}.width=dutPorts.PortWidth{i};
                            APBSignal{end}.BUS=dutPorts.PortConnectivity{i};
                            signal2Add=APBSignal{end}.handle;
                        end

                        if internal
                            portConn{end+1}=dutPorts.PortName{i};
                            comp.assign(signal2Add,comp.(dutPortName_i));
                        else
                            portConn{end+1}=dutPortName_i;
                        end
                        portConn{end+1}=signal2Add;
                    end
                elseif strcmpi(dutPorts.PortConnectivity{i},'APB_CLOCK')||strcmpi(dutPorts.PortConnectivity{i},'APB_RESET')
                    if internal
                        APBSignal{end+1}.handle=comp.signal('Name',[dutPortName_i,'_tmp'],'FiType','boolean');%#ok<*AGROW,*AGROW>
                    else
                        APBSignal{end+1}.handle=this.findAPBSignal(comp.ChildEdge,dutPorts.PortConnectivity{i});
                    end
                    APBSignal{end}.width=dutPorts.PortWidth{i};
                    APBSignal{end}.BUS=dutPorts.PortConnectivity{i};
                    signal2Add=APBSignal{end}.handle;

                    if internal
                        portConn{end+1}=dutPorts.PortName{i};
                        comp.assign(comp.(dutPortName_i),signal2Add);
                    else
                        portConn{end+1}=dutPortName_i;
                    end
                    portConn{end+1}=signal2Add;%#ok<*AGROW>
                end
            end
            hdlcodegenmode(oldCodeGen);
            PersistentHDLPropSet(oldPropSet);
        end

        function[files,directory]=getHDLFiles(this,buildInfo)%#ok<INUSL>
            files={};
            FilePath=buildInfo.SourceFiles.FilePath;
            [directory,filename,extension]=cellfun(@(x)fileparts(x),FilePath,'uniformOutput',false);

            for i=1:length(FilePath)
                files{end+1}=[filename{i},extension{i}];
            end
        end


        function handle=findAPBSignal(this,Signal,Name)%#ok<INUSL>
            handle='';
            for i=1:length(Signal)
                if strcmpi(Signal{i}.Name,Name)
                    handle=Signal{i};
                    break;
                end
            end
        end
    end
end


