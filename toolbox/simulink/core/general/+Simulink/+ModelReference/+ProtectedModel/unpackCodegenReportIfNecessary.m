function dstDir=unpackCodegenReportIfNecessary(protectedModelFile)




    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;


    [opts,fullName]=getOptions(protectedModelFile);
    buildDirs=RTW.getBuildDir(opts.modelName);
    dstDir='';

    if opts.report&&supportsCodeGen(opts)

        rootRTWDir=getRTWBuildDir();

        try

            year=RelationshipReportCodegen.getRelationshipYear();
            currentTarget=getCurrentTarget(opts.modelName);



            htmlcodegen=constructTargetRelationshipName('htmlcodegen',currentTarget);
            if strcmp(opts.codeInterface,'Top model')
                dstDir=fullfile(rootRTWDir,buildDirs.RelativeBuildDir);
            else
                dstDir=fullfile(rootRTWDir,buildDirs.ModelRefRelativeBuildDir);
            end
            writeRelationship(fullName,dstDir,htmlcodegen,year);
            unpackReportCodegenSummary(fullName,dstDir,currentTarget);


            year=RelationshipReportSharedUtils.getRelationshipYear();




            if~Creator.ReportV2
                rtwsharedutilshtml=constructTargetRelationshipName('rtwsharedutilshtml',currentTarget);
                dstDirShared=fullfile(rootRTWDir,buildDirs.SharedUtilsTgtDir);
                writeRelationship(fullName,dstDirShared,rtwsharedutilshtml,year);
            end


            configsetRel=constructTargetRelationshipName('configset',currentTarget);
            year=RelationshipConfigSetCodegen.getRelationshipYear();
            writeRelationship(fullName,dstDir,configsetRel,year);
        catch me
            if strcmp(me.identifier,'Simulink:protectedModel:ProtectedModelWrongPassword')
                myException=getWrongPasswordDetailedException(opts.modelName,'RTW');
                myException.throw;
            else
                rethrow(me);
            end
        end
    end

end

