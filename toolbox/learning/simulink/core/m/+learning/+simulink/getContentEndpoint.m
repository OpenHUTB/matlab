function[serviceResponse]=getContentEndpoint(contentInfo)






    endPoint=learning.simulink.internal.getEndPoint()+"?release="+contentInfo.release+"&language="+contentInfo.language+"&course="+contentInfo.course;

    opts=weboptions(...
    'RequestMethod','get',...
    'MediaType','application/json',...
    'Timeout',10,...
    'CertificateFilename','',...
    'ContentType','json');
    try
        [serviceResponse]=webread(endPoint,opts);
    catch err
        rethrow(err);
    end
end