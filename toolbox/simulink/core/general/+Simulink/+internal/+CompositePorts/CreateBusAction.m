classdef CreateBusAction<Simulink.internal.CompositePorts.BusAction

    properties(Constant,Access=protected)
        ORNTN_RIGHT=1
        ORNTN_LEFT=2
        ORNTN_UP=3
        ORNTN_DOWN=4
        ORNTN_NUM_TO_STR={'right','left','up','down'}
        ORNTN_STR_TO_NUM=containers.Map({'right','left','up','down'},{1,2,3,4})


        IMAG_LINE_LEN=50;
    end

    properties(Access=private)


        mDispatcher;
    end


    methods(Access=protected)

        function this=CreateBusAction(editor,selection,derivedClassType)
            narginchk(3,3);



            this@Simulink.internal.CompositePorts.BusAction(editor,selection,mfilename('class'));


            this.mDispatcher=Simulink.internal.CompositePorts.Dispatcher(this,derivedClassType);
        end
    end


    methods(Access=protected,Abstract)
        w=getBusBlockWidth(this)
        orntn=computeOrientationForPort(this,h)
    end


    methods(Static,Access={?Simulink.internal.CompositePorts.Dispatcher,?Simulink.internal.CompositePorts.BusAction})

        function tf=canExecuteImpl(this)
            tf=this.mDispatcher.dispatch('canExecuteImpl');
        end


        function msg=executeImpl(this)

            this.mData.endpointInfos=arrayfun(@(h)this.createEndpointInfo(h),this.mData.handles);

            this.mData.orientation=this.computeOrientation();

            this.mData.sourceSingleBlock=this.isSourceSingleBlock();

            this.mData.endpointInfos=this.extendImagLines(this.IMAG_LINE_LEN);
            this.mData.endpointInfos=this.sortEndpointInfos();

            this.mData.busBlockPos=this.computeBusBlockPos(this.getBusBlockWidth());


            msg=this.mDispatcher.dispatch('executeImpl');


            this.mData.editor.clearSelection();
            this.mData.editor.select(SLM3I.SLDomain.handle2DiagramElement(this.mData.busBlock));
        end


        function res=errorRecoveryImpl(this)
            res=[];
        end
    end

    methods(Access=protected)
        function tf=isAnyInVariantWrapper(this,handles)
            tf=any(arrayfun(@(h)this.isVariantWrapper(this.getOwnerHandle(h)),handles));
        end

        function orntn=getConnectionPortSide(this,h)

            block=get_param(h,'ParentHandle');
            ph=get_param(block,'PortHandles');

            if any(ph.LConn==h)
                orntn='left';
            else
                assert(any(ph.RConn==h))
                orntn='right';
            end

            orntn=this.getOrntnNum(orntn);
        end

        function res=filterUnsupportedConnectionPorts(this,ports)




            function tf=locIsSupported(h)

                blockType=get_param(get_param(h,'ParentHandle'),'BlockType');
                if strcmpi(blockType,'SimscapeBus')&&this.getConnectionPortSide(h)~=this.ORNTN_RIGHT
                    tf=false;
                    return;
                end
                portType=get_param(h,'ConnectionType');
                [dom,rem]=strtok(portType,'.');

                if strcmpi(dom,'DefaultConnectivityDomain')||strcmpi(dom,'BusConnectivityDomain')
                    tf=true;
                    return;
                end
                if~strcmpi(dom,'network_engine_domain')
                    tf=false;
                    return;
                end

                if strcmpi(rem,'.input')||strcmpi(rem,'.output')
                    tf=false;
                    return;
                end

                tf=true;
            end
            res=ports(arrayfun(@locIsSupported,ports));
        end

        function handles=getUnconnectedLinesAndPortsInSelection(this,selection,type)

            assert(strcmpi(type,'signal')||strcmpi(type,'connection'));
            workingOnSignals=strcmpi(type,'signal');


            handles=[];

            for i=1:selection.size
                try

                    h=selection.at(i).handle;
                    if this.isBlock(h)
                        ports=get_param(h,'PortHandles');
                        if workingOnSignals

                            ports=[this.makeRow(ports.Outport),this.makeRow(ports.State)];
                        else

                            ports=[this.makeRow(ports.LConn),this.makeRow(ports.RConn)];

                            ports=this.filterUnsupportedConnectionPorts(ports);
                        end

                        unconnectedPortsMask=arrayfun(@(h)~ishandle(get_param(h,'Line')),ports);
                        handles=[handles,ports(unconnectedPortsMask)];

                        portsWithLines=ports(~unconnectedPortsMask);
                    elseif this.isLine(h)

                        if~strcmpi(get_param(h,'LineType'),type);continue;end

                        portsWithLines=this.getSourcePortIfLine(h);
                        if~workingOnSignals

                            portsWithLines=this.filterUnsupportedConnectionPorts(portsWithLines);
                        end
                    end


                    leafLines=arrayfun(@(h)this.getLineChildrenRecursively(get_param(h,'Line'),false),portsWithLines,'UniformOutput',false);
                    leafLines=[leafLines{:}];

                    unconnectedLinesMask=arrayfun(@(h)strcmpi(get_param(h,'Connected'),'off'),leafLines);
                    unconnectedLines=leafLines(unconnectedLinesMask);




                    if~workingOnSignals
                        unconnectedConnectionsMask=arrayfun(@(h)~SLM3I.SLDomain.handle2DiagramElement(h).terminator.isEmpty,unconnectedLines);
                        unconnectedLines=unconnectedLines(unconnectedConnectionsMask);
                    end

                    handles=[handles,unconnectedLines];%#ok<AGROW>
                catch

                end
            end



            handles=unique(handles);
        end

        function info=createEndpointInfo(this,h)
            info=struct();
            if this.isLine(h)


                segment=SLM3I.SLDomain.handle2DiagramElement(h);
                obj=segment.terminator.at(1);
                points=get_param(h,'Points');

                points=points([1,sum(abs(diff(points)),2)']~=0,:);

                if strcmpi(get_param(h,'LineType'),'connection')&&all(points(1,:)==obj.position)
                    points=flipud(points);
                end

                if size(points,1)==1
                    points=[points;NaN,NaN];
                end
            elseif this.isPort(h)

                obj=SLM3I.SLDomain.handle2DiagramElement(h);


                start_pnt=get_param(h,'Position');
                points=[start_pnt;NaN,NaN];
            end
            info.h=h;
            info.obj=obj;
            info.prevX=points(end-1,1);
            info.prevY=points(end-1,2);
            info.endX=points(end,1);
            info.endY=points(end,2);
        end

        function tf=isSourceSingleBlock(this)
            tf=false;


            ports=arrayfun(@(h)this.getSourcePortIfLine(h),[this.mData.endpointInfos.h],'UniformOutput',false);
            ports=[ports{:}];
            blocks=arrayfun(@(h)get_param(h,'ParentHandle'),ports);
            tf=numel(unique(blocks))==1;
        end

        function source=getSourcePortIfLine(this,h)
            switch lower(get_param(h,'Type'))
            case 'port'

                source=h;
            case 'line'
                switch lower(get_param(h,'LineType'))
                case 'signal'

                    source=get_param(h,'SrcPortHandle');
                case 'connection'

                    l=SLM3I.SLDomain.handle2DiagramElement(h);
                    if l.container.isvalid()&&isa(l.container,'SLM3I.Line')
                        l=l.container;
                        source=l.getAllPorts();
                        source=arrayfun(@(i)source.at(i).handle,1:source.size);
                    end
                otherwise

                    assert(false);
                end
            otherwise

                assert(false);
            end
        end

        function orntnStr=getOrntnStr(this,orntnNum)
            orntnStr=this.ORNTN_NUM_TO_STR{orntnNum};
        end

        function orntnNum=getOrntnNum(this,orntnStr)
            orntnNum=this.ORNTN_STR_TO_NUM(orntnStr);
        end

        function orntn=computeOrientation(this)








            ei=this.mData.endpointInfos;


            orntns=ones(1,numel(ei))*this.ORNTN_RIGHT;

            for i=1:numel(ei)
                if isnan(ei(i).endX)||isnan(ei(i).endY)

                    assert(isnan(ei(i).endX)&&isnan(ei(i).endY));


                    port=this.getSourcePortIfLine(ei(i).h);

                    orntns(i)=this.computeOrientationForPort(port);
                else

                    assert(~isnan(ei(i).endX)&&~isnan(ei(i).endY));
                    assert(~isnan(ei(i).prevX)&&~isnan(ei(i).prevY));
                    dx=ei(i).endX-ei(i).prevX;
                    dy=ei(i).endY-ei(i).prevY;
                    if abs(dx)>=abs(dy)
                        if dx>=0
                            orntns(i)=this.ORNTN_RIGHT;
                        else
                            orntns(i)=this.ORNTN_LEFT;
                        end
                    else
                        if dy<0
                            orntns(i)=this.ORNTN_UP;
                        else
                            orntns(i)=this.ORNTN_DOWN;
                        end
                    end
                end
            end


            [cnts,orntns]=hist(orntns,unique(orntns));
            orntn=orntns(cnts==max(cnts));
            if~isscalar(orntn)




                if any(orntn==this.ORNTN_RIGHT)
                    orntn=this.ORNTN_RIGHT;
                elseif any(orntn==this.ORNTN_LEFT)
                    orntn=this.ORNTN_LEFT;
                else
                    orntn=this.ORNTN_DOWN;
                end
            end
        end

        function sortedEndpointInfos=sortEndpointInfos(this)
            fields=fieldnames(this.mData.endpointInfos);
            data=struct2cell(this.mData.endpointInfos);
            sz=size(data);
            data=reshape(data,sz(1),[])';

            switch this.mData.orientation
            case{this.ORNTN_RIGHT,this.ORNTN_LEFT}



                data=sortrows(data,sz(1));
            case{this.ORNTN_UP,this.ORNTN_DOWN}

                data=sortrows(data,sz(1)-1);
            end
            data=reshape(data',sz);
            sortedEndpointInfos=cell2struct(data,fields,1);
        end

        function ei=extendImagLines(this,len)





            ei=this.mData.endpointInfos;
            for i=1:numel(ei)
                if isnan(ei(i).endX)||isnan(ei(i).endY)

                    assert(isnan(ei(i).endX)&&isnan(ei(i).endY));
                    assert(~isnan(ei(i).prevX)&&~isnan(ei(i).prevY));
                    switch this.mData.orientation
                    case this.ORNTN_RIGHT
                        ei(i).endX=ei(i).prevX+len;
                        ei(i).endY=ei(i).prevY;
                    case this.ORNTN_LEFT
                        ei(i).endX=ei(i).prevX-len;
                        ei(i).endY=ei(i).prevY;
                    case this.ORNTN_UP
                        ei(i).endX=ei(i).prevX;
                        ei(i).endY=ei(i).prevY-len;
                    case this.ORNTN_DOWN
                        ei(i).endX=ei(i).prevX;
                        ei(i).endY=ei(i).prevY+len;
                    otherwise
                        assert(false);
                    end
                end
            end

        end

        function pos=computeBusBlockPos(this,width)







            numSigs=numel(this.mData.endpointInfos);


            maxX=max([this.mData.endpointInfos.endX]);
            minX=min([this.mData.endpointInfos.endX]);
            maxY=max([this.mData.endpointInfos.endY]);
            minY=min([this.mData.endpointInfos.endY]);
            midX=mean([minX,maxX]);
            midY=mean([minY,maxY]);



            if this.mData.sourceSingleBlock

                halfHeightMax=Inf;
            else
                halfHeightMax=40*numSigs;
            end
            halfHeightMin=5*numSigs;
            ratio=numSigs/(numSigs-1);
            switch this.mData.orientation
            case{this.ORNTN_RIGHT,this.ORNTN_LEFT}
                halfHeight=(maxY-minY)*ratio/2;
            case{this.ORNTN_UP,this.ORNTN_DOWN}
                halfHeight=(maxX-minX)*ratio/2;
            otherwise
                assert(false);
            end
            halfHeight=min(max(halfHeight,halfHeightMin),halfHeightMax);
            switch this.mData.orientation
            case this.ORNTN_RIGHT
                topLeftX=maxX;
                botRightX=topLeftX+width;
                topLeftY=midY-halfHeight;
                botRightY=midY+halfHeight;
            case this.ORNTN_LEFT
                topLeftX=minX-width;
                botRightX=topLeftX+width;
                topLeftY=midY-halfHeight;
                botRightY=midY+halfHeight;
            case this.ORNTN_UP
                topLeftX=midX-halfHeight;
                botRightX=midX+halfHeight;
                topLeftY=minY-width;
                botRightY=topLeftY+width;
            case this.ORNTN_DOWN
                topLeftX=midX-halfHeight;
                botRightX=midX+halfHeight;
                topLeftY=maxY;
                botRightY=topLeftY+width;
            otherwise
                assert(false)
            end

            pos=this.clipPos(floor([topLeftX,topLeftY,botRightX,botRightY]));
        end
    end
end
