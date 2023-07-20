function thisBase=MachineFieldCircuitBase(name,statorBase,fundamentalParameters,parameterName,parameterValue)%#codegen






    coder.allowpcode('plain');


    thisBase=ee.internal.perunit.createEmptyMachineFieldCircuitBase();

    thisBase.Name=name;



    if strcmp('baseefd',parameterName)
        baseefd=parameterValue;
        thisBase.v=baseefd*fundamentalParameters.Rfd/fundamentalParameters.Lad;
        thisBase.i=(statorBase.SRated/baseefd)/fundamentalParameters.Lad;
    elseif strcmp('baseifd',parameterName)
        baseifd=parameterValue;
        thisBase.i=baseifd/fundamentalParameters.Lad;
        thisBase.v=(statorBase.SRated/baseifd)*fundamentalParameters.Rfd/fundamentalParameters.Lad;
    elseif strcmp('baseEfd',parameterName)
        baseEfd=parameterValue;
        thisBase.v=baseEfd;
        thisBase.i=(statorBase.SRated*fundamentalParameters.Rfd)/(fundamentalParameters.Lad^2*baseEfd);
    elseif strcmp('baseIfd',parameterName)
        baseIfd=parameterValue;
        thisBase.i=baseIfd;
        thisBase.v=(statorBase.SRated*fundamentalParameters.Rfd)/(fundamentalParameters.Lad^2*baseIfd);
    elseif strcmp('Lafd_H',parameterName)
        Lafd=parameterValue;
        thisBase.i=(statorBase.L*statorBase.i)/Lafd;
        thisBase.v=(statorBase.SRated*fundamentalParameters.Rfd)/(fundamentalParameters.Lad^2*thisBase.i);
    else
        pm_error('physmod:ee:library:PerUnitMachineCircuitBaseParameterName','parameterName');
    end


    thisBase.Z=thisBase.v/thisBase.i;
    thisBase.R=thisBase.Z;
    thisBase.X=thisBase.Z;
