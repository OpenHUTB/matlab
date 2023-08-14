function profile(modelName,varargin)



















    modelName=convertStringsToChars(modelName);

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    load_system(modelName);

    mgr=get_param(modelName,'MappingManager');
    mapping=mgr.getActiveMappingFor('DistributedTarget');
    profReport=mapping.ProfileReport;


    origNumSamples=profReport.ProfileNumSamples;
    origProfReportStatus=profReport.ProfileGenCode;
    profReport.ProfileGenCode=true;

    if nargin==2

        profReport.ProfileNumSamples=num2str(varargin{1});
    elseif(nargin>2)||(nargin<1)
        DAStudio.error(...
        'Simulink:mds:InvalidArgs_SetupProfileReport');
    end

    try

        slbuild(modelName);
        Simulink.SoftwareTarget.runGeneratedExecutable(get_param(modelName,'Handle'));

        profReport.ProfileGenCode=origProfReportStatus;
        profReport.ProfileNumSamples=origNumSamples;

        taskEditor=DeploymentDiagram.explorer(modelName);
        profileNode=taskEditor.findNodes('ProfileReport');
        taskEditor.imme.selectTreeViewNode(profileNode);
    catch err

        profReport.ProfileGenCode=origProfReportStatus;
        profReport.ProfileNumSamples=origNumSamples;
        throw(err);
    end
end


