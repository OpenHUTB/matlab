function fileChecksum=getFileChecksumFromPath(filePath)




    fileChecksum=char.empty;
    if isfile(filePath)
        digester=matlab.internal.crypto.BasicDigester("DeprecatedMD5");
        checksumBytes=digester.computeFileDigest(filePath);
        fileChecksum=convertStringsToChars...
        (matlab.internal.crypto.hexEncode(checksumBytes));
    end
end
