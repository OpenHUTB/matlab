function[retStatus,schema]=Render(hThis,schema)












    retStatus=true;

    innerBox=[];
    [retStatus,innerBox]=hThis.Items(1,1).Render(innerBox);

    emptyPanel.Type='panel';

    outerBox.Type='panel';
    outerBox.Items={innerBox,emptyPanel};
    outerBox.RowStretch=[0,1];
    outerBox.LayoutGrid=[2,1];

    schema=outerBox;
