function clear(h,preserveBuildDir)



    if nargin==1
        preserveBuildDir=false;
    end

    h.Registry=[];
    if~preserveBuildDir
        h.BuildDir='';
        h.BuildDirRoot='';
        h.RelativeBuildDir='';
        h.ModelRefRelativeBuildDir='';
    end
    h.LastWarning={};
    h.GeneratedFiles=[];
    h.ModelVersionAtBuild='';
    h.ModelDirtyAtBuild=false;
    h.ModelFileNameAtBuild='';
    h.TimeStamp=0.0;
    h.ModifiedTimeStamp=0.0;
    h.ReducedBlocks=[];
    h.InsertedBlocks=[];
    h.SourceSystem='';
    h.TmpModel='';
    h.SystemMap=[];
    h.ReuseInfo=[];
    h.ReuseMap=[];

    h.IsTestHarnes=false;
    h.HarnessOwner='';
    h.HarnessName='';
    h.OwnerFileName='';
