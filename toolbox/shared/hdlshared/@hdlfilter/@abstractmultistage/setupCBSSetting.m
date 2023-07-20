function setupCBSSetting(this,filterobj)






    hprop=this.HDLParameters;

    set(hprop.CLI,'CastBeforeSum','off')


    for n=1:length(filterobj.stage)
        hprop=this.Stage(n).HDLParameters;

        set(hprop.CLI,'CastBeforeSum','off')
        if any(strcmpi(fieldnames(get(filterobj.Stage(n))),'Arithmetic'))&&...
            strcmpi(filterobj.Stage(n).arithmetic,'fixed')
            if any(strcmpi(fieldnames(filterobj.Stage(n)),'CastBeforeSum'))

                if filterobj.stage(n).CastBeforeSum,
                    set(hprop.CLI,'CastBeforeSum','on')
                else
                    set(hprop.CLI,'CastBeforeSum','off')
                end
            end
        end
    end



