%#codegen




classdef InputDataPreparer


    methods(Hidden=true)
        function obj=InputDataPreparer()
            coder.allowpcode('plain');
        end
    end

    methods(Static)





        [height,width,channels,batchSize]=parseInputSize(in,inputLayerSize,callerFunction);


        checkInputsForVaryingSize(oldInputSize,newInputSize,callerFunction);



        checkInputsForVaryingFormats(oldInputFormat,newInputFormat,callerFunction)



        checkInputSize(inputdata,net_insize,isPredict);



        inputT=permuteImageInput(input,targetLib);



        paddedData=batchPadInputData(in,batchSize,paddedBatchSize,isPadded,isImageInput);
    end
end