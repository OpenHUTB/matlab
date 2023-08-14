function deployableNW=codegenforcosim(params,cnnp)



    dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.nilFrontend(),dnnfpga.compiler.cosimTransformChain(),dnnfpga.compiler.cosimBackend());
    deployableNW=dc.compile(params);
    emit(deployableNW,'.');
end

function emit(deployableNW,targetDir)%#ok<INUSL>
    save(fullfile(targetDir,'DeployableNetwork.mat'),'deployableNW');
end

