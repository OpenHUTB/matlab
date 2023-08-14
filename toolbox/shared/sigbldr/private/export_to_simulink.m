function UD=export_to_simulink(UD,blckpath,blckpos,openModel)





    if UD.common.dirtyFlag==1
        UD=save_session(UD);
    end


    allNames=cell(1,UD.numChannels);
    for i=1:UD.numChannels
        allNames{i}=UD.channels(i).label;
    end

    if isempty(blckpath)
        UD.simulink=sigbuilder_block('create',UD.dialog,allNames,openModel);
    elseif isempty(blckpos)
        UD.simulink=sigbuilder_block('create',UD.dialog,allNames,openModel,blckpath);
    else
        UD.simulink=sigbuilder_block('create',UD.dialog,allNames,openModel,blckpath,blckpos);
    end

    UD=save_to_location(UD);