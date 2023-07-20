classdef(Sealed)CreateSimulinkBus<Simulink.internal.CompositePorts.CreateBusAction


    methods(Access={?Simulink.internal.CompositePorts.CreateBusWrapper})

        function this=CreateSimulinkBus(editor,selection)
            narginchk(2,2);



            this@Simulink.internal.CompositePorts.CreateBusAction(editor,selection,mfilename('class'));


            if~this.checkSimulinkBusFeature()
                return;
            end


            this.mData.handles=this.getUnconnectedLinesAndPortsInSelection(this.mData.selection,'signal');
        end
    end

    methods(Access=protected)
        function m=getEditorModels(this)
            m={this.mData.editor.getDiagram().model.getRootDeviant()};
        end

        function w=getBusBlockWidth(this)
            w=5;
        end

        function orntn=computeOrientationForPort(this,h)

            source=get_param(h,'ParentHandle');
            orntn=this.getOrntnNum(get_param(source,'Orientation'));
        end
    end


    methods(Static,Access={?Simulink.internal.CompositePorts.Dispatcher,?Simulink.internal.CompositePorts.BusAction})

        function tf=canExecuteImpl(this)
            tf=this.checkSimulinkBusFeature()&&...
            numel(this.mData.handles)>=2&&...
            ~this.isAnyInVariantWrapper(this.mData.handles);
        end


        function msg=executeImpl(this)
            msg='';




            if slsvTestingHook('BusActionsThrowBeforeChange')==1
                assert(false)
            end


            this.mData.busBlock=this.addBusCreator(this.mData.editor.getName(),this.getOrntnStr(this.mData.orientation),numel(this.mData.endpointInfos),this.mData.busBlockPos);
            this.connectBusCreator();

            if slsvTestingHook('BusActionsThrowAfterChange')==1
                assert(false)
            end
        end
    end


    methods(Access=private)
        function connectBusCreator(this)
            inports=get_param(this.mData.busBlock,'PortHandles');
            inports=inports.Inport;
            arrayfun(@(i)SLM3I.SLDomain.createSegment(this.mData.editor,this.mData.endpointInfos(i).obj,SLM3I.SLDomain.handle2DiagramElement(inports(i))),1:numel(this.mData.endpointInfos));
        end

        function tf=checkSimulinkBusFeature(this)
            tf=this.checkFeatures({'CreateSimulinkBusAction'});
        end
    end
end
