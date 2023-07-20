classdef ProtectedModelBehavior<systemcomposer.internal.validator.ModelBehavior


    methods

        function this=ProtectedModelBehavior(handleOrPath)
            this=this@systemcomposer.internal.validator.ModelBehavior(handleOrPath);
        end

        function[canConvert,allowed]=canAddVariant(this)
            [canConvert,allowed]=checkProtectedModelCompatibility(this);
        end

        function[canConvert,allowed]=canInline(this)
            [canConvert,allowed]=checkProtectedModelCompatibility(this);
        end
    end

    methods(Access=private)
        function[canConvert,allowed]=checkProtectedModelCompatibility(this)
            canConvert=true;
            allowed=true;

            try
                refName=systemcomposer.internal.getReferenceName(this.handleOrPath);
                resolvedFile=Simulink.loadsave.resolveFile(refName);
                [~,~,extension]=fileparts(resolvedFile);
                if extension==".slxp"
                    Simulink.ModelReference.ProtectedModel.getOptions(resolvedFile,'runAllConsistencyChecks');
                end
            catch
                canConvert=false;
                allowed=false;
            end
        end
    end
end

