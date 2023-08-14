classdef TimingLogReader<handle





    properties
m_delayMap
    end

    methods
        function self=TimingLogReader()
            t=struct('ports',{},'delay',{});
            self.m_delayMap=t;
        end

        function self=reset(self)
            t=struct('ports',{},'delay',{});
            self.m_delayMap=t;
        end

        function delaySpec=parseReport(self,reportFile)

            self.reset();

            fid=fopen(reportFile);
            delaySpec=self.m_delayMap;
            if(fid<0)

                error(['file not found ',reportFile]);
            end

            rline=fgets(fid);

            while(ischar(rline))

                delayString=regexp(rline,'DelayInfo.*','match');

                if(isempty(delayString))
                    rline=fgets(fid);
                    continue;
                end
                delayString=delayString{1};

                if(~isempty(delayString))
                    delayTags=regexp(delayString,'DelayInfo\s*,\s*(?<inport>[\w\d_]*)\s*,\s*(?<outport>[\w\d_]*)\s*,\s*(?<delay>[\w\d\.]*)','names');
                    inport=characterization.STA.Characterization.InvalidPort;
                    outport=characterization.STA.Characterization.InvalidPort;
                    delay=characterization.STA.Characterization.InvalidDelay;

                    if(~isempty(delayTags.inport))
                        inport=self.getPortID(delayTags.inport);
                    end

                    if(~isempty(delayTags.outport))
                        outport=self.getPortID(delayTags.outport);
                    end
                    if(~isempty(delayTags.delay))
                        delay=self.parseDelay(delayTags.delay);
                    end

                    self.registerDelays(inport,outport,delay);
                end

                rline=fgets(fid);
            end
            fclose(fid);
            delaySpec=self.getDelayMap();

        end

        function delayMap=getDelayMap(self)

            delayMap=self.m_delayMap;

        end

        function portNum=getPortID(self,portStr)

            portNum=characterization.STA.Characterization.InvalidPort;
            portId=regexp(portStr,'mw_(inport|outport)_(?<portNum>\d+)','names');

            if(~isempty(portId)&&~isempty(portId.portNum))
                portNum=str2double(portId.portNum);
                return;

            end

            if(strcmp(portStr,'mw_internal_registers'))

                portNum=characterization.STA.Characterization.RegisterPort;
                return;
            end

        end

        function delay=parseDelay(self,delayString)

            delay=characterization.STA.Characterization.InvalidDelay;

            t=regexp(delayString,characterization.STA.RegexpCatalog.DecimalNumber,'match');


            if(~isempty(t))
                t=t{1};
                delay=str2double(t);
                return;
            end

        end

        function self=registerDelays(self,inport,outport,delay)

            if inport==characterization.STA.Characterization.InvalidPort||outport==characterization.STA.Characterization.InvalidPort||delay==characterization.STA.Characterization.InvalidDelay
                return;
            end


            t.ports=inport;
            t.ports(2)=outport;
            t.delay=delay;
            self.m_delayMap(end+1)=t;

        end

    end

end

