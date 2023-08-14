function out=isModelDict(dd)
    if isa(dd,'Simulink.data.Dictionary')
        [~,~,fext]=fileparts(dd.filepath);
        if strcmp(fext,'.sldd')
            out=false;
        else
            out=true;
        end
    else

        out=strcmp(dd.owner.context,'model');
    end
end