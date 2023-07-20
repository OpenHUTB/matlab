function setupCBSSetting(this,filterobj)




    hprop=this.HDLParameters;


    set(hprop.CLI,'CastBeforeSum','off');

    if isa(filterobj,'dfilt.basefilter')

        if any(strcmpi(fieldnames(get(filterobj)),'Arithmetic'))&&...
            strcmpi(filterobj.arithmetic,'fixed')
            if any(strcmpi(fieldnames(filterobj),'CastBeforeSum'))

                if filterobj.CastBeforeSum
                    set(hprop.CLI,'CastBeforeSum','on');
                else
                    set(hprop.CLI,'CastBeforeSum','off');
                end
            end
        end

    else
        [cando,errstr]=ishdlable(filterobj);
        if cando

            set(hprop.CLI,'CastBeforeSum','on');
        else
            error(message('HDLShared:hdlfilter:wrongSysObj',errstr));
        end
    end
