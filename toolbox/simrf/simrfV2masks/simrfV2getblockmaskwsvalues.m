function MaskWSVal=simrfV2getblockmaskwsvalues(block)








    mwsv=get_param(block,'MaskWSVariables');
    MaskWSNames={mwsv.Name};
    MaskWSValues={mwsv.Value};
    MaskWSVal=cell2struct(MaskWSValues,MaskWSNames,2);

end