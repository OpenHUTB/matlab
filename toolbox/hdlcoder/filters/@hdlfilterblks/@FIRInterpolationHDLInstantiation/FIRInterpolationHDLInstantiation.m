function this=FIRInterpolationHDLInstantiation(block)








    this=hdlfilterblks.FIRInterpolationHDLInstantiation;

    supportedBlocks={'dspmlti4/FIR Interpolation'};

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','FIR Interpolation HDL instantiation',...
    'HelpText','FIR Interpolation code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Fully Parallel'},...
    'CodeGenMode','instantiation',...
    'Description',desc,...
    'DeprecatedArchName',{'default'});
