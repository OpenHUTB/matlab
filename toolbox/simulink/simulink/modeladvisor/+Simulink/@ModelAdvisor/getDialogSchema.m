function dlgstruct=getDialogSchema(this,name)




    item1.RowSpan=[2,10];
    item1.ColSpan=[1,1];

    if isempty(this.URL)

        item1.Type='textbrowser';
        item1.Text=Constructhtml(this);
    else


        item1.Type='textbrowser';
        item1.FilePath=this.URL;
    end




    dlgstruct.DialogTitle=DAStudio.message('Simulink:tools:MAModelAdvisor');
    dlgstruct.Items={item1};
    dlgstruct.HelpMethod='helpview([docroot ''/mapfiles/simulink.map''],''model_advisor'')';


    function htmltext=Constructhtml(this)
        htmltext='';
        htmltext=[htmltext,'<h3 align="center">',DAStudio.message('Simulink:tools:MAModelAdvisor'),'</h3>'];

        htmltext=[htmltext,'<h4 align="left">',DAStudio.message('Simulink:tools:MAExplorerAdviceMsg'),'</h4>'];
        htmltext=[htmltext,'<a href="matlab: modeladvisor ',this.getFullName,'">',DAStudio.message('Simulink:tools:MAExplorerStartMsg'),'</a>'];
