function hf=updateAccumInfo(this,hf,hC,arith)






    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    if~strcmpi(arith,'double')
        switch block.accumMode
        case 'Same as input'

            [insize,inbp]=hdlgetsizesfromtype(hf.inputsltype);
            accumsize=insize;
            if isFilterSOS(hf)
                accumbp_num=inbp;
                accumbp_den=inbp;
            else
                accumbp=inbp;
            end

        case 'Same as product output'
            if isFilterSOS(hf)

                [prodsize_num,prodbp_num]=hdlgetsizesfromtype(hf.numprodsltype);
                accumsize=prodsize_num;
                accumbp_num=prodbp_num;
                [~,prodbp_den]=hdlgetsizesfromtype(hf.denprodsltype);
                accumbp_den=prodbp_den;
            else
                [prodsize,prodbp]=hdlgetsizesfromtype(hf.productsltype);
                accumsize=prodsize;
                accumbp=prodbp;
            end

        case{'Binary point scaling'}
            accumsize=this.hdlslResolve('accumWordLength',bfp);
            if isFilterSOS(hf)
                accumbp_num=this.hdlslResolve('accumFracLength',bfp);
                accumbp_den=accumbp_num;
            else
                accumbp=this.hdlslResolve('accumFracLength',bfp);
            end

        case{'Slope and bias scaling'}

            error(message('hdlcoder:validate:unsupportedslopebias'));

        otherwise
            error(message('hdlcoder:validate:InvalidAccumMode',block.accumMode,block.Name));
        end

        if isFilterSOS(hf)
            [~,hf.numaccumsltype]=hdlgettypesfromsizes(accumsize,accumbp_num,true);
            [~,hf.denaccumsltype]=hdlgettypesfromsizes(accumsize,accumbp_den,true);
        else
            [~,hf.accumsltype]=hdlgettypesfromsizes(accumsize,accumbp,true);
        end
    else
        if isFilterSOS(hf)
            hf.numaccumsltype=hf.inputsltype;
            hf.denaccumsltype=hf.inputsltype;
        else
            hf.accumsltype=hf.inputsltype;
        end
    end

    function isSOS=isFilterSOS(hf)
        isSOS=(isa(hf,'hdlfilter.df1sos')||...
        isa(hf,'hdlfilter.df1tsos')||...
        isa(hf,'hdlfilter.df2sos')||...
        isa(hf,'hdlfilter.df2tsos'));
