



classdef ExprInfo


    properties
        Kind char='e'
        Txt char=''
        Val int32
        Radix char=''
        Id uint32=0
    end


    methods




        function this=ExprInfo(kind,txt,val,radix,id)


            narginchk(1,5);
            validatestring(kind,{'e','i','d','s','n','v'},1);

            this.Kind=kind;


            if nargin>1
                this.Txt=txt;
                if nargin>2
                    this.Val=val;
                    if nargin>3
                        this.Radix=radix;
                        if nargin>4
                            this.Id=id;
                        end
                    end
                end
            end
        end


        function val=isExpression(this)
            val=this.Kind=='e';
        end

        function val=isInteger(this)
            val=this.Kind=='i';
        end

        function val=isDouble(this)
            val=this.Kind=='d';
        end

        function val=isSizeFcn(this)
            val=this.Kind=='s';
        end

        function val=isNumelFcn(this)
            val=this.Kind=='n';
        end

        function val=isParameterVal(this)
            val=this.Kind=='v';
        end

        function tf=eq(obj1,obj2)
            tf=true;
            if numel(obj1)~=numel(obj2)
                tf=false;
                return
            end

            for ii=1:numel(obj1)
                if~isequal(obj1(ii).Kind,obj2(ii).Kind)
                    tf=false;
                    return
                end
                if~isequal(obj1(ii).Txt,obj2(ii).Txt)
                    tf=false;
                    return
                end
                if~isequal(obj1(ii).Val,obj2(ii).Val)
                    tf=false;
                    return
                end
                if~isequal(obj1(ii).Radix,obj2(ii).Radix)
                    tf=false;
                    return
                end
                if~isequal(obj1(ii).Id,obj2(ii).Id)
                    tf=false;
                    return
                end
            end
        end
    end
end
