



classdef Type<legacycode.lct.util.IdObject


    properties
        DTName char
        IdAliasedTo uint32=0
        IdAliasedThruTo uint32=0
        StorageId uint32=0
        Elements legacycode.lct.types.BusElement
        IsBus logical=false
        IsStruct logical=false
        IsLookupTable logical=false
        IsBreakpoint logical=false
        IsEnum logical=false
        EnumInfo legacycode.lct.types.EnumInfo
        WordLength int32=-1
        FixedExp int32=0
        FracSlope double=1
        Bias double=0
        IsSigned logical=false
        IsFixedPoint logical=false
        IsBuiltin logical=false
        HeaderFile char
        Object=[]
        Name char
        Enum char
        DataTypeName char
        NativeType char
        IsPartOfSpec logical=false
        IsOpaque logical=false
    end


    properties(Dependent,SetAccess=protected)
NumElements
HasObject
    end


    methods




        function this=Type(varargin)

            this@legacycode.lct.util.IdObject(varargin{:});
        end




        function out=isBuiltinType(this)
            out=this.Id<=legacycode.lct.types.Common.NumSLBuiltInDataTypes;
        end


        function out=get.IsBuiltin(this)
            out=this.isBuiltinType();
        end




        function out=isBooleanType(this)
            out=this.Id==legacycode.lct.types.Common.NumSLBuiltInDataTypes;
        end




        function out=isAggregateType(this)

            out=this.IsBus||this.IsStruct;
        end




        function out=isBusType(this)
            out=this.IsBus;
        end




        function out=isStructType(this)
            out=this.IsStruct;
        end




        function out=isEnumType(this)
            out=this.IsEnum;
        end




        function out=isFixpointType(this)
            out=this.IsFixedPoint;
        end





        function out=isAliasType(this)
            out=(this.Id~=this.IdAliasedThruTo)&&(this.IdAliasedTo~=0);
        end





        function out=isFakeAliasType(this)
            out=(this.Id~=this.IdAliasedThruTo)&&(this.IdAliasedTo==0);
        end




        function val=get.NumElements(this)
            val=numel(this.Elements);
        end




        function val=get.HasObject(this)
            val=~isempty(this.Object);
        end




        function val=hasVariableDimsElement(this)
            val=false;
            if~this.isAggregateType()
                return
            end
            for ii=1:numel(this.Elements)
                val=val||strcmpi(this.Elements(ii).DimensionsMode,'Variable');
            end
        end




        function val=hasDynamicArrayElement(this)
            val=false;
            if~this.isAggregateType()
                return
            end
            for ii=1:numel(this.Elements)
                val=val||this.Elements(ii).IsDynamicArray;
            end
        end
    end
end
