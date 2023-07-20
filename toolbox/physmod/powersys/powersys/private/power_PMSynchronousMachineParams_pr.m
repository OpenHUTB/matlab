function[Params,varargout]=power_PMSynchronousMachineParams_pr(spec,Caller)%#ok










































































    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_PMSynchronousMachineParams'));
    end


    if nargin==0&&nargout==0
        powerPMSMparameterEstimator;
        return
    end


    if~exist('Caller','var')
        CmdLineCall=1;
    else
        CmdLineCall=0;
    end

    if CheckPMSMSpecs(spec,CmdLineCall);

    else

        Params=[];
        if nargout==2
            varargout{1}=[];
        end
        return
    end






    spec.lambdaUnits='V.s';

    switch lower(spec.suppliedConstant)
    case{'voltage','voltage constant'}
        spec.suppliedConstant='Voltage constant';
        spec.ke=spec.k;
        spec.keUnitsNum=spec.kUnitsNum;
        spec.keUnitsDenom=spec.kUnitsDenom;
        spec.ktUnitsNum='N.m';
        spec.ktUnitsDenom='Apeak';
    case{'torque','torque constant'}
        spec.suppliedConstant='Torque constant';
        spec.kt=spec.k;
        spec.ktUnitsNum=spec.kUnitsNum;
        spec.ktUnitsDenom=spec.kUnitsDenom;
        spec.keUnitsNum='Vpeak';
        spec.keUnitsDenom='krpm';
    case 'flux'
        spec.suppliedConstant='Flux induced by magnets';
        spec.lambda=spec.k;
        spec.ktUnitsNum='N.m';
        spec.ktUnitsDenom='Apeak';
        spec.keUnitsNum='Vpeak';
        spec.keUnitsDenom='krpm';
    end




    [Params,testParams]=power_PMSynchronousMachineConstants(spec);

    if nargout==2
        varargout{1}=testParams;
    end

    Params.Rs=spec.R/2;






    switch lower(spec.rotorType)
    case 'round'
        Params.Ls=spec.Lab/1000/2;
        Params.Ld=[];
        Params.Lq=[];
    case{'salient','salient-pole'}
        Params.Ls=[];
        Params.Ld=spec.Ld/1000;
        Params.Lq=spec.Lq/1000;
    end

    Params.p=spec.p;