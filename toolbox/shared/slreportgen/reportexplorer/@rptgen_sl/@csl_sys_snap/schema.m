function schema






    pkgRG=findpackage('rptgen');
    pkgSL=findpackage('rptgen_sl');

    h=schema.class(pkgSL,'csl_sys_snap',pkgRG.findclass('rpt_graphic'));

    lic='SIMULINK_Report_Gen';


    rptgen.prop(h,'Format',...
    rptgen.getImgFormat('ALLSL'),...
    'AUTOSL',...
    getString(message('RptgenSL:rsl_csl_sys_snap:formatLbl')),lic);



    p=rptgen.prop(h,'PaperOrientation',{
    'inherit',getString(message('RptgenSL:rsl_csl_sys_snap:sysOrientationLbl'))
    'auto',getString(message('RptgenSL:rsl_csl_sys_snap:largestDimVerticalLbl'))
    'portrait',getString(message('RptgenSL:rsl_csl_sys_snap:portraitLbl'))
    'landscape',getString(message('RptgenSL:rsl_csl_sys_snap:landscapeLbl'))
    'maximize',getString(message('rptgen:r_rpt_graphic:maximizeImageLabel'))
    },'portrait',getString(message('RptgenSL:rsl_csl_sys_snap:orientationLbl')),lic);
    p.SetFunction=@setPaperOrientation;


    p=rptgen.prop(h,'PaperExtentMode',{
    'auto',getString(message('RptgenSL:rsl_csl_sys_snap:automaticLbl'))
    'manual',[getString(message('RptgenSL:rsl_csl_sys_snap:customLbl')),':']
    'zoom',[getString(message('RptgenSL:rsl_csl_sys_snap:zoomLbl')),':']
    },'auto',...
    getString(message('RptgenSL:rsl_csl_sys_snap:scalingLbl')),lic);
    p.GetFunction=@getPaperExtentMode;


    rptgen.prop(h,'UseCallouts','bool',false,...
    getString(message('RptgenSL:rsl_csl_sys_snap:includeCalloutsLbl')),lic);

    rptgen.prop(h,'PaperExtent','real point',[7,9],getString(message('RptgenSL:rsl_csl_sys_snap:sizeLbl')),lic);


    rptgen.prop(h,'MaxPaperExtent','real point',[7,9],getString(message('RptgenSL:rsl_csl_sys_snap:maxSizeLbl')),lic);


    rptgen.prop(h,'PaperZoom','double',100,'Zoom',lic);


    p=rptgen.prop(h,'PaperUnits',{
    'inches',getString(message('RptgenSL:rsl_csl_sys_snap:inchesLbl'))
    'centimeters',getString(message('RptgenSL:rsl_csl_sys_snap:centimetersLbl'))
    'points',getString(message('RptgenSL:rsl_csl_sys_snap:pointsLbl'))
    'percent','%'
    },'inches','Units',lic);
    p.Visible='off';


    p=rptgen.prop(h,'PrintUnits',{
    'inches',getString(message('RptgenSL:rsl_csl_sys_snap:inchesLbl'))
    'centimeters',getString(message('RptgenSL:rsl_csl_sys_snap:centimetersLbl'))
    'points',getString(message('RptgenSL:rsl_csl_sys_snap:pointsLbl'))
    },'inches','Units',lic);
    p.GetFunction=@getPrintUnits;
    p.SetFunction=@setPrintUnits;


    rptgen.prop(h,'isPrintFrame','bool',false,...
    getString(message('RptgenSL:rsl_csl_sys_snap:printframeLbl')),lic);


    rptgen.prop(h,'PrintFrameName',rptgen.makeStringType,'rptdefaultframe.fig',...
    '',lic);


    rptgen.prop(h,'CaptionType',{
    'none',getString(message('RptgenSL:rsl_csl_sys_snap:noneLbl'))
    'auto',getString(message('RptgenSL:rsl_csl_sys_snap:descriptionLbl'))
    'manual',[getString(message('RptgenSL:rsl_csl_sys_snap:customLbl')),': ']
    },'none',getString(message('RptgenSL:rsl_csl_sys_snap:captionLbl')),lic);


    rptgen.prop(h,'TitleType',{
    'none',getString(message('RptgenSL:rsl_csl_sys_snap:noneLbl'))
    'sysname',getString(message('RptgenSL:rsl_csl_sys_snap:sysNameLbl'))
    'fullname',getString(message('RptgenSL:rsl_csl_sys_snap:systemNameLbl'))
    'manual',[getString(message('RptgenSL:rsl_csl_sys_snap:customLbl')),': ']
    },'none',getString(message('RptgenSL:rsl_csl_sys_snap:titleLbl')),lic);


    rptgen.prop(h,'CreateImagemap','bool',true,...
    getString(message('RptgenSL:rsl_csl_sys_snap:createImagemapLbl')),lic);


    p=rptgen.prop(h,'RuntimeCreateImagemap','bool',false,'',2);
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';


    p=rptgen.prop(h,'RuntimePointers','MATLAB array',{},'',2);%#ok
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';


    p=rptgen.prop(h,'RuntimeSize','real point',[0,0],'',2);%#ok
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';


    rptgen.prop(h,'isAdvancedVisible','bool',false,'',lic);


    p=rptgen.prop(h,'UseMaxSize','bool',true,'',lic);
    p.AccessFlags.PublicSet='off';
    p.Visible='off';
    p.AccessFlags.Serialize='off';


    m=schema.method(h,'toggleAdvanced');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    rptgen.makeStaticMethods(h,{
    },{
'gr_getCaption'
'gr_getFileName'
'gr_getTitle'
'gr_preCreateAction'
'toggleAdvanced'
    });


    function value=getPrintUnits(this,storedValue)



        if strcmp(this.PaperUnits,'percent')
            set(this,'PaperUnits',storedValue);
            set(this,'PaperExtentMode','zoom');
            value=storedValue;
        else
            value=this.PaperUnits;
        end;

        function newValue=setPrintUnits(this,proposedValue)


            newValue=proposedValue;
            this.PaperUnits=newValue;

            function newValue=setPaperOrientation(this,proposedValue)

                newValue=proposedValue;
                this.MaximizeImage=strcmp(proposedValue,'maximize');


                function value=getPaperExtentMode(this,storedValue)

                    if strcmp(storedValue,'manual')&&strcmp(this.PaperUnits,'percent')
                        value='zoom';
                    else
                        value=storedValue;
                    end;