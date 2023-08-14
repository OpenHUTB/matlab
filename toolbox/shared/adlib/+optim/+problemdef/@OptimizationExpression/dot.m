function c=dot(a,b,dim)

















    if ishypervector(a)&&ishypervector(b)&&nargin<3


        if numel(a)~=numel(b)
            error(message('MATLAB:dot:InputSizeMismatch'));
        end



        a=subsref(a,substruct('()',{':'}));
        b=subsref(b,substruct('()',{':'}));
        c=a'*b;
        return;
    end


    if any(size(a)~=size(b))


        error(message('MATLAB:dot:InputSizeMismatch'));
    end


    if nargin==2
        c=sum(a.*b);
    else

        c=sum(a.*b,dim);
    end

end

function isHV=ishypervector(x)
    numNonSingularDim=sum(size(x)~=1);
    isHV=numNonSingularDim<2;
end