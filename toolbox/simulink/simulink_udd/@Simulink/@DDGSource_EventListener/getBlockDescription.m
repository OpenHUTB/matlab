function[descGrp,unknownBlockFound]=getBlockDescription(~)
    unknownBlockFound=false;
    descTxt.Name=DAStudio.message('Simulink:dialog:SL_DSCPT_IRTCONFIG');
    descGrp.Name='Event Listener';

    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];
end
