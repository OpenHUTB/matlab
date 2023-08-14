function subsystems=getSelectedSubsystemsWithPortLabel(cbinfo,portLabel)




    selection=cbinfo.selection;
    subsystems=[];
    if selection.size>0
        model=selection.at(1).modelM3I;

        resultArray=cbinfo.studio.App.getActiveEditor.getSelectedObjectHandlesOfType(model,SLM3I.Block.MetaClass);
        for i=1:length(resultArray)
            objHandle=resultArray(i);
            if strcmpi(get_param(objHandle,'BlockType'),'SubSystem')
                showPortLabels=get_param(objHandle,'ShowPortLabels');
                if(strcmpi(portLabel,'any')||strcmpi(showPortLabels,portLabel))
                    subsystems=[subsystems,objHandle];%#ok<AGROW>
                end
            end
        end
    end
end
