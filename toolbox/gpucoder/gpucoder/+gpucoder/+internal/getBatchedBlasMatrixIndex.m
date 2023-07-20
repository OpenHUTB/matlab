function matrixIdx=getBatchedBlasMatrixIndex(varargin)
%#codegen    
    coder.allowpcode('plain');
    coder.inline('always');

    j=1;
    for i=1:numel(varargin)
        if~isnumeric(varargin{i})
            break;
        end
        j=i+1;
    end

    if j==1
        matrixIdx=0;
        return;
    end

    if j==numel(varargin)+1
        matrixIdx=numel(varargin);
    else
        matrixIdx=j-1;
    end
end
