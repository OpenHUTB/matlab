function varargout=setValueSpecial(this,vType,propName,parentNode)






    if nargin<1

        varargout{1}={
        'text',getString(message('rptgen:RptgenML_StylesheetHeaderCell:textLabel'))
        'author',getString(message('rptgen:RptgenML_StylesheetHeaderCell:authorLabel'))
        'pagenumber',getString(message('rptgen:RptgenML_StylesheetHeaderCell:pageNumberLabel'))
        'chaptertitle',getString(message('rptgen:RptgenML_StylesheetHeaderCell:chapterTitle'))
        'chapternumbertitle',getString(message('rptgen:RptgenML_StylesheetHeaderCell:numberedChapterTitle'))
        'sectiontitle',getString(message('rptgen:RptgenML_StylesheetHeaderCell:sectionTitleLabel'))
        'graphic',getString(message('rptgen:RptgenML_StylesheetHeaderCell:graphicLabel'))
        'comment',getString(message('rptgen:RptgenML_StylesheetHeaderCell:commentLabel'))
        };
        return;
    end


    if isa(vType,'DAStudio.Dialog')

        allTypes=vType.getUserData('ListValueSpecial');
        typeIdx=vType.getWidgetValue('ListValueSpecial')+1;
        vType=allTypes{typeIdx};
        if isempty(vType)
            return;
        end
    end

    propNameInvalid=[propName,'Invalid'];

    if~isempty(this.(propNameInvalid))
        btnOK=getString(message('rptgen:RptgenML_StylesheetHeaderCell:revertAndAppendLabel'));
        btnCancel=getString(message('rptgen:RptgenML_StylesheetHeaderCell:cancelLabel'));
        btnResult=questdlg(getString(message('rptgen:RptgenML_StylesheetHeaderCell:badXmlMsg')),...
        getString(message('rptgen:RptgenML_StylesheetHeaderCell:badXmlInValueMsg')),...
        btnOK,btnCancel,btnCancel);
        switch btnResult
        case btnOK
            this.(propNameInvalid)='';
            this.ErrorMessage='';
        otherwise
            return;
        end
    end


    switch vType
    case 'text'
        n=parentNode.getOwnerDocument.createElement('xsl:text');
        n.appendChild(parentNode.getOwnerDocument.createTextNode(getString(message('rptgen:RptgenML_StylesheetHeaderCell:confidentialLabel'))));
        descText=getString(message('rptgen:RptgenML_StylesheetHeaderCell:customTextLabel'));
    case 'author'

        n=parentNode.getOwnerDocument.createDocumentFragment;
        nMain=parentNode.getOwnerDocument.createElement('xsl:apply-templates');
        nMain.setAttribute('select','//author[1]');
        n.appendChild(nMain);
        descText=getString(message('rptgen:RptgenML_StylesheetHeaderCell:authorNameLabel'));
        n.appendChild(parentNode.getOwnerDocument.createComment(descText));
    case 'pagenumber'
        n=parentNode.getOwnerDocument.createDocumentFragment;
        nMain=parentNode.getOwnerDocument.createElement('fo:page-number');
        n.appendChild(nMain);
        descText=getString(message('rptgen:RptgenML_StylesheetHeaderCell:pageNumberLabel'));
        n.appendChild(parentNode.getOwnerDocument.createComment(descText));
    case 'chaptertitle'
        n=parentNode.getOwnerDocument.createDocumentFragment;
        nMain=parentNode.getOwnerDocument.createElement('xsl:apply-templates');
        nMain.setAttribute('select','.');
        nMain.setAttribute('mode','title.markup');
        n.appendChild(nMain);
        descText=getString(message('rptgen:RptgenML_StylesheetHeaderCell:chapterTitleLabel'));
        n.appendChild(parentNode.getOwnerDocument.createComment(descText));
    case 'chapternumbertitle'


        n=parentNode.getOwnerDocument.createDocumentFragment;
        nMain=parentNode.getOwnerDocument.createElement('xsl:apply-templates');
        nMain.setAttribute('select','.');
        nMain.setAttribute('mode','object.title.markup');
        n.appendChild(nMain);
        descText=getString(message('rptgen:RptgenML_StylesheetHeaderCell:chapterTitleNumberLabel'));
        n.appendChild(parentNode.getOwnerDocument.createComment(descText));
    case 'sectiontitle'
        n=parentNode.getOwnerDocument.createDocumentFragment;
        nMain=parentNode.getOwnerDocument.createElement('fo:retrieve-marker');
        nMain.setAttribute('retrieve-class-name','section.head.marker');
        nMain.setAttribute('retrieve-position','first-including-carryover');
        nMain.setAttribute('retrieve-boundary','page-sequence');
        n.appendChild(nMain);
        n.appendChild(parentNode.getOwnerDocument.createTextNode(''));
        descText=getString(message('rptgen:RptgenML_StylesheetHeaderCell:sectionTitleLabel'));
        n.appendChild(parentNode.getOwnerDocument.createComment(descText));
    case 'draft'





        n=parentNode.getOwnerDocument.createElement('xsl:call-template');
        n.setAttribute('name','draft.text');
        descText=getString(message('rptgen:RptgenML_StylesheetHeaderCell:draftLabel'));
    case 'graphic'
        n=parentNode.getOwnerDocument.createElement('fo:external-graphic');

        thisParent=this;
        while~isa(thisParent,'RptgenML.StylesheetHeader')&&~isempty(thisParent)
            thisParent=thisParent.up;
        end


        heightAtt=parentNode.getOwnerDocument.createElement('xsl:attribute');
        heightAtt.setAttribute('name','height');
        n.appendChild(heightAtt);

        voElement=parentNode.getOwnerDocument.createElement('xsl:value-of');
        heightAtt.appendChild(voElement);
        if isa(thisParent,'RptgenML.StylesheetHeader')&&strcmp(thisParent.ID,'footer.content')
            voElement.setAttribute('select','$region.after.extent');
        else
            voElement.setAttribute('select','$region.before.extent');
        end




        nAtt=parentNode.getOwnerDocument.createElement('xsl:attribute');
        nAtt.setAttribute('name','src');
        n.appendChild(nAtt);

        nCall=parentNode.getOwnerDocument.createElement('xsl:call-template');
        nCall.setAttribute('name','fo-external-image');
        nAtt.appendChild(nCall);

        nCall.appendChild(parentNode.getOwnerDocument.createTextNode(char(10)));

        nWith=parentNode.getOwnerDocument.createElement('xsl:with-param');
        nWith.setAttribute('name','filename');

        nCall.appendChild(nWith);

        nWith.appendChild(parentNode.getOwnerDocument.createTextNode('./logo.bmp'));
        nWith.appendChild(parentNode.getOwnerDocument.createComment(getString(message('rptgen:RptgenML_StylesheetHeaderCell:graphicNameLabel'))));

        nCall.appendChild(parentNode.getOwnerDocument.createTextNode(char(10)));

        descText=getString(message('rptgen:RptgenML_StylesheetHeaderCell:graphicLabel'));
    otherwise
        n=parentNode.getOwnerDocument.createComment(getString(message('rptgen:RptgenML_StylesheetHeaderCell:commentTextLabel')));
    end

    parentNode.appendChild(parentNode.getOwnerDocument.createTextNode(char(10)));
    parentNode.appendChild(n);



















