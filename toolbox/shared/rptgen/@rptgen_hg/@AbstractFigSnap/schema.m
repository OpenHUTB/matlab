function schema






    pkgHG=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgHG,'AbstractFigSnap',pkgRG.findclass('rpt_graphic'));


    rptgen.makeProp(h,'isCapture','bool',false,...
    [getString(message('rptgen:rh_AbstractFigSnap:captureScreenLabel')),':']);

    rptgen.makeProp(h,'CaptureWindowDecorations',{
    'client',getString(message('rptgen:rh_AbstractFigSnap:clientOnlyLabel'))
    'window',getString(message('rptgen:rh_AbstractFigSnap:entireWindowLabel'))
    },'client','');


    p=rptgen.makeProp(h,'PaperOrientation',{
    'inherit',getString(message('rptgen:rh_AbstractFigSnap:inheritLabel'))
    'portrait',getString(message('rptgen:rh_AbstractFigSnap:portraitLabel'))
    'landscape',getString(message('rptgen:rh_AbstractFigSnap:landscapeLabel'))
    'rotated',getString(message('rptgen:rh_AbstractFigSnap:rotatedLabel'))
    'maximize',getString(message('rptgen:r_rpt_graphic:maximizeImageLabel'))
    },'inherit',getString(message('rptgen:rh_AbstractFigSnap:paperOrientationLabel')));
    p.SetFunction=@setPaperOrientation;



    rptgen.makeProp(h,'isResizeFigure',{
    'inherit',getString(message('rptgen:rh_AbstractFigSnap:paperPosModeLabel'))
    'auto',getString(message('rptgen:rh_AbstractFigSnap:autoScreenSizeLabel'))
    'manual',[getString(message('rptgen:rh_AbstractFigSnap:customLabel')),':']
    },'auto',getString(message('rptgen:rh_AbstractFigSnap:imageSizeLabel')));


    rptgen.prop(h,'PrintSize','real point',[5,3],'');


    rptgen.prop(h,'PrintUnits',{
    'inches',getString(message('rptgen:rh_AbstractFigSnap:inchesLabel'))
    'centimeters',getString(message('rptgen:rh_AbstractFigSnap:centimetersLabel'))
    'points',getString(message('rptgen:rh_AbstractFigSnap:pointsLabel'))
    'normalized',getString(message('rptgen:rh_AbstractFigSnap:normalizedLabel'))
    },'inches','');


    rptgen.prop(h,'InvertHardcopy',{
    'auto',getString(message('rptgen:rh_AbstractFigSnap:autoLabel'))
    'on',getString(message('rptgen:rh_AbstractFigSnap:invertLabel'))
    'off',getString(message('rptgen:rh_AbstractFigSnap:noInvertLabel'))
    'inherit',getString(message('rptgen:rh_AbstractFigSnap:useInvertHardcopyLabel'))
    'none',getString(message('rptgen:rh_AbstractFigSnap:transparentBackgroundLabel'))
    },'auto',getString(message('rptgen:rh_AbstractFigSnap:invertHardcopyLabel')));


    rptgen.prop(h,'ImageFormat',rptgen.getImgFormat('ALLHG'),'AUTOHG',...
    getString(message('rptgen:rh_AbstractFigSnap:imageFormatLabel')));


    p=rptgen.prop(h,'RuntimePaperOrientation','ustring','','',2);
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';


    rptgen.makeStaticMethods(h,{
    },{
'dlgContainerFormat'
'dlgContainerPrint'
'dlgContainerSimplePrint'
'findInvertState'
'gr_getIntrinsicSize'
'gr_getFileName'
    });
