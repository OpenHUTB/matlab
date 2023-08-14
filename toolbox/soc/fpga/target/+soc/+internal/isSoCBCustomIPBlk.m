function[isCstmIP,internalCstmIPBlk]=isSoCBCustomIPBlk(blk)

    isCstmIP=false;
    internalCstmIPBlk='';

    dp=get_param(blk,'DialogParameters');
    if isfield(dp,'isSoCBCustomIP')&&strcmpi(get_param(blk,'isSoCBCustomIP'),'on')


        cstmIPIntBlks=libinfo(blk,'searchdepth',1);
        indx=find(strcmp({cstmIPIntBlks.ReferenceBlock},'hwcustomlib_internal/Custom IP'),1);
        if~isempty(indx)

            isCstmIP=true;
            internalCstmIPBlk=cstmIPIntBlks(indx).Block;
        end
    end
end