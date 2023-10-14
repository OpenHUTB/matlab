classdef toFCFmtLayer < nnet.layer.Layer & nnet.layer.Formattable & dnnfpga.layer.NotCustomLayer

    methods
        function layer = toFCFmtLayer( NameValueArgs )

            arguments
                NameValueArgs.Name = 'toFC';
            end

            name = NameValueArgs.Name;


            layer.Name = name;


            layer.Description = "toFCFmt layer";


            layer.Type = "toFCFmtLayer";

        end

        function Z = predict( ~, X )


            Z = X;

        end
    end
end


