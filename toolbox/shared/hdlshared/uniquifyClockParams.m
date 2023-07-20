function uniquifyClockParams(this)


    CLIParams={'ClockInputPort','ResetInputPort','ClockEnableInputPort',...
    'ClockEnableOutputPort','EnablePrefix'};
    INIParams={'clockname','resetname','clockenablename',...
    'clockenableoutputname','enableprefix'};
    currentINIValues=cellfun(@hdlgetparameter,INIParams,'UniformOutput',false);

    gp=pir;
    uniqueValues=gp.uniquifyClockParameters(currentINIValues);
    clockParams=struct;



    for ii=2:numel(uniqueValues)
        if~strcmp(currentINIValues{ii},uniqueValues{ii})
            hdldisp(sprintf('Name collision with user-specified parameter %s.  Changing %s to %s.',...
            CLIParams{ii},currentINIValues{ii},uniqueValues{ii}));
            clockParams.(INIParams{ii})=uniqueValues{ii};
            if isa(this,'slhdlcoder.HDLTestbench')
                if ii<4

                    this.(INIParams{ii})=uniqueValues{ii};
                end
            else
                this.updateCLI(CLIParams{ii},uniqueValues{ii});
            end
            hdlsetparameter(INIParams{ii},uniqueValues{ii});
        end
    end

    if~isempty(fieldnames(clockParams))
        gp.initParams(clockParams);
    end
end
