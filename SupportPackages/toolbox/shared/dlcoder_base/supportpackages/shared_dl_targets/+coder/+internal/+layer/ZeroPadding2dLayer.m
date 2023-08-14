%#codegen
%#internal

classdef ZeroPadding2dLayer<nnet.layer.Layer&nnet.layer.Formattable



    properties
Top
Bottom
Left
Right
    end

    methods
        function this=ZeroPadding2dLayer(name,top,bottom,left,right)
            this.Name=name;
            this.Top=top;
            this.Bottom=bottom;
            this.Left=left;
            this.Right=right;
        end

        function Z=predict(this,X)
            coder.allowpcode('plain');

            [H,W,C,N]=size(X);
            Z=zeros(H+this.Top+this.Bottom,W+this.Left+this.Right,C,N,'like',X);
            Z(this.Top+(1:H),this.Left+(1:W),:,:)=X;
        end
    end
end

