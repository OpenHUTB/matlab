function result=activations(this,varargin)









    p=inputParser;
    for i=1:numel(this.Network.InputNames)
        addRequired(p,strcat('inputImage',int2str(i)),@dnnfpga.apis.Workflow.validateInputImages);
    end
    addRequired(p,'Layer',@ischar);
    addParameter(p,'Verbose',this.DefaultVerbose,@isnumeric);
    addParameter(p,'Profiler','off',@dnnfpga.parseUtils.validateBoolean);
    addParameter(p,'Tile',[]);
    addParameter(p,'HardwareNormalization','auto',@dnnfpga.parseUtils.validateOnOffOrAuto);

    parse(p,varargin{:});
    activationLayer=p.Results.Layer;

    for i=1:numel(this.Network.InputNames)
        inputName=strcat('inputImage',int2str(i));
        inputImages{i}=getfield(p.Results,inputName);
    end

    verbose=p.Results.Verbose;
    profiler=dnnfpga.parseUtils.toBool(p.Results.Profiler);
    hardwareNormalization=p.Results.HardwareNormalization;
    tileActivation=p.Results.Tile;






    this.validateInputRequirements(inputImages);


    if profiler&&((numel(this.Network.InputNames)>1||numel(this.Network.OutputNames)>1))
        error(message('dnnfpga:workflow:MIMOProfilerNotSupported'));
    end


    this.validateBitstreamAndNet();



    this.checkoutLicense;




    [acts_idx,acts_lname,acts_output]=...
    dnnfpga.apis.Workflow.parseActivationLayerName(this.Network,activationLayer);
    acts_op_valid=true;


    layers=this.Network.Layers;

    currLayer=layers(acts_idx);
    isCurrFC=isa(currLayer,'nnet.cnn.layer.FullyConnectedLayer');
    isCurrConv=isa(currLayer,'nnet.cnn.layer.Convolution2DLayer');
    isCurrDropout=isa(currLayer,'nnet.cnn.layer.DropoutLayer');
    isCurrBatchNorm=isa(currLayer,'nnet.cnn.layer.BatchNormalizationLayer');

    if isCurrDropout

        acts_idx=acts_idx-1;
        acts_lname=layers(acts_idx).Name;
        acts_op_valid=false;
    elseif isCurrFC||isCurrConv


        [sourceIndices,destLayerNames,destLayerClasses]=...
        findDestinationLayers(acts_lname,layers,this.Network);


        isNextReLU=arrayfun(@(x)strcmp(x,'nnet.cnn.layer.ReLULayer'),destLayerClasses);
        isNextClippedReLU=arrayfun(@(x)strcmp(x,'nnet.cnn.layer.ClippedReLULayer'),destLayerClasses);
        isNextLeakyReLU=arrayfun(@(x)strcmp(x,'nnet.cnn.layer.LeakyReLULayer'),destLayerClasses);
        isNextBatchNorm=arrayfun(@(x)strcmp(x,'nnet.cnn.layer.BatchNormalizationLayer'),destLayerClasses);

        switch numel(sourceIndices)
        case 0

        case 1

            if isNextReLU||isNextClippedReLU||isNextLeakyReLU
                warning(message('dnnfpga:workflow:UnsupportedActivationLayer',...
                destLayerNames{1}));
                acts_idx=acts_idx+1;
                acts_lname=layers(acts_idx).Name;
                acts_op_valid=false;
            end

            if isNextBatchNorm
                warning(message('dnnfpga:workflow:UnsupportedActivationLayer',...
                destLayerNames{1}));
            end
        end

    elseif isCurrBatchNorm



        acts_idx=acts_idx-1;
        acts_lname=layers(acts_idx).Name;
        acts_op_valid=false;
    end





    this.NotRunTiledLayerPos=[];


    if(~isempty(tileActivation)&&(profiler==true))
        profiler=dnnfpga.parseUtils.toBool('off');
    end



    if strcmpi(this.Network.OutputNames,acts_lname)
        this.compile('ForceCompile',true,'Verbose',verbose,'HardwareNormalization',hardwareNormalization);

        this.deploy()

        result=this.predict(inputImages{:},'Profiler',profiler,'Verbose',verbose);
        this.NotRunTiledLayerPos=this.DeployableNet.getSingletonFPGALayer.getNotRunTiledLayerPos();


        this.DeployableNet=[];
        return;
    end


    if acts_op_valid==false


        [acts_idx,acts_lname,acts_output]=...
        dnnfpga.apis.Workflow.parseActivationLayerName(this.Network,acts_lname);
    end
    fullActivationName=[acts_lname,'/',acts_output];


    nw=this.compile('ForceCompile',true,'Verbose',verbose,'ActivationLayer',...
    fullActivationName,'ActivationTile',tileActivation,'HardwareNormalization',hardwareNormalization);



    if isa(layers(acts_idx),'nnet.cnn.layer.ImageInputLayer')&&isempty(nw.constantData)




        result=this.DeployableNet.activations(inputImages,acts_lname);
    else

        this.deploy()
        result=this.predict(inputImages{:},'Profiler',profiler,...
        'Verbose',verbose,'IsCalledFromActivations',true,'ActivationLayer',fullActivationName);
    end

    this.NotRunTiledLayerPos=this.DeployableNet.getSingletonFPGALayer.getNotRunTiledLayerPos();


    this.DeployableNet=[];

end

function[sourceIndices,destLayerNames,destLayerClasses]=...
    findDestinationLayers(lname,layers,network)

    layerNames={layers.Name};

    switch class(network)
    case 'SeriesNetwork'

        sourceIndices=find(strcmp(layerNames,lname));
        destLayer=layers(sourceIndices+1);
        destLayerNames={destLayer.Name};
        destLayerClasses={class(destLayer)};

    case{'DAGNetwork','dlnetwork'}

        connections=network.Connections;

        sourceIndices=strcmp(connections.Source,lname);

        destLayerInputNames=connections.Destination(sourceIndices);

        n=numel(destLayerInputNames);
        destLayerClasses=cell(1,n);
        destLayerNames=cell(1,n);

        for i=1:n
            destLayerInputName=destLayerInputNames{i};
            destLayerNameParts=strsplit(destLayerInputName,'/');
            destLayerNames{i}=destLayerNameParts{1};
            mask=strcmp(layerNames,destLayerNames{i});
            destLayer=layers(mask);
            destLayerClasses{i}=class(destLayer);
        end
        sourceIndices=find(sourceIndices);

    otherwise

    end
end


