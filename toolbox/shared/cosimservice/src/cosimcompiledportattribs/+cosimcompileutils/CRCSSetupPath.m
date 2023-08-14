
function CRCSSetupPath(modelPath,blockPathHash,currFolder,reuseArtifacts)

    [modelDir,modelName,~]=fileparts(modelPath);

    fxVar=['cosim__wrapper__fx__',modelName];
    ocVar=['cosim__wrapper__oc__',modelName];


    folderFixtureStr='matlab.unittest.fixtures.WorkingFolderFixture';
    pathFixtureStr=['matlab.unittest.fixtures.PathFixture(''',modelDir,''')'];
    if reuseArtifacts
        reusablePath=cosimcompileutils.CRCSArtifactsMgr.getInstance().getReusablePath(modelPath,currFolder,blockPathHash);
        folderFixtureStr=['matlab.unittest.fixtures.CurrentFolderFixture(''',reusablePath,''')'];
    end
    evalin('base',[fxVar,'= [',folderFixtureStr,';',...
    pathFixtureStr,'];']);

    evalin('base',['arrayfun(@(x) x.setup,',fxVar,');']);


    evalin('base',[ocVar,' = onCleanup(@() arrayfun(@(x) x.delete,',fxVar,'));']);

end