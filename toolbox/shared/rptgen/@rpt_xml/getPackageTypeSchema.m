function schema=getPackageTypeSchema()


    schema.Type='radiobutton';
    schema.ObjectProperty='PackageType';
    schema.Name=tr('PackagingTypeGroupLabel');
    schema.Tag=prefixTag('PackagingTypeGroup');
    schema.ToolTip=tr('PackagingTypeGroupToolTip');
    schema.OrientHorizontal=true;
    schema.Mode=1;
    schema.DialogRefresh=true;

    schema.Entries={
    tr('PackagingTypeZippedLabel')
    tr('PackagingTypeUnzippedLabel')
    tr('PackagingTypeBothLabel')
    };


    function msg=tr(msgid,varargin)
        msg=getString(message(['rptgen:rx_db_output:',msgid],varargin{:}));



        function prefix=getTagPrefix()
            prefix='RptGen_';



            function prefixedTag=prefixTag(tag)
                prefixedTag=[getTagPrefix(),tag];


