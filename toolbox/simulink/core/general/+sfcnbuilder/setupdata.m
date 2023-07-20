function ad=setupdata(blockHandle,rtwsimTest)




    ad.DefaultTitle=['S-Function Builder: ',strrep(getfullname(blockHandle),newline,' ')];
    ad.IncPathExists=0;
    if isappdata(0,'SfunctionBuilderIncludePath')
        ad.IncludeDir=getappdata(0,'SfunctionBuilderIncludePath');
    else
        SfunBuilderAddIncludePath=cell(1,3);
        SfunBuilderAddIncludePath{1}=pwd;
        ad.IncludeDir=SfunBuilderAddIncludePath;
        setappdata(0,'SfunctionBuilderIncludePath',ad.IncludeDir);
        ad.IncPathExists=1;
    end
    ad.rtwsimTest=rtwsimTest;
    ad.PathName=pwd;
    ad.Overwritable='';
    ad.compileSuccess=0;
    ad.CreateCompileMexFileFlag=1;
    ad.AlertOnClose=0;
    if nargin
        ad.inputArgs=blockHandle;
    else
        ad.inputArgs='';
    end
    ad.blockName=getfullname(blockHandle);
    ad=sfcnbuilder.setupSfunWizardData(ad);
end