
function v=validateBlock(~,hC)
    v=hdlvalidatestruct;
    referenceBlock=get_param(hC.SimulinkHandle,'ReferenceBlock');
    if~contains(referenceBlock,'HDL Optimized')
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:useHDLOptimized'));
    end
end
