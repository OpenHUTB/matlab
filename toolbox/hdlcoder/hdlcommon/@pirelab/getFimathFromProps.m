function hdlfm=getFimathFromProps(satMode,rndMode)



    if~ischar(satMode)
        if satMode
            satOption='saturate';
        else
            satOption='wrap';
        end
    else
        satOption=lower(satMode);
    end

    switch lower(rndMode)
    case{'floor','simplest'}
        rndOption='floor';
    case{'ceiling','ceil'}
        rndOption='ceil';
    case 'nearest'
        rndOption='nearest';
    case{'zero','fix'}
        rndOption='fix';
    case 'convergent'
        rndOption='convergent';
    case{'matlab','round'}
        rndOption='round';
    otherwise
        error(message('hdlcommon:hdlcommon:invalidmasksetting',rndMode));
    end

    hdlfm=hdlfimath;
    hdlfm.RoundMode=rndOption;
    hdlfm.OverflowMode=satOption;

end