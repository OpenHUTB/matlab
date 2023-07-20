function className=getChipClassName(h,tgtInfo,classnameprefix)




    if isequal(tgtInfo.chipInfo.subFamily,'2804x')
        className='TMS320C280x';
    else
        className=[classnameprefix,tgtInfo.chipInfo.subFamily];
    end
