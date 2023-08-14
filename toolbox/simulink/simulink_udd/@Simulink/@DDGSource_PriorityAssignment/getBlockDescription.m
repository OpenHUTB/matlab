function[descGrp,unknownBlockFound]=getBlockDescription(~,priorityMode)



    unknownBlockFound=false;

    switch priorityMode
    case 'First'
        descTxt.Name=DAStudio.message(...
        'Simulink:dialog:FirstPrioritySubsystemDescription');
        descGrp.Name='First Priority';

    case 'Last'
        descTxt.Name=DAStudio.message(...
        'Simulink:dialog:LastPrioritySubsystemDescription');
        descGrp.Name='Last Priority';

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