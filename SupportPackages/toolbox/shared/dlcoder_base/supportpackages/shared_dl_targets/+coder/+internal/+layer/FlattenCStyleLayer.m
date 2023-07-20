%#codegen
%#internal

classdef FlattenCStyleLayer<nnet.layer.Layer&nnet.layer.Formattable



    methods
        function this=FlattenCStyleLayer(name)
            this.Name=name;
        end

        function Z=predict(~,X)
            coder.allowpcode('plain');
            fmt=dims(X);
            if coder.const(isequal(fmt,'SSSC')||isequal(fmt,'SSSCB'))


                [sz1,sz2,sz3,sz4,sz5]=size(X);
                Z=reshape(permute(stripdims(X),[4,3,2,1,5]),[1,1,1,sz1*sz2*sz3*sz4,sz5]);
                Z=dlarray(Z,fmt);
            elseif coder.const(isequal(fmt,'SC')||isequal(fmt,'SCB'))
                [sz1,sz2,sz3]=size(X);
                Z=reshape(permute(stripdims(X),[2,1,3]),[1,sz1*sz2,sz3]);
                Z=dlarray(Z,fmt);
            elseif coder.const(isequal(fmt,'CBT'))



                [sz1,sz2,sz3]=size(X);
                Z=reshape(permute(stripdims(X),[1,3,2]),[sz1*sz3,sz2]);
                Z=dlarray(Z,"CB");
            else


                [sz1,sz2,sz3,sz4]=size(X);
                Z=reshape(permute(stripdims(X),[3,2,1,4]),[1,1,sz1*sz2*sz3,sz4]);
                Z=dlarray(Z,fmt);
            end
        end
    end
end

