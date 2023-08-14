function obj=hdlcosim(varargin)




















    simIdx=find(cellfun(@(x)(strcmp(x,'HDLSimulator')),varargin(1:2:end)));
    if isempty(simIdx)
        hdlSimulator='ModelSim or Xcelium';
        varargin{end+1}='HDLSimulator';
        varargin{end+1}=hdlSimulator;
    else
        hdlSimulator=varargin{simIdx+1};
    end

    switch hdlSimulator
    case 'Vivado Simulator'
        obj=hdlverifier.VivadoHDLCosimulation(varargin{:});
    otherwise
        obj=hdlverifier.HDLCosimulation(varargin{:});
    end

end