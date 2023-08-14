function schema





    pkg=findpackage('rptgen');
    pkgXML=findpackage('rpt_xml');

    h=schema.class(pkg,'coutline',pkg.findclass('rpt_section'));


    rptgen.makeStaticMethods(h,{
    },{
'cleanup'
'doDelete'
'getrptname'
'getSectionType'
'getChunkFileName'
'getSectionFileName'
'initialize'
'makeDocumentPost'
'makeDocumentPre'
'viewFile'
'getContextMenu'
'getDirty'
'setDirty'
'getDisplayIcon'
'mcodeConstructor'
'writeXmlHeader'
    });


    rptgen.prop(h,'DirectoryType',{
    'setfile',getString(message('rptgen:r_coutline:useSetupFileLabel'))
    'pwd',getString(message('rptgen:r_coutline:currentDirectoryLabel'))
    'tempdir',getString(message('rptgen:r_coutline:tempDirectoryLabel'))
    'other',[getString(message('rptgen:r_coutline:customLabel')),':']
    },'setfile',getString(message('rptgen:r_coutline:directoryLabel')),1);


    rptgen.prop(h,'DirectoryName','ustring','','',1);


    rptgen.prop(h,'FilenameType',{
    'setfile',getString(message('rptgen:r_coutline:useSetupFileLabel'))
    'other',[getString(message('rptgen:r_coutline:customLabel')),':']
    },'setfile',getString(message('rptgen:r_coutline:filenameLabel')),1);


    rptgen.prop(h,'FilenameName','ustring','index','',1);


    rptgen.prop(h,'isIncrementFilename','bool',false,...
    getString(message('rptgen:r_coutline:incrementReportNameLabel')),1);



    p=rptgen.prop(h,'OutputFullFileName','ustring','',...
    getString(message('rptgen:r_coutline:filenameLabel')),1);
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction=@getOutputFullFileName;
    p.SetFunction=@setOutputFullFileName;
    p.Visible='off';






    pkgXML.findclass('db_output');
    p=rptgen.prop(h,'Output','rpt_xml.db_output');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction=@getOutput;
    p.SetFunction=@setOutput;
    p.Visible='off';





    p=rptgen.prop(h,'Format','rptgen_docbook_target','html');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction=@getFormat;
    p.SetFunction=@setFormat;





    p=rptgen.prop(h,'PackageType','rptgen_packagetype','zipped');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction=@getPackageType;
    p.SetFunction=@setPackageType;





    p=rptgen.prop(h,'Stylesheet','ustring','default-html');
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction=@getStylesheet;
    p.SetFunction=@setStylesheet;


    rptgen.prop(h,'isView','bool',true,...
    getString(message('rptgen:r_coutline:viewAfterGenerationLabel')),1);


    rptgen.prop(h,'ForceXmlSource','bool',false,...
    getString(message('rptgen:r_coutline:preserveXMLLabel')),1);


    rptgen.prop(h,'isAutoSaveOnGenerate','bool',false,...
    getString(message('rptgen:r_coutline:autoSaveLabel')));


    rptgen.prop(h,'isGenerateDocBookOnly','bool',false,...
    getString(message('rptgen:r_coutline:generateDocBookOnlyLabel')));


    p=rptgen.prop(h,'isRegenerateImages','bool',true,...
    getString(message('rptgen:r_coutline:refreshSLSFImagesLabel')));
    p.Visible='off';
    p.SetFunction=@setIsRegenerateImages;
    p.AccessFlags.Serialize='off';


    p=rptgen.prop(h,'isDebug','bool',false,'Debug mode',2);
    p.Visible='off';


    rptgen.prop(h,'Description','ustring',getString(message('rptgen:r_coutline:reportDescriptionDefault')),...
    getString(message('rptgen:r_coutline:reportDescriptionLabel')));


    rptgen.prop(h,'Language',rpt_xml.typeLanguage,'auto',...
    getString(message('rptgen:r_coutline:languageLabel')));


    p=rptgen.prop(h,'FileEncoding','ustring','utf-8','FileEncoding',2);
    p.Visible='off';




    rptgen.prop(h,'PostGenerateFcn','ustring','',...
    getString(message('rptgen:r_coutline:postGenerationStepLabel')));



    rptgen.prop(h,'RptFileName','ustring','','',2);


    pkg.findclass('appdata');
    rptgen.prop(h,'ApplicationDataObjects','rptgen.appdata vector',[],'',2);


    rptgen.prop(h,'CompileModel','bool',false,getString(message('rptgen:r_coutline:compileModelLabel')));


    p=rptgen.prop(h,'cleanupFontDirectory','bool',false,'',1);
    p.Visible='off';


    p=rptgen.prop(h,'fontDirsToClean','MATLAB array',{});
    p.Visible='off';
    p.AccessFlags.PublicSet='off';



    p=rptgen.prop(h,'PublicGenerate','bool',false);
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Default='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Copy='off';
    p.Visible='off';
    p.FactoryValue=false;


    setMethodSignature(h,'getContextMenu',{'handle','handle vector'},{'handle'});
    setMethodSignature(h,'getDisplayIcon',{'handle'},{'ustring'});

    function setMethodSignature(h,methodName,inputTypes,outputTypes)
        m=find(h.Method,'Name',methodName);
        if~isempty(m)
            s=m.Signature;
            s.varargin='off';
            s.InputTypes=inputTypes;
            s.OutputTypes=outputTypes;
        end
