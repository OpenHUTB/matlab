function[strList1,strList2]=getSignalBuilderOrEditor(group,strList1,strList2)
    if isSignalBuilder(group)
        blockResource=getString(message('stm:ReportContent:Field_SignalBuilderBlock'));
        groupResource=getString(message('stm:ReportContent:Field_SignalBuilderGroup'));
        blockString=group.SignalBuilderBlock;
        groupString=group.SignalBuilderGroup;
    elseif isSignalEditor(group)
        blockResource=getString(message('stm:ReportContent:Field_SignalEditorBlock'));
        groupResource=getString(message('stm:ReportContent:Field_SignalEditorScenario'));
        blockString=group.SignalEditorBlock;
        groupString=group.SignalEditorScenario;
    end

    if exist('blockResource','var')
        if strlength(blockString)>0
            strList1=[strList1,{blockResource}];
            strList2=[strList2,{blockString}];
        end

        strList1=[strList1,{groupResource}];
        strList2=[strList2,{groupString}];
    end
end

function bool=isSignalBuilder(group)
    bool=isfield(group,'SignalBuilderGroup')&&strlength(group.SignalBuilderGroup)>0;
end

function bool=isSignalEditor(group)
    bool=isfield(group,'SignalEditorBlock')&&strlength(group.SignalEditorBlock)>0;
end
