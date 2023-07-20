function[sections_arch,scaled_input]=emit_scaleinput(this,sections_arch,current_input,section)





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    scales=this.ScaleValues;
    rmode=this.Roundmode;
    productrounding=rmode;
    omode=this.Overflowmode;
    productsaturation=omode;
    numcoeffall=hdlgetallfromsltype(this.numcoeffSLtype);
    coeffsvsize=numcoeffall.size;
    coeffssigned=numcoeffall.signed;

    scaleall=hdlgetallfromsltype(this.scaleSLtype);
    scalebp=scaleall.bp;
    scalevtype=scaleall.vtype;
    scalesltype=scaleall.sltype;

    cplxty_scaleconst=any(imag(scales(section)));
    [uname,scaleconstant]=hdlnewsignal(['scaleconst',num2str(section)],'filter',-1,cplxty_scaleconst,0,...
    scalevtype,scalesltype);
    if emitMode
        if cplxty_scaleconst
            value=hdlconstantvalue(real(scales(section)),coeffsvsize,scalebp,coeffssigned);
            sections_arch.constants=[sections_arch.constants,makehdlconstantdecl(scaleconstant,value)];
            value=hdlconstantvalue(imag(scales(section)),coeffsvsize,scalebp,coeffssigned);
            sections_arch.constants=[sections_arch.constants,makehdlconstantdecl(hdlsignalimag(scaleconstant),value)];
        else
            value=hdlconstantvalue(scales(section),coeffsvsize,scalebp,coeffssigned);
            sections_arch.constants=[sections_arch.constants,makehdlconstantdecl(scaleconstant,value)];
        end
    else
        pirelab.getConstComp(hN,scaleconstant,scales(section));
    end

    mcand_input=current_input;

    [scaleResultProdSLType,scaleResultSumSLType]=this.getScaleSLTypes;

    [sz,sbp,ssgn]=hdlgetsizesfromtype(scaleResultProdSLType);
    [scaleresultvtype,scaleresultsltype]=hdlgettypesfromsizes(sz,sbp,ssgn);
    [scaled_input,tempbody,tempsignals,moresignals]=hdlcoeffmultiply(mcand_input,...
    scales(section),...
    scaleconstant,...
    ['scale',num2str(section)],...
    scaleresultvtype,scaleresultsltype,...
    productrounding,productsaturation,scaleResultSumSLType);

    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
    sections_arch.signals=[sections_arch.signals,tempsignals,moresignals];




