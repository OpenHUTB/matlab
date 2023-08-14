classdef(Hidden,Abstract)ArchElement<matlab.mixin.SetGet&matlab.mixin.Heterogeneous





    properties(Dependent=true)
Name
    end

    properties(Dependent=true,SetAccess=protected)
Parent
    end

    properties(Transient,SetAccess=protected)
SimulinkHandle
    end


    methods(Abstract,Access=protected)
        getName(this);
        setName(this,newName);
        destroyImpl(this);
        getParent(this);
    end

    methods
        function b=eq(this,other)

            b=isa(this,'autosar.arch.ArchElement')&&...
            isa(other,'autosar.arch.ArchElement')&&...
            isequal(this.SimulinkHandle,other.SimulinkHandle);
        end

        function this=ArchElement(slHandle)



            this.SimulinkHandle=slHandle;
            this.checkValidSimulinkHandle();


            archModelH=this.getRootArchModelH();
            assert(Simulink.internal.isArchitectureModel(this.getRootArchModelH(),'AUTOSARArchitecture'),...
            '%s is not an AUTOSAR architecture model.',getfullname(archModelH));
        end

        function val=get.SimulinkHandle(this)
            val=this.SimulinkHandle;
            if~is_simulink_handle(val)
                val=-1;
            end
        end

        function name=get.Name(this)
            name=this.getName();
        end

        function set.Name(this,newName)
            this.setName(newName);
        end

        function p=get.Parent(this)
            p=this.getParent();
        end

        function destroy(this)









            this.destroyImpl();
        end
    end

    methods(Hidden)
        function slModelH=getRootArchModelH(this)

            slModelH=get_param(bdroot(this.SimulinkHandle),'Handle');
        end

        function rootArch=getRootArchModelObj(this)


            p=this.Parent;
            while~isa(p,'autosar.arch.Model')
                p=p.Parent;
            end
            rootArch=p;
        end


        function getdisp(this)
            getdisp@matlab.mixin.SetGet(this);
        end


        function setdisp(this)
            setdisp@matlab.mixin.SetGet(this);
        end
    end

    methods(Hidden,Access=protected)
        function refreshPropertyInspector(this)

            h=DAStudio.EventDispatcher;
            h.broadcastEvent('PropertyChangedEvent',this.SimulinkHandle);
        end

        function checkValidSimulinkHandle(this)
            if~is_simulink_handle(this.SimulinkHandle)
                DAStudio.error('Simulink:Commands:InvSimulinkObjHandle');
            end
        end

        function name=getNameDefaultImpl(this)

            this.checkValidSimulinkHandle();

            name=get_param(this.SimulinkHandle,'Name');
        end

        function setNameDefaultImpl(this,newName)

            this.checkValidSimulinkHandle();

            set_param(this.SimulinkHandle,'Name',newName);
        end

        function p=getParentDefaultImpl(this)

            this.checkValidSimulinkHandle();

            parentH=get_param(get_param(this.SimulinkHandle,'Parent'),'Handle');
            if autosar.arch.Utils.isBlockDiagram(parentH)
                p=autosar.arch.Model.create(parentH);
            else
                p=autosar.arch.Composition.create(parentH);
            end
        end

        function destroyDefaultImpl(this)

            this.checkValidSimulinkHandle();

            delete_block(this.SimulinkHandle);
            delete(this);
        end
    end
end
