function result=isDerived(Obj)




    id=Obj.id;


    result=(id==0);
    if~result
        result=cv('get',id,'testdata.isDerived');
    end;
