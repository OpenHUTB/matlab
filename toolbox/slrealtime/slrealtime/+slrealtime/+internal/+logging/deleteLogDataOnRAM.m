function deleteLogDataOnRAM(tg)





    if tg.isfile("/dev/shmem/BufferedLogging_*")
        res=tg.executeCommand("ls /dev/shmem/BufferedLogging_*");
        res=split(res.Output);
        files=res(~cellfun('isempty',res));
        for i=1:numel(files)
            tg.executeCommand(strcat("rm -f ",files{i}));
        end
    end
end
