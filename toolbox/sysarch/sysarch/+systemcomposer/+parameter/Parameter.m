classdef Parameter<handle




    properties
Name
    end

    properties(Dependent=true)
Value
    end

    properties(Hidden,Dependent=true)
isPromoted
isDefaultValue
Context
    end

    properties(Dependent=true,SetAccess=private)
Owner
Unit
    end

    methods

        function set.Name(this,name)

        end
        function owner=get.Owner(this)
            owner=[];
            if this.Owner.isvalid
                owner=this.Owner;
            end
        end

        function val=get.Value(this)
            val='';
            if this.isValid
                val=this.Owner.getParameterValue(this.Name);
            end
        end

        function set.Value(this,newVal)
            if this.isValid
                this.Owner.setParameterValue(this.Name,string(newVal));
            end
        end

        function unit=get.Unit(this)
            unit='';
            if this.isValid
                [~,unit]=this.Owner.getParameterValue(this.Name);
            end
        end

        function ctx=get.Context(this)
            ctx='';
            if this.isValid
                ctx=this.Owner.getImpl.getQualifiedName;
            end
        end

        function flag=get.isPromoted(this)
            flag=false;
            if this.isValid
                arch=this.Owner;
                if isa(this.Owner,'systemcomposer.arch.BaseComponent')
                    arch=this.Owner.Architecture;
                end
                flag=arch.getImpl.isPromotedParameter(this.Name);
            end
        end

        function flag=get.isDefaultValue(this)
            flag=false;
            if this.isValid
                [~,~,flag]=this.Owner.getParameterValue(this.Name);
            end
        end



        function resetToDefault(this)
            if~this.isDefaultValue
                this.Owner.resetParameterToDefault(this.Name);
            end
        end

        function destroy(this)
            if this.isValid
                if isa(this.Owner,'systemcomposer.arch.BaseComponent')
                    error('systemcomposer:Parameter:CannotDeleteOnComponent',message(...
                    'SystemArchitecture:Parameter:CannotDeleteOnComponent').getString);
                else
                    if this.isPromoted
                        promotedInstImpl=this.Owner.getImpl.getComponentPromotedFrom(this.Name);
                        prmName=strrep(this.Name,[promotedInstImpl.getName,'.'],'');
                        this.Owner.unexposeParameter("Path",promotedInstImpl.getQualifiedName,"Parameters",prmName);
                    else
                        this.Owner.removeParameter(this.Name);
                    end
                end
            end
        end

        function valid=isValid(this)
            valid=~isempty(this.Owner)&&this.Owner.getImpl.hasParameter(this.Name);
        end
    end

    methods(Static,Access={?systemcomposer.arch.Architecture,?systemcomposer.arch.BaseComponent})
        function parameter=wrapper(owningElem,name)



            assert(isa(owningElem,'systemcomposer.arch.Architecture')||isa(owningElem,'systemcomposer.arch.BaseComponent'));
            parameter=systemcomposer.parameter.Parameter(owningElem,name);
        end
    end

    methods(Access=private)
        function this=Parameter(owner,name)



            this.Owner=owner;
            this.Name=name;
        end
    end

end
