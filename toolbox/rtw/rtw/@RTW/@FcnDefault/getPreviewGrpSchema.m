function grp=getPreviewGrpSchema(hSrc,hParent)



    tDisplay.Type='text';
    tDisplay.Tag='Tag_fcnproto_preview';
    tDisplay.Name=visualize(hSrc,hParent);
    tDisplay.RowSpan=[1,1];
    tDisplay.ColSpan=[1,10];
    tDisplay.WordWrap=true;
    tDisplay.Editable=false;
    tDisplay.Enabled=true;

    grp.Name=DAStudio.message('RTW:fcnClass:fcnProtoPreview');
    grp.Type='group';
    grp.Items={tDisplay};
    grp.LayoutGrid=[1,10];


    function signature=visualize(hSrc,hParent)

        if isa(hSrc,'RTW.FcnDefault')
            if hParent.validationStatus&&...
                strcmp(hParent.validationResult,...
                DAStudio.message('RTW:fcnClass:pressValidate'))
                signature=DAStudio.message('RTW:fcnClass:pressValidatePreview');
                return;
            elseif~hParent.validationStatus||...
                (hParent.validationStatus&&...
                ~isempty(hParent.validationResult))
                signature=DAStudio.message('RTW:fcnClass:previewUnavailable');
                return;
            end
        end
        signature=hSrc.getPreview();