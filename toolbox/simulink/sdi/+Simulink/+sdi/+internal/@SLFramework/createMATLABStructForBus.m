function ret=createMATLABStructForBus(~,mdl,busName)



    if~isempty(mdl)&&exist(mdl,'file')==4
        if~bdIsLoaded(mdl)
            load_system(mdl);
        end


        ddPath=get_param(mdl,'DataDictionary');
        if~isempty(ddPath)
            dd=Simulink.data.dictionary.open(ddPath);
            ddSect=dd.getSection('Design Data');
            if ddSect.exist(busName)
                ret=Simulink.Bus.createMATLABStruct(busName,[],1,dd);
                return
            end
        end
    end


    ret=Simulink.Bus.createMATLABStruct(busName);
end
