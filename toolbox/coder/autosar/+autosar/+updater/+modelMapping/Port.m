classdef Port<autosar.updater.ModelMappingMatcher






    properties(Access=private)
        UnmatchedElements autosar.mm.util.Set
    end

    methods
        function this=Port(modelName)
            this=this@autosar.updater.ModelMappingMatcher(modelName);

            this.UnmatchedElements=autosar.mm.util.Set(...
            'InitCapacity',40,...
            'KeyType','char',...
            'HashFcn',@(x)x);
        end

        function markAsUnmatched(this)
            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end

            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
            for ii=1:length(modelMapping.Inports)
                this.UnmatchedElements.set(modelMapping.Inports(ii).Block);
            end

            for ii=1:length(modelMapping.Outports)
                this.UnmatchedElements.set(modelMapping.Outports(ii).Block);
            end
        end

        function[isMapped,portBlk]=isMapped(this,varargin)


            m3iPort=varargin{1};
            m3iElement=varargin{2};
            slBlockType=varargin{3};
            if nargin>4
                portType=varargin{4};
            else
                portType='';
            end

            isMapped=false;
            portBlk=[];

            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);

            if isa(m3iPort,'Simulink.metamodel.arplatform.port.AdaptivePort')
                dataElementName='Event';
            else
                dataElementName='Element';
            end

            switch slBlockType
            case 'Inport'
                assert(isa(m3iPort,'Simulink.metamodel.arplatform.port.RequiredPort'),...
                'm3iPort should be a RequiredPort but it is of type: %s.',class(m3iPort));

                inports=modelMapping.Inports;
                for ii=1:length(inports)
                    if strcmp(inports(ii).MappedTo.Port,m3iPort.Name)&&...
                        strcmp(inports(ii).MappedTo.(dataElementName),m3iElement.Name)
                        if isempty(portType)||strcmp(inports(ii).MappedTo.DataAccessMode,portType)
                            if isempty(portType)

                                if~contains(inports(ii).MappedTo.DataAccessMode,{'ErrorStatus','IsUpdated'})
                                    isMapped=true;
                                    portBlk=inports(ii).Block;
                                end
                            else
                                isMapped=true;
                                portBlk=inports(ii).Block;
                            end
                        end
                        this.UnmatchedElements.remove(inports(ii).Block);
                    end
                end
            case 'Outport'
                assert(isa(m3iPort,'Simulink.metamodel.arplatform.port.ProvidedPort'),...
                'm3iPort should be a ProvidedPort but it is of type: %s.',class(m3iPort));

                outports=modelMapping.Outports;
                for ii=1:length(outports)
                    if strcmp(outports(ii).MappedTo.Port,m3iPort.Name)&&...
                        strcmp(outports(ii).MappedTo.(dataElementName),m3iElement.Name)
                        isMapped=true;
                        portBlk=outports(ii).Block;
                        this.UnmatchedElements.remove(outports(ii).Block);


                        return;
                    end
                end
            otherwise
                assert(false,'Did not recognize block type %s, expected Inport or Outport',slBlockType);
            end
        end

        function logDeletions(this,changeLogger,deletionMode)
            switch deletionMode
            case 'DeleteBlock'
                this.logManualBlkDeletions(this.UnmatchedElements,'Port','AutoDelete',changeLogger);
            case 'DeleteBlockAndConnections'
                this.logManualBlkDeletions(this.UnmatchedElements,'Port','DeleteBlockAndLeafs',changeLogger);
            otherwise
                this.logManualBlkDeletions(this.UnmatchedElements,'Port','MarkBlockForDelete',changeLogger);
            end
        end
    end
end


