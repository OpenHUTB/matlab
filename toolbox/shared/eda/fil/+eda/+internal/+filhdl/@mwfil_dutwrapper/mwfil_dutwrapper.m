classdef mwfil_dutwrapper<eda.internal.component.WhiteBox
    properties
clk
enb
reset
din
dout
buildInfo
enableCodeGen
outPutDataWidth
    end
    methods
        function this=mwfil_dutwrapper(buildInfo,inPutDataWidth,outPutDataWidth)
            this.buildInfo=buildInfo;
            this.outPutDataWidth=outPutDataWidth;
            this.clk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;
            this.enb=eda.internal.component.ClockEnablePort;


            if inPutDataWidth>0
                this.din=eda.internal.component.Inport('FiType',['std',num2str(inPutDataWidth)]);
            end

            this.dout=eda.internal.component.Outport('FiType',['std',num2str(outPutDataWidth)]);

            this.flatten=false;
            topLeveFileIdx=this.buildInfo.TopLevelIndex;
            this.Partition.Lang=cell2mat(this.buildInfo.SourceFiles.FileType(topLeveFileIdx));
        end

        function implement(this)
            [~,directory]=this.getHDLFiles(this.buildInfo);
            [portInfo,portConn]=this.getPortInfo(this.buildInfo,this.outPutDataWidth);

            h=this.component(...
            'UniqueName',this.buildInfo.DUTName,...
            'InstName',this.buildInfo.DUTName,...
            'Component',eda.internal.component.BlackBox(portInfo),...
            'HDLFiles',{},...
            'HDLFileDir',directory,...
            portConn{:});
            h.addprop('NoHDLFiles');
        end




        function[files,directory]=getHDLFiles(this,buildInfo)%#ok<INUSL>
            files={};
            FilePath=buildInfo.SourceFiles.FilePath;
            [directory,filename,extension]=cellfun(@(x)fileparts(x),FilePath,'uniformOutput',false);

            for i=1:length(FilePath)
                files{end+1}=[filename{i},extension{i}];%#ok<AGROW>
            end
        end

        function[portInfo,portConn]=getPortInfo(this,buildInfo,outPutDataWidth)
            portConn={};
            portInfo={};

            if~isempty(buildInfo.getClockPortName)
                portInfo={...
                buildInfo.getClockPortName,'INPUT','ClockPort',...
                buildInfo.getResetPortName,'INPUT','ResetPort'};

                portConn{end+1}=buildInfo.getClockPortName;
                portConn{end+1}=this.clk;
                portConn{end+1}=buildInfo.getResetPortName;
                portConn{end+1}=this.reset;
                dutReset=this.signal('Name','dut_reset','FiType','boolean');
                if strcmpi(buildInfo.ResetAssertedLevel,'Active-high')
                    this.assign(this.reset,dutReset);
                else
                    this.assign('~ this.reset',dutReset);
                end

                if isempty(buildInfo.getClockEnablePortName)
                    dutclk=this.signal('Name','dutclk','FiType','boolean');
                    this.assign('~ this.enb',dutclk);

                    portConn{end+1}=buildInfo.getClockPortName;
                    portConn{end+1}=dutclk;
                    portConn{end+1}=buildInfo.getResetPortName;
                    portConn{end+1}=dutReset;
                else
                    portConn{end+1}=buildInfo.getClockPortName;
                    portConn{end+1}=this.clk;
                    portConn{end+1}=buildInfo.getResetPortName;
                    portConn{end+1}=dutReset;
                    portInfo=[portInfo,{buildInfo.getClockEnablePortName,'INPUT','ClockEnablePort'}];
                    portConn{end+1}=buildInfo.getClockEnablePortName;
                    portConn{end+1}=this.enb;
                end
            end

            dutPorts=buildInfo.DUTPorts;

            inBitCount=0;
            outBitCount=0;
            bitconcatStr='';
            zero_count=0;
            for i=1:length(dutPorts.PortName)
                dutPortName_i=hdllegalnamersvd(dutPorts.PortName{i});
                if strcmpi(dutPorts.PortType{i},'Data')
                    if dutPorts.PortWidth{i}==1
                        connType='boolean';
                        connTmpType='boolean';
                    else
                        connType=[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})];
                        connTmpType=['std',num2str(dutPorts.PortWidth{i})];
                    end
                    connSignal=this.signal('Name',dutPortName_i,'FiType',connType);
                    connSignal_tmp=this.signal('Name',[dutPortName_i,'_tmp'],'FiType',connTmpType);

                    portConn{end+1}=dutPorts.PortName{i};%#ok<AGROW>
                    portConn{end+1}=connSignal;%#ok<AGROW>

                    portInfo{end+1}=dutPorts.PortName{i};%#ok<AGROW>                  
                    if strcmpi(dutPorts.PortDirection{i},'In')
                        portInfo{end+1}='INPUT';%#ok<AGROW>

                        lowerbound=num2str(inBitCount);
                        if dutPorts.PortWidth{i}==1
                            this.assign(['bitsliceget(this.din,',lowerbound,')'],connSignal_tmp);
                        else
                            upperbound=num2str(inBitCount+dutPorts.PortWidth{i}-1);
                            this.assign(['bitsliceget(this.din,',upperbound,',',lowerbound,')'],connSignal_tmp);
                        end
                        this.assign(connSignal_tmp,connSignal);

                        inBitCount=inBitCount+ceil(dutPorts.PortWidth{i}/8)*8;
                    else
                        storageLen=ceil(dutPorts.PortWidth{i}/8)*8;
                        outBitCount=outBitCount+storageLen;
                        portInfo{end+1}='OUTPUT';%#ok<AGROW>
                        bitconcatStr=[connSignal_tmp.Name,',',bitconcatStr];%#ok<AGROW>

                        zeroLen=storageLen-dutPorts.PortWidth{i};
                        if zeroLen>0
                            tmp=this.signal('Name',['zero',num2str(zero_count)],'FiType',['std',num2str(zeroLen)]);
                            this.assign(['fi(0,0,',num2str(zeroLen),',0)'],tmp);
                            bitconcatStr=[tmp.Name,',',bitconcatStr];%#ok<AGROW>
                            zero_count=zero_count+1;
                        end
                        this.assign(connSignal,connSignal_tmp);
                    end
                    if dutPorts.PortWidth{i}==1
                        portInfo{end+1}='boolean';%#ok<AGROW>
                    else
                        portInfo{end+1}=[dutPorts.PortDataType{i},num2str(dutPorts.PortWidth{i})];%#ok<AGROW>
                    end
                end
            end
            if(bitconcatStr(end)==',')
                bitconcatStr(end)=')';
            end

            tmpconcat=this.signal('Name','tmpconcat','FiType',['std',num2str(outPutDataWidth)]);
            if(outBitCount<outPutDataWidth)
                tmpzero=this.signal('Name','tmpzeros','FiType',['std',num2str(outPutDataWidth-outBitCount)]);
                this.assign(['fi(0,0,',num2str(outPutDataWidth-outBitCount),',0)'],tmpzero);
                bitconcatStr=['bitconcat(',tmpzero.Name,',',bitconcatStr];
            else
                bitconcatStr=['bitconcat(',bitconcatStr];
            end


            this.assign(tmpconcat,this.dout);
            this.assign(bitconcatStr,tmpconcat);

        end
    end
end



