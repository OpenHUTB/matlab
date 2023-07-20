function[totallutsize,lutsizedisp]=getLUTSize(this,dalut,fl)





    totallutsize=0;
    alllutsizestr={};
    for ph=1:size(fl.effective_polycoeffs,1)
        [lutsize,lutsizestr]=getLUTSizeforDApart(this,dalut(ph,:),fl.effective_polycoeffs(ph,:));
        totallutsize=totallutsize+lutsize;
        alllutsizestr=[alllutsizestr,lutsizestr];
    end
    lutsizedisp=uniquifyLUTDetails(this,alllutsizestr);

