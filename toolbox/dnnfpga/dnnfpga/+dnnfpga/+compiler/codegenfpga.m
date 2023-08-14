function deployableNW=codegenfpga(net,cnnp,varargin)



    input.net=net;





    p=inputParser;




    addParameter(p,'InputFrameNumberLimit',30,@isnumeric);
    addParameter(p,'UniqueActivations',false,@(x)islogical(x));


    addParameter(p,'ExternalMemorySize',[],@isnumeric);


    addParameter(p,'exponentData',[]);
    addParameter(p,'verbose',1)
    addParameter(p,'target',[])
    addParameter(p,'ActivationLayer','',@ischar)
    addParameter(p,'ActivationTile',[]);


    addParameter(p,'LegLevel',false,@(x)islogical(x));
    addParameter(p,'FCWeightBaseAddrOffset',0,@isnumeric);
    addParameter(p,'ConvWeightBaseAddrOffset',0,@isnumeric);
    addParameter(p,'TopLevelDDRAddrOffsetMap',[],@(x)isa(x,'containers.Map'));
    addParameter(p,'LegLevelDDRAddrOffsetMap',[],@(x)isa(x,'containers.Map'));
    addParameter(p,'hasTrueOutputLayer',true,@(x)islogical(x));
    addParameter(p,'hasTrueInputLayer',true,@(x)islogical(x));
    addParameter(p,'maxpoolType',0,@(x)isnumeric(x));
    addParameter(p,'hasUnpool',false,@(x)islogical(x));
    addParameter(p,'unpoolRemainder',[0;0],@isnumeric);
    addParameter(p,'hasTransposedConv',false,@(x)islogical(x));

    addParameter(p,'ProcessorConfig',[]);
    addParameter(p,'ValidateTrimmableKernel',true,@(x)islogical(x));

    addParameter(p,'HardwareNormalization','auto',@dnnfpga.parseUtils.validateOnOffOrAuto);
    addParameter(p,'ParentDataFormat',[],@(x)isa(x,'dnnfpga.dagCompile.DataFormat'));

    parse(p,varargin{:});

    ExponentsData=p.Results.exponentData;
    verbose=p.Results.verbose;
    legLevel=p.Results.LegLevel;
    hasTrueOutputLayer=p.Results.hasTrueOutputLayer;
    hasTrueInputLayer=p.Results.hasTrueInputLayer;
    maxpoolType=p.Results.maxpoolType;
    hasUnpool=p.Results.hasUnpool;
    unpoolRemainder=p.Results.unpoolRemainder;
    hasTransposedConv=p.Results.hasTransposedConv;

    input.argin={...
    'exponentData',ExponentsData,...
    'hasTrueOutputLayer',hasTrueOutputLayer,...
    'hasTrueInputLayer',hasTrueInputLayer,...
    'maxpoolType',maxpoolType,...
    'hasUnpool',hasUnpool,...
    'unpoolRemainder',unpoolRemainder,...
    'hasTransposedConv',hasTransposedConv};


    try
        dnnfpga.utilscripts.checkUtility;
    catch ME

        throwAsCaller(ME);
    end

    switch(class(cnnp))
    case{'dnnfpga.processorbase.cnn5Processor'}
        if legLevel
            dnnfpga.compiler.sanityChecks(net,cnnp,ExponentsData);
        end
    otherwise
        dnnfpga.compiler.sanityChecks(net,cnnp,ExponentsData);

    end


    switch(class(cnnp))
    case{'dnnfpga.processorbase.cnn4Processor'}

        dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.seriesNetworkAndPIRFrontend(),dnnfpga.compiler.cnn4ProcessorTransformChain(),dnnfpga.compiler.cnn4ProcessorBackend(verbose));
    case{'dnnfpga.processorbase.cnn5Processor'}

        if~legLevel
            dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.cnn5ProcessorFrontend(verbose),dnnfpga.compiler.cnn5ProcessorTransformChain(verbose),dnnfpga.compiler.cnn5ProcessorBackend(verbose));
        else
            dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.cnn5LegFrontend(),dnnfpga.compiler.cnn5LegTransformChain(),dnnfpga.compiler.cnn5LegBackend(verbose));
        end
    case{'dnnfpga.processorbase.conv4Processor'}
        dc=dnnfpga.compiler.dnnCompiler(cnnp,dnnfpga.compiler.seriesNetworkAndPIRFrontend(),dnnfpga.compiler.conv4ProcessorTransformChain(),dnnfpga.compiler.conv4ProcessorBackend());
    end
    deployableNW=dc.compile(input,varargin{:});
    deployableNW.setCnnProcessor(cnnp);
end




