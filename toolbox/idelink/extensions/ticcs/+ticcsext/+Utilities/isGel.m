function resp=isGel(filename)




    resp=0;
    if~isempty(filename)
        [fpath,fname,fext]=fileparts(filename);
        if strcmpi(fext,'.gel')
            resp=1;
        else
            resp=0;
        end
    end

