function addInterrupt(fid,hbuild)
    intr=hbuild.Interrupt;
    if~isempty(hbuild.HPS)&&~isempty(intr)
        for ii=1:numel(intr)
            fprintf(fid,'add_connection hps.f2h_irq0 %s\n',intr(ii).name);
            fprintf(fid,'set_connection_parameter_value hps.f2h_irq0/%s irqNumber {%d}\n',intr(ii).name,intr(ii).irq_num);
        end
    end