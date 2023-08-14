function reqReport(fPath,outputDir)



    if~license_checkout_slvnv()
        return;
    end


    if rmitm.hasData(fPath)&&rmitm.hasChanges(fPath)
        escapedPath=strrep(fPath,'\','\\');
        questionString=getString(message('Slvnv:rmiml:UnsavedChangesSaveNowQuestion',escapedPath));
        reply=input(['  ',questionString,'  '],'s');
        if~isempty(reply)&&upper(reply(1))=='Y'
            rmide.save(fPath);
        else
            return;
        end
    end

    RptgenRMI.mllinkMgr('clear');
    RptgenRMI.mllinkMgr('tmfile',fPath);
    [~,stName]=fileparts(fPath);
    templateFile=fullfile(matlabroot,'toolbox','slrequirements','slrequirements','+rmitm','rmitm.rpt');
    if nargin>1
        outputName=fullfile(outputDir,[stName,'_rmitm.html']);
    else
        outputName=[stName,'_rmitm.html'];
    end
    rptgen.report(templateFile,['-o',outputName]);

end

function success=license_checkout_slvnv()
    licenseError=builtin('_license_checkout','Simulink_Requirements','quiet');
    if licenseError
        warning(message('Slvnv:reqmgt:licenseCheckoutFailed'));
        success=false;
    else
        success=true;
    end
end


