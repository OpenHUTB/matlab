function f=createEmptySynchronousFundamental()%#codegen




    coder.allowpcode('plain');

    f=struct(...
    'Lad',nan,...
    'Laq',nan,...
    'L0',nan,...
    'Ll',nan,...
    'Ra',nan,...
    'Lfd',nan,...
    'Rfd',nan,...
    'L1d',nan,...
    'R1d',nan,...
    'num_q_dampers',nan,...
    'L1q',nan,...
    'R1q',nan,...
    'L2q',nan,...
    'R2q',nan,...
    'Ld',nan,...
    'Lq',nan,...
    'Lffd',nan,...
    'Lf1d',nan,...
    'L11d',nan,...
    'L11q',nan,...
    'L22q',nan,...
    'saturation_option',nan,...
    'axes_param',nan,...
    'saturation',ee.internal.machines.createEmptySynchronousSaturation());
end

