function cs=fileCheckSum(file)









    digester=matlab.internal.crypto.BasicDigester('DeprecatedMD5');
    checksumBytes=digester.computeFileDigest(file);
    cs=lower(dec2hex(checksumBytes));
