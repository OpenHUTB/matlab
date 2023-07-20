




function xcpExtModeArgs=parseXcpExtModeSerialParameters(xcpExtModeArgs,tokens)

    xcpExtModeArgs.baudRate=57600;

    if ispc
        portNamePrefix='COM';
    else
        portNamePrefix='ttyS';
    end
    xcpExtModeArgs.portName=[portNamePrefix,'1'];






    xcpExtModeArgs.flowControlType=0;









    xcpExtModeArgs.openDelayInMs=0;


    if~isempty(tokens)

        [verbosityLevel,elemNumber,errMsg]=sscanf(tokens{1}{1},"%i");

        if~isempty(verbosityLevel)&&(elemNumber==1)&&isempty(errMsg)&&(verbosityLevel==1)

            xcpExtModeArgs.verbosityLevel=1;
        else

            xcpExtModeArgs.verbosityLevel=0;
        end


        if numel(tokens)>1
            [port,elemNumber,errMsg]=sscanf(tokens{2}{1},"%i");

            if~isempty(port)&&(elemNumber==1)&&isempty(errMsg)


                xcpExtModeArgs.portName=[portNamePrefix,tokens{2}{1}];
            else

                xcpExtModeArgs.portName=strip(tokens{2}{1},'''');
            end
        end


        if numel(tokens)>2&&~(strcmp(tokens{3}{1},'[]')||strcmp(tokens{3}{1},''''''))
            [baudRate,elemNumber,errMsg]=sscanf(tokens{3}{1},"%i");

            if~isempty(baudRate)&&(elemNumber==1)&&isempty(errMsg)&&isValidBaudRate(baudRate)
                xcpExtModeArgs.baudRate=double(baudRate);

                if(isBaudRateTooLow(baudRate))
                    MSLDiagnostic('coder_xcp:host:TooLowSerialBaudRate',xcpExtModeArgs.baudRate).reportAsWarning;
                end
            else
                MSLDiagnostic('coder_xcp:host:InvalidSerialBaudRate',xcpExtModeArgs.baudRate).reportAsWarning;
            end
        end



        if numel(tokens)>3
            xcpExtModeArgs.symbolsFileName=strip(tokens{4}{1},'''');
        end


        if numel(tokens)>4
            xcpExtModeArgs.flowControlType=str2double(tokens{5}{1});
        end


        if numel(tokens)>5
            xcpExtModeArgs.openDelayInMs=str2double(tokens{6}{1});
        end


        if numel(tokens)>6&&~(strcmp(tokens{7}{1},'[]')||strcmp(tokens{7}{1},''''''))
            [targetPollingTime,elemNumber,errMsg]=sscanf(tokens{7}{1},"%i");

            if~isempty(targetPollingTime)&&(elemNumber==1)&&isempty(errMsg)&&...
                (targetPollingTime>0)
                xcpExtModeArgs.targetPollingTime=double(targetPollingTime);
            else
                MSLDiagnostic('coder_xcp:host:InvalidTargetPollingTime',xcpExtModeArgs.targetPollingTime).reportAsWarning;
            end
        end
    end
end

function valid=isValidBaudRate(baudRate)


    valid=(baudRate>0);
end

function lowBaudrate=isBaudRateTooLow(baudRate)















    lowBaudrate=(baudRate<57600);
end
