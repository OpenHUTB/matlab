function blockInfo=getSysObjInfo(this,sysObj)%#ok





    blockInfo.N=sysObj.NumRegisters;
    blockInfo.B=sysObj.RegisterLengthStep;
    blockInfo.intdelay=(0:blockInfo.B:blockInfo.B*(blockInfo.N-1))';
    blockInfo.ic=sysObj.InitialConditions;
    blockInfo.isint=isa(sysObj,'comm.ConvolutionalInterleaver');


