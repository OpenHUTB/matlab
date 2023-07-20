function out=rtwinbat(param,value)







    mlock;

    persistent bIgnoreInBatFlag;
    persistent inBat;
    if isempty(bIgnoreInBatFlag)
        bIgnoreInBatFlag=false;
    end
    if isempty(inBat)
        inBat=false;
    end

    if nargin>0
        if nargin==2&&strcmp(param,'setIgnoreInBatFlag')&&...
            (isnumeric(value)||islogical(value))
            out=bIgnoreInBatFlag;
            bIgnoreInBatFlag=value;
            return;
        end
        if nargin==2&&strcmp(param,'setInBat')
            out=inBat;
            inBat=value;
            return;
        end
        error('unexpected error');
    end

    if bIgnoreInBatFlag
        out=false;
    else
        out=inBat;
    end

