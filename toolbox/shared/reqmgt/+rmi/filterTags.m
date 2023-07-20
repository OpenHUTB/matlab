function[reqs,idx]=filterTags(reqs,filter_in,filter_out)









    if isempty(filter_in)
        deleteIdx=false(length(reqs),1);
    else
        deleteIdx=true(length(reqs),1);
    end


    for i=1:length(reqs)

        keywords=rmiut.strToCell(reqs(i).keywords);


        j=1;
        while deleteIdx(i)&&j<=length(filter_in)
            if any(strcmpi(filter_in{j},keywords))
                deleteIdx(i)=false;
            else
                j=j+1;
            end
        end


        j=1;
        while~deleteIdx(i)&&j<=length(filter_out)
            if any(strcmpi(filter_out{j},keywords))
                deleteIdx(i)=true;
            else
                j=j+1;
            end
        end
    end


    idx=~deleteIdx;


    if any(deleteIdx)
        reqs(deleteIdx)=[];
    end
end


