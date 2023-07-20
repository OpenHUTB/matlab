function save(cs,filename)


    [~,~,ext]=fileparts(filename);

    if any(ext==[".m",""])

        cs.saveAs(filename);
    elseif ext==".mat"

        name=strrep(strrep(strtrim(cs.Name),' ','_'),'-','_');
        if isvarname(name)

            feval(@()assignin('caller',name,cs));
        else

            name='cs';
        end
        save(filename,name);
    else
        throw(MSLException([],message('Simulink:ConfigSet:badFileExtension')));
    end
