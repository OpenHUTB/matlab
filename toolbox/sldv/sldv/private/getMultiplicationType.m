function status=getMultiplicationType(blockH)






    status=~strcmp(get_param(blockH,'Multiplication'),'Matrix(*)');
end
