function schema=getTitlePageOptionsSchema(dlgsrc,name)%#ok<INUSD>







    tag_prefix='sdd_';








    editTitle.Type='edit';
    editTitle.RowSpan=[1,1];
    editTitle.ColSpan=[2,3];
    editTitle.ObjectProperty='title';
    editTitle.Tag=[tag_prefix,'Title'];
    editTitle.ToolTip=dlgsrc.bxlate('BaseWidgetTipTitle');


    editTitleLbl.Type='text';
    editTitleLbl.Name=dlgsrc.bxlate('BaseWidgetLblTitle');
    editTitleLbl.RowSpan=[1,1];
    editTitleLbl.ColSpan=[1,1];
    editTitleLbl.Tag=[editTitle.Tag,'Label'];
    editTitleLbl.Buddy=editTitle.Tag;


    editSubtitle.Type='edit';
    editSubtitle.RowSpan=[2,2];
    editSubtitle.ColSpan=[2,3];
    editSubtitle.ObjectProperty='subtitle';
    editSubtitle.Tag=[tag_prefix,'Subtitle'];
    editSubtitle.ToolTip=dlgsrc.bxlate('BaseWidgetTipSubtitle');


    editSubtitleLbl.Type='text';
    editSubtitleLbl.Name=dlgsrc.bxlate('BaseWidgetLblSubtitle');
    editSubtitleLbl.RowSpan=[2,2];
    editSubtitleLbl.ColSpan=[1,1];
    editSubtitleLbl.Tag=[editSubtitle.Tag,'Label'];
    editSubtitleLbl.Buddy=editSubtitle.Tag;


    editAuthors.Type='edit';
    editAuthors.RowSpan=[3,3];
    editAuthors.ColSpan=[2,3];
    editAuthors.ObjectProperty='authorNames';
    editAuthors.Tag=[tag_prefix,'Authors'];
    editAuthors.ToolTip=dlgsrc.bxlate('BaseWidgetTipAuthors');


    editAuthorsLbl.Type='text';
    editAuthorsLbl.Name=dlgsrc.bxlate('BaseWidgetLblAuthors');
    editAuthorsLbl.RowSpan=[3,3];
    editAuthorsLbl.ColSpan=[1,1];
    editAuthorsLbl.Tag=[editAuthors.Tag,'Label'];
    editAuthorsLbl.Buddy=editAuthors.Tag;


    editImage.Type='edit';
    editImage.RowSpan=[4,4];
    editImage.ColSpan=[2,2];
    editImage.ObjectProperty='titleImgPath';
    editImage.Tag=[tag_prefix,'TitlePageImage'];
    editImage.ToolTip=dlgsrc.bxlate('BaseWidgetTipImage');


    editImageLbl.Type='text';
    editImageLbl.Name=dlgsrc.bxlate('BaseWidgetLblImage');
    editImageLbl.RowSpan=[4,4];
    editImageLbl.ColSpan=[1,1];
    editImageLbl.Tag=[editImage.Tag,'Label'];
    editImageLbl.Buddy=editImage.Tag;


    btnBrowseImage.Type='pushbutton';
    btnBrowseImage.Name=dlgsrc.bxlate('BaseButtonLblBrowseImage');
    btnBrowseImage.RowSpan=[4,4];
    btnBrowseImage.ColSpan=[3,3];
    btnBrowseImage.ObjectMethod='browseImage';
    btnBrowseImage.MethodArgs={'%dialog',editImage.Tag};
    btnBrowseImage.ArgDataTypes={'handle','string'};
    btnBrowseImage.Tag=[tag_prefix,'BrowseImageButton'];
    btnBrowseImage.ToolTip=dlgsrc.bxlate('BaseButtonTipBrowseImage');


    editLegalNotice.Type='editarea';
    editLegalNotice.RowSpan=[5,5];
    editLegalNotice.ColSpan=[2,3];
    editLegalNotice.ObjectProperty='legalNotice';
    editLegalNotice.Tag=[tag_prefix,'LegalNotice'];
    editLegalNotice.ToolTip=dlgsrc.bxlate('BaseWidgetTipLegalNotice');


    editLegalNoticeLbl.Type='text';
    editLegalNoticeLbl.Alignment=2;
    editLegalNoticeLbl.Name=dlgsrc.bxlate('BaseWidgetLblLegalNotice');
    editLegalNoticeLbl.RowSpan=[5,5];
    editLegalNoticeLbl.ColSpan=[1,1];
    editLegalNoticeLbl.Tag=[editLegalNotice.Tag,'Label'];
    editLegalNoticeLbl.Buddy=editLegalNotice.Tag;


    grpTitlePageOptions.Type='group';
    grpTitlePageOptions.Tag=[tag_prefix,'TitlePageOptionsGroup'];
    grpTitlePageOptions.Name=dlgsrc.bxlate('BaseWidgetLblTitlePageOptions');
    grpTitlePageOptions.LayoutGrid=[5,3];
    grpTitlePageOptions.Items={editTitleLbl,...
    editTitle,...
    editSubtitleLbl,...
    editSubtitle,...
    editAuthorsLbl,...
    editAuthors,...
    editImageLbl,...
    editImage,...
    btnBrowseImage,...
    editLegalNoticeLbl,...
    editLegalNotice};

    pnlTitlePageOptions.Type='panel';
    pnlTitlePageOptions.Tag=[tag_prefix,'TitlePageOptionsPanel'];
    pnlTitlePageOptions.Items={grpTitlePageOptions};

    schema=pnlTitlePageOptions;

end


