function reqReport(fPath,outputDir)



    if~license_checkout_slvnv()
        return;
    end


    if rmide.dictHasChanges(fPath)
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
    RptgenRMI.mllinkMgr('ddfile',fPath);
    [~,ddName]=fileparts(fPath);
    templateFile=fullfile(matlabroot,'toolbox','slrequirements','slrequirements','+rmide','rmide.rpt');
    if nargin>1
        outputName=fullfile(outputDir,[ddName,'_rmide.html']);
    else
        outputName=[ddName,'_rmide.html'];
    end
    rptgen.report(templateFile,['-o',outputName]);

end

function success=license_checkout_slvnv()
    if builtin('_license_checkout','Simulink_Requirements','quiet')
        warning(message('Slvnv:reqmgt:licenseCheckoutFailed'));
        success=false;
    else
        success=true;
    end
end

