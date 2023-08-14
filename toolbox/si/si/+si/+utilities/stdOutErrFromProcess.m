function stdOutErrFromProcess(process)









    if process.isAlive
        disp("Standard output and error not available: The process is still active.")



        return
    end
    echoStream(process,true)
    echoStream(process,false)
    disp("Process exited with return code of "+num2str(process.exitValue))
    function echoStream(process,stdOut)
        if stdOut
            streamName="Standard Out";
            stream=process.getInputStream();
        else
            streamName="Standard Error";
            stream=process.getErrorStream();
        end
        disp(streamName+" Follows:")
        if~isempty(stream)
            inReader=java.io.InputStreamReader(stream);
            reader=java.io.BufferedReader(inReader);
            line=reader.readLine;
            while~isempty(line)
                line=strip(string(line));
                if line~=""
                    disp(line);
                end
                line=reader.readLine;
            end
            disp(streamName+" End")
        else
            disp(streamName+" Not Found")
        end
    end
end
