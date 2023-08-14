classdef Function<systemcomposer.base.BaseElement&systemcomposer.base.StereotypableElement




    properties(Dependent,SetAccess=private)
Model
ExecutionOrder
    end

    properties(Dependent,SetAccess=immutable)
Component
Parent
    end

    properties(Dependent)
Name
        Period string
    end

    methods(Hidden)
        function this=Function(functionImpl)
            this@systemcomposer.base.BaseElement(functionImpl);
            functionImpl.cachedWrapper=this;
        end

        function functionElem=getPrototypable(this)
            functionElem=swarch.utils.getPrototypableFunction(this.getImpl());
        end
    end

    methods
        function name=get.Name(this)
            name=this.getImpl().getName();
        end

        function set.Name(this,name)
            if~this.isRootFunction()
                error(message('SoftwareArchitecture:API:CannotModifyComponentFunction'));
            end

            swarch.utils.setFunctionAndRootInportBlockName(this.getImpl(),name);
        end

        function comp=get.Component(this)
            comp=systemcomposer.internal.getWrapperForImpl(this.getImpl().calledFunctionParent);
            if isempty(comp)
                comp=systemcomposer.arch.Component.empty;
            end
        end

        function parent=get.Parent(this)
            parent=systemcomposer.internal.getWrapperForImpl(this.getImpl().parent.p_Architecture);
        end

        function period=get.Period(this)
            period=this.getImpl().period;
        end

        function set.Period(this,period)
            if~this.isRootFunction()
                error(message('SoftwareArchitecture:API:CannotModifyComponentFunction'));
            end

            if size(period,2)>1

                period=strcat('[',strjoin(period),']');
            end

            impl=this.getImpl();
            inport=this.getInportBlock();
            if~(isempty(inport)||strcmpi(impl.period,get_param(inport,'SampleTime')))


                error(message('SoftwareArchitecture:API:CannotEditPeriodicFunctionRate',this.Name));
            end

            swarch.utils.setFunctionAndRootInportBlockPeriod(impl,period);
        end

        function m=get.Model(this)
            zcModelImpl=systemcomposer.architecture.model...
            .SystemComposerModel.getSystemComposerModel(this.MFModel);
            m=[];%#ok<NASGU>
            if(~zcModelImpl.isProtectedModel)
                if(~bdIsLoaded(zcModelImpl.getName))
                    m=systemcomposer.loadModel(zcModelImpl.getName);
                else
                    m=get_param(zcModelImpl.getName(),'SystemComposerModel');
                end
            else
                m=systemcomposer.internal.getWrapperForImpl(zcModelImpl);
            end
        end

        function order=get.ExecutionOrder(this)
            order=this.getImpl().executionOrder;
        end

        function increaseExecutionOrder(this)


            if~this.isRootFunction()
                error(message('SoftwareArchitecture:API:CannotModifyComponentFunction'));
            end

            if strcmpi(...
                get_param(this.Model.SimulinkHandle,'OrderFunctionsByDependency'),'on')
                error(message('SoftwareArchitecture:API:CannotModifyExecOrderWithDependencyOrdering'));
            end

            orderBef=this.getImpl().executionOrder;
            this.getImpl().setOrder(orderBef+1);
            if orderBef==this.getImpl().executionOrder
                warning(message('SoftwareArchitecture:API:CannotIncreaseExecutionOrder',this.Name));
            else
                this.syncInportPriorities();
            end
        end

        function decreaseExecutionOrder(this)


            if~this.isRootFunction()
                error(message('SoftwareArchitecture:API:CannotModifyComponentFunction'));
            end

            if strcmpi(...
                get_param(this.Model.SimulinkHandle,'OrderFunctionsByDependency'),'on')
                error(message('SoftwareArchitecture:API:CannotModifyExecOrderWithDependencyOrdering'));
            end

            orderBef=this.getImpl().executionOrder;
            this.getImpl().setOrder(this.getImpl().executionOrder-1);
            if orderBef==this.getImpl().executionOrder
                warning(message('SoftwareArchitecture:API:CannotDecreaseExecutionOrder',this.Name));
            else
                this.syncInportPriorities();
            end
        end

        function destroy(this)


            if~this.isRootFunction()
                error(message('SoftwareArchitecture:API:CannotModifyComponentFunction'));
            end

            if~swarch.utils.isInlineSoftwareComponent(this.Component.getImpl())&&...
                strcmp(get_param(this.Model.getImpl().getRootArchitecture().getName(),...
                'AutosarExportToRateBasedArch'),'off')
                error(message('SoftwareArchitecture:API:CannotDestroyFunction'));
            end

            swarch.utils.destroyFunctionAndRootInportBlock(this.getImpl());
        end
    end

    methods(Access=private)
        function inpBlock=getInportBlock(this)
            inpBlock=swarch.utils.getFcnCallInport(this.getImpl());
        end

        function isRoot=isRootFunction(this)

            parentArch=this.getImpl().parent.p_Architecture;
            isRoot=~parentArch.hasParentComponent()&&...
            parentArch.isSoftwareArchitecture();
        end

        function syncInportPriorities(this)
            rootArch=this.Model.getImpl().getRootArchitecture();
            osFuncs=rootArch.getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).getFunctionsOfType(...
            systemcomposer.architecture.model.swarch.FunctionType.OSFunction...
            );

            for os=osFuncs
                set_param(swarch.utils.getFcnCallInport(os),'Priority',num2str(os.executionOrder));
            end
        end
    end
end


