function newReqs=catReqs(reqs,srcKey,id)


    oldReqs=rmiml.getReqs(srcKey,id);
    newReqs=[oldReqs;reqs];
    rmiml.setReqs(newReqs,srcKey,id);
end