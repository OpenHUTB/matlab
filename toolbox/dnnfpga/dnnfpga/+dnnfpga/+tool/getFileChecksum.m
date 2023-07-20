function checksum=getFileChecksum(file,varargin)







    if nargin&&isstring(file)
        file=convertStringsToChars(file);
    end

    if nargin<1||~ischar(file)
        DAStudio.error('dnnfpga:workflow:GetFileChecksumWrongOrEmptyInput')
    end

    if exist(file,'file')==0
        DAStudio.error('dnnfpga:workflow:GetFileChecksumFileNotFound',file)
    end

    if exist(file,'dir')
        DAStudio.error('dnnfpga:workflow:GetFileChecksumFolderNotFile',file)
    end

    try
        checksum=loc_call_nonjava_md5_on_file(file);
    catch E

        DAStudio.error('dnnfpga:workflow:GetFileChecksumErrorOccurred',file);
    end

end



function checksum=loc_call_nonjava_md5_on_file(fileName)
    digester=matlab.internal.crypto.BasicDigester('DeprecatedMD5');
    checksumBytes=digester.computeFileDigest(fileName);
    checksum=char(upper(matlab.internal.crypto.hexEncode(checksumBytes)));
end


