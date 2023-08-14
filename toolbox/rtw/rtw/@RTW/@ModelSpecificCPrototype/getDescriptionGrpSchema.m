function grp=getDescriptionGrpSchema(hSrc)%#ok<INUSD>



    txtDescription.Type='text';
    txtDescription.Name=DAStudio.message('RTW:fcnClass:configDescription');
    txtDescription.WordWrap=true;
    txtDescription.RowSpan=[1,1];
    txtDescription.ColSpan=[1,10];

    grp.Name=DAStudio.message('RTW:fcnClass:fcnProtoDescription');
    grp.Type='group';
    grp.Items={txtDescription};
    grp.LayoutGrid=[1,10];
