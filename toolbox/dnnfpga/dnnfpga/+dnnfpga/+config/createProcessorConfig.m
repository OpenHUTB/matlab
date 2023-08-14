function hPC=createProcessorConfig(varargin)





    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    p=inputParser;
    p.addParameter('Bitstream','',@(x)ischar(x)||isstring(x));



    p.addParameter('ProcessorType','cnn5');
    p.addParameter('ShowHidden',false);

    p.parse(varargin{:});
    inputArgs=p.Results;

    processorType=inputArgs.ProcessorType;
    showHidden=inputArgs.ShowHidden;
    bitstreamName=inputArgs.Bitstream;


    try
        dnnfpga.utilscripts.checkUtility;
    catch ME

        throwAsCaller(ME);
    end


    if~isempty(bitstreamName)



        hBitstreamManager=dnnfpga.bitstream.BitstreamManager;
        exampleStrTemplate='hPC = dlhdl.ProcessorConfig(''Bitstream'', ''%s'')';



        hBitstream=hBitstreamManager.resolveBitstream(bitstreamName,exampleStrTemplate);


        hPC=hBitstream.getProcessorConfig();

    else

        switch(processorType)
        case 'cnn5'

            hPC=dnnfpga.config.CNN5ProcessorConfig();
        case 'cnn4'

            hPC=dnnfpga.config.CNN4ProcessorConfig();
        case 'cnn2'

            hPC=dnnfpga.config.CNN2ProcessorConfig();
        case 'unit'

            hPC=dnnfpga.config.CNNUnitProcessorConfig();
        otherwise
            error(message('dnnfpga:workflow:InvalidProcessorType',processorType));
        end
    end


    hPC.ShowHidden=showHidden;

end


