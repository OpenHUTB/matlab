function[initVal,numDelays,delayorder,includecurrent]=getBlockInfo(this,hC)

    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;
        initVal=sysObjHandle.InitialConditions;
        numDelays=sysObjHandle.NumberOfDelays;
        delayorder=getDelayOrderIdx(sysObjHandle.OutputOrder);
        includecurrent=double(sysObjHandle.CurrentInputInOutput);
    elseif isTappedDelaySystemBlock(hC)
        slbh=hC.SimulinkHandle;
        initVal=hdlslResolve('InitialConditions',slbh);
        numDelays=hdlslResolve('NumberOfDelays',slbh);
        delayorder=getDelayOrder(slbh,'OutputOrder');
        includecurrent=getIncludeCurrent(slbh,'CurrentInputInOutput');
    else
        slbh=hC.SimulinkHandle;
        initVal=getInitialValue(slbh);
        numDelays=getDelayLength(slbh);
        delayorder=getDelayOrder(slbh,'DelayOrder');
        includecurrent=getIncludeCurrent(slbh,'includeCurrent');
    end

end

function delayorder=getDelayOrder(slbh,delayOrder)

    order=get_param(slbh,delayOrder);

    delayorder=getDelayOrderIdx(order);

end

function delayorder=getDelayOrderIdx(order)
    delayorder=0;
    if(strcmp(order,'Oldest'))
        delayorder=1;
    end

end

function ic=getIncludeCurrent(slbh,includeCurrent)

    prm=get_param(slbh,includeCurrent);

    ic=0;
    if(strcmp(prm,'on'))
        ic=1;
    end

end

function y=isTappedDelaySystemBlock(hC)

    y=false;
    try
        y=isa(hC,'hdlcoder.black_box_comp')&&...
        strcmp(get(hC.SimulinkHandle,'BlockType'),'MATLABSystem')&&...
        strcmp(get(hC.SimulinkHandle,'System'),'hdl.TappedDelay');
    catch
    end

end




function scalarIC=getInitialValue(slbh)


    scalarIC=0;
    rto=get_param(slbh,'RuntimeObject');
    np=get(rto,'NumRuntimePrms');
    for n=1:np
        if strcmp(rto.RuntimePrm(n).get.Name,'InitialCondition')
            scalarIC=rto.RuntimePrm(n).Data;
            break;
        end
    end

end



function numdelays=getDelayLength(slbh)

    numdelays=hdlslResolve('NumDelays',slbh);

end