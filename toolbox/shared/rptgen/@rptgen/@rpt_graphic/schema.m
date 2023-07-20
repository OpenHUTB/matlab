function schema






    pkgRG=findpackage('rptgen');
    h=schema.class(pkgRG,'rpt_graphic',pkgRG.findclass('rptcomponent'));


    rptgen.prop(h,'Title','ustring','',getString(message('rptgen:r_rpt_graphic:titleLabel')));


    rptgen.prop(h,'Caption','ustring','',getString(message('rptgen:r_rpt_graphic:captionLabel')));




    rptgen.prop(h,'isInline','bool',false,getString(message('rptgen:r_rpt_graphic:makeInlineLabel')),1);


    rptgen.prop(h,'DocHorizAlign',{
    'auto',getString(message('rptgen:r_rpt_graphic:autoLabel'))
    'right',getString(message('rptgen:r_rpt_graphic:rightLabel'))
    'center',getString(message('rptgen:r_rpt_graphic:centerLabel'))
    'left',getString(message('rptgen:r_rpt_graphic:leftLabel'))
    },'auto',getString(message('rptgen:r_rpt_graphic:alignmentLabel')));


    p=rptgen.prop(h,'DocWidth','ustring','',...
    getString(message('rptgen:r_rpt_graphic:documentWidthLabel')),2);
    p.Visible='off';


    p=rptgen.prop(h,'DocHeight','ustring','',...
    getString(message('rptgen:r_rpt_graphic:documentHeightLabel')),2);
    p.Visible='off';


    rptgen.prop(h,'ViewportType',{
    'none',getString(message('rptgen:r_rpt_graphic:imageSizeLabel'))
    'zoom',getString(message('rptgen:r_rpt_graphic:zoomLabel'))
    'fixed',getString(message('rptgen:r_rpt_graphic:fixedSizeLabel'))
    },'none',getString(message('rptgen:r_rpt_graphic:scalingLabel')));


    rptgen.prop(h,'ViewportSize','real point',[7,9],getString(message('rptgen:r_rpt_graphic:sizeLabel')));


    p=rptgen.prop(h,'UseMaxSize','bool',false);
    p.AccessFlags.PublicSet='off';
    p.Visible='off';
    p.AccessFlags.Serialize='off';


    rptgen.prop(h,'ViewportUnits',{
    'inches',getString(message('rptgen:r_rpt_graphic:inchesLabel'))
    'centimeters',getString(message('rptgen:r_rpt_graphic:centimetersLabel'))
    'points',getString(message('rptgen:r_rpt_graphic:pointsLabel'))
    },'inches');


    rptgen.prop(h,'ViewportZoom','double',100);


    p=rptgen.prop(h,'RuntimeViewportSize','real point',[-1,-1],'',2);
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';


    p=rptgen.prop(h,'RuntimeFileName','ustring','','',2);
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';



    p=rptgen.prop(h,'MaxViewportSize','real point',[10,10],getString(message('rptgen:r_rpt_graphic:maxSizeLabel')));
    p.GetFunction=@getMaxViewportSize;


    rptgen.prop(h,'maximizeImage','bool',false,getString(message('rptgen:r_rpt_graphic:maximizeImageLabel')),1);


    rptgen.makeStaticMethods(h,{
    },{
'gr_dlgDisplayOptions'
'gr_getCaption'
'gr_getFileName'
'gr_getTitle'
'gr_makeGraphic'
'gr_preCreateAction'
'gr_makeViewport'
'gr_getIntrinsicSize'
    });

