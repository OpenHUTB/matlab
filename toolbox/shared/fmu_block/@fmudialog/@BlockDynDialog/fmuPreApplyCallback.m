function[status,errmsg]=fmuPreApplyCallback(this,dlg)






    block=this.getBlock();


    updateParamsList=find(this.DialogData.ChangeList);
    numChanges=size(updateParamsList,2);

    set_param_cmd='';
    restore_param_cmd='';

    if numChanges>0
        set_param_cmd=['set_param(block.Handle'];
        restore_param_cmd=['set_param(block.Handle'];
        for i=1:numChanges
            set_param_cmd=[set_param_cmd,', ''',this.DialogData.ListParams{updateParamsList(i)},''', '];
            restore_param_cmd=[restore_param_cmd,', ''',this.DialogData.ListParams{updateParamsList(i)},''', '];
            val=this.DialogData.ListValue{updateParamsList(i)};
            if isStringScalar(val)
                val=convertStringsToChars(val);
            end
            if ischar(val)

                escaped_new_value=regexprep(val,'('')','''$1');
                set_param_cmd=[set_param_cmd,'''',escaped_new_value,''''];
            else
                set_param_cmd=[set_param_cmd,num2str(val)];
            end
            oldVal=this.DialogData.ListOldValue{updateParamsList(i)};

            if isStringScalar(oldVal)
                oldVal=convertStringsToChars(oldVal);
            end
            if ischar(oldVal)
                escaped_old_value=regexprep(oldVal,'('')','''$1');
                restore_param_cmd=[restore_param_cmd,'''',escaped_old_value,''''];
            else
                restore_param_cmd=[restore_param_cmd,num2str(this.DialogData.ListOldValue{updateParamsList(i)})];
            end
        end

        set_param_cmd=[set_param_cmd,')'];
        restore_param_cmd=[restore_param_cmd,')'];
    end

    status=1;
    errmsg='';

    try

        eval(set_param_cmd);


        if(~isequal(this.DialogData.DebugLoggingFilter,block.FMUDebugLoggingFilter))
            set_param(block.Handle,'FMUDebugLoggingFilter',this.DialogData.DebugLoggingFilter);
        end


        if(~isequal(this.DialogData.FMUSampleTime,block.FMUSampleTime))
            set_param(block.Handle,'FMUSampleTime',this.DialogData.FMUSampleTime);
        end


        if(~isequal(this.DialogData.FMUToleranceValue,block.FMUToleranceValue))
            set_param(block.Handle,'FMUToleranceValue',this.DialogData.FMUToleranceValue);
        end


        if this.DialogData.InputBusStructTableDataChanged
            set_param(block.Handle,'FMUInputBusObjectName',...
            eval(['{''',strjoin(regexprep(this.DialogData.InputBusStructTableData,'('')','''$1'),''','''),'''}']));
            this.DialogData.InputBusStructTableDataChanged=false;
        end


        if this.DialogData.OutputBusStructTableDataChanged
            set_param(block.Handle,'FMUOutputBusObjectName',...
            eval(['{''',strjoin(regexprep(this.DialogData.OutputBusStructTableData,'('')','''$1'),''','''),'''}']));
            this.DialogData.OutputBusStructTableDataChanged=false;
        end


        if this.DialogData.InputBusObjectNameChanged
            inTree=this.DialogData.inputListSource.valueStructure;
            topLeveIdxArray=arrayfun(@(x)(x.IsRoot==1&&~isempty(x.ChildrenIndex)),inTree);
            inTree=inTree(topLeveIdxArray);

            busObjectNames=cell(1,length(inTree));
            for i=1:length(inTree)
                busObjectNames{i}=inTree(i).BusObjectName;
            end
            set_param(block.Handle,'FMUInputBusObjectName',busObjectNames);
            this.DialogData.InputBusObjectNameChanged=false;
        end


        if this.DialogData.OutputBusObjectNameChanged
            outTree=this.DialogData.outputListSource.valueStructure;
            topLeveIdxArray=arrayfun(@(x)(x.IsRoot==1&&~isempty(x.ChildrenIndex)),outTree);
            outTree=outTree(topLeveIdxArray);

            busObjectNames=cell(1,length(outTree));
            for i=1:length(outTree)
                busObjectNames{i}=outTree(i).BusObjectName;
            end
            set_param(block.Handle,'FMUOutputBusObjectName',busObjectNames);
            this.DialogData.OutputBusObjectNameChanged=false;
        end


        if this.DialogData.InputStartValueChanged

            cellVal=[this.DialogData.InputAlteredNameStartMap.keys',this.DialogData.InputAlteredNameStartMap.values'];
            set_param(block.Handle,'FMUInputAlteredNameStartMap',cellVal);
            this.DialogData.InputStartValueChanged=false;
        end


        if this.DialogData.InputVisibilityChanged
            inTree=this.DialogData.inputListSource.valueStructure;
            visibility={};
            for i=1:length(inTree)
                if inTree(i).IsRoot

                    visibility=[visibility,str2logic(inTree(i).IsVisible)];
                end
            end
            set_param(block.Handle,'FMUInputVisibility',visibility);
            this.DialogData.InputVisibilityChanged=false;
        end


        if this.DialogData.OutputVisibilityChanged
            outTree=this.DialogData.outputListSource.valueStructure;
            visibility={};
            for i=1:length(outTree)
                if outTree(i).IsRoot

                    visibility=[visibility,str2logic(outTree(i).IsVisible)];
                end
            end
            set_param(block.Handle,'FMUOutputVisibility',visibility);
            this.DialogData.OutputVisibilityChanged=false;
        end


        if this.DialogData.InternalVisibilityChanged
            internalTree=this.DialogData.outputListSource.internalValueStructure;
            visibility={};
            for i=1:length(internalTree)
                if internalTree(i).IsRoot
                    visibility=[visibility,str2logic(internalTree(i).IsVisible)];
                end
            end
            set_param(block.Handle,'FMUInternalNameVisibilityList',visibility);
            this.DialogData.InternalVisibilityChanged=false;
        end


        if this.DialogData.OutputStartValueChanged

        end



        [status,errmsg]=this.preApplyCallback(dlg);
        if(status==0)
            me=MException('FMU:InvSetting','%s',errmsg);
            throw(me);
        end



        if slfeature('FMUNativeSimulinkBehavior')&&...
            (~isequal(this.DialogData.SimulateUsing,block.SimulateUsing))
            set_param(block.handle,'SimulateUsing',this.DialogData.SimulateUsing);
            isVisible=strcmpi(this.DialogData.SimulateUsing,'FMU');
            dlg.setVisible('FMULoggingGroup',isVisible);
            dlg.setVisible('FMUSettingGroup',isVisible);
            dlg.setVisible('fmu_input_tab',isVisible);
            dlg.setVisible('fmu_output_tab',isVisible);
        end


        this.DialogData.ChangeList(updateParamsList)=zeros(1,numChanges);
        this.DialogData.ListOldValue(updateParamsList)=this.DialogData.ListValue(updateParamsList);
        dlg.refresh;
    catch ex
        status=0;
        errmsg=ex.message;


        try
            eval(restore_param_cmd);
        catch
        end
    end
end

function val=str2logic(str)
    if strcmp(str,'0')||strcmp(str,'false')||strcmp(str,'off')
        val=false;
    else
        val=true;
    end
end
