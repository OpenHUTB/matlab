function jmaab_ar_0001




    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(1).subcheck.InitParams.CheckName='ar_0001_a';
    SubCheckCfg(1).subcheck.InitParams.RegValue='[^a-z_A-Z_0-9]';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(2).subcheck.InitParams.CheckName='ar_0001_b';
    SubCheckCfg(2).subcheck.InitParams.RegValue='^[0-9]';
    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(3).subcheck.InitParams.CheckName='ar_0001_c';
    SubCheckCfg(3).subcheck.InitParams.RegValue='^_';
    SubCheckCfg(4).Type='Normal';
    SubCheckCfg(4).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(4).subcheck.InitParams.CheckName='ar_0001_d';
    SubCheckCfg(4).subcheck.InitParams.RegValue='_$';
    SubCheckCfg(5).Type='Normal';
    SubCheckCfg(5).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(5).subcheck.InitParams.CheckName='ar_0001_e';
    SubCheckCfg(5).subcheck.InitParams.RegValue='[_][_]';
    SubCheckCfg(6).Type='Normal';
    SubCheckCfg(6).subcheck.ID='slcheck.jmaab.IsAKeyWord';
    SubCheckCfg(6).subcheck.InitParams.CheckName='ar_0001_f';
    SubCheckCfg(7).Type='Normal';
    SubCheckCfg(7).subcheck.ID='slcheck.jmaab.ar_0001_g';
    SubCheckCfg(7).subcheck.InitParams.CheckName='ar_0001_g';

    rec=slcheck.Check('mathworks.jmaab.ar_0001',...
    SubCheckCfg,...
    {sg_jmaab_group,sg_maab_group});

    rec.LicenseString=styleguide_license;

    rec.relevantEntities=@getRelevantEntity;

    inputParamList=rec.setDefaultInputParams(false);
    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:ar_0001_input');
    inputParamList{end}.Type='Enum';
    inputParamList{end}.Entries={'All files',...
    '*.mat, *.fig, *.mldatx, *.sltx, *.prj, *.sldd, *.mlappinstall, *.m, *.mlapp, *.mdl, *.mltbx, *.mlproj, *.slx, *.req',...
    '*.txt',...
    '*.doc, *.docx',...
    '*.xls, *.xlsx'};
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.ColSpan=[1,4];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value='All files';

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:ar_0001_allowHiddenFile');
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=rowSpan+1;
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=false;

    rec.setInputParametersLayoutGrid([1,1]);
    rec.setInputParameters(inputParamList);

    rec.register();

end

function ents=getRelevantEntity(system,~,~)

    system=bdroot(system);
    mdlFullName=get_param(system,'FileName');
    if~isempty(mdlFullName)
        DepResult=slcheck.jmaab.getDependentFiles(system);

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        fileType=mdladvObj.getInputParameterByName(DAStudio.message('ModelAdvisor:jmaab:ar_0001_input')).Value;
        checkHiddenFile=mdladvObj.getInputParameterByName(DAStudio.message('ModelAdvisor:jmaab:ar_0001_allowHiddenFile')).Value;


        [mdlFullPath,~]=fileparts(mdlFullName);

        directories=dir(mdlFullPath);
        curFiles={};

        for n=1:length(directories)
            if~directories(n).isdir
                [~,fileName,ext]=fileparts(directories(n).name);


                if~strcmp(fileType,'All files')&&~contains(fileType,ext)
                    continue;
                end


                if~checkHiddenFile
                    [~,fAttrib]=fileattrib([directories(n).folder,filesep,directories(n).name]);



                    if~isnan(fAttrib.hidden)&&fAttrib.hidden
                        continue;
                    end
                end



                DepResult=DepResult(~ismember(DepResult,fileName));
                curFiles=[curFiles;[mdlFullPath,filesep,directories(n).name]];
            else

            end
        end
        ents=[DepResult;curFiles];



        ents=unique(ents);

        ents=ents(~startsWith(ents,matlabroot));

        ents=ents(~endsWith(ents,[filesep,'rtwmakecfg.m']));
    else
        ents=[];
    end
end