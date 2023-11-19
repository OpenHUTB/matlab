function simrfV2_checksparam(data,freq,Z0)

    validateattributes(data,{'numeric'},...
    {'nonempty','finite'},'','S-parameter');

    if~isempty(freq)
        validateattributes(freq,{'numeric'},...
        {'nonempty','finite','nonnegative','real','vector'},...
        '','Frequency information with S-parameter data');
    end

    [n1,n2,m]=size(data);

    if(n1~=n2)
        error(message('simrf:simrfV2errors:DataNotSquare','S-parameters'));
    end

    if(m~=length(freq))&&~(m==1&&isempty(freq))
        error(message('simrf:simrfV2errors:IncompleteData'));
    end

    if isscalar(real(Z0))
        validateattributes(real(Z0),{'numeric'},...
        {'nonempty','finite','positive','scalar'},...
        '','Reference Impedance information with S-parameter data');
    else
        validateattributes(Z0,{'numeric'},...
        {'nonempty','row','size',[1,n1],'real','positive','finite'},...
        '','Reference Impedance information with S-parameter data');
    end