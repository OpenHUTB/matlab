function[infoType,value]=getMD5Checksum(source)




    infoType=message('simulink_comparisons:rptgen:MD5Checksum').getString;
    value=lower(Simulink.getFileChecksum(source.Path));

end
