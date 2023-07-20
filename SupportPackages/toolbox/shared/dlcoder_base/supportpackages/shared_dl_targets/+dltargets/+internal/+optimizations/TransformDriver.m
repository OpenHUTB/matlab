classdef TransformDriver<handle



    properties

CodegenInfo

    end

    properties(Access=private)

        transformWorklist{}

    end


    methods


        function this=TransformDriver(hN,layer2comp,networkInfo,netname,...
            codegendir,codegentarget,dlcfg,connectivity)

            this.CodegenInfo=dltargets.internal.optimizations.CodegenInfo(hN,...
            layer2comp,...
            networkInfo,...
            netname,...
            codegendir,...
            codegentarget,...
            dlcfg,...
            connectivity);

        end

    end


    methods

        function addTransform(this,transformObj)

            this.transformWorklist{end+1}=transformObj;

        end

        function runTransforms(this)

            for i=1:numel(this.transformWorklist)
                this.transformWorklist{i}.runTransform(this.CodegenInfo);
            end

        end

    end

end
