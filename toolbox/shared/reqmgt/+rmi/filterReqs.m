function result=filterReqs(reqs,index,count)



    if index~=-1

        reqFilter=index:(index+count-1);


        allIndices=1:length(reqs);


        indices=setdiff(allIndices,reqFilter);


        reqs=rmi.deleteReqsPrim(reqs,indices);
    end
    result=reqs;
end
