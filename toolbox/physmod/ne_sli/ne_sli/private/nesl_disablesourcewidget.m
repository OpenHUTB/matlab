function[isDisabled,disabledExt]=nesl_disablesourcewidget(disable,ext)





    mlock;

    persistent pDisable;
    persistent pExt;
    if isempty(pDisable)
        pDisable=false;
    end

    if isempty(pExt)
        pExt={};
    end

    if nargin==1
        pDisable=disable;
        pExt={};
    end

    if nargin==2
        pDisable=disable;
        if isempty(ext)
            pExt={};
        elseif~iscell(ext)
            ext=strrep(ext,'.','');
            pExt={['.',ext]};
        elseif iscell(ext)
            ext=strrep(ext,'.','');
            pExt=strcat('.',ext);
        end
    end

    isDisabled=pDisable;
    disabledExt=pExt;
end
