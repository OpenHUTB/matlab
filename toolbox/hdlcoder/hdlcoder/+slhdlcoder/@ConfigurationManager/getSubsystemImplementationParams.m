function params=getSubsystemImplementationParams(this,slBlockPath)










    params={};

    [~,implInfo]=getImplementationForBlock(this,slBlockPath);

    if~isempty(implInfo)

        params=implInfo.Parameters;


        params=params(2:end);
    end

