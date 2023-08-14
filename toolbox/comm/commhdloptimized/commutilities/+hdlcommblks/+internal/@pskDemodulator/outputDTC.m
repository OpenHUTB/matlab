function outputDTC(this,hN,decision,outsig)






    if isa(outsig.Type,'hdlcoder.tp_array')
        if isa(outsig.Type.BaseType,'hdlcoder.tp_boolean')
            sliceT=hN.getType('Boolean');
        else
            sliceT=hN.getType('FixedPoint','Signed',0,...
            'WordLength',1,'FractionLength',0);
        end

        loopl=outsig.Type.Dimensions;
        sliceVecT=hN.getType('Array','BaseType',sliceT,'Dimensions',double(loopl));
        sliceVec=hN.addSignal2('Name',[outsig.Name,'_vector'],'Type',sliceVecT);

        for ii=1:loopl
            slice(ii)=hN.addSignal2('Name',[outsig.Name,'_part',num2str(ii-1)],'Type',sliceT);
            slicebit=loopl-ii;
            pirelab.getBitSliceComp(hN,decision,slice(ii),slicebit,slicebit);
        end

        pirelab.getMuxComp(hN,slice,sliceVec);


        pirelab.getDTCComp(hN,sliceVec,outsig,'Floor','Wrap');

    else
        pirelab.getDTCComp(hN,decision,outsig,'Floor','Wrap');
    end



end
