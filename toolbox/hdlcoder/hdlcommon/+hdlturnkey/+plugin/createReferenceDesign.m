function hRD=createReferenceDesign(varargin)





    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    p=inputParser;
    p.addParameter('SynthesisTool','Xilinx Vivado');
    p.parse(varargin{:});
    inputArgs=p.Results;

    toolName=inputArgs.SynthesisTool;


    switch lower(toolName)
    case 'xilinx vivado'
        hRD=hdlturnkey.plugin.ReferenceDesignVivado();
    case 'xilinx ise'



        hdlturnkey.plugin.validateSPInstall(toolName);
        hRD=hdlturnkey.plugin.ReferenceDesignEDK();
    case 'altera quartus ii'

        hRD=hdlturnkey.plugin.ReferenceDesignQsys();
    case 'intel quartus pro'

        hRD=hdlturnkey.plugin.ReferenceDesignQsysQpro();
    case 'microchip libero soc'
        hRD=hdlturnkey.plugin.ReferenceDesignLibero();
    otherwise
        error(message('hdlcommon:plugin:InvalidTool',toolName,...
        'Xilinx Vivado','Xilinx ISE','Altera QUARTUS II','Microchip Libero SoC'));
    end


