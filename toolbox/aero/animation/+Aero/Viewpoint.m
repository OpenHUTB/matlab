classdef(CompatibleInexactProperties=true)Viewpoint...
    <matlab.mixin.SetGet&matlab.mixin.Copyable

    properties(Transient,SetObservable)

        Name='';

        Node={};
    end


    methods
        function h=Viewpoint(varargin)
            if~builtin('license','test','Aerospace_Toolbox')
                error(message('aero:licensing:noLicenseVP'));
            end

            if~builtin('license','checkout','Aerospace_Toolbox')
                return;
            end

        end

    end

    methods
        function set.Name(obj,value)

            obj.Name=value;
        end

    end
end