function h=customize(h)





    h.Title=DAStudio.message('Simulink:Logging:SigLogDlgTitle');
    h.setTreeTitle('');


    h.Icon=fullfile(...
    matlabroot,...
    'toolbox',...
    'simulink',...
    'core',...
    'general',...
    '@SigLogSelector',...
    'resources',...
    'SigLogSelector.png');


    h.imme=DAStudio.imExplorer(h);


    sig=SigLogSelector.LogSignalObj;
    props=sig.getPreferredProperties;
    h.setListProperties(props);
    h.addPropDisplayNames({'SourcePath','Source Port'});


    h.setTreeTitle(...
    DAStudio.message('Simulink:Logging:SigLogDlgModelHierarchyLabel'));


    h.showDialogView(true);
    h.setDlgViewScrollable(false);
    h.setDlgListViewLayoutVert(true);

end
