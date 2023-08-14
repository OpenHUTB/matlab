function verNum=versionToNumber(versionStr,nDigits)




















    MAX_PIECES=3;

    if nargin<2
        nDigits=3;
    end

    dots=find(versionStr=='.');
    assert(numel(dots)<MAX_PIECES);

    dots=[0,dots,numel(versionStr)+1];

    baseScale=10^nDigits;
    numbers=zeros(1,MAX_PIECES);
    for i=1:numel(dots)-1
        numbers(i)=str2double(versionStr((dots(i)+1):(dots(i+1)-1)));
        assert(numbers(i)<baseScale);
        assert(mod(numbers(i),1)==0);
    end

    powers=(MAX_PIECES-1):-1:0;
    multipliers=baseScale.^powers;

    verNum=sum(numbers.*multipliers);

end
