classdef(Sealed)PresentableValue





    properties(SetAccess=immutable)

Value
    end

    properties(Dependent,SetAccess=immutable)
IsEmpty
MatlabClass
    end

    properties

        DisplayValue=codergui.internal.undefined()



        Tags cell={}
    end

    methods
        function this=PresentableValue(value)
            this.Value=value;
        end

        function this=set.DisplayValue(this,value)
            if isa(value,'message')
                value=value.getString();
            end
            this.DisplayValue=value;
        end

        function empty=get.IsEmpty(this)
            empty=isempty(this.Value);
        end

        function mlClass=get.MatlabClass(this)
            mlClass=class(this.Value);
        end

        function structRep=toStruct(this)
            if~isscalar(this)
                structRep=cell(size(this));
                for i=1:numel(this)
                    structRep{i}=this(i).toStruct(this(i));
                end
                return
            end

            structRep.value=this.Value;
            if~codergui.internal.undefined(this.DisplayValue)
                structRep.displayValue=this.DisplayValue;
            end
            structRep.isEmpty=this.IsEmpty;
            structRep.matlabClass=this.MatlabClass;
            structRep.tags=this.Tags;
        end
    end
end
