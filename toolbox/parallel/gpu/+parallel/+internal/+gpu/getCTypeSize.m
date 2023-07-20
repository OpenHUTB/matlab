function bytes=getCTypeSize(typeName)















    bytes=feval('_gpu_getCTypeSize',typeName);
