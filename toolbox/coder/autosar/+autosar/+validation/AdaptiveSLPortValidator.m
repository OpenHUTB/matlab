classdef AdaptiveSLPortValidator<autosar.validation.PhasedValidator




    methods(Access=public)
        function this=AdaptiveSLPortValidator(modelHandle)
            this@autosar.validation.PhasedValidator('ModelHandle',modelHandle);
        end
    end

    methods(Access=protected)

        function verifyPostProp(this,hModel)
            assert(isscalar(hModel)&&ishandle(hModel),'hModel is not a handle');
            this.verifyRootIODataTypes(hModel);
        end

    end


    methods(Access=private)

        function verifyRootIODataTypes(this,hModel)



            mapping=autosar.api.Utils.modelMapping(hModel);
            maxShortNameLength=get_param(hModel,'AutosarMaxShortNameLength');
            supportMatrixIOAsArray=true;

            for portIdx=1:length(mapping.Inports)
                blkName=mapping.Inports(portIdx).Block;
                dataTypes=get_param(blkName,'CompiledPortDataTypes');
                this.AutosarUtilsValidator.checkDataType(blkName,dataTypes.Outport{1},maxShortNameLength,...
                supportMatrixIOAsArray);
            end
            for portIdx=1:length(mapping.Outports)
                blkName=mapping.Outports(portIdx).Block;
                dataTypes=get_param(blkName,'CompiledPortDataTypes');
                this.AutosarUtilsValidator.checkDataType(blkName,dataTypes.Inport{1},maxShortNameLength,...
                supportMatrixIOAsArray);
            end
        end
    end

end


