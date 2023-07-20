function HandleProtectedModels(block,h)



    modelFile=get_param(block,'ModelFile');
    [~,~,modelExt]=fileparts(modelFile);

    fullPath=which(modelFile);

    if(strcmpi(modelExt,'.mdlp')||...
        ((~isempty(fullPath))&&...
        (~slInternal('isProtectedModelFromThisSimulinkVersion',fullPath))))
        message=DAStudio.message('Simulink:protectedModel:protectedModelSimulinkVersionMismatchForSlUpdate');
        appendTransaction(h,block,message,{});
    end
end


