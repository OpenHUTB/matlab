function hNewC=elaborate(this,hN,hC)


    slbh=hC.SimulinkHandle;



    if~this.isMatchingBlock(slbh)
        hNewC=pirelab.getNilComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
        hC.Name,'docblock not matched this codegen setting',slbh);
        return;
    end

    dtype=get_param(slbh,'DocumentType');
    if strcmp(dtype,'Text')
        txtStr=docblock('getContent',slbh);
    else
        txtStr='';
    end

    NtwkName=hdlget_param(getfullname(slbh),'PreferredNamePrefix');
    if(isempty(NtwkName)||~ischar(NtwkName))
        NtwkName=hC.Name;
    end


    topNet=pirelab.createNewNetwork(...
    'Network',[],...
    'Name',NtwkName,...
    'InportNames',{},...
    'OutportNames',{});
    topNet.setNetworkKind('Verbatim');

    q=topNet.addComponent2('kind','verbatim_text_comp','Name',[hC.Name,'_','verbatim'],...
    'InputSignals',[],'OutputSignals',[],'VerbatimText',txtStr);
    q.setPreserve(true);
    q.setShouldDraw(false);
    q.setSynthetic();


    hN.removeComponent(hC);
    hNewC=q;
end


