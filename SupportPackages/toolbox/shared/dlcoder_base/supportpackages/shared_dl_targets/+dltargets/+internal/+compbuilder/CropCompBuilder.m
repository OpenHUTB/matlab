classdef CropCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='MWCrop2dLayer';


        compKind='customlayer';


        cppClassName='MWCrop2dLayer';


        createMethodName='createCrop2dLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.CropCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.CropCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.CropCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.CropCompBuilder.createMethodName;
        end

        function comp=convert(layer,converter,comp)

            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            comp.setIsScaleInvariant(true);

            if strcmp(layer.Mode,'centercrop')

                comp.addCreateMethodArg(int32(-1));
                comp.addCreateMethodArg(int32(-1));
                comp.addCreateMethodArg(logical(1));%#ok
            else



                comp.addCreateMethodArg(int32(layer.Location(2)-1));
                comp.addCreateMethodArg(int32(layer.Location(1)-1));
                comp.addCreateMethodArg(logical(0));%#ok % 1 based indexing
            end
        end

        function validate(layer,validator)

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

            if strcmp(validator.getTargetLib(),'arm-compute')&&(str2double(validator.dlcfg.ArmComputeVersion)<19.02)
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_arm_compute_version',class(layer),'19.02');
                validator.handleError(layer,errorMessage);
            end

        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'Mode',layer.Mode,...
            'Location',layer.Location);
        end
    end
end
