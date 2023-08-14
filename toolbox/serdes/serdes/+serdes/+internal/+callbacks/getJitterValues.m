function[numValue,unitValue]=getJitterValues(jitter,varargin)






    if nargin==2&&varargin{1}==true
        secondsOrFloat='Float';
    else
        secondsOrFloat='Seconds';
    end

    if isempty(jitter)
        numValue=0;
        unitValue=secondsOrFloat;
    else


        unitOptions={'UI',secondsOrFloat};
        unit1=jitter.Types;
        unitValue=unitOptions{strcmp(unit1{1}.Name,'Float')+1};


        if jitter.Hidden==0&&isnumeric(jitter.CurrentValue)
            numValue=jitter.CurrentValue;
        elseif jitter.Hidden==0&&isnumeric(jitter.Default)
            numValue=jitter.Default;
        else
            numValue=0;
        end
    end
end