function hf=updateOutputInfo(this,hf,hC,arith)









    if strcmpi(arith,'double')
        hf.outputsltype='double';
    else
        isSysObj=isa(hC,'hdlcoder.sysobj_comp');
        if~isSysObj
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
            outputMode=block.outputMode;
        else
            sysObjHandle=hC.getSysObjImpl;
            outputMode=sysObjHandle.OutputDataType;
        end

        switch outputMode
        case 'Same as input'

            [insize,inbp]=hdlgetsizesfromtype(hf.inputsltype);
            outsize=insize;
            outbp=inbp;

        case 'Same as accumulator'
            if isFilterSOS(hf)
                [accumsize,accumbp]=hdlgetsizesfromtype(hf.numaccumsltype);
                outsize=accumsize;
                if isFilterdf1SOS(hf)
                    [~,accumbp]=hdlgetsizesfromtype(hf.denaccumsltype);
                end
                outbp=accumbp;
            else
                [accumsize,accumbp]=hdlgetsizesfromtype(hf.accumsltype);
                outsize=accumsize;
                outbp=accumbp;
            end

        case{'Binary point scaling','Custom'}
            if~isSysObj
                outsize=this.hdlslResolve('outputWordLength',bfp);
                outbp=this.hdlslResolve('outputFracLength',bfp);
            else
                outDataType=sysObjHandle.CustomOutputDataType;
                outsize=outDataType.WordLength;
                outbp=outDataType.FractionLength;
            end

        case{'Slope and bias scaling'}

            error(message('hdlcoder:validate:unsupportedslopebias'));

        otherwise
            error(message('hdlcoder:validate:InvalidOutputMode',block.outputMode,block.Name));
        end


        [~,hf.outputsltype]=hdlgettypesfromsizes(outsize,outbp,true);
    end



    function isdf1SOS=isFilterdf1SOS(hf)

        isdf1SOS=isa(hf,'hdlfilter.df1sos');


        function isSOS=isFilterSOS(hf)
            isSOS=(isa(hf,'hdlfilter.df1sos')||...
            isa(hf,'hdlfilter.df1tsos')||...
            isa(hf,'hdlfilter.df2sos')||...
            isa(hf,'hdlfilter.df2tsos'));


