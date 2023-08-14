function fcnName=getSlFunctionName(block)





    [~,~,fcnName]=autosar.validation.ClientServerValidator.getBlockInOutParams(block);

end
