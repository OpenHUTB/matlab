function ct=findComponentTypes(libH)






    ctNodes=find(libH,'-depth',1,'-isa','RptgenML.LibraryCategory');
    ct=sort(get(ctNodes,'Name'));

