function[opName,inputSameDT]=getBlockInfo(~,hC)


    slbh=hC.SimulinkHandle;
    opName=get_param(slbh,'Operator');
    inputSameDT=get_param(slbh,'InputSameDT');
end
