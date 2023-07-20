



function generateRTEMain(modelName,buildDir,overrideMain)
    narginchk(2,3);
    if nargin<3
        overrideMain=false;
    end

    mainfile=coder.internal.rte.SchedulingServiceGenerator.getMainFile(modelName,buildDir);


    if isfile(mainfile)&&~overrideMain

        return
    end

    mainGenerator=coder.internal.rte.SchedulingServiceGenerator(modelName,buildDir);
    mainGenerator.generateSDPMain();
end