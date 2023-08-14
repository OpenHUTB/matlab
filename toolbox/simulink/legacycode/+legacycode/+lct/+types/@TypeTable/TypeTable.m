



classdef TypeTable<legacycode.lct.types.Common&legacycode.lct.util.IdObjectSet


    properties(SetAccess=protected)
DataTypeNames
    end


    properties(Dependent,SetAccess=protected,Hidden)

NumDataTypes
DataType
    end

    properties(GetAccess=public,SetAccess=protected,Hidden)
        UseInt64 logical=false
    end


    properties
BusInfo
    end


    methods




        function this=TypeTable()




            this.DataTypeNames=this.DTNames;
            this.Ids=1:numel(this.DataTypeNames);

            for ii=1:numel(this.DataTypeNames)

                type=legacycode.lct.types.Type(ii);
                type.Name=this.NativeTypes{ii};
                type.DTName=this.DTNames{ii};
                type.DataTypeName=this.DTNames{ii};
                type.NativeType=this.NativeTypes{ii};
                type.Enum=this.Enums{ii};
                type.StorageId=type.Id;
                type.IdAliasedThruTo=type.Id;
                type.IsSigned=type.DTName(1)~='u';
                type.WordLength=this.WordLengths(ii);


                this.Items(ii)=type;
            end


            dtInfo={'int64';'uint64'};
            for ii=1:numel(dtInfo)
                type=legacycode.lct.types.Type(numel(this.Ids)+1);
                type.DTName=dtInfo{ii,1};
                type.DataTypeName=type.DTName;
                type.NativeType=[dtInfo{ii,1},'_T'];
                type.Name=type.NativeType;
                type.IsSigned=type.DTName(1)~='u';
                type.IsFixedPoint=1;
                type.WordLength=64;
                this.addType(type,true);
            end




            this.BusInfo.BusDataTypesId=[];
            this.BusInfo.OtherDataTypesId=[];
            this.BusInfo.BusElementHashTable=cell(0,2);
            this.BusInfo.DataTypeSizeTable=cell(0,1);
        end




        function val=get.NumDataTypes(this)
            val=this.Numel;
        end




        function types=get.DataType(this)
            types=this.Items;
        end




        function out=isBuiltinType(this,arg)
            type=this.getType(arg);
            out=type.isBuiltinType();
        end




        function out=isBooleanType(this,arg)
            type=this.getType(arg);
            out=type.isBooleanType();
        end




        function out=isAggregateType(this,arg)
            type=this.getType(arg);
            out=type.isAggregateType();
        end




        function out=isBusType(this,arg)
            type=this.getType(arg);
            out=type.isBusType();
        end




        function out=isStructType(this,arg)
            type=this.getType(arg);
            out=type.isStructType();
        end




        function out=isEnumType(this,arg)
            type=this.getType(arg);
            out=type.isEnumType();
        end




        function out=isFixpointType(this,arg)
            type=this.getType(arg);
            out=type.IsFixedPoint();
        end





        function out=isAliasType(this,arg)
            type=this.getType(arg);
            out=type.isAliasType();
        end





        function out=isFakeAliasType(this,arg)
            type=this.getType(arg);
            out=type.isFakeAliasType();
        end




        function type=getAliasedType(this,arg)
            type=this.getType(arg);
            if type.isAliasType()
                type=this.Items(type.IdAliasedTo);
            end
        end




        function type=getBottomAliasedType(this,arg)
            type=this.getType(arg);
            if type.isAliasType()
                type=this.Items(type.IdAliasedThruTo);
            end
        end






        function type=getTypeForDeclaration(this,arg)
            type=this.getType(arg);
            if~type.isAliasType()
                type=this.Items(type.IdAliasedThruTo);
            end
        end





        function typeName=getComplexTypeName(this,arg)
            type=this.getType(arg);
            if~this.isAggregateType(type)

                type=this.getBottomAliasedType(type);
                typeName=['c',type.Name];
            else
                typeName=type.Name;
            end
        end




        function out=isBuiltin64Bits(this,arg)
            type=this.getType(arg);
            out=(type.Id>this.NumBuiltinDataTypes)&&...
            (type.Id<=this.NumBuiltinDataTypes+2)&&...
            (type.WordLength==64);
        end



        function out=is64Bits(this,arg)
            type=this.getType(arg);
            out=this.isBuiltin64Bits(type.IdAliasedThruTo);
        end




        function val=hasVariableDimsElement(this,arg)
            val=false;
            type=this.getType(arg);


            if~type.isAggregateType()
                return
            end

            val=type.hasVariableDimsElement();
            if val
                return
            end

            for ii=1:numel(type.Elements)
                elType=this.getType(type.Elements(ii).DataTypeId);
                val=val||this.hasVariableDimsElement(elType);

                if val
                    return
                end
            end
        end




        function val=hasDynamicArrayElement(this,arg)
            val=false;
            type=this.getType(arg);


            if~type.isAggregateType()
                return
            end

            val=type.hasDynamicArrayElement();
            if val
                return
            end

            for ii=1:numel(type.Elements)
                elType=this.getType(type.Elements(ii).DataTypeId);
                val=val||this.hasDynamicArrayElement(elType);

                if val
                    return
                end
            end
        end




        dataTypeId=addNamedType(this,dataTypeName,varargin)

    end


    methods(Access=protected)





        function type=getType(this,arg)
            if isa(arg,'legacycode.lct.types.Type')
                type=arg(1);
            elseif isnumeric(arg)
                type=this.Items(arg(1));
            else
                assert(false);
            end
        end




        function typeId=addType(this,type,updateObjIds)


            this.add(type);
            this.DataTypeNames{type.Id}=type.DTName;


            if nargin==3&&updateObjIds
                type.IdAliasedThruTo=type.Id;
                type.StorageId=type.Id;
            end

            typeId=type.Id;
        end

    end
end
