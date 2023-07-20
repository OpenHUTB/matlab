




function classicExtModeArgs=parseClassicExtModeSerialParameters(classicExtModeArgs,tokens)

    classicExtModeArgs.baudRate=57600;

    if ispc
        portNamePrefix='COM';
    else
        portNamePrefix='ttyS';
    end
    classicExtModeArgs.portName=[portNamePrefix,'1'];


    if~isempty(tokens)

        [verbosityLevel,elemNumber,errMsg]=sscanf(tokens{1}{1},"%i");

        if~isempty(verbosityLevel)&&(elemNumber==1)&&isempty(errMsg)&&(verbosityLevel==1)

            classicExtModeArgs.verbosityLevel=1;
        else

            classicExtModeArgs.verbosityLevel=0;
        end


        if numel(tokens)>1
            [port,elemNumber,errMsg]=sscanf(tokens{2}{1},"%i");

            if~isempty(port)&&(elemNumber==1)&&isempty(errMsg)


                classicExtModeArgs.portName=[portNamePrefix,tokens{2}{1}];
            else

                classicExtModeArgs.portName=strip(tokens{2}{1},'''');
            end
        end


        if numel(tokens)>2&&~(strcmp(tokens{3}{1},'[]')||strcmp(tokens{3}{1},''''''))
            [baudRate,elemNumber,errMsg]=sscanf(tokens{3}{1},"%i");

            if~isempty(baudRate)&&(elemNumber==1)&&isempty(errMsg)&&isValidBaudRate(baudRate)
                classicExtModeArgs.baudRate=double(baudRate);

                if(isBaudRateTooLow(baudRate))
                    MSLDiagnostic('coder_xcp:host:TooLowSerialBaudRate',classicExtModeArgs.baudRate).reportAsWarning;
                end
            else
                MSLDiagnostic('coder_xcp:host:InvalidSerialBaudRate',classicExtModeArgs.baudRate).reportAsWarning;
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