function flag=checkMATLABPersistentVariables(this)




    MLroot=sfroot;
    EMLblocks=MLroot.find('Name',get_param(this.m_DUT,'Name'));

    if(isempty(EMLblocks))
        flag=true;
        return
    end

    EMLcharts=EMLblocks.find('-isa','Stateflow.Chart','-or',...
    '-isa','Stateflow.EMChart','-or',...
    '-isa','Stateflow.TruthTable','-regexp','Name','.*');

    flag=isempty(EMLcharts);
    for itr=1:length(EMLcharts)
        if isa(EMLcharts(itr),'Stateflow.EMChart')
            if strfind(EMLcharts(itr).script,'persistent')
                this.addCheck('warning','no-persistent-vars',EMLcharts(itr).Path,0);
            end
        end
    end
end
