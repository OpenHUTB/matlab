function schema





    pkg=findpackage('rptgen_hg');

    h=schema.class(pkg,'chg_ax_snap',pkg.findclass('AbstractFigSnap'));



    p=rptgen.makeProp(h,'AxesHandle','MATLAB array',[],...
    '');
    p.AccessFlags.PublicGet='on';
    p.Visible='off';



    rptgen.prop(h,'TitleType',{
    'none',getString(message('rptgen:rh_chg_ax_snap:noneLabel'))
    'name',getString(message('rptgen:rh_chg_ax_snap:nameLabel'))
    'manual',getString(message('rptgen:rh_chg_ax_snap:customLabel'))
    },'manual',getString(message('rptgen:rh_chg_ax_snap:manualLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'gr_getTitle'
'copyAxes'
    });
