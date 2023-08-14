function hChip=getChipObj(reg,AdaptorName,device,subFamily,codeGenHook)





    try
        hChip=reg.getAdaptorInfo(AdaptorName).getChipObj(device,subFamily,codeGenHook);
    catch chipExcep
        noChipExcep=MException('ERRORHANDLER:tgtpref:NoChipFound',DAStudio.message('ERRORHANDLER:tgtpref:NoChipFound',codeGenHook,device));
        noChipExcep=addCause(noChipExcep,chipExcep);
        throw(noChipExcep);
    end

    if(isempty(hChip))
        DAStudio.error('ERRORHANDLER:tgtpref:NoChipFound',codeGenHook,device);
    end
