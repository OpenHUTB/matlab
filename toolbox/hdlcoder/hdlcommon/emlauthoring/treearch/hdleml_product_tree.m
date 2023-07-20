%#codegen
function varargout=hdleml_product_tree(outtp_ex,varargin)




    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex);

    if nargin==2

        u=varargin{1};
        inputLen=length(u);
        numOps=floor(inputLen/2);


        for ii=1:numOps
            varargout{ii}=hdleml_product(u(ii*2-1),u(ii*2),outtp_ex);
        end


        inputLenOdd=(mod(inputLen,2)==1);
        if inputLenOdd
            varargout{numOps+1}=u(end);
        end
    elseif nargin==3

        varargout{1}=hdleml_product(varargin{1},varargin{2},outtp_ex);
    end
