function hf=updateTapSumInfo(this,hf,hC,arith)









    if isFilterSymAsymFIR(hf)
        if~strcmpi(arith,'double')

            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');

            switch block.tapSumMode
            case 'Same as input'

                [insize,inbp]=hdlgetsizesfromtype(hf.inputsltype);
                tapsumsize=insize;
                tapsumbp=inbp;

            case{'Binary point scaling'}
                tapsumsize=this.hdlslResolve('TapSumWordLength',bfp);
                tapsumbp=this.hdlslResolve('TapSumFracLength',bfp);

            case{'Slope and bias scaling'}

                error(message('hdlcoder:validate:unsupportedslopebias'));

            otherwise
                error(message('hdlcoder:validate:InvalidAccumMode',block.accumMode,block.Name));
            end

            [~,hf.tapsumsltype]=hdlgettypesfromsizes(tapsumsize,tapsumbp,true);
        else
            hf.tapsumsltype=hf.inputsltype;
        end
    end


    function isSymAsymFIR=isFilterSymAsymFIR(hf)
        isSymAsymFIR=isa(hf,'hdlfilter.dfsymfir')||...
        isa(hf,'hdlfilter.dfasymfir');
