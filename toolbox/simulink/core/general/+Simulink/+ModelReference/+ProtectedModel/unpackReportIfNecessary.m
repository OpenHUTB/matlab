function dstDir=unpackReportIfNecessary(protectedModelFile,varargin)






    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;

    [opts,fullName]=getOptions(protectedModelFile);
    dstDir='';

    if opts.report

        getPasswordFromDialog(opts.modelName,'','SIM',true);



        setCurrentTarget(opts.modelName,'sim');


        buildDirs=RTW.getBuildDir(opts.modelName);

        if slsvTestingHook('ProtectedModelCleanupTest')

            rootSimDir=getSimBuildDir();
        elseif nargin==3&&ischar(varargin{1})

            rootSimDir=varargin{1};
        else

            rootSimDir=tempname;
        end
        dstDir=fullfile(rootSimDir,buildDirs.ModelRefRelativeSimDir);

        try

            year=RelationshipReport.getRelationshipYear();


            writeRelationship(fullName,dstDir,'html',year);
            unpackReportSummary(fullName,dstDir);


            year=RelationshipConfigSet.getRelationshipYear();
            writeRelationship(fullName,dstDir,'configset',year);
        catch me
            if strcmp(me.identifier,'Simulink:protectedModel:ProtectedModelWrongPassword')
                myException=getWrongPasswordDetailedException(opts.modelName,'SIM');
                myException.throw;
            else
                rethrow(me);
            end
        end
    end
end

