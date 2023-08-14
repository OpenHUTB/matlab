function result=insertReqsPrim(reqs,insertReqs,insertPoint)



    if isempty(reqs)
        result=insertReqs;
    else
        result=[reqs(1:(insertPoint-1));insertReqs(:);reqs(insertPoint:end)];
    end;


