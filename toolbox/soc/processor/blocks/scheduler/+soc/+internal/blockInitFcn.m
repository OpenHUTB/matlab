
function blockInitFcn(blk)





    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    if isLibraryModified
        return;
    end
    if~isBlockInApprovedList(blk)
        return;
    end

    if~soc.blkcb.cbutils('SimStatusIsStopped',blk,bdroot(blk))
        set_param(blk,'Watermark','update');
    end

end


function ret=isLibraryModified
    certInfo=load(fullfile(matlabroot,'toolbox','soc','cert.mat'));
    expCheck=certInfo.check;

    socbFolder=fullfile(matlabroot,'toolbox','soc');

    mlVerInfo=ver('matlab');
    mlVersion=mlVerInfo.Version;
    libs={'processor/blocks','esblib.slx';...
    'processor/blocks','prociodatalib.slx';...
    'processor/blocks','procinterlib.slx';...
    'processor/blocks','prociolib.slx';...
    'processor/blocks','proclib_internal.slx';...
    'processor/blocks','proctasklib.slx';...
    'processor/blocks','peripheralslib.slx';...
    'processor/blocks/scheduler','esblib_internal.slx';...
    'fpga/simulation','socmemlib.slx';...
    'fpga/simulation','socmemlib_internal.slx';...
    'shared/blocks/','socsharedlib_internal.slx'};

    allLibNames='';
    sumLibSizes=uint64(0);

    arrSz=size(libs);
    for i=1:arrSz(1)
        libDir=libs{i,1};
        libName=libs{i,2};
        allLibNames=strcat(allLibNames,libName);
        libPath=fullfile(socbFolder,libDir,libName);
        libInfo=dir(libPath);
        libSize=libInfo.bytes;
        sumLibSizes=sumLibSizes+uint64(libSize);
    end

    part1=slInternal('hashUsingSHA2',num2str(sumLibSizes));
    part2=slInternal('hashUsingSHA2',libName);
    part3=uint64(sum(int8(char(mlVersion))));
    part3=dec2hex(bitshift(part3,10));

    curCheck=strcat(part1,part2,part3);

    ret=~isequal(curCheck,expCheck);
end


function ret=isBlockInApprovedList(blk)
    refBlk=get_param(blk,'ReferenceBlock');
    approvedBlocks={...
    'proctasklib/Task Manager',...
    'socmemlib/Memory Controller',...
    'socmemlib/Memory Channel',...
    'socmemlib/Register Channel',...
    'socmemlib/Interrupt Channel',...
    'socmemlib/Memory Traffic Generator',...
    'socmemlib/AXI4-Stream to Software',...
    'socmemlib/Software to AXI4-Stream',...
    'socmemlib/AXI4 Random Access Memory',...
    'socmemlib/AXI4 Video Frame Buffer',...
    'socmemlib_internal/Memory Controller',...
    'socsharedlib_internal/HWSW Message Send',...
    'socsharedlib_internal/HWSW Message Receive',...
    'socsharedlib_internal/HWSW Message Receive Full',...
    'procinterlib/Interprocess Data Channel',...
    'procinterlib/Interprocess Data Read',...
    'procinterlib/Interprocess Data Write',...
    'prociodatalib/IO Data Source',...
    'prociodatalib/IO Data Sink',...
    'prociolib/ADC Read',...
    'prociolib/PWM Write',...
    'prociolib/Audio Capture',...
    'prociolib/Audio Playback',...
    'prociolib/Video Capture',...
    'prociolib/Video Display',...
    'peripheralslib/ADC Interface',...
    'peripheralslib/PWM Interface',...
    'peripheralslib/Audio Capture Interface',...
    'peripheralslib/Audio Playback Interface',...
    'peripheralslib/Video Capture Interface',...
    'peripheralslib/Video Display Interface',...
'peripheralslib/Digital IO Interface'...
    };


    ret=~isempty(refBlk)&&any(contains(approvedBlocks,refBlk));
end



