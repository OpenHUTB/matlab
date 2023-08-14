classdef(Sealed)CreatePhysmodBus<Simulink.internal.CompositePorts.CreateBusAction


    methods(Access={?Simulink.internal.CompositePorts.CreateBusWrapper})

        function this=CreatePhysmodBus(editor,selection)
            narginchk(2,2);



            this@Simulink.internal.CompositePorts.CreateBusAction(editor,selection,mfilename('class'));


            if~this.checkPhysmodBusFeature()
                return;
            end


            this.mData.handles=this.getUnconnectedLinesAndPortsInSelection(this.mData.selection,'connection');
        end
    end

    methods(Access=protected)
        function m=getEditorModels(this)
            m={this.mData.editor.getDiagram().model.getRootDeviant()};
        end

        function w=getBusBlockWidth(this)
            w=80;
        end

        function orntn=computeOrientationForPort(this,h)

            assert(strcmpi(get_param(h,'PortType'),'connection'));

            orntn=this.getOrntnNum(get_param(get_param(h,'ParentHandle'),'Orientation'));

            portSide=this.getConnectionPortSide(h);

            flip=(portSide==this.ORNTN_LEFT);
            if flip
                orntn=this.flipOrientntation(orntn);
            end
        end
    end

    methods(Static,Access={?Simulink.internal.CompositePorts.Dispatcher,?Simulink.internal.CompositePorts.BusAction})


        function tf=canExecuteImpl(this)
            tf=this.checkPhysmodBusFeature()&&...
            numel(this.mData.handles)>=2&&...
            ~this.isAnyInVariantWrapper(this.mData.handles);
        end


        function msg=executeImpl(this)
            msg='';




            if slsvTestingHook('BusActionsThrowBeforeChange')==1
                assert(false)
            end


            this.mData.busBlock=this.addPhysmodRouter();
            this.connectPhysmodRouter();

            if slsvTestingHook('BusActionsThrowAfterChange')==1
                assert(false)
            end
        end
    end


    methods(Access=private)

        function res=flipOrientntation(this,orntn)
            switch orntn
            case this.ORNTN_RIGHT
                res=this.ORNTN_LEFT;
            case this.ORNTN_LEFT
                res=this.ORNTN_RIGHT;
            case this.ORNTN_UP
                res=this.ORNTN_DOWN;
            case this.ORNTN_DOWN
                res=this.ORNTN_UP;
            otherwise
                assert(false);
            end
        end

        function h=addPhysmodRouter(this)
            h=private_sl_feval_with_named_counter('Simulink::sluCheckForNewConnectionsInGraph',...
            'add_block','built-in/SimscapeBus',...
            [this.mData.editor.getName(),'/Simscape Bus'],'MakeNameUnique','on');

            private_sl_feval_with_named_counter('Simulink::sluCheckForNewConnectionsInGraph',...
            'set_param',h,'Orientation',this.getOrntnStr(this.mData.orientation),...
            'Position',this.mData.busBlockPos,'hierStrings',this.generateHierStrings());
        end

        function connectPhysmodRouter(this)
            inports=get_param(this.mData.busBlock,'PortHandles');
            inports=inports.LConn;
            arrayfun(@(i)SLM3I.SLDomain.createSegment(this.mData.editor,this.mData.endpointInfos(i).obj,SLM3I.SLDomain.handle2DiagramElement(inports(i))),1:numel(this.mData.endpointInfos));
        end

        function str=generateHierStrings(this)
            str=strjoin(arrayfun(@(i)sprintf('connection%d',i),1:numel(this.mData.endpointInfos),'UniformOutput',false),';');
        end

        function tf=checkPhysmodBusFeature(this)
            tf=this.checkFeatures({'CreatePhysmodBusAction','PHYSMOD_BUSES'});
        end
    end
end
