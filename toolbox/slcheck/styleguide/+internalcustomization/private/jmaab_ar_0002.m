function jmaab_ar_0002



    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.ar_0002_a';
    SubCheckCfg(1).subcheck.InitParams.CheckName='ar_0002_a';
    SubCheckCfg(1).subcheck.InitParams.RegValue='[^a-z_A-Z_0-9]';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(2).subcheck.InitParams.CheckName='ar_0002_b';
    SubCheckCfg(2).subcheck.InitParams.RegValue='^[0-9]';
    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(3).subcheck.InitParams.CheckName='ar_0002_c';
    SubCheckCfg(3).subcheck.InitParams.RegValue='^_';
    SubCheckCfg(4).Type='Normal';
    SubCheckCfg(4).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(4).subcheck.InitParams.CheckName='ar_0002_d';
    SubCheckCfg(4).subcheck.InitParams.RegValue='_$';
    SubCheckCfg(5).Type='Normal';
    SubCheckCfg(5).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(5).subcheck.InitParams.CheckName='ar_0002_e';
    SubCheckCfg(5).subcheck.InitParams.RegValue='[_][_]';
    SubCheckCfg(6).Type='Normal';
    SubCheckCfg(6).subcheck.ID='slcheck.jmaab.IsAKeyWord';
    SubCheckCfg(6).subcheck.InitParams.CheckName='ar_0002_f';

    rec=slcheck.Check('mathworks.jmaab.ar_0002',...
    SubCheckCfg,...
    {sg_jmaab_group,sg_maab_group});

    rec.LicenseString=styleguide_license;

    rec.relevantEntities=@getRelevantEntity;
    rec.setDefaultInputParams(false);

    inputParamList=rec.setDefaultInputParams(false);
    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:ar_0002_input');
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=false;

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:ar_0002_allowHiddenFolder');
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=rowSpan+1;
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=false;

    rec.setInputParametersLayoutGrid([1,1]);
    rec.setInputParameters(inputParamList);
    rec.setSupportedReportStyles({'ModelAdvisor.Report.StandardStyle'});
    rec.register();
end

function ents=getRelevantEntity(system,~,~)
    system=bdroot(system);
    mdlFullName=get_param(system,'FileName');
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    checkHiddenFolder=mdladvObj.getInputParameterByName(DAStudio.message('ModelAdvisor:jmaab:ar_0002_allowHiddenFolder')).Value;
    if~isempty(mdlFullName)

        [mdlFullPath,~]=fileparts(mdlFullName);


        directories=dir([mdlFullPath,filesep,'**',filesep]);

        directories=directories([directories.isdir]);
        ents={};
        for ii=1:length(directories)


            if isInExclusionList([directories(ii).folder,filesep,directories(ii).name],system)
                continue
            end

            if~checkHiddenFolder
                [~,fAttrib]=fileattrib([directories(ii).folder,filesep,directories(ii).name]);


                if~isnan(fAttrib.hidden)&&fAttrib.hidden
                    continue;
                end
            end
            ents=[ents,[directories(ii).folder,filesep,directories(ii).name]];
        end
    else
        ents=[];
    end
end

function filePresent=isInExclusionList(fileName,system)






    exclusionList={'.','..','.SimulinkProject','slprj'};


    simFilegenHelper=Simulink.filegen.internal.Helpers;
    stf=simFilegenHelper.getCachedOrOriginalSystemTargetFile(system,false);
    reader=coder.internal.stf.FileReader.getInstance(stf);
    if~isempty(reader)&&~isempty(reader.GenSettings)
        codegenFolder=[system,reader.GenSettings.BuildDirSuffix];
        exclusionList=[exclusionList,codegenFolder];
    end
    filePresent=any(ismember(strsplit(fileName,filesep),exclusionList));
end