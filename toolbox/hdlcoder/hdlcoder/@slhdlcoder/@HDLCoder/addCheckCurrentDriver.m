








function addCheckCurrentDriver(lvlB,msgObj,varargin)


    hDriver=hdlcurrentdriver();

    bypass_assertion=false;
    if(nargin>=3)
        assert(strcmpi(varargin{1},'log to terminal if required'));
        bypass_assertion=true;
    end

    if(bypass_assertion&&isempty(hDriver))
        switch upper(lvlB)
        case 'WARNING'
            warning(msgObj);
        case 'ERROR'
            error(msgObj);
        otherwise
            assert(false)
        end
    else
        assert(~isempty(hDriver)&&isa(hDriver,'slhdlcoder.HDLCoder'))
        hDriver.addCheck(hDriver.ModelName,lvlB,msgObj);
    end

    return
end
