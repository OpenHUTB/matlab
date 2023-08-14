function thisBase=MachineRotorCircuitBase(name,statorBase,fundamentalParameters,parameterName,parameterValue)%#codegen






    coder.allowpcode('plain');


    thisBase=ee.internal.perunit.createEmptyMachineRotorCircuitBase();

    thisBase.Name=name;



    if strcmp('baseefd',parameterName)
        baseefd=parameterValue;
        thisBase.v=baseefd;
        thisBase.i=statorBase.SRated/thisBase.v;
    elseif strcmp('baseifd',parameterName)
        baseifd=parameterValue;
        thisBase.i=baseifd;
        thisBase.v=statorBase.SRated/thisBase.i;
    elseif strcmp('baseEfd',parameterName)
        baseEfd=parameterValue;
        thisBase.v=(fundamentalParameters.Lad/fundamentalParameters.Rfd)*baseEfd;
        thisBase.i=statorBase.SRated/thisBase.v;
    elseif strcmp('baseIfd',parameterName)
        baseIfd=parameterValue;
        thisBase.i=fundamentalParameters.Lad*baseIfd;
        thisBase.v=statorBase.SRated/thisBase.i;
    elseif strcmp('Lafd_H',parameterName)
        Lafd=parameterValue;
        thisBase.i=(statorBase.L*fundamentalParameters.Lad/Lafd)*statorBase.i;
        thisBase.v=statorBase.SRated/thisBase.i;
    else
        pm_error('physmod:ee:library:PerUnitMachineCircuitBaseParameterName','parameterName');
    end


    thisBase.Z=thisBase.v/thisBase.i;
    thisBase.R=thisBase.Z;
    thisBase.X=thisBase.Z;

end