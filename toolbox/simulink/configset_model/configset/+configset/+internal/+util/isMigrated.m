function out=isMigrated(cs,param)








    out=false;
    model=cs.getModel;


    if~isempty(model)&&~isequal(model,0)

        out=configset.internal.util.coderDictionaryMigrationHandler('test',model,param);





    end
