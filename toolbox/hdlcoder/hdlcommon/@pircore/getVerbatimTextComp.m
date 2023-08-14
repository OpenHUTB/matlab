
function vComp=getVerbatimTextComp(hN,hC,base_text)
    vComp=hN.addComponent2('kind','verbatim_text_comp','Name',['placeholder_doc_block_',hC.Name],...
    'InputSignals',[],'OutputSignals',[],'VerbatimText',base_text);
    vComp.setPreserve(true);
    vComp.setShouldDraw(false);
    vComp.setSynthetic();
end
