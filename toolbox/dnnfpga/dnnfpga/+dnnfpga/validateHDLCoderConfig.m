function validateHDLCoderConfig(hPC,hdlcoderConfig)








    for ii=1:2:length(hdlcoderConfig)
        property=hdlcoderConfig{ii};
        value=hdlcoderConfig{ii+1};


        if strcmpi(property,'TargetLang')
            if~strcmpi(value,'vhdl')
                if contains(hPC.SynthesisTool,'Intel')||contains(hPC.SynthesisTool,'Altera')
                    msg=message('hdlcoder:validate:TargetAlteraFPFunctionsVHDLOnly');
                    error(msg);
                end
            end
        end
    end
end

