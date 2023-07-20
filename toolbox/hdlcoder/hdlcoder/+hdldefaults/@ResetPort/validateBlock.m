function v=validateBlock(this,hC)


    v=baseValidateCtlPort(this,hC);

    if 2==slfeature('ResettableSubsystem')
        slbh=hC.SimulinkHandle;
        if this.isInHwFriendly(hC)
            v=checkParam(v,slbh,'ResetTriggerType',{'level hold'},...
            'hdlcoder:validate:resettabletriggertype');
        else
            v=hdlvalidatestruct(1,message('hdlcoder:validate:ResetPortNotSupported'));
        end
    else

        v=hdlvalidatestruct(1,message('hdlcoder:validate:ResetPortNotSupported'));
    end

    hN=hC.Owner;
    insts=hN.instances;
    for ii=1:numel(insts)
        parent=insts(ii).Owner;
        if parent.isInResettableHierarchy
            blockPath=[hN.FullPath,'/',hC.Name];
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:CannotNestResetSS',blockPath));%#ok<AGROW>
        elseif parent.isInConditionalHierarchy&&~(parent.isInTriggeredHierarchy&&parent.getWithinHWFriendlyHierarchy)
            blockPath=[hN.FullPath,'/',hC.Name];
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:CannotNestResetSSInsideConditionalSS',blockPath));%#ok<AGROW>
        end
    end


    if~hdlgetparameter('MinimizeGlobalResets')&&hdlgetparameter('AsyncResetPort')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:AsyncResetPortNotSupported'));
    end

end

function v=checkParam(v,slbh,param,expectedValues,errmsg,errmsgargs)
    if nargin<6
        errmsgargs=[];
    end
    isMatched=0;
    slbParamValue=get_param(slbh,param);

    if iscell(expectedValues)

        for ii=1:length(expectedValues)
            expectedValue=expectedValues{ii};


            if strcmpi(slbParamValue,expectedValue)
                isMatched=1;
                break
            end
        end
    else
        isMatched=strcmp(slbParamValue,expectedValues);
    end

    if~isMatched
        if isempty(errmsgargs)
            v(end+1)=hdlvalidatestruct(1,message(errmsg));
        else
            v(end+1)=hdlvalidatestruct(1,message(errmsg,errmsgargs{:}));
        end
    end
end


