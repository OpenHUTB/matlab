function StateflowAnimation(obj)








    if isR2014bOrEarlier(obj.ver)
        machines=getStateflowMachine(obj);
        for i=1:numel(machines)
            machineId=machines(i).Id;
            delay=sf('get',machineId,'.debug.animation.delay');
            if(delay<0)
                sf('set',machineId,'.debug.animation.delay',0);
            end
        end
    end
end
