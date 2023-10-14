classdef identityLayer < nnet.layer.Layer & nnet.layer.Formattable

    methods
        function layer = identityLayer( NameValueArgs )

            arguments
                NameValueArgs.Name = 'identity';
            end

            name = NameValueArgs.Name;

            layer.Name = name;

            layer.Description = "identity layer";

            layer.Type = "IdentityLayer";
        end

        function Z = predict( layer, X )
            Z = X;
        end
    end
end


