classdef VariantComponent<systemcomposer.arch.BaseComponent





    properties(SetAccess=private)
Architecture
    end

    methods(Hidden)
        function this=VariantComponent(archElemImpl)
            narginchk(1,1);
            if~isa(archElemImpl,'systemcomposer.architecture.model.design.VariantComponent')
                error('systemcomposer:API:VariantComponentInvalidInput',message('SystemArchitecture:API:VariantComponentInvalidInput').getString);
            end

            this@systemcomposer.arch.BaseComponent(archElemImpl);
        end

        function ports=getActivePorts(this)


            activeChoice=this.Architecture;
            activeVariantPorts=activeChoice.Ports;
            ports=systemcomposer.arch.ComponentPort.empty(numel(activeVariantPorts),0);
            cnt=1;
            for i=1:numel(activeVariantPorts)
                p=this.getPort(activeVariantPorts(i).Name);
                if~isempty(p)
                    ports(cnt)=p;
                    cnt=cnt+1;
                end
            end
        end

    end

    methods
        function owningArch=get.Architecture(this)



            owningArch=systemcomposer.arch.Architecture.empty(1,0);
            activeChoice=this.getActiveChoice;
            if~isempty(activeChoice)


                owningArch=get(activeChoice,'Architecture');
            end
        end

        function isRef=isReference(~)
            isRef=false;
        end

        function applyStereotype(this,stereotypeName)

            error('SystemArchitecture:Profile:CannotApplyStereotypeOnVariant',...
            message('SystemArchitecture:Profile:CannotApplyStereotypeOnVariant',...
            stereotypeName,this.getQualifiedName).getString)
        end

        choiceArray=addChoice(this,nameArray,labelArray);
        setCondition(this,choice,expr);
        setActiveChoice(this,choice);
        compList=getChoices(this);
        comp=getActiveChoice(this);
        expr=getCondition(this,choice);
    end

    methods(Access='private')
        function comp=getComponentWrapper(this,compImpl)
            comp=systemcomposer.internal.getWrapperForImpl(compImpl,'');
        end

        function b=isChoiceWithinVariant(this,choice)
            children=this.getChoices;
            b=isa(choice,'systemcomposer.arch.BaseComponent');
            if b
                for child=children
                    if isequal(child.UUID,choice.UUID)
                        comp=child;
                        break;
                    end
                end
                b=~isempty(comp);
            end
        end
    end
end
