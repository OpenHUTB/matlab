function isProcessorOnly=isESBProcessorOnly(hObj)



    isProcessorOnly=(codertarget.targethardware.isESBCompatible(hObj,1)&&~codertarget.targethardware.isESBCompatible(hObj,2));
end

