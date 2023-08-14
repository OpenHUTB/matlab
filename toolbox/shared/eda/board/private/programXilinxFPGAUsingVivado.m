function programXilinxFPGAUsingVivado(bitstreamfile,chainposition,varargin)




    assert(exist(bitstreamfile,'file')==2,message('EDALink:loadFPGABitstream:BitstreamNotFound',bitstreamfile));


    dispFpgaMsg('Generating Vivado programming script',1);

    batchFile=l_generateBatchFile(bitstreamfile,chainposition);


    dispFpgaMsg('Checking Vivado tool',1);
    [retval,~]=system('vivado -version');

    assert(retval==0,'The Vivado executable is not found on system path.');


    dispFpgaMsg(sprintf('Start loading bitstream "%s"',bitstreamfile),1);

    [retval,msg]=system(['vivado -mode batch -source ',batchFile]);

    assert(retval==0,message('EDALink:loadFPGABitstream:LoadingFailed',msg));

    dispFpgaMsg(sprintf('Loading bitstream "%s" completed successfully',bitstreamfile),1);

end

function batchFile=l_generateBatchFile(bitstreamfile,chainposition)

    cmds=['set chain_position ',num2str(chainposition-1),char(10)...
    ,'open_hw',char(10)...
    ,'connect_hw_server -url localhost:3121',char(10)...
    ,'open_hw_target',char(10)...
    ,'current_hw_device [lindex [get_hw_devices] $chain_position]',char(10)...
    ,'refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] $chain_position]',char(10)...
    ,'set_param xicom.use_bitstream_version_check false',char(10)...
    ,'set_property PROGRAM.FILE {',bitstreamfile,'} [lindex [get_hw_devices] $chain_position]',char(10)...
    ,'program_hw_devices [lindex [get_hw_devices] $chain_position]',char(10)...
    ,'disconnect_hw_server'];


    batchFile='_vivado_program.cmd';
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





