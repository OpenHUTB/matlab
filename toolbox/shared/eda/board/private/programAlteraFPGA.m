function programAlteraFPGA(filename,chainposition,varargin)







    if nargin==1
        chainposition=1;
    end


















    NonBlockingMode=false;


    [a,b,c]=fileparts(filename);
    if~exist(filename,'file')

        filename_timelimited=fullfile(a,[b,'_time_limited',c]);
        if exist(filename_timelimited,'file')
            dispFpgaMsg(sprintf('FPGA programming file"%s" does not exist.',filename));
            dispFpgaMsg(sprintf('Use time-limited FPGA programming file "%s" instead.',filename_timelimited));
            filename=filename_timelimited;
            NonBlockingMode=true;
        end
    else

        result=regexp(filename,'_time_limited.sof$','once');
        if~isempty(result)
            NonBlockingMode=true;
        end
    end



    assert(exist(filename,'file')==2,message('EDALink:loadFPGABitstream:BitstreamNotFound',filename));


    dispFpgaMsg('Checking Quartus II Programmer tool',1);

    [retval,~]=system('quartus_pgm --help');


    assert(retval==0,message('EDALink:loadFPGABitstream:QuartusPgmNotFound'));



    dispFpgaMsg(sprintf('Start programming FPGA with file "%s"',filename),1);

    if chainposition>1
        programCmd=['quartus_pgm -m JTAG -o "p;',filename,'@',num2str(chainposition),'"'];
    else
        programCmd=['quartus_pgm -m JTAG -o "p;',filename,'"'];
    end

    if NonBlockingMode
        if isunix
            programCmd=['xterm -hold -sb -sl 256 -e bash -e -c ''',programCmd,'''&'];
        else
            programCmd=['start ',programCmd];
        end
    end

    [retval,msg]=system(programCmd);

    assert(retval==0,message('EDALink:loadFPGABitstream:LoadingFailed',msg));

    if NonBlockingMode

        pause(30);
        dispFpgaMsg(sprintf('Check external shell for FPGA programming progress.'),1);
        dispFpgaMsg(sprintf('Quit the Quartus II programmer in external shell will interrupt your Ethernet connection.'),1);
    else
        dispFpgaMsg(sprintf('Programming FPGA using file "%s" completed successfully',filename),1);
    end

end




