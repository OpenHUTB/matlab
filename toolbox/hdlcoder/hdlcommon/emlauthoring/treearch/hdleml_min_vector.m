%#codegen
function y=hdleml_min_vector(varargin)








    coder.allowpcode('plain')

    if nargin==1

        u=varargin{1};
        inputLen=length(u);
        outLen=ceil(inputLen/2);
        numOps=floor(inputLen/2);

        y=hdleml_define_len(u,outLen);


        for ii=coder.unroll(1:numOps)
            if(u(ii*2-1)<=u(ii*2))
                y(ii)=u(ii*2-1);
            else
                y(ii)=u(ii*2);
            end
        end


        inputLenOdd=(mod(inputLen,2)==1);
        if inputLenOdd
            y(end)=u(end);
        end

    else

        inputLen=nargin;
        outLen=ceil(inputLen/2);
        numOps=floor(inputLen/2);

        y=hdleml_define_len(varargin{1},outLen);


        for ii=coder.unroll(1:numOps)
            if(varargin{ii*2-1}<=varargin{ii*2})
                y(ii)=varargin{ii*2-1};
            else
                y(ii)=varargin{ii*2};
            end
        end


        inputLenOdd=(mod(inputLen,2)==1);
        if inputLenOdd
            y(end)=varargin{end};
        end

    end

