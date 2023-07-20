function hf=updateStateInfo(~,hf,hC,arith)








    if~isa(hf,'hdlfilter.df1sos')


        if~strcmpi(arith,'double')
            if~isa(hC,'hdlcoder.sysobj_comp')

                bfp=hC.SimulinkHandle;
                block=get_param(bfp,'Object');

                switch block.FilterSource
                case 'Filter object'
                    hd=clone(block.UserData.filter);
                    memoryMode=hd.StateDataType;
                otherwise
                    memoryMode=block.memoryMode;
                end

                dataTypes=getCompiledFixedPointInfo(block.getFullName());

            else

                sysObj=hC.getSysObjImpl;
                memoryMode=sysObj.StateDataType;
                dataTypes=getCompiledFixedPointInfo(sysObj);

            end


            if strcmpi(memoryMode,'Slope and bias scaling')
                error(message('hdlcoder:validate:unsupportedslopebias'));
            else
                if isa(hf,'hdlfilter.df1tsos')
                    numStateDT=dataTypes.NumeratorStateDataType;
                    denStateDT=dataTypes.DenominatorStateDataType;
                    [~,hf.numstatesltype]=...
                    hdlgettypesfromsizes(numStateDT.WordLength,numStateDT.FractionLength,true);
                    [~,hf.denstatesltype]=...
                    hdlgettypesfromsizes(denStateDT.WordLength,denStateDT.FractionLength,true);
                else
                    stateDT=dataTypes.StateDataType;
                    [~,hf.statesltype]=hdlgettypesfromsizes(...
                    stateDT.WordLength,stateDT.FractionLength,true);
                end
            end

        else

            if isa(hf,'hdlfilter.df1tsos')
                [hf.numstatesltype,hf.denstatesltype]=deal(hf.inputsltype);
            else
                hf.statesltype=hf.inputsltype;
            end

        end
    end
end
