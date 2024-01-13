function res=getFileAttributes(filePath)

    x=dir(filePath);
    lastModifiedTime=datestr(x.datenum,'yyyy-mm-dd HH:MM:SS');
    creationTime=lastModifiedTime;
    fileSize=x.bytes;

    md5Eng=matlab.internal.crypto.BasicDigester('DeprecatedMD5');
    digest=md5Eng.computeFileDigest(filePath);
    checksum=[...
    prod(uint32(digest(1:4)));...
    prod(uint32(digest(5:8)));...
    prod(uint32(digest(9:12)));...
    prod(uint32(digest(13:16)))...
    ];
    res=struct('creationTime',creationTime,...
    'lastModifiedTime',lastModifiedTime,...
    'fileSize',fileSize,...
    'checksum',checksum);
