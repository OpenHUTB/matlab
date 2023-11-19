function[IPfreq,OPfreq,IPBlkNames]=simrfV2_find_solverIPOPfreqs(solverblock)
    connectedBlks=simrfV2_findConnected(solverblock);
    blks=findBlksMatchingRefSystem(connectedBlks,'simrfV2util1/Inport');
    [IPfreq,IPBlkNames]=simrfV2_read_freqs(solverblock,...
    blks,'CarrierFreq',[]);

    blks=findBlksMatchingRefSystem(connectedBlks,...
    'simrfV2util1/Outport');
    OPfreq=simrfV2_read_freqs(solverblock,blks,'CarrierFreq',[]);

    blks=findBlksMatchingRefSystem(connectedBlks,...
    sprintf('simrfV2sources1/Continuous\nWave'));
    IPfreq=[IPfreq,simrfV2_read_freqs(solverblock,...
    blks,'CarrierFreq',[])];

    blks=findBlksMatchingRefSystem(connectedBlks,...
    'simrfV2sources1/Sinusoid');
    IPfreq=[IPfreq,simrfV2_read_freqs(solverblock,...
    blks,'CarrierFreq',[])];

    blks=findBlksMatchingRefSystem(connectedBlks,...
    'simrfV2systems/IQ Demodulator');
    IPfreq=[IPfreq,simrfV2_read_freqs(solverblock,blks,'LOFreq',[])];


    blks=findBlksMatchingRefSystem(connectedBlks,...
    'simrfV2systems/IQ Modulator');
    IPfreq=[IPfreq,simrfV2_read_freqs(solverblock,blks,'LOFreq',[])];


    blks=findBlksMatchingRefSystem(connectedBlks,...
    'simrfV2systems/Demodulator');
    IPfreq=[IPfreq,simrfV2_read_freqs(solverblock,blks,'LOFreq',[])];

    blks=findBlksMatchingRefSystem(connectedBlks,...
    'simrfV2systems/Modulator');
    IPfreq=[IPfreq,simrfV2_read_freqs(solverblock,blks,'LOFreq',[])];

    blks=findBlksMatchingRefSystem(connectedBlks,...
    'rfBudgetAnalyzer_lib/Modulator');
    IPfreq=[IPfreq,simrfV2_read_freqs(solverblock,blks,'LOFreq',[])];

    blks=findBlksMatchingRefSystem(connectedBlks,...
    'rfBudgetAnalyzer_lib/IQ Modulator');
    IPfreq=[IPfreq,simrfV2_read_freqs(solverblock,blks,'LOFreq',[])];

    blks=findBlksMatchingRefSystem(connectedBlks,...
    'rfBudgetAnalyzer_lib/IQ Demodulator');
    IPfreq=[IPfreq,simrfV2_read_freqs(solverblock,blks,'LOFreq',[])];

    blks=findBlksMatchingRefSystem(connectedBlks,...
    'simrfV2elements/Antenna');
    [IPfreqAdded,IPBlkNamesAdded]=simrfV2_read_freqs(solverblock,...
    blks,'CarrierFreqInc','InputIncWave');
    IPfreq=[IPfreq,IPfreqAdded];
    IPBlkNames=[IPBlkNames,IPBlkNamesAdded];
    OPfreq=[OPfreq,simrfV2_read_freqs(solverblock,...
    blks,'CarrierFreqRad','OutputRadWave')];

    blks=findBlksMatchingRefSystem(connectedBlks,...
    sprintf('simrfV2elements/IMT\nMixer'));
    IPfreq=[IPfreq,simrfV2_read_freqs(solverblock,...
    blks,'FrequencyLO',[])];

end

function blks=findBlksMatchingRefSystem(connectedBlks,refsystem)

    idx=strcmp(get_param(connectedBlks,'ReferenceBlock'),refsystem);
    blks=connectedBlks(idx);

end