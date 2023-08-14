classdef(Sealed)Image<handle


















    properties



        File;



        Label;



        Description;







        Placement;
    end

    methods
        function set.File(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            if~ischar(v)||~isempty(v)
                validateattributes(v,{'char'},{'row'},'','File')
            end
            obj.File=v;
        end

        function set.Label(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            if~ischar(v)||~isempty(v)
                validateattributes(v,{'char'},{'row'},'','Label')
            end
            obj.Label=v;
        end

        function set.Description(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            if~ischar(v)||~isempty(v)
                validateattributes(v,{'char'},{'row'},'','Description')
            end
            obj.Description=v;
        end

        function set.Placement(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{'row'},'','Placement')
            obj.Placement=v;
        end

        function obj=Image(varargin)

            p=inputParser;
            p.addParameter('File','');
            p.addParameter('Label','');
            p.addParameter('Description','');
            p.addParameter('Placement','first');
            p.parse(varargin{:});
            results=p.Results;


            obj.File=results.File;
            obj.Label=results.Label;
            obj.Description=results.Description;
            obj.Placement=results.Placement;
        end
    end
end

