function block_type=findblocktype(h,a_string,lcounter)




    if~isempty(strfind(a_string,'ACDATA'))
        block_type='ACDATA';
    elseif~isempty(strfind(a_string,'NDATA'))
        block_type='NDATA';
    elseif~isempty(strfind(a_string,'GCOMP1'))
        block_type='GCOMP1';
    elseif~isempty(strfind(a_string,'GCOMP2'))
        block_type='GCOMP2';
    elseif~isempty(strfind(a_string,'GCOMP3'))
        block_type='GCOMP3';
    elseif~isempty(strfind(a_string,'GCOMP4'))
        block_type='GCOMP4';
    elseif~isempty(strfind(a_string,'GCOMP5'))
        block_type='GCOMP5';
    elseif~isempty(strfind(a_string,'GCOMP6'))
        block_type='GCOMP6';
    elseif~isempty(strfind(a_string,'GCOMP7'))
        block_type='GCOMP7';
    elseif~isempty(strfind(a_string,'IMTDATA'))
        block_type='IMTDATA';
    else
        error(message('rf:rfdata:data:findblocktype:missblockidentifier',lcounter));
    end