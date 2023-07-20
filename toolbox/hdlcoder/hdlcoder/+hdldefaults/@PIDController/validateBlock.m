
function v=validateBlock(this,hC)%#ok<INUSL>


    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;

    td=get_param(bfp,'TimeDomain');
    if any(strcmpi(td,'Continuous-time'))
        errorStatus=1;
        v(end+1)=hdlvalidatestruct(errorStatus,message('hdlcoder:validate:PIDControllerContinuous'));
    end

    usesDerivative=any(strcmp(get_param(bfp,'Controller'),{'PID','PD'}));
    uf=strcmp(get_param(bfp,'UseFilter'),'on');
    if usesDerivative&&~uf
        errorStatus=1;
        v(end+1)=hdlvalidatestruct(errorStatus,message('hdlcoder:validate:PIDControllerFilteredDerivative'));
    end

    fm=get_param(bfp,'FilterMethod');
    if usesDerivative&&uf&&any(strcmpi(fm,{'Backward Euler','Trapezoidal'}))
        errorStatus=1;
        v(end+1)=hdlvalidatestruct(errorStatus,message('hdlcoder:validate:PIDControllerLoop'));
    end

    ics=get_param(bfp,'InitialConditionSource');
    if any(strcmpi(ics,'external'))
        errorStatus=1;
        v(end+1)=hdlvalidatestruct(errorStatus,message('hdlcoder:validate:PIDControllerExternal'));
    end

    er=get_param(bfp,'ExternalReset');
    if~any(strcmpi(er,{'none','level'}))
        errorStatus=1;
        v(end+1)=hdlvalidatestruct(errorStatus,message('hdlcoder:validate:PIDExternalResetModeNotSupported'));
    end

    if any(strcmpi(get_param(bfp,'AntiWindupMode'),'clamping'))
        hCRn=hC.ReferenceNetwork;
        for ii=1:length(hCRn.PirInputSignals)
            if hCRn.PirInputSignals(ii).Type.isDoubleType
                errorStatus=1;
                v(end+1)=hdlvalidatestruct(errorStatus,message('hdlcoder:validate:PIDClampingDoubleType'));%#ok<AGROW>
                break;
            end
        end
    end

end
