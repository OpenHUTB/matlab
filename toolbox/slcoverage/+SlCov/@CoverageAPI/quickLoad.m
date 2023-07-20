function data=quickLoad(filename)






    try
        data=[];
        uniqueId=getFirstUniqueIdFromFile(filename);
        if~isempty(uniqueId)
            cvd=cvdata.findCvdataByUniqueId(uniqueId);
            if~isempty(cvd)
                data{1}=cvd;
            end
        end

    catch MEx %#ok<NASGU>
        data=[];
    end
end

function uniqueId=getFirstUniqueIdFromFile(filename)
    try
        uniqueId=[];


        fid=fopen(filename,'r');
        c=onCleanup(@()fclose(fid));


        testdataFound=false;
        while~feof(fid)&&~testdataFound
            tline=fgetl(fid);
            testdataFound=contains(tline,'testdata {');
        end

        if(~testdataFound)
            return;
        end



        testdataEndReached=false;
        while~feof(fid)&&~testdataEndReached
            tline=fgetl(fid);
            uIdTokens=regexp(tline,'uniqueId\s*"(.*?)"','tokens');
            if~isempty(uIdTokens)
                uniqueId=uIdTokens{1}{1};
                return;
            end
            testdataEndReached=contains(tline,'}');
        end
    catch MEx %#ok<NASGU>
        uniqueId=[];
    end
end

