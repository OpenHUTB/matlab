classdef SwishLayer<nnet.layer.Layer


%#codegen  



    methods
        function layer=SwishLayer(name)
            coder.allowpcode('plain');
            layer.Name=name;
            layer.Description=getString(message('nnet_cnn:layer:SwishLayer:OneLineDisplay'),matlab.internal.i18n.locale('en_US'));
            layer.Type=getString(message('nnet_cnn:layer:SwishLayer:Type'),matlab.internal.i18n.locale('en_US'));
        end

        function Z=predict(~,X)


            coder.dnn.elementwise();
            Z=X.*1./(1+exp(-X));
        end

    end

    methods(Static)
        function this_cg=matlabCodegenToRedirected(this)


            this_cg=nnet.internal.cnn.coder.layer.SwishLayer(this.Name);
        end

        function this=matlabCodegenFromRedirected(this_cg)


            this=nnet.cnn.layer.SwishLayer(this_cg.Name);
        end
    end

end