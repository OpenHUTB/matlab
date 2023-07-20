function writeToProcess(process,cmd)






    if~process.isAlive
        oldWarnState=warning('off','backtrace');
        warning("Process is not active.")
        warning(oldWarnState.state,'backtrace')
        return;
    end
    stream=process.getOutputStream();
    streamWriter=java.io.OutputStreamWriter(stream);
    writer=java.io.BufferedWriter(streamWriter);
    writer.write(cmd,0,cmd.strlength)
    writer.newLine
    writer.flush
end
