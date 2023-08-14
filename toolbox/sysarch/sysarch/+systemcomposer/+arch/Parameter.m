classdef Parameter<handle














    properties
Name
    end

    properties(Dependent=true,Transient=true)
Value
    end

    properties(Dependent=true,Transient=true,SetAccess=private)
Type
    end

    properties(SetAccess=private)
Parent
Unit
    end

    properties(Hidden,Transient=true)

isPromoted
isDefaultValue
Context
    end

    properties(Hidden,Transient=true,Access='private')
        IsSetFromConstructor=false;
    end

    methods
        function set.Name(this,newName)
            if this.IsSetFromConstructor
                this.Name=newName;
            else
                if~this.isPromoted
                    if isa(this.Parent,'systemcomposer.arch.BaseComponent')
                        error('systemcomposer:Parameter:CannotRenameOnComponent',message(...
                        'SystemArchitecture:Parameter:CannotRenameOnComponent').getString);
                    elseif isa(this.Parent,'systemcomposer.arch.Architecture')
                        set(this.Type,'Name',newName);
                    end
                else
                    error('systemcomposer:Parameter:CannotRenamePromotedParameter',message(...
                    'SystemArchitecture:Parameter:CannotRenamePromotedParameter').getString);
                end
            end
        end

        function parent=get.Parent(this)

            parent=[];

            if this.Parent.isvalid
                parent=this.Parent;
            end

        end

        function type=get.Type(this)

            if this.isValid
                type=systemcomposer.ValueType.empty;
                if isa(this.Parent,'systemcomposer.arch.BaseComponent')
                    type=this.Parent.Architecture.getParameterDefinition(this.Name);
                elseif isa(this.Parent,'systemcomposer.arch.Architecture')
                    type=this.Parent.getParameterDefinition(this.Name);
                end
            end
        end

        function val=get.Value(this)

            val='';
            if this.isValid
                val=this.Parent.getParameterValue(this.Name);
            end
        end

        function set.Value(this,newVal)
            if this.isValid
                this.Parent.setParameterValue(this.Name,string(newVal));
            end
        end

        function unit=get.Unit(this)

            unit='';
            if this.isValid
                [~,unit]=this.Parent.getParameterValue(this.Name);
            end
        end

        function ctx=get.Context(this)
            ctx='';
            if this.isValid
                ctx=this.Parent.getImpl.getQualifiedName;
            end
        end

        function tf=get.isPromoted(this)
            tf=false;
            if this.isValid
                arch=this.Parent;
                if isa(this.Parent,'systemcomposer.arch.BaseComponent')
                    arch=this.Parent.Architecture;
                end
                tf=arch.getImpl.isPromotedParameter(this.Name);
            end
        end

        function tf=get.isDefaultValue(this)
            tf=false;
            if this.isValid
                [~,~,tf]=this.Parent.getParameterValue(this.Name);
            end
        end

        function resetToDefault(this)

            if this.isValid&&~this.isDefaultValue
                this.Parent.resetParameterToDefault(this.Name);
            end
        end

        function usg=getParameterPromotedFrom(this)

            usg=systemcomposer.arch.Parameter.empty;
            if this.isValid&&this.isPromoted
                promotedInstImpl=this.Parent.getImpl.getComponentPromotedFrom(this.Name);
                prmName=strrep(this.Name,[promotedInstImpl.getName,'.'],'');
                compWrapper=systemcomposer.internal.getWrapperForImpl(promotedInstImpl);
                usg=compWrapper.getParameter(prmName);
            end
        end

        function destroy(this)

            if this.isValid
                if isa(this.Parent,'systemcomposer.arch.BaseComponent')
                    error('systemcomposer:Parameter:CannotDeleteOnComponent',message(...
                    'SystemArchitecture:Parameter:CannotDeleteOnComponent').getString);
                else
                    if this.isPromoted
                        promotedInstImpl=this.Parent.getImpl.getComponentPromotedFrom(this.Name);
                        prmName=strrep(this.Name,[promotedInstImpl.getName,'.'],'');
                        this.Parent.unexposeParameter("Path",promotedInstImpl.getQualifiedName,"Parameters",prmName);
                    else
                        this.Parent.removeParameter(this.Name);
                    end
                end
            end
        end
    end

    methods(Hidden)
        function valid=isValid(this)
            valid=~isempty(this.Parent)&&any(ismember(this.Parent.getImpl.getParameterNames,this.Name));
            if~valid
                delete(this);
            end
        end
    end


    methods(Static,Access={?systemcomposer.arch.Architecture,?systemcomposer.arch.BaseComponent})
        function parameter=wrapper(owningElem,name)



            assert(isa(owningElem,'systemcomposer.arch.Architecture')||isa(owningElem,'systemcomposer.arch.BaseComponent'));
            parameter=systemcomposer.arch.Parameter(owningElem,name);
        end
    end

    methods(Access=private)
        function this=Parameter(owner,name)



            this.IsSetFromConstructor=true;
            this.Parent=owner;
            this.Name=name;
            this.IsSetFromConstructor=false;
        end
    end

end
