
function hdlblkdelay(blockname,value)
    narginchk(2,2);
    if~isa(blockname,'handle')
        blockname=get_param(blockname,'handle');
    end

    block_kind=strrep(custom_getblocklibpath(blockname),char(10),' ');
    switch(block_kind)
    case{'hdlsllib/Lookup Tables/Cosine HDL Optimized',...
        'hdlsllib/Lookup Tables/Sine HDL Optimized',...
        'hdlsllib_helper/Sine HDL Optimized',...
        'hdlsllib_helper/Cosine HDL Optimized',...
        'hdlsllib_helper/Exp HDL Optimized',...
        'hdlsllib_helper/SinCos HDL Optimized',...
        }

        value=lower(value);


        vis=get_param(blockname,'MaskVisibilities');
        vis{end}=value;
        set_param(blockname,'MaskVisibilities',vis);


        set_param(blockname,'SimulateLUTROMDelay',value);
    otherwise
        error('Function is not applicable to this block');
    end
end

function blktag=custom_getblocklibpath(blockname)
    obj=get_param(blockname,'object');
    blktag='';

    switch(obj.blockType)
    case{'SubSystem','S-Function','M-S-Function'}
        if strcmpi(obj.LinkStatus,'resolved')
            blktag=obj.ReferenceBlock;
        end
    end
end
