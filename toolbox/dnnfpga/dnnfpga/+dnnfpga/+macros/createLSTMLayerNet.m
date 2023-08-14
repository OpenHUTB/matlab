function net=createLSTMLayerNet(layer,dataTransNum,inputSize)

    if nargin<2
        dataTransNum=0;
    end

    if nargin<3
        inputSize={};
    end

    if dnnfpga.dagCompile.Utils.cmpChars(layer.OutputMode,'last')
        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLSTMOutputMode',layer.Name);
        error(msg);
    end

    if dataTransNum~=0
        szOrig=[1,1,layer.InputSize];
        szNew=dnnfpga.dagCompile.DDRSupport.normalizeSizeStatic(szOrig,dataTransNum);
        if any(szNew~=szOrig)
            layerMod=dnnfpga.macros.expandLSTMInputSize(szNew(3),layer);
            net=dnnfpga.macros.createLSTMLayerNet(layerMod,0,szOrig);
            return;
        end
    end

    import dnnfpga.macros.*

    function prefixed=addPrefix(name)
        prefixed=[layer.Name,'.',name];
    end

    mem_cnt=layer.NumHiddenUnits;
    x_dim=layer.InputSize;

    [wi,wf,wo,wg,bi,bf,bo,bg]=getLSTMWeights(layer);

    lgraph=layerGraph();

    inSize=[1,1,x_dim];

    afterInputName='in';

    if~isempty(inputSize)
        inSize=inputSize;
    end




    tempLayers=imageInputLayer([1,1,mem_cnt],'Name',addPrefix('c__Read'),'Normalization','none');
    lgraph=addLayers(lgraph,tempLayers);

    tempLayers=imageInputLayer([1,1,mem_cnt],'Name',addPrefix('h__Read'),'Normalization','none');
    lgraph=addLayers(lgraph,tempLayers);

    tempLayers=imageInputLayer(inSize,'Name',addPrefix('in'),'Normalization','none');
    lgraph=addLayers(lgraph,tempLayers);

    if~isempty(inputSize)
        afterInputName='in_padded';
        tempLayers=dnnfpga.layer.padLayer([1,1,x_dim],'Name',addPrefix(afterInputName));
        lgraph=addLayers(lgraph,tempLayers);
    end

    tempLayers=dnnfpga.layer.toFCFmtLayer('Name',addPrefix('toFC'));
    lgraph=addLayers(lgraph,tempLayers);




    tempLayers=depthConcatenationLayer(2,'Name',addPrefix('depthcat'));
    lgraph=addLayers(lgraph,tempLayers);

    fci=fullyConnectedLayer(mem_cnt,'Name',addPrefix('wi'));

    fci.Weights=wi;
    fci.Bias=bi;

    tempLayers=[
fci
    sigmoidLayer('Name',addPrefix('sigmoid_1'))];

    lgraph=addLayers(lgraph,tempLayers);

    fco=fullyConnectedLayer(mem_cnt,'Name',addPrefix('wo'));

    fco.Weights=wo;
    fco.Bias=bo;

    tempLayers=[
fco
    sigmoidLayer('Name',addPrefix('sigmoid_3'))];
    lgraph=addLayers(lgraph,tempLayers);

    fcg=fullyConnectedLayer(mem_cnt,'Name',addPrefix('wg'));

    fcg.Weights=wg;
    fcg.Bias=bg;


    tempLayers=[
fcg
    tanhLayer('Name',addPrefix('tanh_1'))];

    lgraph=addLayers(lgraph,tempLayers);


    fcf=fullyConnectedLayer(mem_cnt,'Name',addPrefix('wf'));

    fcf.Weights=wf;
    fcf.Bias=bf;


    tempLayers=[
fcf
    sigmoidLayer('Name',addPrefix('sigmoid_2'))];
    lgraph=addLayers(lgraph,tempLayers);

    tempLayers=multiplicationLayer(2,'Name',addPrefix('multiplication_1'));
    lgraph=addLayers(lgraph,tempLayers);

    tempLayers=multiplicationLayer(2,'Name',addPrefix('multiplication_2'));
    lgraph=addLayers(lgraph,tempLayers);

    tempLayers=additionLayer(2,'Name',addPrefix('c_add'));
    lgraph=addLayers(lgraph,tempLayers);

    tempLayers=tanhLayer('Name',addPrefix('tanh_2'));
    lgraph=addLayers(lgraph,tempLayers);

    lgraph=connectLayers(lgraph,addPrefix('c_add'),addPrefix('tanh_2'));

    tempLayers=[
    multiplicationLayer(2,'Name',addPrefix('multiplication_3'))
    regressionLayer('Name',addPrefix('h__Write'))];
    lgraph=addLayers(lgraph,tempLayers);

    tempLayers=regressionLayer('Name',addPrefix('out'));
    lgraph=addLayers(lgraph,tempLayers);

    tempLayers=[regressionLayer('Name',addPrefix('c__Write'))];
    lgraph=addLayers(lgraph,tempLayers);



    clear tempLayers;



    lgraph=connectLayers(lgraph,addPrefix('c__Read'),addPrefix('multiplication_1/in2'));
    lgraph=connectLayers(lgraph,addPrefix('h__Read'),addPrefix('depthcat/in2'));
    if~isempty(inputSize)
        lgraph=connectLayers(lgraph,addPrefix('in'),addPrefix(afterInputName));
    end
    lgraph=connectLayers(lgraph,addPrefix(afterInputName),addPrefix('toFC'));


    lgraph=connectLayers(lgraph,addPrefix('toFC'),addPrefix('depthcat/in1'));
    lgraph=connectLayers(lgraph,addPrefix('depthcat'),addPrefix('wi'));
    lgraph=connectLayers(lgraph,addPrefix('depthcat'),addPrefix('wo'));
    lgraph=connectLayers(lgraph,addPrefix('depthcat'),addPrefix('wg'));
    lgraph=connectLayers(lgraph,addPrefix('depthcat'),addPrefix('wf'));
    lgraph=connectLayers(lgraph,addPrefix('tanh_1'),addPrefix('multiplication_2/in1'));
    lgraph=connectLayers(lgraph,addPrefix('sigmoid_3'),addPrefix('multiplication_3/in2'));
    lgraph=connectLayers(lgraph,addPrefix('sigmoid_1'),addPrefix('multiplication_2/in2'));
    lgraph=connectLayers(lgraph,addPrefix('sigmoid_2'),addPrefix('multiplication_1/in1'));
    lgraph=connectLayers(lgraph,addPrefix('multiplication_1'),addPrefix('c_add/in1'));
    lgraph=connectLayers(lgraph,addPrefix('multiplication_2'),addPrefix('c_add/in2'));
    lgraph=connectLayers(lgraph,addPrefix('tanh_2'),addPrefix('multiplication_3/in1'));
    lgraph=connectLayers(lgraph,addPrefix('c_add'),addPrefix('c__Write'));
    lgraph=connectLayers(lgraph,addPrefix('multiplication_3'),addPrefix('out'));

    net=assembleNetwork(lgraph);

end

function[wi,wf,wo,wg,bi,bf,bo,bg]=getLSTMWeights(lstmLayer)
    cell_cnt=lstmLayer.NumHiddenUnits;
    x_dim=lstmLayer.InputSize;

    pi=lstmLayer.InputWeights(1:cell_cnt,:);
    pf=lstmLayer.InputWeights(cell_cnt+1:2*cell_cnt,:);
    pg=lstmLayer.InputWeights(2*cell_cnt+1:3*cell_cnt,:);
    po=lstmLayer.InputWeights(3*cell_cnt+1:4*cell_cnt,:);

    ri=lstmLayer.RecurrentWeights(1:cell_cnt,:);
    rf=lstmLayer.RecurrentWeights(cell_cnt+1:2*cell_cnt,:);
    rg=lstmLayer.RecurrentWeights(2*cell_cnt+1:3*cell_cnt,:);
    ro=lstmLayer.RecurrentWeights(3*cell_cnt+1:4*cell_cnt,:);

    wi=horzcat(pi,ri);
    wf=horzcat(pf,rf);
    wg=horzcat(pg,rg);
    wo=horzcat(po,ro);

    bi=lstmLayer.Bias(1:cell_cnt,:);
    bf=lstmLayer.Bias(cell_cnt+1:2*cell_cnt,:);
    bg=lstmLayer.Bias(2*cell_cnt+1:3*cell_cnt,:);
    bo=lstmLayer.Bias(3*cell_cnt+1:4*cell_cnt,:);

end
