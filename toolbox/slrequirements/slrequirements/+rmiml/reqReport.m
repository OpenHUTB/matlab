function reqReport(fPath,outputDir)



    if~license_checkout_slvnv()
        return;
    end


    if slreq.hasChanges(fPath)
        escapedPath=strrep(fPath,'\','\\');
        questionString=getString(message('Slvnv:rmiml:UnsavedChangesSaveNowQuestion',escapedPath));
        reply=input(['  ',questionString,'  '],'s');
        if~isempty(reply)&&upper(reply(1))=='Y'
            rmiml.save(fPath);
        else
            return;
        end
    end

    RptgenRMI.mllinkMgr('clear');
    RptgenRMI.mllinkMgr('mfile',fPath);
    key=rmiut.pathToCmd(fPath);
    templateFile=which('+rmiml/rmiml.rpt');
    if nargin>1
        outputName=fullfile(outputDir,[key,'_rmiml.html']);
    else
        outputName=[key,'_rmiml.html'];
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


