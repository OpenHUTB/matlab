function result=permuteReqs(obj,indices)




    reqs=rmi.getReqs(obj);


    reqs=reqs(indices);


    rmi.setReqs(obj,reqs,1,length(reqs));

    result=reqs;
end
