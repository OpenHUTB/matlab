classdef PortPlacement<handle
    properties
        schemaType='ConnectorPositionOnRectBoundary';
        schemaStrategy='PositionConnectorsProportionallyOnRectEdge';
        ids={};
        types={};
        sides={};
        numers={};
        denoms={};
    end
    methods
        function obj=PortPlacement(varargin)
            if nargin==0

            elseif nargin==4
                types=cell(size(varargin{1}));
                obj.ids=varargin{1};
                obj.types=types;
                obj.sides=varargin{2};
                obj.numers=varargin{3};
                obj.denoms=varargin{4};
            else
                error('bad PortPlacement ctor call');
            end
        end
        function addAXIInterface(obj,what)
            switch what
            case 'A4SWrSlaveMemCh'

                newSides={'LEFT','LEFT','LEFT','TOP','TOP'};
                newTypes={'input','input','output','output','input'};
            case 'A4S2HWrSlaveMemCh'

                newSides={'LEFT','LEFT','LEFT','TOP','TOP'};
                newTypes={'output','input','output','output','input'};

            case 'A4SRdMasterMemCh'

                newSides={'RIGHT','RIGHT','RIGHT','TOP','TOP'};
                newTypes={'output','output','input','output','input'};

            case 'A4H2SRdMasterMemCh'

                newSides={'RIGHT','RIGHT','RIGHT','TOP','TOP'};
                newTypes={'output','output','input','output','input'};

            case 'ReqDoneMemMaster'

                newSides={'BOTTOM','BOTTOM'};
                newTypes={'input','output'};

            case 'ReqDoneDummyMaster'

                newSides={'TOP','TOP'};
                newTypes={'output','input'};

            case 'A4SWrMasterLocal'

                newSides={'RIGHT','RIGHT','RIGHT'};
                newTypes={'output','output','input'};
            case 'A4SRdSlaveLocal'

                newSides={'LEFT','LEFT','LEFT'};
                newTypes={'input','input','output'};
            case 'Diagnostic'

                newSides={'RIGHT'};
                newTypes={'output'};
            otherwise
                error('bad AXI interface ''%s'' for port placement',what);
            end
            obj.addGroup(newSides,newTypes);
        end

        function addGroup(obj,newSides,newTypes)
            obj.appendIds(newTypes);
            obj.appendNumers(newSides);
            obj.sides=[obj.sides,newSides];
            obj.types=[obj.types,newTypes];
            obj.addSpacers(newSides);
        end

        function finishPlacement(obj)

            lrId=max(obj.lId,obj.rId);
            tbId=max(obj.tId,obj.bId);
            obj.addEndSpacers('LEFT','lId',lrId-1);
            obj.addEndSpacers('RIGHT','rId',lrId-1);
            obj.addEndSpacers('TOP','tId',tbId-1);
            obj.addEndSpacers('BOTTOM','bId',tbId-1);
        end

        function schemaJSON=generateSchema(obj)
            obj.errorCheck();

            schemaModel=mf.zero.Model;

            schema=ConnectorPlacement.(obj.schemaType)(schemaModel);
            assert(strcmp(schema.getStrategyName,obj.schemaStrategy));

            for ii=1:numel(obj.ids)
                portPosInfo=ConnectorPlacement.RectBoundaryConnectorPosition(schemaModel);
                portPosInfo.connectorId=obj.ids{ii};
                portLoc=ConnectorPlacement.Fraction;
                portLoc.numerator=obj.numers{ii};
                portLoc.denominator=obj.denoms{ii};
                portPosInfo.location=portLoc;
                portPosInfo.rectSide=ConnectorPlacement.RectSide.(obj.sides{ii});
                schema.connectorPositions.add(portPosInfo)
            end

            serializer=mf.zero.io.JSONSerializer;
            schemaJSON=serializer.serializeToString(schemaModel);
        end
        function addSpacer(obj,side,id)
            obj.appendIds({'<spacer>'});
            obj.appendAndIncr('numers',id);
            obj.sides=[obj.sides,side];
            obj.types=[obj.types,'<spacer>'];
        end
    end


    methods(Access=private)
        function addSpacers(obj,newSides)
            if any(strcmp(newSides,'LEFT')),obj.addSpacer('LEFT','lId');end
            if any(strcmp(newSides,'RIGHT')),obj.addSpacer('RIGHT','rId');end
            if any(strcmp(newSides,'TOP')),obj.addSpacer('TOP','tId');end
            if any(strcmp(newSides,'BOTTOM')),obj.addSpacer('BOTTOM','bId');end
        end
        function addEndSpacers(obj,side,id,denom)
            if~any(strcmp(obj.sides,side)),return;end

            endSpacers=denom+1-obj.(id);
            if(endSpacers>0)
                for sidx=(1:endSpacers),obj.addSpacer(side,id);end
            end
            obj.denoms(strcmp(obj.sides,side))={deal(denom)};
        end

        function appendIds(obj,newTypes)
            for idx=1:length(newTypes)
                switch newTypes{idx}
                case 'input'
                    obj.ids{end+1}=['In',num2str(obj.iId)];
                    obj.iId=obj.iId+1;
                case 'output'
                    obj.ids{end+1}=['Out',num2str(obj.oId)];
                    obj.oId=obj.oId+1;
                case '<spacer>'
                    obj.ids{end+1}='<spacer>';
                otherwise
                    error('bad type %s',newTypes{idx});
                end
            end
        end
        function appendNumers(obj,newSides)
            for idx=1:length(newSides)
                switch newSides{idx}
                case 'LEFT',obj.appendAndIncr('numers','lId');
                case 'RIGHT',obj.appendAndIncr('numers','rId');
                case 'TOP',obj.appendAndIncr('numers','tId');
                case 'BOTTOM',obj.appendAndIncr('numers','bId');
                end
            end
        end
        function appendAndIncr(obj,appendTo,incrWhat)
            obj.(appendTo){end+1}=obj.(incrWhat);
            obj.(incrWhat)=obj.(incrWhat)+1;
        end

        function errorCheck(obj)
            assert(iscell(obj.ids));
            numIds=numel(obj.ids);
            assert(iscell(obj.types)&&(numel(obj.types)==numIds));
            assert(iscell(obj.numers)&&(numel(obj.numers)==numIds));
            assert(iscell(obj.denoms)&&(numel(obj.denoms)==numIds));
            assert(iscell(obj.sides)&&(numel(obj.sides)==numIds));
        end

    end

    properties(Access=private)
        iId=1;
        oId=1;
        lId=1;
        rId=1;
        tId=1;
        bId=1;
    end

end