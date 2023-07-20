function hf=updateOutputInfo(~,hf,hC,arith)







    if strcmpi(arith,'double')

        hf.outputsltype='double';

    else


        if~isa(hC,'hdlcoder.sysobj_comp')
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
            dataTypes=getCompiledFixedPointInfo(block.getFullName());
        else

            sysObj=hC.getSysObjImpl;

            if strcmpi(sysObj.OutputDataType,'Slope and bias scaling')
                error(message('hdlcoder:validate:unsupportedslopebias'));
            else
                dataTypes=getCompiledFixedPointInfo(sysObj);
            end

        end


        outputDT=dataTypes.OutputDataType;

        [~,hf.outputsltype]=hdlgettypesfromsizes(...
        outputDT.WordLength,outputDT.FractionLength,true);

    end

end
