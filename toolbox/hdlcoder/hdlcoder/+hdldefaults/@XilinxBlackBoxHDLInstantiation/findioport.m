function[port,portpath]=findioport(this,blk,is_inport)









    port='';
    portpath='';
    sdepth=1;


    while sdepth<=2
        blkpath=findblksrc(blk);

        if isempty(blkpath)

            break;
        else
            blktype=hdlgetblocklibpath(blkpath);

            if is_inport&&strcmpi(blktype,'built-in/Inport')
                port=get_param(blkpath,'Port');
                portpath=blkpath;
                break;
            elseif~is_inport&&strcmpi(blktype,'xbsIndex_r4/Gateway Out')
                port=get_param(blkpath,'Name');
                portpath=blkpath;
                break;
            else
                blk=blkpath;
                sdepth=sdepth+1;
            end
        end
    end



    function blkpath=findblksrc(blk)


        blk=get_param(blk,'Object');
        blksrc=blk.getGraphicalSrc;

        if length(blksrc)==1
            blkpath=get_param(blksrc,'Parent');
        else
            blkpath='';
        end






