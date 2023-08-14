function checksum=getFileChecksum(file,varargin)







    if nargin&&isstring(file)
        file=convertStringsToChars(file);
    end

    if nargin<1||~ischar(file)
        DAStudio.error('Simulink:utility:getFileChecksum_wrong_or_empty_input')
    end

    if exist(file,'file')==0
        DAStudio.error('Simulink:utility:getFileChecksum_file_not_found',file)
    end

    if exist(file,'dir')
        DAStudio.error('Simulink:utility:getFileChecksum_folder_not_file',file)
    end

    try
        checksum=loc_call_nonjava_md5_on_file(file);

    catch E

        DAStudio.error('Simulink:utility:getFileChecksum_error_occurred',file);
    end

end



function checksum=loc_call_nonjava_md5_on_file(fileName)
    digester=matlab.internal.crypto.BasicDigester('DeprecatedMD5');
    checksumBytes=digester.computeFileDigest(fileName);
    checksum=char(upper(matlab.internal.crypto.hexEncode(checksumBytes)));
end


