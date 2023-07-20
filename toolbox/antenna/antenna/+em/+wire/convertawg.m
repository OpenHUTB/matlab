function diam=convertawg(gauge)
    if isnumeric(gauge)
        validateattributes(gauge,{'numeric'},...
        {'nonempty','scalar','finite','integer','nonnegative','<=',40})
        g=gauge;
    elseif ischar(gauge)
        g=awgstr2num(gauge);
    end
    diam=0.000127*92^((36-g)/39);
end

function g=awgstr2num(gauge)



















    if~isempty(regexp(gauge,'[^0-9/]','once'))
        error('disallowed character')
    end

    i=regexp(gauge,'/0');
    if~isempty(i)
        if~isscalar(i)||i==1||~any(gauge(i-1)=='1234')
            error('Expected string ''1/0'', ''2/0'', ''3/0'', or ''4/0''.')
        end
        g=1-str2double(gauge(i-1));
    elseif all(gauge=='0')
        if numel(gauge)>4
            error('Expected string ''0'', ''00'', ''000'', or ''0000''.')
        end
        g=1-numel(gauge);
    else
        g=str2double(gauge);
        if~isscalar(g)||g~=round(g)||g<0||g>40
            error('Expected string to be a nonnegative scalar integer with value <= 40.')
        end
    end
end
