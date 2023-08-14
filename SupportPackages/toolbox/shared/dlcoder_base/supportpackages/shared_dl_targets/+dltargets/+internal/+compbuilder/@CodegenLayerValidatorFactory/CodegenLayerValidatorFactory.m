classdef(Sealed)CodegenLayerValidatorFactory




    methods

        function validator=createValidator(~,varargin)

            dlcfg=varargin{2};
            switch dlcfg.TargetLibrary
            case 'none'
                validator=coder.internal.ctarget.layerClassBuilder.CustomLayerClassValidator(varargin{:});
            otherwise
                validator=dltargets.internal.compbuilder.CodegenLayerValidator(varargin{:});
            end

        end

    end


end

