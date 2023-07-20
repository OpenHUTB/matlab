



classdef DimInfo


    properties
        Val int32=-1
        Expr char
        Info legacycode.lct.spec.ExprInfo
        IsInf logical=false
    end


    properties(Hidden)

        Pos int32=0
    end


    properties(Dependent,SetAccess=protected)
        HasInfo logical
    end


    methods


        function val=get.HasInfo(this)
            val=~isempty(this.Info);
        end

        function tf=eq(obj1,obj2)
            tf=true;
            if numel(obj1)~=numel(obj2)
                tf=false;
                return
            end
            for ii=1:numel(obj1)
                if~isequal(obj1(ii).Val,obj2(ii).Val)
                    tf=false;
                    return
                end
                if~isequal(obj1(ii).IsInf,obj2(ii).IsInf)
                    tf=false;
                    return
                end
                if~isequal(obj1(ii).Expr,obj2(ii).Expr)
                    tf=false;
                    return
                end
                if~isequal(obj1(ii).HasInfo,obj2(ii).HasInfo)
                    tf=false;
                    return
                end
                if numel(obj1(ii).Info)~=numel(obj2(ii).Info)
                    tf=false;
                    return
                end
                if~(obj1(ii).Info==obj2(ii).Info)
                    tf=false;
                    return
                end
            end
        end
    end
end
