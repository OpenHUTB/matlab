classdef CFIE<em.solvers.FMMSolver




    properties

        Alpha(1,1)double{mustBeGreaterThanOrEqual(Alpha,0),mustBeLessThanOrEqual(Alpha,1)}=0.5
    end

    methods
        function c=CFIE(varargin)

            c=c@em.solvers.FMMSolver(varargin{:});
            c.IEType='CFIE';
        end
    end

end

