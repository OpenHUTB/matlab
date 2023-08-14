classdef AbstractEntryQuery<Simulink.ModelManagement.Project.Search.AbstractQuery




    methods
        function[match,location]=createResult(~,token,value,path)
            import com.mathworks.toolbox.slprojectsimulink.search.dictionaries.DataDictionaryLoadsaveMatch;
            import com.mathworks.toolbox.slprojectsimulink.search.dictionaries.DataDictionaryEntryMatchLocation;

            match=DataDictionaryLoadsaveMatch(token,value);
            location=DataDictionaryEntryMatchLocation(path);
        end
    end

end

