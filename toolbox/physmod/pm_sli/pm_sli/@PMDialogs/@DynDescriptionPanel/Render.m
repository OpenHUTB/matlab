function[retStatus,schema]=Render(hThis,schema)












    retStatus=true;%#ok

    textLabel.Name=hThis.DescrText;
    textLabel.Type='text';
    textLabel.WordWrap=true;
    textLabel.RowSpan=[1,1];
    textLabel.ColSpan=[1,1];


    lablStr=strrep(hThis.BlockTitle,sprintf('\n'),' ');

    lablStr=strrep(lablStr,'  ',' ');

    lablStr=strrep(lablStr,' & ',' && ');
    grpBox.Name=lablStr;
    grpBox.Type='group';
    grpBox.RowSpan=[1,1];
    grpBox.ColSpan=[1,1];
    grpBox.LayoutGrid=[1,1];
    grpBox.ColStretch=1;
    grpBox.Items={textLabel};

    schema=grpBox;
end
