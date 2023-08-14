classdef CustomLayer<handle




    properties

        Name='';


        Layer='';


        Model='';

    end

    methods

        function obj=CustomLayer(varargin)

            p=inputParser;
            addParameter(p,'Name','',@(x)(ischar(x)||isstring(x))&&~isempty(x));
            addParameter(p,'Layer',[]);
            addParameter(p,'Model','',@(x)(ischar(x)||isstring(x))&&~isempty(x));

            parse(p,varargin{:});

            obj.Name=p.Results.Name;
            obj.Layer=p.Results.Layer;
            obj.Model=p.Results.Model;

        end

    end

    methods(Hidden=true)

        function setModelPath(obj,path)
            obj.Model=path;
        end
    end

end
