function deployableNW=codegenSN2Cosim(snet,cnnp,varargin)



    input.net=snet;


    p=inputParser;
    addParameter(p,'exponentData',[]);

    addParameter(p,'LegLevel',false,@(x)islogical(x));
    addParameter(p,'hasTrueOutputLayer',true,@(x)islogical(x));
    addParameter(p,'hasTrueInputLayer',true,@(x)islogical(x));
    addParameter(p,'maxpoolType',0,@(x)isnumeric(x));
    addParameter(p,'hasTransposedConv',false,@(x)islogical(x));
    addParameter(p,'processorDataType','single');
    addParameter(p,'ProcessorConfig',[]);

    parse(p,varargin{:});
    ExponentsData=p.Results.exponentData;
    legLevel=p.Results.LegLevel;
    hasTrueOutputLayer=p.Results.hasTrueOutputLayer;
    hasTrueInputLayer=p.Results.hasTrueInputLayer;
    maxpoolType=p.Results.maxpoolType;
    hasTransposedConv=p.Results.hasTransposedConv;
    processorDataType=p.Results.processorDataType;
    processorConfig=p.Results.ProcessorConfig;
    isSimulator=1;

    input.argin={'exponentData',ExponentsData,...
    'hasTrueOutputLayer',hasTrueOutputLayer,...
    'hasTrueInputLayer',hasTrueInputLayer,...
    'maxpoolType',maxpoolType,...
    'hasTransposedConv',hasTransposedConv,...
    'processorDataType',processorDataType,...
    'isSimulator',isSimulator
    };


    dnnfpga.compiler.sanityChecks(snet,cnnp,ExponentsData);






    switch(class(cnnp))
    case{'dnnfpga.processorbase.cnn5Processor'}
        if~legLevel
            dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.cnn5CosimIRFrontend(),dnnfpga.compiler.cnn5CosimTransformChain(),dnnfpga.compiler.cnn5CosimBackend());
            [deployableNWArray,connections]=dc.compileDAG(input,'ProcessorConfig',processorConfig,'LegLevel',false);

            deployableNW=dnnfpga.deployablenetwork.deployableNetwork([]);

            deployableNW.setDAGNetInfo(deployableNWArray,connections);
        else

            if(strcmpi(processorDataType,'int4'))
                dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.fixedPointFrontend(),dnnfpga.compiler.fixedPointTransformChain(),dnnfpga.compiler.fixedPointBackend());
            else
                dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.seriesNetworkAndPIRFrontend(),dnnfpga.compiler.cosimTransformChain(),dnnfpga.compiler.cosimBackend());
            end
            deployableNW=dc.compile(input);
        end
    otherwise
        dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.seriesNetworkAndPIRFrontend(),dnnfpga.compiler.cosimTransformChain(),dnnfpga.compiler.cosimBackend());
        deployableNW=dc.compile(input);
    end
    emit(deployableNW,'.');
end

function emit(deployableNW,targetDir)%#ok<INUSL>
    save(fullfile(targetDir,'DeployableNetwork.mat'),'deployableNW');
end


