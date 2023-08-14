function schema




    pkg=findpackage('rpt_xml');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,...
    'db_output',...
    pkgRG.findclass('DAObject'));


    try
        allFormats=rptgen.internal.output.OutputFormat.listAllIDs;
        allDesc=rptgen.internal.output.OutputFormat.listAllDescriptions;
    catch ex
        warning(ex.message);
        allFormats={'html'};
        allDesc={getString(message('rptgen:rx_db_output:webFormat'))};
    end

    defaultFormat='html';
    if~any(strcmpi(allFormats,defaultFormat))
        defaultFormat=allFormats{1};
    end

    enumType='rptgen_docbook_target';
    rptgen.enum(enumType,allFormats,allDesc);


    allPackageTypes={'zipped','unzipped','both'};
    allPackageDesc=allPackageTypes;

    defaultPackageType='zipped';
    if~any(strcmpi(allPackageTypes,defaultPackageType))
        defaultPackageType=allPackageTypes{1};
    end

    enumPTType='rptgen_packagetype';
    rptgen.enum(enumPTType,allPackageTypes,allPackageDesc);


    rptgen.prop(h,'Format',enumType,defaultFormat,...
    getString(message('rptgen:rx_db_output:fileFormatLabel')),1);

    rptgen.prop(h,'PackageType',enumPTType,defaultPackageType,...
    getString(message('rptgen:rx_db_output:packageTypeLabel')),1);


    rptgen.prop(h,'FormatObject','MATLAB array',[],'',2);

    rptgen.prop(h,'DstFileName','ustring','',getString(message('rptgen:rx_db_output:destFileLabel')),2);

    rptgen.prop(h,'SrcFileName','ustring','',getString(message('rptgen:rx_db_output:srcFileLabel')),2);

    ssDataType='RGStylesheetRef';
    ssRef=findtype(ssDataType);
    if isempty(ssRef)
        schema.UserType(ssDataType,'MATLAB array',@checkStylesheetRef);
    end

    rptgen.prop(h,'StylesheetHTML',ssDataType,'default-html','',1);
    rptgen.prop(h,'StylesheetFO',ssDataType,'default-fo','',1);
    rptgen.prop(h,'StylesheetLaTeX',ssDataType,'default-latex','',1);
    rptgen.prop(h,'StylesheetDSSSL','ustring','!print-NoOptions','',1);

    tDataType='RGTemplateRef';
    tRef=findtype(tDataType);
    if isempty(tRef)
        schema.UserType(tDataType,'MATLAB array',@checkStylesheetRef);
    end

    rptgen.prop(h,'TemplateDOCX',tDataType,'default-rg-docx','',1);
    rptgen.prop(h,'TemplateHTMX',tDataType,'default-rg-html','',1);
    rptgen.prop(h,'TemplateHTMLFile',tDataType,'default-rg-html-file','',1);
    rptgen.prop(h,'TemplatePDF',tDataType,'default-rg-pdf','',1);


    rptgen.prop(h,'ImportFiles','bool',true,'',2);


    rptgen.prop(h,'Language','ustring','','',2);


    rptgen.prop(h,'fontMap','MATLAB array',[],'',2);


    p=rptgen.prop(h,'cleanupFontDirectory','bool',false,'',1);
    p.Visible='off';


    p=rptgen.prop(h,'fontDirsToClean','MATLAB array',{});
    p.Visible='off';
    p.AccessFlags.PublicSet='off';

    m=find(h.Method,'Name','getDialogSchema');
    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle','string'};
        s.OutputTypes={'mxArray'};
    end

    function ok=checkStylesheetRef(~,~)

        ok=true;
