function licenseCheck





%#codegen
    isMATLAB=isempty(coder.target);

    coder.allowpcode('plain');
    if isMATLAB
        WAlic=false;
        SPTlic=false;
        licInuse=builtin('license','inuse');
        WA=sum(arrayfun(@(x)strcmpi(x.feature,'wavelet_toolbox'),licInuse));
        SPT=sum(arrayfun(@(x)strcmpi(x.feature,'signal_toolbox'),licInuse));

        if(~SPT&&~WA)||SPT


            [SPTlic,~]=builtin('license','checkout','signal_toolbox');
            if~SPTlic
                [WAlic,~]=builtin('license','checkout','wavelet_toolbox');
            end

        elseif WA&&~SPT
            [WAlic,~]=builtin('license','checkout','wavelet_toolbox');
            if~WAlic
                [SPTlic,~]=builtin('license','checkout','signal_toolbox');
            end
        end

        if~WAlic&&~SPTlic
            ME=MException(message('shared_signalwavelet:util:general:LicRequired'));
            throwAsCaller(ME);
        end
    else
        coder.license('checkout','signal_toolbox or wavelet_toolbox');
    end

end