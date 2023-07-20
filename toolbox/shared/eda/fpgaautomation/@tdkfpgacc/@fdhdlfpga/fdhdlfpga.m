function this=fdhdlfpga(varargin)




    this=tdkfpgacc.fdhdlfpga;
    this.SubComponentName=DAStudio.message('HDLShared:fdhdldialog:fdhdlfpgaComponentName');

    this.FPGAProperties=fpgaworkflowprops.FDHDLCoder;


    this.fpgaPropToSource;


