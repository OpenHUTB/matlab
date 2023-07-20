function dlgstruct=OnRampDialog(this)



    spacerTop=struct('Type','text','Name','','RowSpan',[1,1]);
    webWidget=struct('Type','webbrowser','RowSpan',[2,2],...
    'ColSpan',[1,1],...
    'Tag','ReqLinksDDG',...
    'WebKit',true);
    LB=Advisor.LineBreak;

    doc=Advisor.Document;
    doc.BodyItem.TagAttributes={'bgcolor','#FAFAFA';};

    if isempty(this.children)||...
        (isprop(this.view,'requirementsEditor')&&...
        ~isempty(this.view.requirementsEditor)&&...
        this.view.requirementsEditor.getSelectionStatus==slreq.gui.SelectionStatus.None)

        css=Advisor.Element('style','type','text/css');
        css.setContent(fileread(fullfile(matlabroot,'toolbox','shared',...
        'reqmgt','icons','onRamp.css')));


        doc.addHeadItem(css);

        reqSetImage=Advisor.Image;
        reqSetImage.ImageSource=fullfile(matlabroot,'toolbox','shared','reqmgt','editorPlugin','resources','icons','addReqSet_24.png');

        text1=Advisor.Text;
        text1.Content=getString(message('Slvnv:slreq:OnRampInstructionReqSet',getString(message('Slvnv:slreq:NewRequirementSet')),reqSetImage.emitHTML));
        doc.addItem(text1);
        doc.addItem([LB,LB]);

        addReqImage=Advisor.Image;
        addReqImage.ImageSource=fullfile(matlabroot,'toolbox','shared','reqmgt','editorPlugin','resources','icons','addReq_24.png');
        text2=Advisor.Text;
        text2.Content=getString(message('Slvnv:slreq:OnRampInstructionReq',getString(message('Slvnv:slreq:AddRequirement')),addReqImage.emitHTML,getString(message('Slvnv:slreq:Properties'))));
        doc.addItem(text2);
        doc.addItem([LB,LB]);

        text3=Advisor.Text;
        text3.Content=getString(message('Slvnv:slreq:OnRampInstructionReqChild',getString(message('Slvnv:slreq:AddChildRequirement'))));
        doc.addItem(text3);
        doc.addItem([LB,LB]);

        contextMenu=getString(message('Slvnv:slreq:LinkWithSelectedResolvedObj',getString(message('Slvnv:slreq:OnRampObjectName')),getString(message('Slvnv:slreq:OnRampObjectType'))));

        text4=Advisor.Text;
        text4.Content=getString(message('Slvnv:slreq:OnRampInstructionLinking',contextMenu));
        doc.addItem(text4);
        doc.addItem([LB,LB]);

        getStart=Advisor.Text;
        getStart.Content=getString(message('Slvnv:slreq:OnRampGettingStarted'));
        getStart.Hyperlink='matlab:helpview(fullfile(docroot,''slrequirements'',''helptargets.map''),''slreqGettingStartedID'')';

        text5=Advisor.Text;
        text5.Content=getString(message('Slvnv:slreq:OnRampForMoreInfo',getStart.emitHTML));
        doc.addItem(text5);
        doc.addItem([LB,LB]);

        text6=Advisor.Text;
        text6.Content=getString(message('Slvnv:slreq:OnRampInstructionLinksView',getString(message('Slvnv:slreq:ShowLinks'))));
        doc.addItem(text6);
        doc.addItem([LB,LB]);

        text7=Advisor.Text;
        text7.Content=getString(message('Slvnv:slreq:OnRampInstructionLinksType',getString(message('Slvnv:slreq:Type')),getString(message('Slvnv:slreq:Properties'))));
        doc.addItem(text7);
    end

    webWidget.HTML=doc.emitHTML;
    dlgstruct.Items={spacerTop,webWidget};
    dlgstruct.DialogTitle='';
    dlgstruct.EmbeddedButtonSet={''};
    dlgstruct.DialogMode='Slim';
    dlgstruct.RowStretch=[0,1];
    dlgstruct.LayoutGrid=[2,1];
end
