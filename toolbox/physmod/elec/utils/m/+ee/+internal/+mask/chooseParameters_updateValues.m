function chooseParameters_updateValues(modelName)
    groupsPerRow=3;
    ds=ee.internal.mask.getSimscapeBlockDatasetFromModel(modelName);
    blockName=[modelName,'/Tuner'];
    dutName=[modelName,'/DUT'];
    mask=Simulink.Mask.get(blockName);
    layoutChanged=false;


    for ii=1:length(ds.parameters)
        for jj=1:length(ds.parameters(ii).names)
            if isfield(get_param(dutName,'ObjectParameters'),ds.parameters(ii).names{jj})
                set_param(dutName,ds.parameters(ii).names{jj},ds.parameters(ii).values{jj});
            else

            end
            if isfield(get_param(blockName,'ObjectParameters'),ds.parameters(ii).names{jj})
                value=str2num(ds.parameters(ii).values{jj});%#ok<ST2NM>
                oldMin=str2double(get_param(blockName,[ds.parameters(ii).names{jj},'_min']));
                oldMax=str2double(get_param(blockName,[ds.parameters(ii).names{jj},'_max']));
                if value<oldMin
                    set_param(blockName,[ds.parameters(ii).names{jj},'_min'],ds.parameters(ii).values{jj});
                elseif value>oldMax
                    set_param(blockName,[ds.parameters(ii).names{jj},'_max'],ds.parameters(ii).values{jj});
                end
                ee.internal.mask.chooseParameters_sliderRangeUpdate(modelName,ds.parameters(ii).names{jj});
                set_param(blockName,ds.parameters(ii).names{jj},ds.parameters(ii).values{jj});
            else
                value=str2num(ds.parameters(ii).values{jj});%#ok<ST2NM>
                if value==0
                    minValue=0;
                    maxValue=1;
                else
                    if value>0
                        minValue=0;
                        maxValue=value*2;
                    else
                        maxValue=0;
                        minValue=value*2;
                    end
                end
                mask.addDialogControl('Type','group','Name',[ds.parameters(ii).names{jj},'_control'],...
                'Prompt',ds.parameters(ii).names{jj},...
                'Container','extras_tab');
                mask.addParameter('Type','slider',...
                'Name',ds.parameters(ii).names{jj},'Value',ds.parameters(ii).values{jj},...
                'Range',[minValue,maxValue],'Container',[ds.parameters(ii).names{jj},'_control'],...
                'Callback',['ee.internal.mask.chooseParameters_sliderUpdate(modelName,''',ds.parameters(ii).names{jj},''');']);
                mask.addParameter('Type','edit','Prompt','min',...
                'Name',[ds.parameters(ii).names{jj},'_min'],'Value',num2str(minValue),...
                'Container',[ds.parameters(ii).names{jj},'_control'],...
                'Callback',['ee.internal.mask.chooseParameters_sliderRangeUpdate(modelName,''',ds.parameters(ii).names{jj},''');']);
                mask.addParameter('Type','edit','Prompt','max',...
                'Name',[ds.parameters(ii).names{jj},'_max'],'Value',num2str(maxValue),...
                'Container',[ds.parameters(ii).names{jj},'_control'],...
                'Callback',['ee.internal.mask.chooseParameters_sliderRangeUpdate(modelName,''',ds.parameters(ii).names{jj},''');']);
                layoutChanged=true;
            end
        end
    end


    for ii=length(mask.Parameters):-1:1
        if strcmp(mask.Parameters(ii).Type,'slider')
            name=mask.Parameters(ii).Name;
            if~ismember(name,ds.parameters.names)
                if~isempty(mask.getParameter(name))
                    mask.removeParameter(name);
                    layoutChanged=true;
                end
                if~isempty(mask.getParameter([name,'_min']))
                    mask.removeParameter([name,'_min']);
                    layoutChanged=true;
                end
                if~isempty(mask.getParameter([name,'_max']))
                    mask.removeParameter([name,'_max']);
                    layoutChanged=true;
                end
                controls=mask.getDialogControl('tabgroup').getDialogControl('extras_tab');
                if~isempty(controls.getDialogControl([name,'_control']))
                    controls.removeDialogControl([name,'_control']);
                    layoutChanged=true;
                end
            end
        end
    end

    if layoutChanged

        tabs=mask.getDialogControl('tabgroup').DialogControls;
        for ii=1:length(tabs)
            groups=tabs(ii).DialogControls;
            skipValues=1:groupsPerRow:length(groups);
            for jj=1:length(groups)
                if ismember(jj,skipValues)
                    groups(jj).Row='new';
                else
                    groups(jj).Row='current';
                end
            end
        end
    end
end