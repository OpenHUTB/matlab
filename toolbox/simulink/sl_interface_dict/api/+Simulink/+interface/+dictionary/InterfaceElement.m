classdef(Hidden)InterfaceElement<Simulink.interface.dictionary.NamedElement




    properties(Access=private)
        Parent Simulink.interface.dictionary.PortInterface
    end

    methods(Hidden)
        function this=InterfaceElement(zcImpl,dictImpl,interface)
            this@Simulink.interface.dictionary.NamedElement(zcImpl,dictImpl);
            this.Parent=interface;
        end

        function tf=getIsStereotypableElement(this)%#ok<MANU>
            tf=true;
        end
    end

    methods
        function destroy(this)



            this.getOwner().removeElement(this.Name);
            delete(this);
        end
    end

    methods(Access=protected)
        function owner=getOwner(this)
            assert(this.Parent.isvalid(),'Invalid or deleted object.');
            owner=this.Parent;
        end
    end
end
