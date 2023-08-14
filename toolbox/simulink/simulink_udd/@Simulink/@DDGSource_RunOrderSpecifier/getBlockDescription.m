function[descGrp,unknownBlockFound]=getBlockDescription(~,runOrderMode)



    unknownBlockFound=false;

    switch runOrderMode
    case 'First'
        descTxt.Name=DAStudio.message(...
        'Simulink:dialog:RunFirstSubsystemDescription');
        descGrp.Name='Run First Subsystem';

    case 'Last'
        descTxt.Name=DAStudio.message(...
        'Simulink:dialog:RunLastSubsystemDescription');
        descGrp.Name='Run Last Subsystem';

    otherwise
        unknownBlockFound=true;
    end

    descTxt.Type='text';
    descTxt.WordWrap=true;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];

end
