function[targetDevice,projSrcFiles]=importProjectSettings(h,textFile,errMsg)





    rtncell=readTextFile(textFile,errMsg);

    if length(rtncell)<4
        error(message('EDALink:WorkflowManager:importProjectSettings:unexpectedisesetting'));
    end


    targetDevice.family=rtncell{1};
    targetDevice.device=rtncell{2};
    targetDevice.speed=rtncell{3};
    targetDevice.package=rtncell{4};


    if length(rtncell)<5
        projSrcFiles='';
    elseif strcmpi(rtncell{5},'Empty Collection')



        projSrcFiles='';
    else
        projSrcFiles=rtncell(5:end);
    end


    function rtncell=readTextFile(textFile,errMsg)
        fid=fopen(textFile,'r');
        if fid==-1
            errormsg='Unable to open text file for reading.';
            if nargin==3
                errormsg=[errMsg,blanks(1),errormsg];
            end
            error(message('EDALink:WorkflowManager:importProjectSettings:opentxtfile',errormsg));
        end

        rtncell=textscan(fid,'%s','Delimiter',char(10));
        fclose(fid);
        rtncell=rtncell{1};

































































