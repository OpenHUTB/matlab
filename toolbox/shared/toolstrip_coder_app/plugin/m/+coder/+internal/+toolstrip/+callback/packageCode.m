function packageCode(cbinfo)
    if~coder.internal.toolstrip.license.isMATLABCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','MATLAB Coder');
    end

    if~coder.internal.toolstrip.license.isSimulinkCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','Simulink Coder');
    end

    mdlH=cbinfo.model.handle;
    cs=getActiveConfigSet(mdlH);


    zipName=get_param(cs,'PackageName');
    coder.internal.verifyPackageName(zipName);


    rtwbuild(mdlH);


    if get_param(cs,'PackageGeneratedCodeAndArtifacts')=="off"
        reportInfo=simulinkcoder.internal.util.getReportInfo(mdlH,false);
        coder.internal.packageCode(reportInfo.BuildDirectory,zipName);
    end