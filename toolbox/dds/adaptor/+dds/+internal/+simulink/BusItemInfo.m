classdef BusItemInfo










    properties

        Type=''



        PropName=''




        PrimitiveType=''


        IsVarLen=false



        VarLenCategory=''





        VarLenElem=''



        OrigType=dds.datamodel.types.ddstypes.AllTypesKind.UnknownType;




        TruncateAction=''
    end

    methods
        function obj=BusItemInfo(desc)
            if nargin>0
                obj=obj.fromDescription(desc);
            end
        end

        function out=isVarLenDataElement(obj)
            out=obj.IsVarLen&&strcmpi(obj.VarLenCategory,'data');
        end

        function obj=set.IsVarLen(obj,val)
            assert(islogical(val)&&isscalar(val));
            obj.IsVarLen=val;
        end

        function obj=set.PrimitiveType(obj,val)
            validatestring(lower(val),{'string','string[]','','char'});
            obj.PrimitiveType=lower(val);
        end

        function obj=set.OrigType(obj,val)
            assert(isa(val,'dds.datamodel.types.ddstypes.AllTypesKind')||isstring(val)||ischar(val));
            if isstring(val)||ischar(val)
                obj.OrigType=dds.datamodel.types.ddstypes.AllTypesKind(val);
            else
                obj.OrigType=val;
            end
        end

        function obj=set.TruncateAction(obj,val)
            validatestring(lower(val),{'warn','none',''});
            obj.TruncateAction=lower(val);
        end

        function obj=set.VarLenElem(obj,val)
            assert(ischar(val));
            obj.VarLenElem=val;
        end

        function obj=set.VarLenCategory(obj,val)
            validatestring(lower(val),{'','data','length'});
            obj.VarLenCategory=lower(val);
        end

        function desc=toDescription(obj)
            desc=jsonencode(obj);
        end

        function obj=fromDescription(obj,desc)
            objStruct=jsondecode(desc);
            fldNames=fields(objStruct);
            for i=1:numel(fldNames)
                obj.(fldNames{i})=objStruct.(fldNames{i});
            end
        end
    end

end
