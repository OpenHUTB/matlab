function hf=updateSectionInfo(~,hf,hC,arith)













    isdf1sos=strcmpi(class(hf),'hdlfilter.df1sos');

    if~strcmpi(arith,'double')


        if~isa(hC,'hdlcoder.sysobj_comp')

            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');

            switch block.FilterSource
            case 'Filter object'
                sysObj=clone(block.UserData.filter);
                stageInputMode=sysObj.SectionInputDataType;
                stageOutputMode=sysObj.SectionOutputDataType;
            otherwise
                stageInputMode=block.stageInputMode;
                stageOutputMode=block.stageOutputMode;
            end

            dataTypes=getCompiledFixedPointInfo(block.getFullName());

        else

            sysObj=hC.getSysObjImpl;
            stageInputMode=sysObj.SectionInputDataType;
            stageOutputMode=sysObj.SectionOutputDataType;
            dataTypes=getCompiledFixedPointInfo(sysObj);

        end


        if strcmpi(stageInputMode,'Slope and bias scaling')||strcmpi(stageOutputMode,'Slope and bias scaling')
            error(message('hdlcoder:validate:unsupportedslopebias'));
        else
            secInDT=dataTypes.SectionInputDataType;
            secOutDT=dataTypes.SectionOutputDataType;
        end


        if isdf1sos
            [~,hf.numstatesltype]=hdlgettypesfromsizes(secInDT.WordLength,secInDT.FractionLength,true);
            [~,hf.denstatesltype]=hdlgettypesfromsizes(secOutDT.WordLength,secOutDT.FractionLength,true);
        else
            [~,hf.sectioninputsltype]=hdlgettypesfromsizes(secInDT.WordLength,secInDT.FractionLength,true);
            [~,hf.sectionoutputsltype]=hdlgettypesfromsizes(secOutDT.WordLength,secOutDT.FractionLength,true);
        end

    else
        if isdf1sos
            hf.numstatesltype=hf.inputsltype;
            hf.denstatesltype=hf.inputsltype;
        else
            hf.sectioninputsltype=hf.inputsltype;
            hf.sectionoutputsltype=hf.inputsltype;
        end
    end

end
