classdef constantLayer < nnet.layer.Layer & nnet.layer.Formattable & dnnfpga.layer.NotCustomLayer

    properties
        Value
    end

    methods
        function layer = constantLayer( NameValueArgs )


            arguments
                NameValueArgs.Name = 'constant';
                NameValueArgs.Value = 0;
            end

            name = NameValueArgs.Name;
            layer.Value = NameValueArgs.Value;


            layer.Name = name;


            layer.Description = "constant layer";


            layer.Type = "ConstantLayer";

        end

        function Z = predict( ~, X )
            Z = cast( zeros( size( X ) ), 'like', X );
            Z = dlarray( Z );
        end
    end
end


