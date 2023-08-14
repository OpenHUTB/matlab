function[status,msgId]=checkLicense(modelH)




    msgId='';
    status=true;
    if SlCov.CoverageAPI.isCovToolUsedBySlicer(modelH)
        [status,msgId]=SlCov.CoverageAPI.checkSlicerLicense;
        if status
            msgId='';
        end
    elseif~cvprivate('cv_autoscale_settings','isForce',modelH)&&~SlCov.CoverageAPI.checkCvLicense
        [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    elseif cvprivate('cv_autoscale_settings','isForce',modelH)&&~license('test','Fixed_Point_Toolbox')
        msgId='Slvnv:simcoverage:ioerrors:LicenseCheckoutFailedAutoScale';
    end
    if~isempty(msgId)
        txt=getString(message('Slvnv:simcoverage:ioerrors:LicenseCheckoutFailedAutoScale'));
        status=false;
        display(sprintf(txt));
        set_param(modelH,'RecordCoverage','off');
    end






