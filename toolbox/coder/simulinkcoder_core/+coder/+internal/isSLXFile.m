function out=isSLXFile(mdlHandle)


    name=get_param(mdlHandle,'Name');
    fileName=which(name);
    [~,~,e]=fileparts(fileName);

    if isempty(e)

        out=true;
    else
        if strcmpi(e,'.slx')
            out=true;
        else
            out=false;
        end
    end
end
