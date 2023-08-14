function enabled=debugmode(newEnabled,scope)



    enabled=false;

    if~usejava('swing')
        return;
    end

    try

        if exist('newEnabled','var')
            validateattributes(newEnabled,{'logical','numeric'},{});

            if~exist('scope','var')
                scope='session';
            end
            assert(ischar(scope)&&any(ismember({'global','session','test'},scope)));

            permanent=strcmp(scope,'global');
            test=strcmp(scope,'test');
            com.mathworks.toolbox.coder.util.InternalUtilities.setDebugMode(logical(newEnabled),permanent,test);
        end

        enabled=com.mathworks.toolbox.coder.util.InternalUtilities.isDebugMode();
    catch me %#ok<NASGU>

    end
end