function res=handleCSHRequest(mapkey,topicid)

    res=struct('CSHURL','','Error','','Docroot','');
    try
        res.CSHURL=dashboard.internal.getCSHURL(mapkey,topicid);
        res.Docroot=docroot;
        if isempty(res.CSHURL)
            res.Error='MATLAB documentation is not available';
        end
    catch ex
        res.Error=ex.getReport();
    end

end

