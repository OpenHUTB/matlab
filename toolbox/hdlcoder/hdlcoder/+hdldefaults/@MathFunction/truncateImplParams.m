function implInfo=truncateImplParams(~,slbh,implInfo)

    params={};
    if slbh<0
        return;
    end

    fcnName=get_param(slbh,'Function');

    MantissaStrategy={...
    'square',...
'magnitude^2'...
    };

    noDenormFcns={...
    'hypot',...
    'conj',...
    'transpose',...
'hermitian'...
    };

    noLatency={...
    'conj',...
    'transpose',...
'hermitian'...
    };






    if~(strcmp(fcnName,'mod')||strcmp(fcnName,'rem'))
        params={'checkresettozero','maxiterations'};
    end

    if~(strcmp(fcnName,'reciprocal'))
        params=[params,{'divisionalgorithm'}];
        params=[params,{'nfpcustomlatency'}];

        latStrat=implInfo('latencystrategy');
        customIdx=ismember(latStrat.AllValues,'Custom');
        latStrat.AllValues(customIdx)=[];
        implInfo('latencystrategy')=latStrat;
    end










    if any(strcmp(fcnName,noDenormFcns))
        params=[params,{'handledenormals'}];
    end



    if any(strcmp(fcnName,noLatency))
        params=[params,{'latencystrategy'}];
    end



    if~any(strcmp(fcnName,MantissaStrategy))
        params=[params,{'mantissamultiplystrategy'}];
    end


    if~isempty(params)
        implInfo.remove(params);
    end

    return



