function jmaab_jc_0791

    rec=Advisor.Utils.getDefaultCheckObject...
    ('mathworks.jmaab.jc_0791',false,@CheckAlgo,'None');

    rec.SupportExclusion=false;

    rec.setLicense({styleguide_license});
    rec.setInputParametersLayoutGrid([3,2]);

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{1}.Name=DAStudio.message('ModelAdvisor:jmaab:jc_0791_a_subtitle');
    inputParamList{1}.Type='bool';
    inputParamList{1}.RowSpan=[1,1];
    inputParamList{1}.ColSpan=[1,2];
    inputParamList{1}.Visible=false;
    inputParamList{1}.Enable=true;
    inputParamList{1}.Value=true;

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:jc_0791_b_subtitle');
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:jc_0791_c_subtitle');
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.TableStyle'});

    rec.setInputParameters(inputParamList);
    rec.setInputParametersCallbackFcn(...
    @(taskobj,tag,handle)slcheck.Check.defaultInputParamCallback...
    (taskobj,tag,handle));


    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end




function[resultData]=CheckAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    inputParams=mdladvObj.getInputParameters;
    subCheckA=false;
    subCheckB=false;
    subCheckC=false;

    for ipCount=1:numel(inputParams)
        if strcmp(inputParams{ipCount}.Name,DAStudio.message...
            ('ModelAdvisor:jmaab:jc_0791_a_subtitle'))&&...
            inputParams{ipCount}.Value==1
            subCheckA=true;
        end
        if strcmp(inputParams{ipCount}.Name,DAStudio.message...
            ('ModelAdvisor:jmaab:jc_0791_b_subtitle'))&&...
            inputParams{ipCount}.Value==1
            subCheckB=true;
        end
        if strcmp(inputParams{ipCount}.Name,DAStudio.message...
            ('ModelAdvisor:jmaab:jc_0791_c_subtitle'))&&...
            inputParams{ipCount}.Value==1
            subCheckC=true;
        end
    end



    if isLibrary(get_param(bdroot(system),'Object'))
        subCheckA=false;
        subCheckC=false;
    end


    vObj1=[];
    vObj2=[];
    vObj3=[];

    da=Simulink.data.DataAccessor.create(bdroot(system));
    shadowedVarInf=da.getShadowedVariables();
    duplicateVarInf=da.getDuplicateVariablesInExternalSources();

    if subCheckA

        dupA={};
        dataStores=struct('type1','','type2',[]);
        for i=1:length(shadowedVarInf)
            bwsShadowedVars=strcmp(shadowedVarInf(i).ShadowedSources,'base workspace');
            if any(bwsShadowedVars)
                dupA{end+1}=shadowedVarInf(i).Name;
                dataStores(i).type1='base workspace';
                dataStores(i).type2={system};
            end
        end
        if~isempty(dupA)
            vObj1=createResultDetailObj(dupA,dataStores,'a');
        end
    end

    if subCheckB

        dupB={};
        dataStores=struct('type1','','type2',[]);
        for i=1:length(duplicateVarInf)
            nonBWSDuplicateSources=~strcmp(duplicateVarInf(i).DuplicateSources,'base workspace');

            dupB{end+1}=duplicateVarInf(i).Name;
            dataStores(i).type1='base workspace';
            dataStores(i).type2=duplicateVarInf(i).DuplicateSources(nonBWSDuplicateSources);
        end
        if~isempty(dupB)
            vObj2=createResultDetailObj(dupB,dataStores,'b');
        end
    end


    if subCheckC
        dupC={};
        dataStores=struct('type1','','type2',[]);
        for i=1:length(shadowedVarInf)
            nonBWSShadowedVars=~strcmp(shadowedVarInf(i).ShadowedSources,'base workspace');
            if any(nonBWSShadowedVars)
                dupC{end+1}=shadowedVarInf(i).Name;
                dataStores(i).type1=system;
                dataStores(i).type2=shadowedVarInf(i).ShadowedSources(nonBWSShadowedVars);
            end
        end
        if~isempty(dupC)
            vObj3=createResultDetailObj(dupC,dataStores,'c');
        end
    end

    resultData=[vObj1;vObj2;vObj3];
end



function vObj=createResultDetailObj(duplicate,dataStores,subCheck)


    vObj=[];
    for dataCount=1:numel(duplicate)
        data={Simulink.VariableUsage(duplicate{dataCount},dataStores(dataCount).type1)};
        for j=1:length(dataStores(dataCount).type2)
            data{end+1}=Simulink.VariableUsage(duplicate{dataCount},dataStores(dataCount).type2{j});
        end

        rdObj=ModelAdvisor.ResultDetail;

        ModelAdvisor.ResultDetail.setData(rdObj,'Custom',...
        DAStudio.message('ModelAdvisor:jmaab:jc_0791_col1'),...
        duplicate{dataCount},...
        DAStudio.message('ModelAdvisor:jmaab:jc_0791_col2'),...
        data);

        rdObj.Title=DAStudio.message(...
        strcat('ModelAdvisor:jmaab:jc_0791_',subCheck,'_subtitle'));
        rdObj.Status=DAStudio.message(...
        strcat('ModelAdvisor:jmaab:jc_0791_',subCheck,'_warn'));
        rdObj.RecAction=DAStudio.message(...
        strcat('ModelAdvisor:jmaab:jc_0791_',subCheck,'_rec_action'));
        vObj=[vObj;rdObj];

    end
end





