function hf=updateProdInfo(~,hf,hC,arith)







    if~strcmpi(arith,'double')


        if~isa(hC,'hdlcoder.sysobj_comp')

            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
            switch block.FilterSource
            case 'Filter object'
                sysObj=block.UserData.filter;
                prodOutputMode=sysObj.NumeratorProductDataType;
            otherwise
                prodOutputMode=block.prodOutputMode;
            end

            dataTypes=getCompiledFixedPointInfo(block.getFullName());

        else

            sysObj=hC.getSysObjImpl;
            prodOutputMode=sysObj.NumeratorProductDataType;
            dataTypes=getCompiledFixedPointInfo(sysObj);

        end

        numeratorProductDT=dataTypes.NumeratorProductDataType;
        denominatorProductDT=dataTypes.DenominatorProductDataType;

        if strcmpi(prodOutputMode,'Slope and bias scaling')
            error(message('hdlcoder:validate:unsupportedslopebias'));
        else
            prodsize=numeratorProductDT.WordLength;
            prodbp_num=numeratorProductDT.FractionLength;
            prodbp_den=denominatorProductDT.FractionLength;
        end

        [~,hf.numprodsltype]=hdlgettypesfromsizes(prodsize,prodbp_num,true);
        [~,hf.denprodsltype]=hdlgettypesfromsizes(prodsize,prodbp_den,true);

    else

        hf.numprodsltype=hf.inputsltype;
        hf.denprodsltype=hf.inputsltype;

    end

end
