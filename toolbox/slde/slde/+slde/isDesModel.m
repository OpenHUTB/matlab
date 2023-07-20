function out=isDesModel(modelName)


    out=false;


    if private_sl_isDesModel(modelName)
        out=true;
    else

        Machine=find(sfroot,'-isa','Stateflow.Machine','Name',modelName);
        Charts=[];
        if~isempty(Machine)
            Charts=Machine.find('-isa','Stateflow.Chart');
        end
        for idx=1:length(Charts)
            if(sfprivate('is_des_chart',Charts(idx).Id))
                out=true;
                return;
            end
        end
    end

end