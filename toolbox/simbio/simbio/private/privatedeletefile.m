function privatedeletefile(filename)










    recycle_status=recycle;


    recycle off;
    delete(filename);


    recycle(recycle_status);

