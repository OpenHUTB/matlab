classdef DLQuantizerSpecificationBuilder<dltargets.internal.quantization.specificationbuilder.SpecificationBuilder





    properties
Context
    end

    methods
        function obj=DLQuantizerSpecificationBuilder(context)
            obj.Context=context;
        end
        function spec=build(obj)
            spec=obj.getDefaultSpec;


            dataAdapter=dlinstrumentation.DataAdapter("ExponentScheme",obj.Context.exponentScheme);
            exponentsData=dataAdapter.computeExponents(obj.Context.instrumentationData,8);
            exponentStruct=exponentsData.exponentsData;


            spec.exponentsData=exponentStruct;
            spec.skipLayers=obj.Context.skipLayers;
            spec.quantizedDLNetwork=false;
        end
    end

end


