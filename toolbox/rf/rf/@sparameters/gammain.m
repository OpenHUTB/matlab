function result=gammain(sobj,varargin)




    narginchk(1,2)

    result=gammain(sobj.Parameters,sobj.Impedance,varargin{:});