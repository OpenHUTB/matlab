function commsIntegerToBitVector(this,insig,outsig)








    if isa(outsig.Type.BaseType,'hdlcoder.tp_boolean'),
        sliceT=this.CurrentNetwork.getType('Boolean');
    else
        sliceT=this.CurrentNetwork.getType('FixedPoint','Signed',0,...
        'WordLength',1,'FractionLength',0);
    end

    loopl=outsig.Type.Dimensions;
    sliceVecT=this.CurrentNetwork.getType('Array','BaseType',sliceT,'Dimensions',double(loopl));
    sliceVec=this.CurrentNetwork.addSignal2('Name',[outsig.Name,'_vector'],'Type',sliceVecT);

    for ii=1:loopl,
        slice(ii)=this.CurrentNetwork.addSignal2('Name',[outsig.Name,'_part',num2str(ii-1)],'Type',sliceT);
        slicebit=loopl-ii;
        pirelab.getBitSliceComp(this.CurrentNetwork,insig,slice(ii),slicebit,slicebit);
    end

    pirelab.getMuxComp(this.CurrentNetwork,slice,sliceVec);


    pirelab.getDTCComp(this.CurrentNetwork,sliceVec,outsig,'Floor','Wrap');



