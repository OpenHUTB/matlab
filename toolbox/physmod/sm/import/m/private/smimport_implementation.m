function[hModel,sDataFileName]=smimport_implementation(mdlDesc,varargin)






    if isstring(mdlDesc)
        mdlDesc=convertStringsToChars(mdlDesc);
    end

    if ischar(mdlDesc)
        [fpath,fname,ext]=fileparts(mdlDesc);
        if(isempty(ext))
            ext='.xml';
        else
            if~(strcmpi(ext,'.xml')||strcmpi(ext,'.urdf'))
                pm_error('sm:import:InvalidFileType',ext);
            end
        end

        mdlDesc=append(fullfile(fpath,fname),ext);
        inputs=parseInputs(fname,ext,varargin);
    elseif isa(mdlDesc,'robotics.RigidBodyTree')


        if license('test','Robotics_System_Toolbox')&&~isempty(ver('robotics'))
            inputs=parseInputs('untitled','',varargin);
        else
            pm_error('sm:import:rbt:NoRoboticsSystemToolbox');
        end
    else
        pm_error('sm:import:InvalidModelDescriptionInput');
    end

    importMode=inputs.ImportMode;
    modelName=inputs.ModelName;
    dataFileName=inputs.DataFileName;
    priorDataFile=inputs.PriorDataFile;
    variableName=inputs.VariableName;
    ModelSimplification=inputs.ModelSimplification;

    if strcmpi(importMode,'dataFile')&&~ismember('ModelSimplification',inputs.UsingDefaults)
        pm_warning('sm:import:ModelSimplificationNotSupportedForDataFileImportMode');
    end

    if ischar(mdlDesc)
        switch lower(ext)
        case '.xml'

            verMech=ver('mech');
            versionStr=verMech.Version;

            builtin('smimport_builtin',mdlDesc,importMode,modelName,...
            dataFileName,priorDataFile,variableName,versionStr,...
            ModelSimplification);
            fschange(dataFileName);
        case '.urdf'

            if~ismember('ImportMode',inputs.UsingDefaults)
                pm_warning('sm:import:urdf:ImportModeNotSupported');
            end
            if~ismember('DataFileName',inputs.UsingDefaults)
                pm_warning('sm:import:urdf:DataFileNameNotSupported');
            end
            if~ismember('PriorDataFile',inputs.UsingDefaults)
                pm_warning('sm:import:urdf:PriorDataFileNotSupported');
            end
            if~ismember('VariableName',inputs.UsingDefaults)
                pm_warning('sm:import:urdf:VariableNameNotSupported');
            end
            if~ismember('ModelSimplification',inputs.UsingDefaults)
                pm_warning('sm:import:urdf:ModelSimplificationNotSupported');
            end



            if nargout==2
                pm_warning('sm:import:urdf:dataFileNameNotSupported');
                sDataFileName='';
            end




            URDFModel=matlabshared.multibody.internal.urdf.Model(mdlDesc,...
            'ParseCollision',false);


            URDFSystem=sm_create_urdf_system(URDFModel,[]);


            builtin('smimport_urdf_builtin',URDFSystem,modelName)
            hModel=get_param(modelName,'Handle');
            simscape.multibody.internal.sm_add_solver(hModel);
            return
        end

        sDataFileName=dataFileName;
        if strcmpi(importMode,'modelAndDataFile')
            hModel=get_param(modelName,'Handle');
            simscape.multibody.internal.sm_add_solver(hModel);


            hWorkspace=get_param(hModel,'modelworkspace');
            hWorkspace.DataSource='MATLAB File';
            hWorkspace.FileName=fullfile(pwd,dataFileName);
            hWorkspace.reload;
        else
            hModel=-1;
        end
    elseif isa(mdlDesc,'robotics.RigidBodyTree')

        if~ismember('ImportMode',inputs.UsingDefaults)
            pm_warning('sm:import:rbt:ImportModeNotSupported');
        end
        if~ismember('DataFileName',inputs.UsingDefaults)
            pm_warning('sm:import:rbt:DataFileNameNotSupported');
        end
        if~ismember('PriorDataFile',inputs.UsingDefaults)
            pm_warning('sm:import:rbt:PriorDataFileNotSupported');
        end
        if~ismember('VariableName',inputs.UsingDefaults)
            pm_warning('sm:import:rbt:VariableNameNotSupported');
        end
        if~ismember('ModelSimplification',inputs.UsingDefaults)
            pm_warning('sm:import:rbt:ModelSimplificationNotSupported');
        end



        if nargout==2
            pm_warning('sm:import:rbt:dataFileNameNotSupported');
            sDataFileName='';
        end




        [URDFModel,translationData]=...
        robotics.manip.internal.Exporter.exportRobot(mdlDesc);


        homeConfig=[];
        if isfield(translationData,'HomeConfiguration')
            homeConfig=translationData.HomeConfiguration;
        end
        URDFSystem=sm_create_urdf_system(URDFModel,homeConfig);


        builtin('smimport_urdf_builtin',URDFSystem,modelName)
        hModel=get_param(modelName,'Handle');
        simscape.multibody.internal.sm_add_solver(hModel);
        return
    end

end



function inputs=parseInputs(mdlDescName,ext,nameValuePairs)

    persistent p;

    acceptedImportMode={'modelAndDataFile','dataFile'};
    acceptedModelSimplification={'none','bringJointsToTop','groupRigidBodies'};

    if isempty(p)
        p=inputParser;

        defaultImportMode=acceptedImportMode{1};

        defaultModelSimplification=acceptedModelSimplification{1};

        addParameter(p,'ImportMode',defaultImportMode,@(x)any(validatestring(x,acceptedImportMode)));

        addParameter(p,'ModelName','');

        addParameter(p,'DataFileName','');

        addParameter(p,'PriorDataFile','');

        addParameter(p,'VariableName','');

        addParameter(p,'ModelSimplification',defaultModelSimplification,...
        @(x)any(validatestring(x,acceptedModelSimplification)));
    end


    parse(p,nameValuePairs{:});


    inputs.UsingDefaults=p.UsingDefaults;


    inputs.ImportMode=validatestring(p.Results.ImportMode,acceptedImportMode);


    inputs.ModelSimplification=validatestring(p.Results.ModelSimplification,...
    acceptedModelSimplification);


    if strcmpi(ext,'.xml')
        if strcmpi(inputs.ImportMode,'modelAndDataFile')

            if~ismember('PriorDataFile',p.UsingDefaults)
                pm_error('sm:import:PriorDataFileIllegalUsage');
            end
        elseif strcmpi(inputs.ImportMode,'dataFile')

            if~ismember('ModelName',p.UsingDefaults)
                pm_error('sm:import:ModelNameIllegalUsage');
            end



            if ismember('PriorDataFile',p.UsingDefaults)
                pm_warning('sm:import:LackOfPriorDataFile');
            end
        end
    end



    if ismember('ModelName',p.UsingDefaults)

        if~strcmpi(inputs.ImportMode,'modelAndDataFile')&&~strcmpi(ext,'.urdf')...
            &&~isempty(ext)
            validName='';
        elseif isvarname(mdlDescName)
            validName=mdlDescName;
        else
            validName=matlab.lang.makeValidName(mdlDescName);
            pm_warning('sm:import:sli:InvalidModelNameModified',mdlDescName,validName);
        end
        inputs.ModelName=local_unique_model_name(validName);

    else

        inputs.ModelName=p.Results.ModelName;



        if isstring(inputs.ModelName)
            inputs.ModelName=char(inputs.ModelName);
        end

        if~isvarname(inputs.ModelName)
            pm_error('sm:import:sli:InvalidModelName',inputs.ModelName);
        end
        if local_exists(inputs.ModelName)
            pm_error('sm:import:sli:ExistingModelNameSpecified',inputs.ModelName);
        end

    end

    if strcmpi(ext,'.urdf')||isempty(ext)


        inputs.DataFileName=p.Results.DataFileName;
        inputs.PriorDataFile=p.Results.PriorDataFile;
        inputs.VariableName=p.Results.VariableName;
    else


        if ismember('DataFileName',p.UsingDefaults)

            if isvarname(mdlDescName)
                validName=mdlDescName;
            else
                validName=matlab.lang.makeValidName(mdlDescName);
                pm_warning('sm:import:sli:InvalidDataFileNameModified',mdlDescName,validName);
            end
            inputs.DataFileName=local_unique_data_file_name([validName,'_DataFile']);

        else

            inputs.DataFileName=p.Results.DataFileName;



            if isstring(inputs.DataFileName)
                inputs.DataFileName=char(inputs.DataFileName);
            end

            if~isvarname(inputs.DataFileName)
                pm_error('sm:import:sli:InvalidDataFileName',inputs.DataFileName);
            end

            if exist(append(pwd,filesep,inputs.DataFileName,'.m'),'file')==2

                msgContent=pm_message('sm:import:sli:OverrideExistingDataFile',[inputs.DataFileName,'.m']);

                choice=questdlg(msgContent,'File Exists','Yes','No','Yes');
                switch choice
                case 'No'
                    inputs.DataFileName=local_unique_data_file_name(inputs.DataFileName);
                end

            end
        end



        if~ismember('PriorDataFile',p.UsingDefaults)
            inputs.PriorDataFile=p.Results.PriorDataFile;



            if isstring(inputs.PriorDataFile)
                inputs.PriorDataFile=char(inputs.PriorDataFile);
            end

            [fpath,fname,ext]=fileparts(inputs.PriorDataFile);

            if(isempty(ext))
                ext='.m';
            else
                if~strcmpi(ext,'.m')
                    pm_error('sm:import:InvalidDataFileType',ext);
                end
            end

            inputs.PriorDataFile=[fullfile(fpath,fname),ext];
        else
            inputs.PriorDataFile='';
        end


        if~ismember('VariableName',p.UsingDefaults)
            inputs.VariableName=p.Results.VariableName;



            if isstring(inputs.VariableName)
                inputs.VariableName=char(inputs.VariableName);
            end

            if~isvarname(inputs.VariableName)
                pm_error('sm:import:sli:InvalidVariableName',inputs.VariableName);
            end
        else
            inputs.VariableName='';
        end
    end

end

function newName=local_unique_data_file_name(origName)


    newName=origName;
    modifier=1;

    while exist([pwd,filesep,newName,'.m'],'file')==2
        newName=[origName,num2str(modifier)];
        modifier=modifier+1;
    end
    if modifier>1
        pm_warning('sm:import:sli:ExistingDataFileNameModified',origName,newName);
    end

end

function newName=local_unique_model_name(origName)



    newName=origName;
    modifier=1;
    while local_exists(newName)
        newName=[origName,num2str(modifier)];
        modifier=modifier+1;
    end
    if modifier>1
        pm_warning('sm:import:sli:ExistingModelNameModified',origName,newName);

    end

end

function isThere=local_exists(mdlName)
    isThere=~isempty(find_system(0,'type','block_diagram','Name',mdlName));
end


