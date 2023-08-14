function objHandle=getTestObject(h,objType)







    load_system('temp_rptgen_model');

    objHandle=find(slroot,'-isa',['Stateflow.',rptgen.capitalizeFirst(objType)]);
    if~isempty(objHandle)
        objHandle=objHandle(1);
    end


