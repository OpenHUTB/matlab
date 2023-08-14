


function output=readSignalList()

    SignalListPath=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
    'VirtualAssemblySignalList.m');

    run(SignalListPath);
    output=SignalList;
end