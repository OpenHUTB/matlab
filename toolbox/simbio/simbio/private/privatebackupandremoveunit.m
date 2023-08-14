function mw_unitbackupfile=privatebackupandremoveunit(unitname,backuplibfile)
















    mw_unitbackupfile='';


    if(backuplibfile)
        mw_unitlibfile=[prefdir,filesep,'SimBiology',filesep,'userdefunits.sbulib'];
        mw_unitbackupfile=[tempname,'_userdefunits.sbulib'];
        copyfile(mw_unitlibfile,mw_unitbackupfile);
    end


    sbioremovefromlibrary('unit',unitname);

    return;

