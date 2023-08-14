function appendConsiderationsAndLimitations(rpt)





    import mlreportgen.dom.*


    conLimMsg=message('Simulink:VariantReducer:ElementsNotReduced');
    conLimHead=Heading1(conLimMsg.getString());
    conLimHead.Style={Bold,Color('black'),BackgroundColor('white')};
    append(rpt,conLimHead);


    appendCallbacks(rpt);


    appendChartsWithVarSFTrans(rpt);

end
