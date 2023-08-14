classdef BusAction<Simulink.internal.CompositePorts.BusActionUtilsMixin

    properties(Access=protected)



        mData;
    end

    properties(Access=private)


        mDispatcher;
    end


    methods(Access=protected)

        function this=BusAction(editor,selection,derivedClassType)
            try
                narginchk(3,3);

                this.mData=struct();
                this.mData.editor=editor;
                this.mData.selection=selection;


                this.mDispatcher=Simulink.internal.CompositePorts.Dispatcher(this,derivedClassType);
            catch ex
                if slsvTestingHook('BusActionsRethrow')==1
                    rethrow(ex);
                end
            end
        end
    end


    methods(Access=protected,Abstract)

        m=getEditorModels(this)
    end



    methods(Static,Abstract,Access={?Simulink.internal.CompositePorts.Dispatcher,?Simulink.internal.CompositePorts.BusAction})

        tf=canExecuteImpl(this)


        msg=executeImpl(this)


        res=errorRecoveryImpl(this)
    end


    methods(Sealed)
        function tf=canExecute(this)

            tf=false;


            if this.mData.editor.isLocked()
                return;
            end


            strictBusMsg=get_param(bdroot(this.mData.editor.getDiagram.getFullName),'StrictBusMsg');
            if strcmpi(strictBusMsg,'warning')||strcmpi(strictBusMsg,'none')
                return;
            end

            try

                tf=this.mDispatcher.dispatch('canExecuteImpl');
            catch ex

                if slsvTestingHook('BusActionsRethrow')==1
                    rethrow(ex);
                end
            end
        end

        function msg=execute(this)
            msg='';


            oldSuspendVal=SLM3I.SLDomain.suspendGraphics(true);
            restoreSuspend=onCleanup(@()SLM3I.SLDomain.suspendGraphics(oldSuspendVal));

            oldWarningVal=warning('off');
            restoreWarning=onCleanup(@()warning(oldWarningVal));

            try





                editorModels=this.uniquifyModels(this.getEditorModels());


                editorModelStates=cellfun(@(m)m.getCurrentChangeLevel(),editorModels);


                msg=this.mDispatcher.dispatch('executeImpl');
            catch ex

                cellfun(@(m)m.commitTransaction(),editorModels);



                this.mDispatcher.dispatch('errorRecoveryImpl');

                for i=1:numel(editorModels)

                    if editorModels{i}.getCurrentChangeLevel()~=editorModelStates(i)
                        editorModels{i}.undo();
                    end

                    editorModels{i}.beginTransaction();
                end

                if slsvTestingHook('BusActionsRethrow')==1
                    rethrow(ex);
                end
            end
        end
    end
end
