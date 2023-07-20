function hf=updateAccumInfo(~,hf,hC,arith)







    if~strcmpi(arith,'double')


        if~isa(hC,'hdlcoder.sysobj_comp')
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
            switch block.FilterSource
            case 'Filter object'


                sysObj=block.UserData.filter;
                accumMode=sysObj.NumeratorAccumulatorDataType;

            otherwise
                accumMode=block.accumMode;
            end

            dataTypes=getCompiledFixedPointInfo(block.getFullName());

        else

            sysObj=hC.getSysObjImpl;
            accumMode=sysObj.NumeratorAccumulatorDataType;
            dataTypes=getCompiledFixedPointInfo(sysObj);

        end


        numeratorAccumulatorDT=dataTypes.NumeratorAccumulatorDataType;
        denominatorAccumulatorDT=dataTypes.DenominatorAccumulatorDataType;

        if strcmpi(accumMode,'Slope and bias scaling')
            error(message('hdlcoder:validate:unsupportedslopebias'));
        else
            accumsize=numeratorAccumulatorDT.WordLength;
            accumbp_num=numeratorAccumulatorDT.FractionLength;
            accumbp_den=denominatorAccumulatorDT.FractionLength;
        end


        [~,hf.numaccumsltype]=hdlgettypesfromsizes(accumsize,accumbp_num,true);
        [~,hf.denaccumsltype]=hdlgettypesfromsizes(accumsize,accumbp_den,true);

    else

        hf.numaccumsltype=hf.inputsltype;
        hf.denaccumsltype=hf.inputsltype;

    end

end
