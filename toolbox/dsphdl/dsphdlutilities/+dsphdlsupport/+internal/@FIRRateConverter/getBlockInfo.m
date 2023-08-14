function blockInfo=getBlockInfo(this,hC)








    blockInfo=struct();

    if isa(hC,'hdlcoder.sysobj_comp')


        hSysObj=hC.getSysObjImpl;


        blockInfo.InterpolationFactor=hSysObj.InterpolationFactor;
        blockInfo.DecimationFactor=hSysObj.DecimationFactor;
        blockInfo.Numerator=hSysObj.Numerator;
        blockInfo.ReadyPort=hSysObj.ReadyPort;
        blockInfo.RoundingMethod=hSysObj.RoundingMethod;
        blockInfo.OverflowAction=hSysObj.OverflowAction;
        blockInfo.CoefficientsDataType=hSysObj.CoefficientsDataType;
        blockInfo.OutputDataType=hSysObj.OutputDataType;

    else


        hBlock=hC.SimulinkHandle;



        blockInfo.InterpolationFactor=this.hdlslResolve('InterpolationFactor',hBlock);
        blockInfo.DecimationFactor=this.hdlslResolve('DecimationFactor',hBlock);
        blockInfo.Numerator=this.hdlslResolve('Numerator',hBlock);
        blockInfo.ReadyPort=strcmpi(get_param(hBlock,'ReadyPort'),'on');
        blockInfo.RoundingMethod=get_param(hBlock,'RoundingMode');


        if strcmpi(get_param(hBlock,'OverflowMode'),'off')
            blockInfo.OverflowAction='Wrap';
        else
            blockInfo.OverflowAction='Saturate';
        end


        coefficientsFixdt=this.hdlslResolve('CoefficientsDataTypeStr',hBlock);

        blockInfo.CoefficientsDataType=numerictype(coefficientsFixdt);


        switch get_param(hBlock,'OutputDataTypeStr')
        case 'Inherit: Inherit via internal rule'
            blockInfo.OutputDataType='Full precision';
        case 'Inherit: Same word length as input'
            blockInfo.OutputDataType='Same word length as input';
        otherwise
            outputFixdt=this.hdlslResolve('OutputDataTypeStr',hBlock);
            blockInfo.OutputDataType=numerictype(outputFixdt);
        end

    end
