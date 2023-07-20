




function subscriptedId=constructSubscript(id,indx)
    numIndex=numel(indx);
    if numIndex==0
        subscriptedId=id;
    elseif numIndex==1
        subscriptedId=[id,'(',indx{1},')'];
    else
        subscriptedId=[id,'(',indx{1}];
        for k=2:numIndex
            subscriptedId=[subscriptedId,',',indx{k}];%#ok<AGROW>
        end
        subscriptedId=[subscriptedId,')'];
    end
end
