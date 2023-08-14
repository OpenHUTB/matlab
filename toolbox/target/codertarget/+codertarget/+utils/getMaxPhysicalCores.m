function maxCores=getMaxPhysicalCores()



    LASTN=maxNumCompThreads('automatic');
    maxCores=maxNumCompThreads;
    maxNumCompThreads(LASTN);
end