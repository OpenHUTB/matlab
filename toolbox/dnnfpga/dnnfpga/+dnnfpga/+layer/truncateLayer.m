classdef truncateLayer < nnet.layer.Layer & nnet.layer.Formattable & dnnfpga.layer.NotCustomLayer

    properties ( Access = private )
        sz
        first = true
    end
    properties
        OutputSize
    end

    methods
        function layer = truncateLayer( outputSize, NameValueArgs )

            arguments
                outputSize{ mustBeNumeric, mustBeNonempty,  ...
                    mustBeReal, mustBeFinite, mustBeInteger, mustBePositive }
                NameValueArgs.Name = '';
            end

            name = NameValueArgs.Name;


            layer.Name = name;


            layer.Description = "truncate layer";


            layer.Type = "Truncate Layer";

            if isscalar( outputSize )
                outputSize = [ outputSize, 1, 1 ];
            end

            layer.OutputSize = outputSize;
        end

        function Z = predict( layer, X )
            if layer.first
                layer.sz = prod( layer.OutputSize );
                layer.first = false;
                if numel( X ) < layer.sz
                    msg = "In truncateLayer '%s', the output size must be less than or equal to the input size.";
                    error( msg, layer.Name );
                end
            end
            Z = X( 1:layer.sz );
            Z = reshape( Z, layer.OutputSize );
        end
    end
end


