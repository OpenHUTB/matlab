classdef(Abstract)IFilterable<handle


%#codegen

    properties(Abstract)


NativeDataType

DataFieldName


CustomConverterPlugIn
    end

    methods
        addInputFilter(obj,filter,options);


        removeInputFilter(obj,filter);

        addOutputFilter(obj,filter,options);


        removeOutputFilter(obj,filter);


        tuneInputFilter(obj,options);


        tuneOutputFilter(obj,options);

        [inputFilters,inputFilterOptions]=getInputFilters(obj);

        [outputFilters,outputFilterOptions]=getOutputFilters(obj);

        data=readRaw(obj,numBytes);


        function obj=IFilterable
            coder.allowpcode('plain');
        end
    end
end

