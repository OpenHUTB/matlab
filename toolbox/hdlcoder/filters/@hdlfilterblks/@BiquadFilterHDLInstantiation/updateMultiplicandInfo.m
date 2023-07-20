function hf=updateMultiplicandInfo(~,hf,hC,arith)








    if isa(hf,'hdlfilter.df1tsos')


        if~strcmpi(arith,'double')


            if~isa(hC,'hdlcoder.sysobj_comp')

                bfp=hC.SimulinkHandle;
                block=get_param(bfp,'Object');
                switch block.FilterSource
                case 'Filter object'
                    sysObj=block.UserData.filter;
                    multiplicandMode=sysObj.MultiplicandDataType;
                otherwise
                    multiplicandMode=block.multiplicandMode;
                end

                dataTypes=getCompiledFixedPointInfo(block.getFullName());

            else

                sysObj=hC.getSysObjImpl;
                multiplicandMode=sysObj.MultiplicandDataType;
                dataTypes=getCompiledFixedPointInfo(sysObj);

            end

            mDT=dataTypes.MultiplicandDataType;


            if strcmpi(multiplicandMode,'Slope and bias scaling')
                error(message('hdlcoder:validate:unsupportedslopebias'));
            else

                [~,hf.multiplicandsltype]=hdlgettypesfromsizes(mDT.WordLength,mDT.FractionLength,true);
            end

        else
            hf.multiplicandsltype=hf.inputsltype;
        end
    end

end
