function schema





    pkgHG=findpackage('rptgen_hg');

    h=schema.class(pkgHG,'chg_fig_snap',pkgHG.findclass('AbstractFigSnap'));




    p=rptgen.makeProp(h,'FigureHandle','MATLAB array',[],'');
    p.AccessFlags.PublicGet='on';
    p.Visible='off';



    rptgen.prop(h,'TitleType',{
    'none',getString(message('rptgen:rh_chg_fig_snap:noneLabel'))
    'name',getString(message('rptgen:rh_chg_fig_snap:nameLabel'))
    'manual',getString(message('rptgen:rh_chg_fig_snap:customLabel'))
    },'manual',getString(message('rptgen:rh_chg_fig_snap:manualLabel')));



    rptgen.makeStaticMethods(h,{
    },{
'gr_getTitle'
    });
