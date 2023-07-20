function result=moveReqs(src,dest)




    reqs_to_move=rmi.getReqs(src,-1,-1);
    result=length(reqs_to_move);
    rmi.catReqs(dest,reqs_to_move);
    rmi.setReqs(src,{},-1,-1);
