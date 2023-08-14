function[port,portpath]=findioport(this,blk,varargin)










    port='';
    portpath='';
    sdepth=1;

    if isempty(varargin)
        targetblk='built-in/Inport';
        targetprop='Port';
    else
        targetblk=varargin{1};
        targetprop='Name';
    end



    while sdepth<=2
        blkpath=findblksrc(blk);

        if isempty(blkpath)

            break;
        elseif strcmpi(hdlgetblocklibpath(blkpath),targetblk)
            port=get_param(blkpath,targetprop);
            portpath=blkpath;
            break;
        else
            blk=blkpath;
            sdepth=sdepth+1;
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






