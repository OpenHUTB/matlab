function data=getData(this,field)




    try
        eval(['data = this.',field,';']);
    catch e %#ok<NASGU>
        data=[];
    end


