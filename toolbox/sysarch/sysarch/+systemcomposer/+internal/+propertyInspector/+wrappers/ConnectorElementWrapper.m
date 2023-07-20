classdef ConnectorElementWrapper<systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper



    properties
        sourcePortHdl;
        destPortHdl;
        schemaType;
        userSelectionMade;
        selectedConn;
        fakeConn;

    end

    methods
        function obj=ConnectorElementWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper(varargin{:});
            obj.schemaType='Connector';
        end

        function removeHilite(obj)
            if~isempty(obj.hilitedConn)&&isvalid(obj.hiliter)
                obj.hiliter.removeClass(obj.hilitedConn,'ArchConnector')
            end
        end

        function setPropElement(obj)
            if~isempty(obj.options)
                obj.selectedConnDest=obj.options.dstPort;
            end
            obj.element=obj.getZCElement();
            if isempty(obj.sourceHandle)
                obj.sourceHandle=systemcomposer.utils.getSimulinkPeer(obj.element);
            end
        end

        function name=getName(obj)
            if~ishandle(get_param(obj.sourceHandle,'DstPortHandle'))
                name="";
            else
                name=obj.element.getName;
            end
        end
        function[isSelected,selectedLine]=DestinationPortConnectors(h)
            if~isempty(h.SignalObjectClass)
                selectedLine=find_system(h.Parent,...
                'searchdepth',1,'followlinks','off','findall','on',...
                'lookundermasks','off','type','line','selected','on');
            else
                selectedLine=cell(0,1);
            end
            if numel(selectedLine)==1
                isSelected=true;
            else
                isSelected=false;

            end

        end
        function name=getNameTooltip(obj)

            name=DAStudio.message('SystemArchitecture:PropertyInspector:Connector');
        end

        function status=isNameEditable(~)

            status=true;
        end

        function error=setName(obj,changeSet,~)

            error='';
            newValue=changeSet.newValue;
            try
                txn=mf.zero.getModel(obj.selectedConn).beginTransaction;
                obj.selectedConn.setName(newValue);
                txn.commit;

            catch
                error='Failed to set Name';
            end
        end

        function value=getSourcePortName(obj)
            if~(ishandle(get_param(obj.sourceHandle,'DstPortHandle')))
                value=systemcomposer.utils.getArchitecturePeer(obj.sourcePortHdl).getName;
            else
                value=obj.element.getSource.getName;

            end
        end
        function value=getDestinationPortName(obj)
            if~(ishandle(get_param(obj.sourceHandle,'DstPortHandle')))
                value="";
            else
                value=obj.element.getDestination.getName;
            end
        end
        function value=getConnectorInfo(obj)
            srcName=obj.getSourcePortName();
            dstName=obj.getDestinationPortName();
            if~isempty(srcName)&&~isempty(dstName)
                value=[srcName,' -> ',dstName];
            else
                value='';
            end

        end
        function value=getDestPortEditable(obj)
            value=true;
        end
        function value=getDestPortRenderMode(obj)

            value='RenderAsText';
        end

        function[value,entries]=getDestinationPorts(elementWrapper)
            value=elementWrapper.getDestinationPortName();
            entries={elementWrapper.getDestinationPortName()};

































        end
        function[hiliter,hilitedConn]=hiliteSelectedSegment(obj,hilit)
            selectedSegDiagObj=diagram.resolver.resolve([obj.sourcePortHdl,obj.destPortHdl]);
            hilitedConn=selectedSegDiagObj;
            hilit.applyClass(selectedSegDiagObj,'ArchConnector')
            hiliter=hilit;
        end

        function hiliter=createHighlighterLine(obj)
            stylerName='Sysarch.SegmentGlyphStyler';
            hiliter=diagram.style.getStyler(stylerName);

            if isempty(hiliter)
                diagram.style.createStyler(stylerName);
                hiliter=diagram.style.getStyler(stylerName);
            end


            darkBlue=[0.0,0.0,0.5,0.8];
            glow=MG2.GlowEffect;
            glow.Color=darkBlue;
            glow.Spread=2.5;
            glow.Gain=10;

            style=diagram.style.Style;
            style.set('Glow',glow)






            archConnTagRule=hiliter.addRule(style,diagram.style.ClassSelector('ArchConnector'));

        end

        function[isTrue,selectedLines]=isSingleLineSelected(ElementWrapper)
            selectedLines=find_system(ElementWrapper.h.Parent,...
            'searchdepth',1,'followlinks','off','findall','on',...
            'lookundermasks','off','type','line','selected','on');

            if numel(selectedLines)==1
                isTrue=true;
            else
                isTrue=false;
            end
        end
        function dstPrtNames=findAllDstPrtNames(elem)
            dstPrtNames={};
            [~,selectedLines]=elem.isSingleLineSelected();
            allDstPrt=get_param(selectedLines,'DstPortHandle');
            allDstPrtSize=cellfun(@size,allDstPrt,'UniformOutput',false);



            allDstPrtNoChild=allDstPrt(cellfun(@isequal,allDstPrtSize,...
            repmat({[1,1]},size(allDstPrtSize))));

            allDstPrtNoChild(~cellfun(@ishandle,allDstPrtNoChild))=[];
            allDstPrts=cellfun(@systemcomposer.utils.getArchitecturePeer,...
            allDstPrtNoChild,'UniformOutput',false);
            for ii=1:numel(allDstPrts)
                zcDstPrt=allDstPrts{ii};
                switch class(zcDstPrt)
                case 'systemcomposer.architecture.model.design.ComponentPort'
                    dstPrtNames{end+1}=[zcDstPrt.getComponent.getName,'/',zcDstPrt.getName];%#ok<AGROW>
                case 'systemcomposer.architecture.model.design.ArchitecturePort'
                    dstPrtNames{end+1}=zcDstPrt.getName;%#ok<AGROW>
                end
            end
        end

        function zcDstPrt=findDstPrt(this,userSelection)
            connArch=this.selectedConn.getArchitecture;
            if contains(userSelection,'/')
                names=strsplit(userSelection,'/');
                compName=names{1};
                portName=names{2};
                comp=connArch.getComponent(compName);
                port=comp.getPort(portName);
                this.destPortHdl=systemcomposer.utils.getSimulinkPeer(port);
            else
                port=connArch.getPort(userSelection);
                portBlockHandle=systemcomposer.utils.getSimulinkPeer(port);
                lineHandles=get_param(portBlockHandle,'LineHandles');
                this.destPortHdl=get_param(lineHandles.Inport,'DstPortHandle');
            end
            zcDstPrt=port;
        end
    end

    methods(Access=private)
        function elem=getElemToSetPropFor(obj)
            elem=obj.element;
            elem=systemcomposer.internal.getWrapperForImpl(elem);
        end
    end
end
