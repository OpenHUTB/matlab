function out=execute(thisComp,parentDoc,varargin)



















    out=[];
    adSL=rptgen_sl.appdata_sl;
    switch lower(adSL.Context)
    case{'','model','none'}
        currObj=adSL.CurrentModel;
    case{'system'}
        currObj=adSL.CurrentSystem;
    otherwise

        return
    end


    opt=Advisor.Options.getInstance();
    previousOptSetting=opt.PrettyPrint;
    opt.PrettyPrint=true;

    mdlObj=get_param(bdroot(currObj),'Object');
    mdladvObject=mdlObj.getModelAdvisorObj;
    if isempty(mdladvObject)
        status(thisComp,sprintf(getString(message('RptgenSL:rsl_CModelAdvisor:couldNotRetriedObjectMsg'))),1);
        error(message('Simulink:rptgen_sl:UnableGetMAObj'));
    end



    if~ispref('modeladvisor','removeExtensiveChecks')
        addpref('modeladvisor','removeExtensiveChecks','ask');
    end
    origPref=getpref('modeladvisor','removeExtensiveChecks');
    scopeResetPref=onCleanup(@()setpref('modeladvisor','removeExtensiveChecks',origPref));
    setpref('modeladvisor','removeExtensiveChecks','Continue');

    if~(thisComp.ReuseReport&&Simulink.ModelAdvisor.reportExists(currObj))
        checksID=modeladvisorprivate('modeladvisorutil2','FeatureControl','RptGenChecks');
        if ischar(checksID)
            switch checksID
            case 'Simulink'
                mdladvObject=Simulink.ModelAdvisor.getModelAdvisor(currObj,'new');
                SLFolder=mdladvObject.getTaskObj('_SYSTEM_By Product_Simulink');
                SLFolder.changeSelectionStatus(true);
                SLFolder.runTaskAdvisor;
            case 'all'
                mdladvObject=Simulink.ModelAdvisor.getModelAdvisor(currObj,'new');
                mdladvObject.selectCheckAll;
                mdladvObject.runCheck;
            otherwise
                mdladvObject=Simulink.ModelAdvisor.getModelAdvisor(currObj,'new');
                mdladvObject.deselectCheckAll;
                mdladvObject.selectCheck(checksID);
                mdladvObject.runCheck;
            end
        else
            mdladvObject=Simulink.ModelAdvisor.getModelAdvisor(currObj,'new');
            mdladvObject.deselectCheckAll;
            mdladvObject.selectCheck(checksID);
            mdladvObject.runCheck;
        end
    end
    origSystem=mdladvObject.System;
    mdladvObject.System=currObj;

    adRG=rptgen.appdata_rg;
    maFile=adRG.getImgName('html','ModelAdvisor');
    mdladvObject.exportReport(maFile.fullname);
    mdladvObject.System=origSystem;





    f=fopen(maFile.fullname,'r','n','utf-8');
    maFileContents=fread(f,'*char')';
    fclose(f);

    maFileContents=regexprep(maFileContents,'<img border="0" src="(\w*).png" />',['<img border="0" src="',fileparts(maFile.relname),'/$1.png">']);
    maFileContents=regexprep(maFileContents,'<img src="(\w*).png" />',['<img src="',fileparts(maFile.relname),'/$1.png">']);
    f=fopen(maFile.fullname,'w','n','utf-8');
    fprintf(f,'%s',maFileContents);
    fclose(f);

    try
        if rptgen.use_java
            out=com.mathworks.toolbox.rptgencore.docbook.FileImporter.importExternalFile(...
            maFile.relname,...
            java(parentDoc),...
            'Model Advisor');
        else
            out=rptgen.internal.docbook.FileImporter.importExternalFile(...
            maFile.relname,...
            parentDoc.Document,...
            'Model Advisor');
        end
        adRG.PostConvertImport=true;

    catch ME
        status(this,sprintf(getString(message('RptgenSL:rsl_CModelAdvisor:couldNotImportMsg')),currObj),2);
        status(this,ME.message,5,0);
    end


    opt.PrettyPrint=previousOptSetting;