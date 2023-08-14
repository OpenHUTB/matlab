function[status,dscr]=silpilBlock(cs,~)

    dscr='CreateSILPILBlock is disabled if GenerateErtSFunction is disabled';

    cs=cs.getConfigSet;
    hSrc=cs.getPropOwner('CreateSILPILBlock');
    if hSrc.isReadonlyProperty('GenerateErtSFunction')
        status=configset.internal.data.ParamStatus.ReadOnly;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end

