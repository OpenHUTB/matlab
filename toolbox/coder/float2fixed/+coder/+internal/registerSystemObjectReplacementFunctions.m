function cfg=registerSystemObjectReplacementFunctions(cfg)
    sysobjRepFcnFolder=fullfile(matlabroot,'toolbox','coder','float2fixed','dmm_emlauthoring','sysobj');

    cfg.setSystemObjectReplacementFunction('dsp.Maximum',fullfile(sysobjRepFcnFolder,'range_dsp_maximum.m'));
    cfg.setSystemObjectReplacementFunction('dsp.Minimum',fullfile(sysobjRepFcnFolder,'range_dsp_minimum.m'));
    cfg.setSystemObjectReplacementFunction('dsp.Delay',fullfile(sysobjRepFcnFolder,'range_dsp_delay.m'));
    cfg.setSystemObjectReplacementFunction('hdlram',fullfile(sysobjRepFcnFolder,'range_hdlram.m'));
    cfg.setSystemObjectReplacementFunction('hdl.RAM',fullfile(sysobjRepFcnFolder,'range_hdlram.m'));


end