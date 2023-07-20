classdef(Abstract,Hidden)Element<systemcomposer.base.StereotypableElement&systemcomposer.base.BaseElement





    properties(Dependent=true,SetAccess=private)
Model
SimulinkHandle
SimulinkModelHandle
    end

    methods

        function m=get.Model(this)
            zcModelImpl=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(this.MFModel);
            m=[];%#ok<NASGU>
            if(~zcModelImpl.isProtectedModel)
                if(~bdIsLoaded(zcModelImpl.getName))
                    m=systemcomposer.loadModel(zcModelImpl.getName);
                else
                    m=get_param(zcModelImpl.getName,'SystemComposerModel');
                end
            else
                m=systemcomposer.arch.Model(zcModelImpl);
            end
        end

        function slhdl=get.SimulinkHandle(this)
            thisImpl=this.getImpl;
            if isa(this,'systemcomposer.arch.BaseComponent')
                slhdl=Simulink.SystemArchitecture.internal.ApplicationManager.getBlockHandleForComponent(thisImpl);
            elseif isa(this,'systemcomposer.arch.Architecture')
                parComp=this.Parent;
                if~isempty(parComp)
                    slhdl=Simulink.SystemArchitecture.internal.ApplicationManager.getBlockHandleForComponent(parComp.getImpl);
                else
                    slhdl=this.SimulinkModelHandle;
                end

            elseif isa(this,'systemcomposer.arch.ArchitecturePort')
                slhdl=Simulink.SystemArchitecture.internal.ApplicationManager.getBlockHandleForArchPort(thisImpl);
            elseif isa(this,'systemcomposer.arch.ComponentPort')
                slhdl=Simulink.SystemArchitecture.internal.ApplicationManager.getPortHandleForCompPort(thisImpl);
            elseif isa(this,'systemcomposer.arch.BaseConnector')
                slhdl=Simulink.SystemArchitecture.internal.ApplicationManager.getSegmentHandlesForConnector(thisImpl);
            else
                slhdl=[];
            end

            if(isempty(slhdl))
                slhdl=-1;
            end
        end

        function slhdl=get.SimulinkModelHandle(this)
            topLevelArchitecture=this.ElementImpl.getTopLevelArchitecture;
            slhdl=-1;
            try
                zcModelImpl=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(mf.zero.getModel(topLevelArchitecture));
                if(~zcModelImpl.isProtectedModel)
                    slhdl=get_param(topLevelArchitecture.getName,'Handle');
                end
            catch
                error('systemcomposer:API:SimulinkModelNotLoaded',...
                message('SystemArchitecture:API:SimulinkModelNotLoaded',...
                topLevelArchitecture.getName).getString);
            end
        end
    end

    methods(Hidden)

        function this=Element(elemImpl)
            this@systemcomposer.base.BaseElement(elemImpl);
        end


        function fullName=getQualifiedName(this)
            fullName=this.ElementImpl.getQualifiedName;
        end
    end

end

