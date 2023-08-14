function result=gammaout(sobj,varargin)




    narginchk(1,2)

    result=gammaout(sobj.Parameters,sobj.Impedance,varargin{:});