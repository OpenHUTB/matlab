function result=getCommentString(fName,rangeId)



    result='';

    reqs=rmiml.getReqs(fName,rangeId);
    if isempty(reqs)
        return;
    end

    if builtin('_license_checkout','Simulink_Requirements','quiet')
        disp(getString(message('Slvnv:rmiml:NoCodegenCommentsWithoutLicense')));
        return;
    end

    descriptions=cell(size(reqs));
    for i=1:numel(reqs)
        descriptions{i}=slreq.internal.getDescriptionOrDestSummary(reqs(i));
    end

    for i=1:length(descriptions)
        if i==1
            result=sprintf('*  %d. %s',i,descriptions{i});
        else
            result=sprintf('%s\n*  %d. %s',result,i,descriptions{i});
        end
    end

end


