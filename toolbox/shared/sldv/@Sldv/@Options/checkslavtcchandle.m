function res=checkslavtcchandle(h)





    try
        if isa(h.sldvcc,'Sldv.ConfigComp')
            res=true;
        else
            res=false;
        end
    catch Mex %#ok<NASGU>
        res=false;
    end
