function copyBitstream(vendorName,bitstreamFile,bitFileDestDir,bitFileDestName)




    switch lower(vendorName)
    case{'altera','intel'}
        [bitstreamFileList,destFileList]=dnnfpga.build.getBitstreamFileListIntel(bitstreamFile,bitFileDestDir,bitFileDestName);
    case 'xilinx'
        [bitstreamFileList,destFileList]=dnnfpga.build.getBitstreamFileListXilinx(bitstreamFile,bitFileDestDir,bitFileDestName);
    otherwise
        [bitstreamFileList,destFileList]=dnnfpga.build.getBitstreamFileListXilinx(bitstreamFile,bitFileDestDir,bitFileDestName);
    end

    for ii=1:length(bitstreamFileList)

        bitstreamFilePath=bitstreamFileList{ii};
        destFilePath=destFileList{ii};


        [status,msg]=copyfile(bitstreamFilePath,destFilePath);
        if~status
            warning(msg)
        end
    end


