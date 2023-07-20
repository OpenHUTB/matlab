




function classicExtModeArgs=parseClassicExtModeTCPIPParameters(classicExtModeArgs,tokens)

    classicExtModeArgs.targetName='localhost';
    classicExtModeArgs.targetPort=17725;

    if~isempty(tokens)

        classicExtModeArgs.targetName=strip(tokens{1}{1},'''');


        if numel(tokens)>1
            [verbosityLevel,elemNumber,errMsg]=sscanf(tokens{2}{1},"%i");

            if~isempty(verbosityLevel)&&(elemNumber==1)&&isempty(errMsg)&&(verbosityLevel==1)

                classicExtModeArgs.verbosityLevel=1;
            else

                classicExtModeArgs.verbosityLevel=0;
            end
        end


        if numel(tokens)>2&&~(strcmp(tokens{3}{1},'[]')||strcmp(tokens{3}{1},''''''))
            [port,elemNumber,errMsg]=sscanf(tokens{3}{1},"%i");

            if~isempty(port)&&(elemNumber==1)&&isempty(errMsg)&&...
                ((port>=0)&&(port<=65535))
                classicExtModeArgs.targetPort=double(port);
            else
                MSLDiagnostic('coder_xcp:host:InvalidTCPIPPortNumber',classicExtModeArgs.targetPort).reportAsWarning;
            end
        end
    end
end
