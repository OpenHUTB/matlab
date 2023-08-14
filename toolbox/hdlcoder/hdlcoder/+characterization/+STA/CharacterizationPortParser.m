classdef CharacterizationPortParser<handle




    properties
m_iterator
m_portToIndex
m_portSpec
m_ports
m_ranges
m_portIndexToPort
    end

    methods

        function self=CharacterizationPortParser(ports,portSpec)
            if(nargin<2)
                portSpec={};
            end
            self.m_portSpec=portSpec;
            self.m_ports=ports;
            self.init();
        end

        function init(self)

            self.m_portToIndex=containers.Map('KeyType','double','ValueType','any');
            self.m_ranges={};
            self.m_portIndexToPort=containers.Map('KeyType','double','ValueType','any');
            self.parsePortSpec();
            self.constructIterator();
        end


        function parsePortSpec(self)
            for i=1:numel(self.m_ports)
                port=self.m_ports(i);
                if iscell(port.port)
                    self.parseMultiPortSpec(port);
                else
                    self.parseSinglePortSpec(port);
                end
            end
        end


        function parseSinglePortSpec(self,port)
            index=self.addRange(port.range);
            self.m_portToIndex(port.port)=index;
            self.m_portIndexToPort(port.port)=port;
        end

        function parseMultiPortSpec(self,port)
            ports=port.port;
            cport=port;
            index=self.addRange(port.range);
            for i=1:numel(ports)
                pid=ports{i};
                cport.port=pid;
                self.m_portToIndex(cport.port)=index;
                self.m_portIndexToPort(cport.port)=cport;
            end
        end



        function index=addRange(self,range)

            if iscell(range)
                range=cell2mat(range);
            end

            self.m_ranges{end+1}=range;
            index=numel(self.m_ranges);
        end

        function constructIterator(self)
            if~isempty(self.m_ranges)

                if numel(self.m_ports)<=2&&any(arrayfun(@(x)isempty(x.widthTemplate),self.m_ports))


                    iter=cell(1,numel(self.m_ports));
                    for ii=1:numel(self.m_ports)
                        if isempty(self.m_ports(ii).widthTemplate)
                            iter{ii}=characterization.STA.ListIterator(self.m_ranges{ii});
                        else
                            iter{ii}=characterization.STA.StepIterator(self.m_ranges{ii});
                        end
                    end
                    if numel(iter)==2
                        self.m_iterator=characterization.STA.DoubleIterator(iter{1},iter{2});
                    else
                        assert(numel(iter)==1,'only 1 port expected');
                        self.m_iterator=iter{1};
                    end
                else

                    self.m_iterator=characterization.STA.MultiIterator('characterization.STA.StepIterator',self.m_ranges{1:end});
                end
            else
                ranges={};
                ranges{1}={[1,1,1]};
                self.m_iterator=characterization.STA.MultiIterator('characterization.STA.StepIterator',ranges);

            end
        end

        function iter=getIterator(self)
            iter=self.m_iterator;
        end

        function portSettings=getWidthSettings(self,tuple,numInputs)
            if~iscell(tuple)
                tuple={tuple};
            end

            portSettings=containers.Map('KeyType','double','ValueType','any');
            ports=self.m_portIndexToPort.keys();
            for i=1:numel(ports)
                portid=ports{i};

                if portid==characterization.PortDesc.REMAINING_PORTS
                    continue;
                end
                index=self.m_portToIndex(portid);
                portdesc=self.m_portIndexToPort(portid);
                if isempty(portdesc.widthTemplate)

                    switch tuple{index}
                    case 16
                        widthTemplate='half';
                    case 32
                        widthTemplate='single';
                    case 64
                        widthTemplate='double';
                    otherwise
                        error('unexpected floating point width found');
                    end
                else
                    widthTemplate=portdesc.widthTemplate;
                end
                portSettings(portid)={tuple{index},widthTemplate};
            end
            if self.m_portToIndex.isKey(characterization.PortDesc.REMAINING_PORTS)
                self.getRemainingPortSettings(numInputs,portSettings,tuple);
            end
        end

        function getRemainingPortSettings(self,numInputs,portSettings,tuple)
            rindex=characterization.PortDesc.REMAINING_PORTS;
            port=self.m_portIndexToPort(rindex);
            value=tuple{self.m_portToIndex(rindex)};
            for i=1:numInputs

                pid=i;
                if portSettings.isKey(pid)
                    continue;
                end
                portSettings(pid)={value,port.widthTemplate};
            end
        end

        function spec=getWidthSpecSorted(~,widthMap)
            spec=num2cell(sort(cell2mat(widthMap.keys())));
        end

        function pvpairs=getWidthSpec(self,wmap)
            pvpairs=[];
            if isempty(self.m_portSpec)
                pvpairs=sort(cell2mat(wmap.keys()))
                return
            end

            pvpairs=self.getWidthSpecFromPortSpec();
        end


        function widthSettings=getWidthSettingsForOutput(self,wmap)
            widthSettings={};

            wSpec=self.getWidthSpec(wmap);

            for i=1:numel(wSpec)
                port=wSpec(i);
                if~wmap.isKey(port)
                    continue;
                end
                value=wmap(port);

                widthSettings{end+1}=port;
                widthSettings{end+1}=value{1};
            end
        end

        function spec=getWidthSpecFromPortSpec(self)
            spec=[];
            for i=1:numel(self.m_portSpec)
                portid=self.m_portSpec{i};
                if portid==characterization.PortDesc.REMAINING_PORTS
                    error('REMAINING_PORTS cannot be specified in the widthSpec');
                end
                spec(end+1)=portid;

            end
        end
    end
end
