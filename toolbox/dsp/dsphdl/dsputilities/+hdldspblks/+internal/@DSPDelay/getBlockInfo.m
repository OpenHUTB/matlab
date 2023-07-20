function blockInfo=getBlockInfo(this,hC)




    slbh=hC.SimulinkHandle;
    blockInfo.desc=get_param(slbh,'Description');

    blockInfo.numDelays=hdlslResolve('delay',slbh);






    blockInfo.initVal=getInitValue(slbh);


    rambased=this.getImplParams('UseRAM');
    if isempty(rambased)
        blockInfo.rambased=0;
    else
        blockInfo.rambased=strcmpi(rambased,'on');
    end


end

function initVal=getInitValue(slbh)


    rto=get_param(slbh,'RuntimeObject');


    initVal=0;
    for ii=1:rto.numDworks
        if strcmp(rto.Dwork(ii).Name,'IC_BUFF')
            data=rto.Dwork(ii).Data;
            if~isempty(data)
                initVal=data;
            end
        end
    end






































end
