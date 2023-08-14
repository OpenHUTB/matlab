function outlineString=getOutlineString(this)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        outlineString=getString(message('RptgenSL:rsl_csl_sys_filter:unlicensedComponentLabel'));
        return;
    end

    if(this.minNumBlocks>0)
        iString=sprintf(getString(message('RptgenSL:rsl_csl_sys_filter:moreBlocksThanLabel')),this.minNumBlocks);
    else
        iString='';
    end

    if(this.minNumSubSystems>0)
        if isempty(iString)
            iString=sprintf(getString(message('RptgenSL:rsl_csl_sys_filter:moreSystemsThanLabel')),this.minNumSubSystems);
        else
            iString=sprintf(getString(message('RptgenSL:rsl_csl_sys_filter:andMoreSystemsThanLabel')),iString,this.minNumSubSystems);
        end
    end

    switch this.isMask
    case 'yes'
        iString=[iString,' ',getString(message('RptgenSL:rsl_csl_sys_filter:maskedLabel'))];
    case 'no'
        iString=[iString,' ',getString(message('RptgenSL:rsl_csl_sys_filter:unmaskedLabel'))];
    end

    if~isempty(iString)
        iString=[' - ',iString];
    end

    outlineString=[this.getName,iString];
