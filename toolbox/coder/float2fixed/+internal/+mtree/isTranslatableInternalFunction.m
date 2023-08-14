function isit=isTranslatableInternalFunction(fcnPath)










    if strcmp(hdlfeature('TranslateInternal'),'on')


        supportedInternalFcns={...
        fullfile(matlabroot,'toolbox','hdlcoder','hdllib','ml_lib','+internal','+hdl','imfilter.m'),...
        };


        isit=ismember(fcnPath,supportedInternalFcns);
    else
        isit=false;
    end
end


