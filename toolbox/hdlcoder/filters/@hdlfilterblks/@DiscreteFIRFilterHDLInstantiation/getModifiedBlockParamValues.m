function blockPVs=getModifiedBlockParamValues(this,hC)






    blockPVs={};

    hF=this.createHDLFilterObj(hC);

    if~strcmpi(hF.InputSLType,'double')&&hF.needModifyforFullPrecision

        [csize,cbp,csgn]=hdlgetsizesfromtype(hF.CoeffSLType);
        fpsets=getFullPrecisionSettings(hF);

        blockPVs={...
        'CoefDataTypeStr',['fixdt(',num2str(csgn),',',num2str(csize),',',num2str(cbp),')'],...
        'ProductDataTypeStr',['fixdt(1,',num2str(fpsets.product(1)),',',num2str(fpsets.product(2)),')']...
        ,'AccumDataTypeStr',['fixdt(1,',num2str(fpsets.accumulator(1)),',',num2str(fpsets.accumulator(2)),')']...
        ,'OutDataTypeStr',['fixdt(1,',num2str(fpsets.output(1)),',',num2str(fpsets.output(2)),')']};
        if isfield(fpsets,'tapsum')
            blockPVs=[blockPVs,...
            {'TapSumDataTypeStr',...
            ['fixdt(1,',num2str(fpsets.tapsum(1)),',',num2str(fpsets.tapsum(2)),')']}];
        end
    end

