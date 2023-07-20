classdef ScatteringParameters<rf.internal.netparams.AllParameters

    properties(SetAccess=protected)
Impedance
    end


    properties(Constant,Access=protected)
        CanAcceptImpedanceInput=true
    end


    methods
        function obj=ScatteringParameters(varargin)
            obj=obj@rf.internal.netparams.AllParameters(varargin{:});
        end
    end


    methods
        function obj=set.Impedance(obj,newZ0)
            rf.internal.checkz0(newZ0)
            obj.Impedance=newZ0;
        end
    end


    methods(Access=protected)
        function plist1=buildScalarPropertyList(obj)
            plist1=buildScalarPropertyList@rf.internal.netparams.AllParameters(obj);
            plist1.Impedance=obj.Impedance;
        end
    end
    methods(Access=protected,Static)
        function plist1=buildNonScalarPropertyList
            plist1=buildNonScalarPropertyList@rf.internal.netparams.AllParameters;
            plist1{end+1}='Impedance';
        end
    end


    methods(Access=protected)
        function obj=assignProperties(obj,varargin)
            obj=assignProperties@rf.internal.netparams.AllParameters(obj,varargin{:});
            obj.Impedance=varargin{3};
        end
    end


    methods(Abstract,Static,Access=protected)
        outdata=me2s(indata)
    end


    methods(Access=protected)
        function z0=getDefaultInputImpedance(obj)
            z0=obj.Impedance;
        end
        function outobj=convertImpedance(inobj,newZ0)
            outobj=inobj;
            origZ0=inobj.Impedance;
            if origZ0~=newZ0
                outdata=inobj.me2s(inobj.Parameters);
                outdata=s2s(outdata,origZ0,newZ0);
                outobj=sparameters(outdata,inobj.Frequencies,newZ0);
            end
        end
    end
end