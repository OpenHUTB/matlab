function update(hObj,event)










    if strcmp(event,'attach')
        cs=hObj.getConfigSet;
        if~isempty(cs)&&~isempty(hObj.UseSoCFeatures)
            if hObj.UseSoCFeatures==1
                cs.set_param('HardwareBoardFeatureSet','SoCBlockSet');
                hObj.UseSoCFeatures=char.empty;
            end
        end
    end
end