classdef DefaultModificationObject<Simulink.ModelReference.Conversion.ModificationObject
    methods(Access=public)
        function this=DefaultModificationObject(description)
            this.Description=description;
        end


        function exec(this)%#ok
        end
    end
end
