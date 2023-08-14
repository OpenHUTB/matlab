function assignObjId(hThis)







    myId=uint32(rand()*intmax('uint32'));
    hThis.ObjId=sprintf('%s.%s',class(hThis),num2str(myId));

