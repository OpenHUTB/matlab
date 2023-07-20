function attrs=derived_mask_attributes(hBlk)








    mws=get_param(hBlk,'MaskWSVariables');
    maskValues=cell2struct({mws.Value}',{mws.Name}');


    cs=physmod.schema.internal.blockComponentSchema(hBlk);
    ctrlTable=lUpdateCtrls(maskValues,cs.defaultControls);
    i=cs.info();


    p={i.Members.Parameters.ID};
    pVis=simscape.schema.internal.visible(p,cs,ctrlTable);
    pTun=lTunable(p,maskValues);
    pTun(~pVis)=false;
    pEval=pVis;


    v={i.Members.Variables.ID};
    vVis=simscape.schema.internal.visible(v,cs,ctrlTable);
    vVis=vVis&lSpecified(v,maskValues);
    vTun=vVis;
    vEval=vVis;

    attrs=lMakeAttributes(...
    [p,v],[pVis,vVis],[pTun,vTun],[pEval,vEval]);
end

function attr=lMakeAttributes(ids,vis,tun,eval)
    attr=struct(...
    'ID',ids,...
    'Visible',lOnOff(vis),...
    'Evaluate',lOnOff(eval),...
    'Tunable',lOnOff(tun));
end

function onOff=lOnOff(val)
    onOff=repmat({'off'},size(val));
    onOff(val)={'on'};
end

function tun=lTunable(params,maskValues)
    tun=logical(cellfun(@(p)strcmp(maskValues.([p,'_conf']),'runtime'),params));
end

function spec=lSpecified(vars,maskValues)
    spec=logical(cellfun(@(v)strcmp(maskValues.([v,'_specify']),'on'),vars));
end

function ctrlTable=lUpdateCtrls(maskValues,ctrlTable)
    for idx=1:numel(ctrlTable)
        id=ctrlTable(idx).ID;
        if isfield(maskValues,id)
            ctrlTable(idx).Value=simscape.Value(maskValues.(id));
        end
    end
end