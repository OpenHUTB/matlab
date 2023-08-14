function reportMsg(mexOrMsg,type,model)







    cgMgr=coder.internal.ModelCodegenMgr.getInstance(model);
    if~isempty(cgMgr)
        model=cgMgr.MdlRefBuildArgs.TopOfBuildModel;
    end
    modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;
    try
        callsite=modelSettingBackup([model,'.CallSite']);
    catch




        callsite='CL';
    end

    if strcmp(callsite,'UI')
        switch type
        case 'Info'
            if isa(mexOrMsg,'message')


                sldiagviewer.reportInfo(mexOrMsg.getString,'MessageId',mexOrMsg.Identifier);
            else
                sldiagviewer.reportInfo(mexOrMsg);
            end
        case 'Warning'
            if isa(mexOrMsg,'message')


                sldiagviewer.reportWarning(mexOrMsg.getString,'MessageId',mexOrMsg.Identifier);
            else
                sldiagviewer.reportWarning(mexOrMsg);
            end
        otherwise
            assert(false,'Invalid report type');
        end
    elseif strcmp(callsite,'CL')
        switch type
        case 'Info'

            if isa(mexOrMsg,'MException')
                mexOrMsg=mexOrMsg.getReport;
            elseif isa(mexOrMsg,'message')
                mexOrMsg=mexOrMsg.getString;
            end
            disp(mexOrMsg);
        case 'Warning'


            if isa(mexOrMsg,'MException')
                mexOrMsg=mexOrMsg.getReport;
            end
            warning(mexOrMsg);
        otherwise
            assert(false,'Invalid report type');
        end
    end
end