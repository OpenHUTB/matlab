function fList=getFilterList(h)




    adSF=rptgen_sf.appdata_sf;
    reportableTypes=listReportableTypes(adSF);

    fList=[{'Name'}
reportableTypes
    strcat(reportableTypes,' (all)')
    ];

    fList=[fList,fList];