
%#codegen
function data=f2f_overflow_logger(idx)
    coder.inline('never');
    coder.allowpcode('plain');

    persistent pCounts pSequence
    if isempty(pCounts)
        coder.varsize('pCounts','pSequence',[1,inf]);
        pCounts=zeros(1,1,'uint32');
        pSequence=uint32([]);
    end

    if nargin==1
        if idx>numel(pCounts)
            pCounts=[pCounts,repmat(uint32(0),1,idx-numel(pCounts))];
        end

        pCounts(idx)=pCounts(idx)+1;
        if numel(pSequence)<1000
            pSequence=[pSequence,idx];
        end
    end

    if nargout==1


        data=pCounts;
        pCounts=uint32(0);
        pSequence=uint32([]);
    end
end
