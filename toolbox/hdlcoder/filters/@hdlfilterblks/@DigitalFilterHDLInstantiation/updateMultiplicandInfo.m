function hf=updateMultiplicandInfo(this,hf,hC,arith)









    if isFilterdf1tSOS(hf)
        isSysObj=isa(hC,'hdlcoder.sysobj_comp');
        if~isSysObj
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
            multiplicandMode=block.multiplicandMode;
        else
            sysObjHandle=hC.getSysObjImpl;
            if isFilterdf1tSOS(hf)
                multiplicandMode=sysObjHandle.MultiplicandDataType;
            end
        end

        if~strcmpi(arith,'double')
            switch multiplicandMode
            case 'Same as output'
                [outsize,outbp]=hdlgetsizesfromtype(hf.outputsltype);
                multsize=outsize;
                multbp=outbp;

            case{'Binary point scaling','Custom'}
                if~isSysObj
                    multsize=this.hdlslResolve('multiplicandWordLength',bfp);
                    multbp=this.hdlslResolve('multiplicandFracLength',bfp);
                else
                    multDataType=sysObjHandle.CustomMultiplicandDataType;
                    multsize=multDataType.WordLength;
                    multbp=multDataType.FractionLength;
                end

            case{'Slope and bias scaling'}

                error(message('hdlcoder:validate:unsupportedslopebias'));

            otherwise
                error(message('hdlcoder:validate:InvalidMultiplicandMode',block.multiplicandMode,block.Name));
            end


            [~,hf.multiplicandsltype]=hdlgettypesfromsizes(multsize,multbp,true);
        else
            hf.multiplicandsltype=hf.inputsltype;
        end
    end

end


function isdf1tSOS=isFilterdf1tSOS(hf)
    isdf1tSOS=isa(hf,'hdlfilter.df1tsos');
end
