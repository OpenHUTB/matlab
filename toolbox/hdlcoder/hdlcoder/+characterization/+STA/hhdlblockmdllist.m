function hdlblockmdllist=hhdlblockmdllist()














    hdlblockmdllist(1).blk='HDL Streaming FFT';
    hdlblockmdllist(1).topdut='FFT_DIF';
    hdlblockmdllist(1).blkpath='HDL Streaming FFT';
    hdlblockmdllist(1).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mfftdif_512in.mdl');

    hdlblockmdllist(end+1).blk='HDL Minimum Resource FFT';
    hdlblockmdllist(end).topdut='DUT';
    hdlblockmdllist(end).blkpath='HDL FFT';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mhdlfftdit.mdl');

    hdlblockmdllist(end+1).blk='FIR Decimation';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['FIR',10,'Decimation'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mfirdecimation.mdl');

    hdlblockmdllist(end+1).blk='FIR Interpolation';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['FIR',10,'Interpolation'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mfirinterpolation.mdl');

    hdlblockmdllist(end+1).blk='CIC Decimation';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['CIC',10,'Decimation'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mcicdecimation.mdl');

    hdlblockmdllist(end+1).blk='CIC Interpolation';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['CIC',10,'Interpolation'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mcicinterpolation.mdl');

    hdlblockmdllist(end+1).blk='DocBlock';
    hdlblockmdllist(end).topdut='HDLSubsystem';
    hdlblockmdllist(end).blkpath='DocBlock';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mdocblock.mdl');

    hdlblockmdllist(end+1).blk='PN Sequence Generator';
    hdlblockmdllist(end).topdut='pnsub';
    hdlblockmdllist(end).blkpath=['PN Sequence',10,'Generator'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mpngen_genericarch.mdl');

    hdlblockmdllist(end+1).blk='Viterbi Decoder';
    hdlblockmdllist(end).topdut='DUT';
    hdlblockmdllist(end).blkpath='Viterbi Decoder';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mviterbi.mdl');

    hdlblockmdllist(end+1).blk='BPSK Demodulator Baseband';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['BPSK',10,'Demodulator',10,'Baseband'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mbpskdemod.mdl');

    hdlblockmdllist(end+1).blk='BPSK Modulator Baseband';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['BPSK',10,'Modulator',10,'Baseband'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mbpskmod.mdl');

    hdlblockmdllist(end+1).blk='M-PSK Demodulator Baseband';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['M-PSK',10,'Demodulator',10,'Baseband'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mmpskdemod.mdl');

    hdlblockmdllist(end+1).blk='M-PSK Modulator Baseband';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['M-PSK',10,'Modulator',10,'Baseband'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mmpskmod.mdl');

    hdlblockmdllist(end+1).blk='QPSK Demodulator Baseband';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['QPSK',10,'Demodulator',10,'Baseband'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mqpskdemod.mdl');

    hdlblockmdllist(end+1).blk='QPSK Modulator Baseband';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['QPSK',10,'Modulator',10,'Baseband'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mqpskmod.mdl');

    hdlblockmdllist(end+1).blk='Rectangular QAM Modulator Baseband';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['Rectangular QAM',10,'Modulator',10,'Baseband'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mrectqammod_hdl.mdl');

    hdlblockmdllist(end+1).blk='Rectangular QAM Demodulator Baseband';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['Rectangular QAM',10,'Demodulator',10,'Baseband4'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mrectqamdemod_hdl.mdl');

    hdlblockmdllist(end+1).blk='Convolutional Encoder';
    hdlblockmdllist(end).topdut='DUT';
    hdlblockmdllist(end).blkpath='CE';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mencodermdl.mdl');

    hdlblockmdllist(end+1).blk='Repeat';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Repeat';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mrepeat.mdl');

    hdlblockmdllist(end+1).blk='EnablePort';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['Enabled',10,'Subsystem/Enable'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mbasicmix2.mdl');

    hdlblockmdllist(end+1).blk='TriggerPort';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath=['Triggered',10,'Subsystem/Trigger'];
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mbasicmix_tr.mdl');

    hdlblockmdllist(end+1).blk='Goto';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Goto';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mGoToFrom.mdl');

    hdlblockmdllist(end+1).blk='From';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='From';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mGoToFrom.mdl');

    hdlblockmdllist(end+1).blk='Model Info';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Model Info';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mMdlInfo.mdl');

    hdlblockmdllist(end+1).blk='Terminator';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Terminator';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mTerminator.mdl');

    hdlblockmdllist(end+1).blk='ToFile';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='To File';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mToFile.mdl');

    hdlblockmdllist(end+1).blk='Serializer_Base';
    hdlblockmdllist(end).topdut='Serializer';
    hdlblockmdllist(end).blkpath='Serializer';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mserializer.mdl');

    hdlblockmdllist(end+1).blk='Deserializer_Base';
    hdlblockmdllist(end).topdut='Deserializer';
    hdlblockmdllist(end).blkpath='Deserializer';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mserializer.mdl');

    hdlblockmdllist(end+1).blk='Deserializer2_Base';
    hdlblockmdllist(end).topdut='Deserializer2';
    hdlblockmdllist(end).blkpath='Deserializer2';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mserializer.mdl');

    hdlblockmdllist(end+1).blk='Serializer2';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Serializer2';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mserializertype2.mdl');

    hdlblockmdllist(end+1).blk='Serializer_dsp';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Serializer_dsp';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mtestserial2.mdl');

    hdlblockmdllist(end+1).blk='Deserializer_dsp';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Deserializer_dsp';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mtestserial2.mdl');

    hdlblockmdllist(end+1).blk='Serializer2_dsp';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Serializer2_dsp';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mtestserial2.mdl');

    hdlblockmdllist(end+1).blk='Serializer1D';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Serializer1D';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mserializer1D.slx');

    hdlblockmdllist(end+1).blk='Deserializer1D';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Deserializer1D';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mdeserializer1D.slx');

    hdlblockmdllist(end+1).blk='SubSystem';
    hdlblockmdllist(end).topdut='DUT';
    hdlblockmdllist(end).blkpath='Sys';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mblkbox2.mdl');

    hdlblockmdllist(end+1).blk='Check Input  Resolution';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Check Input  Resolution';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mCheckInputResolution.mdl');

    hdlblockmdllist(end+1).blk='Stop';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Stop';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mStop.mdl');

    hdlblockmdllist(end+1).blk='modelsimlib/HDL Cosimulation';
    hdlblockmdllist(end).topdut='DUT';
    hdlblockmdllist(end).blkpath='HDL Cosimulation1';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mcosimlfm.mdl');

    hdlblockmdllist(end+1).blk='lfilinklib/HDL Cosimulation';
    hdlblockmdllist(end).topdut='DUT1';
    hdlblockmdllist(end).blkpath='HDL Cosimulation';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mcosimlfi.mdl');

    hdlblockmdllist(end+1).blk='discoverylib/HDL Cosimulation';
    hdlblockmdllist(end).topdut='DUT2';
    hdlblockmdllist(end).blkpath='HDL Cosimulation1';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mcosimlfd.mdl');

    hdlblockmdllist(end+1).blk='sflib/Truth Table';
    hdlblockmdllist(end).topdut='A2';
    hdlblockmdllist(end).blkpath='Truth Table';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mtt_basic.mdl');

    hdlblockmdllist(end+1).blk='sflib/Chart';
    hdlblockmdllist(end).topdut='subsystem_SF_DUT';
    hdlblockmdllist(end).blkpath='Chart';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mbox.mdl');

    hdlblockmdllist(end+1).blk='eml_lib/MATLAB Function';
    hdlblockmdllist(end).topdut='DUT';
    hdlblockmdllist(end).blkpath='sum';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','msimpleeml.mdl');

    hdlblockmdllist(end+1).blk='sflib/State Transition Table';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='State Transition Table';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','msimple_STT.slx');

    hdlblockmdllist(end+1).blk='hdlstreaminglib/Hardware Demux';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='demux';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mhwdemux.mdl');

    hdlblockmdllist(end+1).blk='built-in/MagnitudeAngleToComplex';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Mag';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','pol2cart04.mdl');

    hdlblockmdllist(end+1).blk='dspstat3/Minimum';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Minimum';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mminmaxd_test.mdl');

    hdlblockmdllist(end+1).blk='dspstat3/Maximum';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Maximum';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mminmaxd_test_max.mdl');

    hdlblockmdllist(end+1).blk='MATLABSystem';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='system';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mmatlab_system.slx');

    hdlblockmdllist(end+1).blk='Dual Port RAM System';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='system';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','dualportramsystem.slx');

    hdlblockmdllist(end+1).blk='Simple Dual Port RAM System';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='system';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','simpledualportramsystem.slx');

    hdlblockmdllist(end+1).blk='Single Port RAM System';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='system';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','singleportramsystem.slx');

    hdlblockmdllist(end+1).blk='DiscreteTransferFcn';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Discrete Transfer Fcn';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','DTF_for_others.mdl');

    hdlblockmdllist(end+1).blk='built-in/BusCreator';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Bus Creator';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mbus.mdl');

    hdlblockmdllist(end+1).blk='built-in/BusSelector';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Bus Selector1';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mbus.mdl');

    hdlblockmdllist(end+1).blk='built-in/Bias';
    hdlblockmdllist(end).topdut='SumBiasSaturateLogic';
    hdlblockmdllist(end).blkpath='Bias';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','bias_saturate.slx');

    hdlblockmdllist(end+1).blk='sflib/Chart (MATLAB)';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Chart_MATLAB';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mlchart.slx');

    hdlblockmdllist(end+1).blk='Cosine';
    hdlblockmdllist(end).topdut='SubsystemCosine';
    hdlblockmdllist(end).blkpath='Cosine';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','SineCosQtrWaveLUT.slx');

    hdlblockmdllist(end+1).blk='Sine';
    hdlblockmdllist(end).topdut='SubsystemSine';
    hdlblockmdllist(end).blkpath='Sine';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','SineCosQtrWaveLUT.slx');

    hdlblockmdllist(end+1).blk='Cosine HDL Optimized';
    hdlblockmdllist(end).topdut='SubsystemCosine';
    hdlblockmdllist(end).blkpath='Cosine HDL';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','HDLSineCosQtrWaveLUT.slx');

    hdlblockmdllist(end+1).blk='Sine HDL Optimized';
    hdlblockmdllist(end).topdut='SubsystemSine';
    hdlblockmdllist(end).blkpath='Sine HDL';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','HDLSineCosQtrWaveLUT.slx');

    hdlblockmdllist(end+1).blk='Dual Rate Dual Port RAM';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Dual Rate Dual Port RAM';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mram_dualratedualport.slx');

    hdlblockmdllist(end+1).blk='Enumerated Constant';
    hdlblockmdllist(end).topdut='s';
    hdlblockmdllist(end).blkpath='EnumConst';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','enumconst1.slx');

    hdlblockmdllist(end+1).blk='Discrete PID Controller';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Discrete PID Controller';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','pidcontroller.slx');

    hdlblockmdllist(end+1).blk='built-in/HitCross';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='HitCross';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','hitcross.slx');

    hdlblockmdllist(end+1).blk='Wrap To Zero';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Wrap To Zero';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','wraptozero.slx');

    hdlblockmdllist(end+1).blk='built-in/BusAssignment';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Bus Assignment';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','bus_assignment.slx');

    hdlblockmdllist(end+1).blk='built-in/BusToVector';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Bus to Vector';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','bustovector.slx');

    hdlblockmdllist(end+1).blk='DiscreteFir';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Discrete FIR Filter';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','massiveblkDFIR.slx');

    hdlblockmdllist(end+1).blk='NFPSparseConstMultiply';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='NFPSparseConstMultiply';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','matrixmult.slx');

    hdlblockmdllist(end+1).blk='Dynamic State-Space';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Dynamic State-Space';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','StateSpace.slx');

    hdlblockmdllist(end+1).blk='Fixed-Point State-Space';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Fixed-Point State-Space';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','StateSpace.slx');

    hdlblockmdllist(end+1).blk='Multiply-Accumulate';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Multiply-Accumulate';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','multiply_accumulate.slx');

    hdlblockmdllist(end+1).blk='Probe';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Probe';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mProbe.slx');

    hdlblockmdllist(end+1).blk='Fcn';
    hdlblockmdllist(end).topdut='Subsystem';
    hdlblockmdllist(end).blkpath='Fcn';
    hdlblockmdllist(end).modelpath=fullfile(matlabroot,'test','toolbox','hdlcoder','hdlcoderfiles','mFcn.slx');
end
