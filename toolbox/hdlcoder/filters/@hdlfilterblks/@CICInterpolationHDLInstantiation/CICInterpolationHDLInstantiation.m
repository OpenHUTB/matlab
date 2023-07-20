function this=CICInterpolationHDLInstantiation(block)








    this=hdlfilterblks.CICInterpolationHDLInstantiation;

    supportedBlocks={...
    ['dspmlti4/CIC Interpolation'],...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','CIC Interpolation HDL instantiation',...
    'HelpText','CIC Interpolation code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'CodeGenMode','instantiation',...
    'Description',desc);
