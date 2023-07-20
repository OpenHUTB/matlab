function ret=evalWksVar(~,mdl,str)



    if~isempty(str)&&~isempty(mdl)&&exist(mdl,'file')==4
        if~bdIsLoaded(mdl)
            load_system(mdl);
        end


        ddPath=get_param(mdl,'DataDictionary');
        if~isempty(ddPath)
            dd=Simulink.data.dictionary.open(ddPath);
            ddSect=dd.getSection('Design Data');
            if ddSect.exist(str)
                ent=ddSect.getEntry(str);
                ret=ent.getValue;
                return
            end
        end


        mdl_wks=get_param(mdl,'ModelWorkspace');
        if mdl_wks.hasVariable(str)
            ret=mdl_wks.getVariable(str);
            return
        end
    end


    ret=evalin('base',str);
end
