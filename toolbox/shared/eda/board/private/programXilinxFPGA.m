function programXilinxFPGA(bitstreamfile,chainposition,useDigilentPlugIn,cable)











    narginchk(2,4);

    if nargin==2
        useDigilentPlugIn=false;
        cable='auto';
    end
    if nargin==3
        cable='auto';
    end


    assert(exist(bitstreamfile,'file')==2,message('EDALink:loadFPGABitstream:BitstreamNotFound',bitstreamfile));



    dispFpgaMsg('Generating iMPACT command file',1);

    batchFile=l_generateBatchFile(bitstreamfile,chainposition,useDigilentPlugIn,cable);


    dispFpgaMsg('Checking iMPACT tool',1);





    [retval,~]=system('echo exit | impact -batch');

    assert(retval==0,message('EDALink:loadFPGABitstream:ImpactNotFound'));


    dispFpgaMsg(sprintf('Start loading bitstream "%s"',bitstreamfile),1);

    [retval,msg]=system(['impact -batch ',batchFile]);

    assert(retval==0,message('EDALink:loadFPGABitstream:LoadingFailed',msg));

    dispFpgaMsg(sprintf('Loading bitstream "%s" completed successfully',bitstreamfile),1);

end

function batchFile=l_generateBatchFile(bitstreamfile,chainposition,useDigilentPlugIn,cable)


    cmds=sprintf('setMode -bs\n');


    if(useDigilentPlugIn)
        cmds=[cmds...
        ,sprintf('setCable -target "digilent_plugin"\n')...
        ,sprintf('Identify -inferir\n')...
        ,sprintf('identifyMPM\n')];
    else
        cmds=[cmds...
        ,sprintf(['setCable -p ',cable,'\n'])...
        ,sprintf('identify\n')];
    end

    cmds=[cmds...
    ,sprintf('assignFile -p %d -file "%s"\n',chainposition,bitstreamfile)...
    ,sprintf('program -p %d\n',chainposition)...
    ,sprintf('quit\n')];


    batchFile='_impactbatch.cmd';
    fid=fopen(batchFile,'w');

    if fid==-1
        onCleanupObj=[];
    else
        onCleanupObj=onCleanup(@()fclose(fid));
    end

    assert(fid~=-1,message('EDALink:loadFPGABitstream:BatchFileCreationFailed',batchFile));


    fwrite(fid,cmds);


    delete(onCleanupObj);

end





