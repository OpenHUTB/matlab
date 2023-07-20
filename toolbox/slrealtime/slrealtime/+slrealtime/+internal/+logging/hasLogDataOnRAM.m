function r=hasLogDataOnRAM(tg,rundir)










    r=false;
    if tg.isRunning&&tg.isfile(strcat(rundir,"/ram.token"))



        r=true;
    end

end
