classdef InterfaceAction<Simulink.internal.CompositePorts.BusAction

    properties(Access=private)


        mDispatcher;
    end


    methods(Access=protected)

        function this=InterfaceAction(editor,selection,derivedClassType)
            narginchk(3,3);



            this@Simulink.internal.CompositePorts.BusAction(editor,selection,mfilename('class'));


            this.mDispatcher=Simulink.internal.CompositePorts.Dispatcher(this,derivedClassType);
        end


        function pbs=getModeledPortBlocks(this)

            pbs=[];
            try
                pbs=this.mData.modeledPortBlocks;
            catch
            end
        end
    end



    methods(Static,Access={?Simulink.internal.CompositePorts.Dispatcher,?Simulink.internal.CompositePorts.BusAction})

        function tf=canExecuteImpl(this)
            tf=false;


            tf=this.mDispatcher.dispatch('canExecuteImpl');
        end


        function msg=executeImpl(this)

            SLM3I.SLDomain.openWrapperInterfaceTransaction(this.mData.editor);


            msg=this.mDispatcher.dispatch('executeImpl');


            SLM3I.SLDomain.closeWrapperInterfaceTransaction(true);
        end


        function res=errorRecoveryImpl(this)

            res=[];



            SLM3I.SLDomain.closeWrapperInterfaceTransaction(false);
            portBlocks=this.getModeledPortBlocks();
            portDefs=[];




            for i=1:numel(portBlocks)
                portDefs=[portDefs,portBlocks(i).port.part.ports.toArray()];
            end

            for i=1:numel(portDefs)
                pbs=portDefs(i).blocks.toArray();
                for j=1:numel(pbs)
                    Simulink.BlockDiagram.Internal.restoreModeledPortBlockToSLBlockLink(pbs(j));
                end
            end
        end
    end
end
