function initializeFilter()

%#codegen
    isMATLAB=isempty(coder.target);

    coder.allowpcode('plain');
    if isMATLAB
        CSTlic=false;
        SITlic=false;
        licInuse=builtin('license','inuse');

        CS=any(arrayfun(@(x)strcmp(x.feature,'control_toolbox'),licInuse));
        SI=any(arrayfun(@(x)strcmp(x.feature,'identification_toolbox'),licInuse));

        if(~SI&&~CS)||SI
            [SITlic,~]=builtin('license','checkout','identification_toolbox');
            if~SITlic
                [CSTlic,~]=builtin('license','checkout','control_toolbox');
            end

        elseif CS&&~SI
            [CSTlic,~]=builtin('license','checkout','control_toolbox');
            if~CSTlic
                [SITlic,~]=builtin('license','checkout','identification_toolbox');
            end
        end

        if~CSTlic&&~SITlic
            ME=MException(message('shared_tracking:blocks:errorLicenseRequired'));
            throwAsCaller(ME);
        end

    else
        coder.license('checkout','identification_toolbox or control_toolbox');
    end
end