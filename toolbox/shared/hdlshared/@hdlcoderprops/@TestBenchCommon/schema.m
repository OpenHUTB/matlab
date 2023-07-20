function schema







    mlock;

    pk=findpackage('hdlcoderprops');
    c=schema.class(pk,'TestBenchCommon',pk.findclass('AbstractProp'));

    schema.prop(c,'tb_name','string');

    schema.prop(c,'multifiletestbench','bool');
    schema.prop(c,'usefileiointestbench','bool');
    schema.prop(c,'ignoredatachecking','HDLuint32');

    p=schema.prop(c,'tb_stimulus','mxArray');
    set(p,'SetFunction',@set_testbenchstimulus);

    schema.prop(c,'tb_fracdelay_stimulus','mxArray');
    schema.prop(c,'tb_coeff_stimulus','mxArray');
    schema.prop(c,'tb_rate_stimulus','mxArray');

    schema.prop(c,'tb_user_stimulus','mxArray');
    schema.prop(c,'force_clockenable','bool');
    schema.prop(c,'force_clockenable_value','bool');
    schema.prop(c,'testbenchclockenabledelay','HDLuint32');
    schema.prop(c,'force_clock','bool');
    schema.prop(c,'force_clock_high_time','double');
    schema.prop(c,'force_clock_low_time','double');
    schema.prop(c,'force_reset','bool');
    schema.prop(c,'force_hold_time','double');
    schema.prop(c,'error_margin','HDLuint32');
    schema.prop(c,'force_reset_value','bool');
    schema.prop(c,'tb_postfix','ustring');
    schema.prop(c,'tbdata_postfix','ustring');

    schema.prop(c,'holdinputdatabetweensamples','bool');
    schema.prop(c,'initializetestbenchinputs','bool');
    schema.prop(c,'resetlength','HDLuint32');

    schema.prop(c,'hdlcodecoverage','bool');
    schema.prop(c,'generatehdltestbench','bool');
    schema.prop(c,'generatecosimblock','bool');
    schema.prop(c,'generatecosimmodel','ustring');
    schema.prop(c,'cosimmodelsetup','ustring');
    schema.prop(c,'generatesvdpitestbench','ustring');
    schema.prop(c,'simulationtool','ustring');


    schema.prop(c,'generatefilblock','bool');
    schema.prop(c,'inputdatainterval','double');


    schema.prop(c,'nfpEpsilon','double');



    p=schema.prop(c,'tbrefsignals','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'testbenchreferencepostfix','ustring');
    set(p,'FactoryValue','_ref');


    function stim=set_testbenchstimulus(this,stim)%#ok

        if isempty(stim)
            stim={};
        else
            if~iscell(stim)
                stim={stim};
            end

            stims={'impulse','step','ramp','chirp','noise'};
            temp_stims=[];
            for n=1:length(stim)
                v=stim{n};
                if ischar(v)
                    position=find(strncmpi(v,stims,length(v)));
                else
                    position=[];
                end
                if isempty(position)||length(position)>1
                    errstr='';
                    for i=1:length(stims)-1
                        errstr=[errstr,'''',stims{i},''', '];%#ok
                    end
                    errstr=[errstr,'or ''',stims{end},''''];%#ok
                    error(message('HDLShared:CLI:illegalPropValue',sprintf('%s ',stim{:}),'tb_stimulus',errstr));
                else
                    temp_stims=[temp_stims,position];%#ok % gather the winners 
                end
            end
            stim=stims(sort(unique(temp_stims)));
        end



