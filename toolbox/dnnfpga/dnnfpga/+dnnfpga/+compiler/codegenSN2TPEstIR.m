function IR=codegenSN2TPEstIR(snet,cnnp,varargin)





    input.net=snet;
    p=inputParser;
    addParameter(p,'exponentData',[]);

    addParameter(p,'LegLevel',false,@islogical);
    addParameter(p,'hasTrueOutputLayer',true,@islogical);
    addParameter(p,'hasTrueInputLayer',true,@islogical);

    addParameter(p,'hasTransposedConv',false,@islogical);
    addParameter(p,'hasUnpool',false,@islogical);
    addParameter(p,'unpoolRemainder',[0;0],@isnumeric);
    addParameter(p,'maxpoolType',0,@isnumeric);

    addParameter(p,'ProcessorConfig',[]);
    addParameter(p,'ParentDataFormat',[],@(x)isa(x,'dnnfpga.dagCompile.DataFormat'));
    addParameter(p,'Verbose',1);

    parse(p,varargin{:});

    ExponentsData=p.Results.exponentData;
    legLevel=p.Results.LegLevel;
    hasTrueOutputLayer=p.Results.hasTrueOutputLayer;
    hasTrueInputLayer=p.Results.hasTrueInputLayer;
    hasTransposedConv=p.Results.hasTransposedConv;
    hasUnpool=p.Results.hasUnpool;
    unpoolRemainder=p.Results.unpoolRemainder;
    maxpoolType=p.Results.maxpoolType;
    verbose=p.Results.Verbose;







    if~legLevel

        input.argin={'exponentData',ExponentsData,...
        'hasTrueOutputLayer',hasTrueOutputLayer,...
        'hasTrueInputLayer',hasTrueInputLayer,...
        'isEstimator',true};
        dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.cnn5ProcessorFrontend(),dnnfpga.compiler.cnn5ProcessorTransformChain(),dnnfpga.compiler.cnn5NilBackend());
    else



        input.argin={...
        'exponentData',ExponentsData,...
        'hasTrueOutputLayer',hasTrueOutputLayer,...
        'hasTrueInputLayer',hasTrueInputLayer,...
        'hasTransposedConv',hasTransposedConv,...
        'hasUnpool',hasUnpool,...
        'unpoolRemainder',unpoolRemainder,...
        'maxpoolType',maxpoolType,...
        'Verbose',verbose,...
        'isEstimator',true};
        dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.seriesNetworkAndPIRFrontend(),dnnfpga.compiler.cnn4ProcessorTransformChain(),dnnfpga.compiler.nilBackend());
    end




    IR=dc.compile(input,varargin{:});
end

