function[sgrpInfo,cpArray]=general()



    sgrpInfo.Name=pm_message('sm:sli:configParameters:general:Name');
    sgrpInfo.Description=pm_message('sm:sli:configParameters:general:Description');

    genAnn.Text=pm_message('sm:sli:configParameters:general:Annotation');
    genAnn.TextKey='physmod:simscape:simscape:configset:dialog:SimMechanicsGeneralDescription';
    genAnn.Name='';
    genAnn.Border=false;

    diagAnn.Name=pm_message('sm:sli:configParameters:diagnostics:Description');
    diagAnn.NameKey='physmod:simscape:simscape:configset:dialog:SimMechanicsDiagnosticsContainer';
    diagAnn.Text=pm_message('sm:sli:configParameters:diagnostics:Annotation');
    diagAnn.TextKey='physmod:simscape:simscape:configset:dialog:SimMechanicsDiagnosticsDescription';
    diagAnn.Border=true;

    expAnn.Name=pm_message('sm:sli:configParameters:explorer:Description');
    expAnn.NameKey='physmod:simscape:simscape:configset:dialog:SimMechanicsExplorerContainer';
    expAnn.Text=pm_message('sm:sli:configParameters:explorer:Annotation');
    expAnn.TextKey='physmod:simscape:simscape:configset:dialog:SimMechanicsExplorerDescription';
    expAnn.Border=true;

    sgrpInfo.Annotation={genAnn,diagAnn,expAnn};

    cpArray=[];

end
