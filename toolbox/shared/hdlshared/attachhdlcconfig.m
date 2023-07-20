function varargout=attachhdlcconfig(model)










    narginchk(1,1);




    if isequal(model,0)


        return;
    end

    mdlObj=bdroot(get_param(model,'Handle'));









    sobj=get_param(model,'Object');
    configSet=sobj.getActiveConfigSet;
    if(isa(configSet,'Simulink.ConfigSetRef'))
        error(message('HDLShared:directemit:refconfigset'));
    end

    hdlcc=gethdlcconfigset(configSet);


    if strcmp(get_param(model,'SimulationStatus'),'stopped')
        if~isa(hdlcc,'hdlcoderui.hdlcc'),

            hdlcexist=which('makehdl');
            if isempty(hdlcexist)
                warning(message('HDLShared:directemit:slhdlcoderinstall'));
            else
                if hdlcoderui.isslhdlcinstalled
                    if mdlObj==0
                        hdlcc=hdlcoderui.hdlcc;
                    else
                        hdlcc=hdlcoderui.hdlcc(model);
                    end
                    attachComponent(configSet,hdlcc);
                end
            end
        end
    end

    if nargout==1
        varargout{1}=hdlcc;
    end




