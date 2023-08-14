function schema






    pkg=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csf_obj_snap',pkgRG.findclass('rpt_graphic'));

    lic='SIMULINK_Report_Gen';





    p=rptgen.prop(h,'imageSizing',{
    'auto',getString(message('RptgenSL:rsf_csf_obj_snap:shrinkToMinSizeLabel'))
    'manual',getString(message('RptgenSL:rsf_csf_obj_snap:fixedSizeLabel'))
    'zoom',getString(message('RptgenSL:rsf_csf_obj_snap:zoomLabel'))
    },'auto','',lic);%#ok


    p=rptgen.prop(h,'PrintSize',...
    'real point',[500,300],...
    getString(message('RptgenSL:rsf_csf_obj_snap:sizeLabel')),lic);%#ok


    rptgen.prop(h,'MaxPrintSize',...
    'real point',[500,300],...
    getString(message('RptgenSL:rsf_csf_obj_snap:maxSizeLabel')),lic);


    p=rptgen.prop(h,'PrintZoom',...
    'double',100,...
    '',lic);%#ok


    p=rptgen.prop(h,'PrintUnits',{
    'inches',getString(message('RptgenSL:rsf_csf_obj_snap:inchesLabel'))
    'centimeters',getString(message('RptgenSL:rsf_csf_obj_snap:centimetersLabel'))
    'pixels',getString(message('RptgenSL:rsf_csf_obj_snap:pixelsLabel'))
    'points',getString(message('RptgenSL:rsf_csf_obj_snap:pointsLabel'))
    },'points','',lic);%#ok

    p=rptgen.prop(h,'LastPrintUnits','ustring','','',2);%#ok


    p=rptgen.prop(h,'PaperOrientation',{
    'portrait',getString(message('RptgenSL:rsf_csf_obj_snap:portraitLabel'))
    'landscape',getString(message('RptgenSL:rsf_csf_obj_snap:landscapeLabel'))
    'rotated',getString(message('RptgenSL:rsf_csf_obj_snap:rotatedLabel'))
    'auto',getString(message('RptgenSL:rsf_csf_obj_snap:largestVerticalDimensionLabel'))
    'inherit',getString(message('RptgenSL:rsf_csf_obj_snap:usePaperOrientationLabel'))
    'maximize',getString(message('rptgen:r_rpt_graphic:maximizeImageLabel'))
    },'portrait',getString(message('RptgenSL:rsf_csf_obj_snap:orientationLabel')),lic);
    p.SetFunction=@setPaperOrientation;


    p=rptgen.prop(h,'isPrintFrame',...
    'bool',false,...
    getString(message('RptgenSL:rsf_csf_obj_snap:printframeLabel')),lic);%#ok


    p=rptgen.prop(h,'PrintFrameName',...
    rptgen.makeStringType,'rptdefaultframe.fig',...
    '',lic);%#ok


    p=rptgen.prop(h,'isPrintFrameSettings',...
    'bool',true,...
    getString(message('RptgenSL:rsf_csf_obj_snap:usePaperSettingsLabel')),lic);%#ok


    p=rptgen.prop(h,'PrintSizePoints','real point',[-1,-1],'');
    p.Visible='off';


    p=rptgen.prop(h,'ImageFormat',...
    rptgen.getImgFormat('ALLSF'),...
    'AUTOSF',getString(message('RptgenSL:rsf_csf_obj_snap:formatLabel')),lic);%#ok


    p=rptgen.prop(h,'isCallouts',...
    'bool',true,...
    getString(message('RptgenSL:rsf_csf_obj_snap:includeCalloutsLabel')),lic);%#ok



    p=rptgen.prop(h,'TerminalChildAnchors',{
    'none',getString(message('RptgenSL:rsf_csf_obj_snap:NoneLabel'))
    'redundant',getString(message('RptgenSL:rsf_csf_obj_snap:redundantChildrenOnlyLabel'))
    'all',getString(message('RptgenSL:rsf_csf_obj_snap:allLabel'))
    },'none',getString(message('RptgenSL:rsf_csf_obj_snap:insertTransitionAnchors')),lic);%#ok


    p=rptgen.prop(h,'picMinChildren',...
    'double',0,...
    getString(message('RptgenSL:rsf_csf_obj_snap:runIfThereExistNChildrenLabel')),lic);%#ok


    p=rptgen.prop(h,'AvoidRepeatSnapshot',...
    'bool',true,...
    getString(message('RptgenSL:rsf_csf_obj_snap:ignoreIfDuplicateLabel')),lic);
    p.Visible='off';


    p=rptgen.prop(h,'RuntimePointerCoords','MATLAB array',{},'',2);%#ok


    p=rptgen.prop(h,'RuntimeAnchors','org.w3c.dom.Node',[],'',2);%#ok


    p=rptgen.prop(h,'RuntimeImageSize','real point',[-1,-1],'',2);%#ok


    p=rptgen.prop(h,'RuntimePaperOrientation','ustring','','',2);
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';


    p=rptgen.prop(h,'RuntimeMinMarginsWithCallouts','double',0,'',2);
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';

    p=rptgen.prop(h,'RuntimeMinMarginsNoCallouts','double',0,'',2);
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='off';
    p.Visible='off';


    p=rptgen.prop(h,'TitleType',{
    'none',getString(message('RptgenSL:rsf_csf_obj_snap:NoneLabel'))
    'objname',getString(message('RptgenSL:rsf_csf_obj_snap:objectNameLabel'))
    'fullsfname',getString(message('RptgenSL:rsf_csf_obj_snap:objectNameWithSFPathLabel'))
    'fullslsfname',getString(message('RptgenSL:rsf_csf_obj_snap:objectNameWithSLSFPathLabel'))
    'manual',[getString(message('RptgenSL:rsf_csf_obj_snap:customLabel')),':']
    },'none',getString(message('RptgenSL:rsf_csf_obj_snap:imageTitleLabel')),lic);%#ok


    p=rptgen.prop(h,'CaptionType',{
    'none',getString(message('RptgenSL:rsf_csf_obj_snap:NoneLabel'))
    'auto',getString(message('RptgenSL:rsf_csf_obj_snap:descriptionLabel'))
    'manual',getString(message('RptgenSL:rsf_csf_obj_snap:customColonLabel'))
    },'none',getString(message('RptgenSL:rsf_csf_obj_snap:CaptionLabel')),lic);%#ok


    p=rptgen.prop(h,'UseMaxSize','bool',true,'',lic);
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.Serialize='off';
    p.Visible='off';




    p=rptgen.prop(h,'TitleString',rptgen.makeStringType,'',...
    '',lic);
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction=@getTitleString;
    p.SetFunction=@setTitleString;
    p.Visible='off';


    rptgen.prop(h,'isAdvancedVisible','bool',false,'',lic);


    m=schema.method(h,'toggleAdvanced');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    rptgen.makeStaticMethods(h,{
    },{
'gr_getCaption'
'gr_getFileName'
'gr_getIntrinsicSize'
'gr_getTitle'
'gr_preCreateAction'
'toggleAdvanced'
    });


    function returnedValue=getTitleString(this,storedValue)%#ok



        returnedValue=get(this,'Title');


        function valueStored=setTitleString(this,proposedValue)



            set(this,'Title',proposedValue);
            valueStored='';


            function newValue=setPaperOrientation(this,proposedValue)

                newValue=proposedValue;
                this.MaximizeImage=strcmp(proposedValue,'maximize');

