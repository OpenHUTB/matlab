function ContainerDescription=getDescriptionSchema(this,grouprow)



    str1=DAStudio.message('RTW:configSet:RTWSystemTargetFileName');
    cs=this.getConfigSet;
    str2=cs.get_param('SystemTargetFile');

    ContainerDescription.Name=[this.Description,'  (',str1,'  ',str2,')'];
    ContainerDescription.Type='text';
    ContainerDescription.Tag='text_ContainerDescription';
    ContainerDescription.Alignment=0;
    ContainerDescription.WordWrap=true;
    ContainerDescription.RowSpan=[grouprow,grouprow];
    ContainerDescription.ColSpan=[1,10];
