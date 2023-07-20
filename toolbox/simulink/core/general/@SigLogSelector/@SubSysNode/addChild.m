function child=addChild(h,blk)





    child=SigLogSelector.createSubSystem(blk);
    child.userData.displayIcon='';
    child.hParent=handle(h);


    clz=class(blk);
    switch clz
    case{'Stateflow.Chart',...
        'Stateflow.LinkChart',...
        'Stateflow.TruthTableChart',...
        'Stateflow.StateTransitionTableChart'}
        h.childNodes.insert(blk.up.Name,child);
    case 'char'
        h.childNodes.insert(blk,child);
    otherwise
        h.childNodes.insert(blk.Name,child);
    end



    if isa(h,'SigLogSelector.MdlRefNode')
        child.hMdlRefBlock=handle(h);
    else
        child.hMdlRefBlock=handle(h.hMdlRefBlock);
    end


    child.topMdlName=h.getTopModelName;

end
