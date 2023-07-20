function[outputCheck]=createOutputCheckBox(source)





    outputCheck.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_MuxOut');
    outputCheck.Type='checkbox';
    outputCheck.RowSpan=[5,5];
    outputCheck.ColSpan=[1,2];
    outputCheck.ObjectProperty='OutputAsBus';
    outputCheck.Tag=outputCheck.ObjectProperty;

    outputCheck.MatlabMethod='slDialogUtil';
    outputCheck.MatlabArgs={source,'sync','%dialog','checkbox','%tag'};
end

