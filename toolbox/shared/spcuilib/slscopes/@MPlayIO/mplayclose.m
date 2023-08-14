function mplayclose(blk)







    if nargin<1,blk=gcbh;end


    ioObj=get_param(blk,'userdata');


    isValid=~isempty(ioObj)&&isvalid(ioObj.hMPlay);
    if isValid
        ioObj.hMPlay.close;
    end


