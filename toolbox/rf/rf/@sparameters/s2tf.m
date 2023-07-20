function tf=s2tf(sobj,varargin)




    narginchk(1,4)

    tf=s2tf(sobj.Parameters,sobj.Impedance,varargin{:});