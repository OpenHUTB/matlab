function schema=slxmlmenus(fncname,cbinfo)


    fnc=str2func(fncname);
    schema=fnc(cbinfo);
end


function schema=getModelFilesItem(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=slxmlcomp.internal.message('report:MenuCompare');
    else
        schema.icon='compareModels';
    end
    schema.tag='Simulink:ReportGenerator:XMLComparison';
    schema.callback=@getModelFiles;
    schema.autoDisableWhen='Busy';
end


function getModelFiles(~)

    if~usejava('jvm')
        errordlg(slxmlcomp.internal.message('engine:NoJava'));
        return;
    end

    filePath=get_param(bdroot,'FileName');
    file=java.io.File(filePath);
    javaMethod(...
    'startComparison',...
    'com.mathworks.comparisons.main.ComparisonUtilities',...
    file,[]);
end

