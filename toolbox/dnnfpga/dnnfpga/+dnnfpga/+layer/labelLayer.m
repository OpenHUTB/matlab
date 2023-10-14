classdef labelLayer < nnet.layer.Layer & nnet.layer.Formattable & dnnfpga.layer.NotCustomLayer


    methods
        function layer = labelLayer( NameValueArgs )



            arguments
                NameValueArgs.Name = 'label';
            end

            name = NameValueArgs.Name;


            layer.Name = name;


            layer.Description = "label layer";


            layer.Type = "LabelLayer";

        end

        function Z = predict( layer, X )


            Z = X;

        end
    end
end


