classdef(Abstract,Hidden)HoleReporter<mlreportgen.report.Reporter




    properties





        HoleId{mlreportgen.report.validators.mustBeString(HoleId)}=[];
    end

    methods
        function set.HoleId(hole,holeId)
            hole.HoleId=string(holeId);
        end

        function hole=HoleReporter(varargin)
            if nargin==1
                varargin=[{'HoleId'},varargin];
            end
            hole=hole@mlreportgen.report.Reporter(varargin{:});
        end

    end

end

