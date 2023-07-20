




function xcpExtModeArgs=parseXcpExtModeTCPIPParameters(xcpExtModeArgs,tokens)

    xcpExtModeArgs.targetName='localhost';
    xcpExtModeArgs.targetPort=17725;

    if~isempty(tokens)

        xcpExtModeArgs.targetName=strip(tokens{1}{1},'''');


        if numel(tokens)>1
            [verbosityLevel,elemNumber,errMsg]=sscanf(tokens{2}{1},"%i");

            if~isempty(verbosityLevel)&&(elemNumber==1)&&isempty(errMsg)&&(verbosityLevel==1)

                xcpExtModeArgs.verbosityLevel=1;
            else

                xcpExtModeArgs.verbosityLevel=0;
            end
        end


        if numel(tokens)>2&&~(strcmp(tokens{3}{1},'[]')||strcmp(tokens{3}{1},''''''))
            [port,elemNumber,errMsg]=sscanf(tokens{3}{1},"%i");

            if~isempty(port)&&(elemNumber==1)&&isempty(errMsg)&&...
                ((port>=0)&&(port<=65535))
                xcpExtModeArgs.targetPort=double(port);
            else
                MSLDiagnostic('coder_xcp:host:InvalidTCPIPPortNumber',xcpExtModeArgs.targetPort).reportAsWarning;
            end
        end



        if numel(tokens)>3
            xcpExtModeArgs.symbolsFileName=strip(tokens{4}{1},'''');
        end


        if numel(tokens)>4&&~(strcmp(tokens{5}{1},'[]')||strcmp(tokens{5}{1},''''''))
            [targetPollingTime,elemNumber,errMsg]=sscanf(tokens{5}{1},"%i");

            if~isempty(targetPollingTime)&&(elemNumber==1)&&isempty(errMsg)&&...
                (targetPollingTime>0)
                xcpExtModeArgs.targetPollingTime=double(targetPollingTime);
            else
                MSLDiagnostic('coder_xcp:host:InvalidTargetPollingTime',xcpExtModeArgs.targetPollingTime).reportAsWarning;
            end
        end
    end
end
