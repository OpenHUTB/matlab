function compout_sig=slicerCompares(this,hN,cmpops,derot_sig)










    compout_sig=[];
    for ii=1:numel(cmpops)
        compout_sig=[compout_sig,doCompare(this,hN,cmpops{ii},derot_sig)];
    end

end


function cmpout=doCompare(this,hN,compOp,cmpin)


    part=compOp{1};
    switch compOp{2}
    case 'gt'
        opsym='>';
    case 'lt'
        opsym='<';
    case 'eq'
        opsym='==';
    end
    op=compOp{2};
    cmpin_part=cmpin.(part);
    cmpoutT=hN.getType('Boolean');
    cmpout=hN.addSignal2('Name',[cmpin_part.Name,'_',op,'_zero'],'Type',cmpoutT);
    pirelab.getCompareToValueComp(hN,cmpin_part,cmpout,opsym,0);

end
