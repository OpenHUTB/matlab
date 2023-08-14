
function[impl,implInfo]=localGetImplementation(this,table,blockLibPath,slBlockPath)



    impl=[];
    implInfo=[];
    implSet=table.getImplementationSet(slBlockPath);
    if~isempty(implSet)

        impl=implSet.getImplementation(blockLibPath,this);

        implInfo=implSet.getImplInfoForBlockLibPath(blockLibPath);
    end
