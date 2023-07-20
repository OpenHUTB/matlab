function resp=BlockManagesOwnTime(blk)




    try
        manageowntimer=get_param(blk,'manageowntimer');
        resp=(~isempty(blk)&&strcmpi(manageowntimer,'on'));
    catch me


        resp=0;
    end

