function[licenseFound]=power_checklicense(verbose)











    narginchk(0,1);
    if(nargin<1)
        verboseMode=false;
    else
        if strcmpi(verbose,'1')||strcmpi(verbose,'true')
            verboseMode=true;
        else
            verboseMode=false;
        end
    end


    getCheckLicense=ssc_private('ssc_checklicense');
    licenseFound=getCheckLicense(verboseMode);


    if(licenseFound==0&&verboseMode~=0)
        beep;
        Erreur.message='Unable to check out a Simscape Electrical license.  Check installation and license';
        Erreur.identifier='SpecializedPowerSystems:CheckLicense:UnckeckedLicense';
        psberror(Erreur.message,Erreur.identifier,'NoUiwait');
    end
