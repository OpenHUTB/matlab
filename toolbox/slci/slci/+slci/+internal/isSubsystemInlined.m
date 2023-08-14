


function[isInlined]=isSubsystemInlined(blkH)



    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>


    ssType=slci.internal.getSubsystemType(get_param(blkH,'Object'));
    ssType=lower(ssType);

    switch ssType
    case{'virtual','variant'}
        isAtomic=false;

    case 'stateflow'
        pHArray=get_param(blkH,'PortHandles');
        isAtomic=strcmpi(get_param(blkH,'TreatAsAtomicUnit'),'on')...
        ||~isempty(pHArray.Trigger);

    case{'enable','function-call','trigger','action','for','foreach','iterator','while'}
        isAtomic=true;

    case 'atomic'

        isAtomic=true;
    otherwise


        isInlined=false;
        return;
    end
    isInlined=~isAtomic||strcmpi(get_param(blkH,'RTWSystemCode'),'Inline');
end
