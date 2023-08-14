function hf=updateProdInfo(this,hf,hC,arith)






    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    if~strcmpi(arith,'double')
        switch block.prodOutputMode
        case 'Same as input'

            [insize,inbp]=hdlgetsizesfromtype(hf.inputsltype);
            prodsize=insize;
            if isFilterSOS(hf)
                prodbp_num=inbp;
                prodbp_den=inbp;
            else
                prodbp=inbp;
            end

        case{'Binary point scaling'}
            prodsize=this.hdlslResolve('prodOutputWordLength',bfp);
            if isFilterSOS(hf)
                prodbp_num=this.hdlslResolve('prodOutputFracLength',bfp);
                prodbp_den=prodbp_num;
            else
                prodbp=this.hdlslResolve('prodOutputFracLength',bfp);
            end

        case{'Slope and bias scaling'}

            error(message('hdlcoder:validate:unsupportedslopebias'));

        otherwise
            error(message('hdlcoder:validate:InvalidProdOutputMode',block.productOutputMode,block.Name));
        end

        if isFilterSOS(hf)
            [~,hf.numprodsltype]=hdlgettypesfromsizes(prodsize,prodbp_num,true);
            [~,hf.denprodsltype]=hdlgettypesfromsizes(prodsize,prodbp_den,true);
        else
            [~,hf.productsltype]=hdlgettypesfromsizes(prodsize,prodbp,true);
        end
    else
        if isFilterSOS(hf)
            hf.numprodsltype=hf.inputsltype;
            hf.denprodsltype=hf.inputsltype;
        else
            hf.productsltype=hf.inputsltype;
        end
    end

    function isSOS=isFilterSOS(hf)
        isSOS=(isa(hf,'hdlfilter.df1sos')||...
        isa(hf,'hdlfilter.df1tsos')||...
        isa(hf,'hdlfilter.df2sos')||...
        isa(hf,'hdlfilter.df2tsos'));
