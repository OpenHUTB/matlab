function res=isopen(h,filename)




    filename=convertStringsToChars(filename);


    try

        [fpath,fname]=fileparts(filename);


        openProjs=list(h,'project');
        numOpenProjs=numel(openProjs);
        isopenFlag=zeros(numOpenProjs,1);


        for k=1:numOpenProjs
            [fpathN,fnameN]=fileparts(openProjs(k).name);
            if(isempty(fpath)||strcmpi(fpath,fpathN))&&strcmpi(fname,fnameN)
                isopenFlag(k)=1;
            else
                isopenFlag(k)=0;
            end
        end


        res=any(isopenFlag);

    catch

        res=false;

    end

