function cbkAssociateSimulink(this,sysName,rptName)








    if nargin<3||isempty(rptName)
        rptName=this.getCurrentRpt(true);

    end

    if isa(rptName,'rptgen.coutline')
        rptName=rptName.RptFileName;
    end

    if nargin<2||isempty(sysName)
        if rptgen.isSimulinkLoaded


            sysName=gcs;
        else
            sysName='';
        end
    end

    if isempty(sysName)
        warning(message('rptgen:RptgenML_Root:asssociationErrorSystem'));
    elseif isempty(rptName)
        warning(message('rptgen:RptgenML_Root:asssociationErrorReport'));
    else
        if strcmp(rptName,'-null')
            rptName='';
        else

            [rPath,rFile,rExt]=fileparts(rptName);
            rptName=[rFile,rExt];
        end

        set_param(sysName,'ReportName',rptName);
        disp(getString(message('rptgen:RptgenML_Root:associatedSystemLabel',...
        strrep(sysName,char(10),' '),rptName)));




    end