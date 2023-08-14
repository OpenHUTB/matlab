






classdef DataSet<legacycode.lct.util.IdObjectSet


    properties(Hidden,Constant)

        SetKind=containers.Map(...
        [legacycode.lct.spec.Common.Roles(1:5),{'Arg'}],...
        {1,2,3,4,5,6}...
        )
    end


    properties(Hidden,Dependent,SetAccess=protected)

NumArgs
Input
Output
DWork
Parameter
Arg
    end


    properties(GetAccess=protected,SetAccess=protected)
Kind
    end


    methods




        function this=DataSet(setKind)
            narginchk(1,1);
            setKind=validatestring(setKind,legacycode.lct.spec.DataSet.SetKind.keys(),1);
            this@legacycode.lct.util.IdObjectSet();
            this.Kind=this.SetKind(setKind);
        end



        function val=get.Output(this)
            assert(this.Kind==this.SetKind('Output'));
            val=this.Items;
        end
        function val=get.Input(this)
            assert(this.Kind==this.SetKind('Input'));
            val=this.Items;
        end
        function val=get.Parameter(this)
            assert(this.Kind==this.SetKind('Parameter'));
            val=this.Items;
        end
        function val=get.DWork(this)
            assert(this.Kind==this.SetKind('DWork'));
            val=this.Items;
        end
        function val=get.Arg(this)
            assert(this.Kind==this.SetKind('Arg'));
            val=this.Items;
        end
        function val=get.NumArgs(this)
            assert(this.Kind==this.SetKind('Arg'));
            val=this.Numel;
        end
    end
end
