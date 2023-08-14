function result=getSimCompiler()




    compInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo();
    result=Simulink.packagedmodel.getSimCompilerFromCompInfo(compInfo);
end
