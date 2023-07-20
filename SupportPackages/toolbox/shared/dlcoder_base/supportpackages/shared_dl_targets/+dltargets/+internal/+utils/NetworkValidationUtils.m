classdef NetworkValidationUtils<handle




    methods(Static)


        function inputSize=convertFormattedDlarrayToCodegenSizes(dlarrayInput)



            inputFormat=dims(dlarrayInput);
            numSDims=count(inputFormat,'S');
            numUDims=count(inputFormat,'U');

            isImageInput=numSDims==2;
            hasBatchDim=contains(inputFormat,'B');
            hasSequenceDim=contains(inputFormat,'T');


            if(numSDims==1||numSDims>=3||numUDims>=1)

                error(message("dlcoder_spkg:ValidateNetwork:UnsupportedInputFormatToNetwork",inputFormat));
            end

            if hasSequenceDim
                if isImageInput

                    if~hasBatchDim

                        assert(numel(size(dlarrayInput))==4,'dlarray size does not match its format in validateNetwork');
                        inputSize=[size(dlarrayInput,1:3),1];
                    else

                        assert(numel(size(dlarrayInput))==5,'dlarray size does not match its format in validateNetwork');
                        inputSize=size(dlarrayInput,1:4);
                    end
                else

                    if~hasBatchDim

                        inputSize=[1,1,size(dlarrayInput,1),1];
                    else

                        assert(numel(size(dlarrayInput))==3,'dlarray size does not match its format in validateNetwork');
                        inputSize=[1,1,size(dlarrayInput,1:2)];
                    end
                end
            else
                if isImageInput

                    ndimsDlarray=ndims(dlarrayInput);
                    assert(ndimsDlarray>2&&ndimsDlarray<5,'dlarray size does not match its format in validateNetwork');
                    inputSize=size(dlarrayInput,1:4);
                else

                    assert(numel(size(dlarrayInput))>=2,'dlarray size does not match its format in validateNetwork');
                    inputSize=[1,1,size(dlarrayInput,1:2)];
                end
            end
        end

        function[inputSize,inputLayerFormat]=getCodegenInputSizeAndFormatBasedOnLayer(inputLayer,isLayerInDlnetwork)
            switch class(inputLayer)
            case 'nnet.cnn.layer.ImageInputLayer'
                inputLayerFormat='SSCB';
                inputSize=[inputLayer.InputSize,1];

            case 'nnet.cnn.layer.Image3DInputLayer'
                inputLayerFormat='SSSCB';
                inputSize=[inputLayer.InputSize,1];

            case 'nnet.cnn.layer.SequenceInputLayer'
                if numel(inputLayer.InputSize)==1


                    inputLayerFormat='CBT';
                    inputSize=[1,1,inputLayer.InputSize,1];
                elseif numel(inputLayer.InputSize)==2
                    inputLayerFormat='SCBT';




                    inputSize=[inputLayer.InputSize,1];
                elseif numel(inputLayer.InputSize)==4
                    inputLayerFormat="SSSCBT";
                    inputSize=[inputLayer.InputSize,1];
                else
                    assert(numel(inputLayer.InputSize)==3);
                    inputLayerFormat='SSCBT';
                    inputSize=[inputLayer.InputSize,1];
                end
            case 'nnet.cnn.layer.FeatureInputLayer'


                inputSize=[1,1,inputLayer.InputSize,1];
                if isLayerInDlnetwork
                    inputLayerFormat='CB';
                else
                    inputLayerFormat='BC';
                end
            otherwise
                error(message("dlcoder_spkg:ValidateNetwork:UnsupportedInputLayerType",inputLayer.Name,class(inputLayer)));
            end
        end

    end

end
