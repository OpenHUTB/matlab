classdef AnnotationQuery<Simulink.ModelManagement.Project.Search.AbstractQuery




    properties(Constant=true)
        ValueQuery=i_createValueQuery;
        PathQuery=i_createPathQuery;
    end

    methods
        function[match,location]=createResult(~,token,value,path)
            import com.mathworks.toolbox.slprojectsimulink.search.models.SimulinkLoadsaveMatch;
            import com.mathworks.toolbox.slprojectsimulink.search.models.SimulinkBlockDiagramMatchLocation;

            match=SimulinkLoadsaveMatch(token,value);
            location=SimulinkBlockDiagramMatchLocation(path);
        end
    end

end


function query=i_createValueQuery
    query=Simulink.loadsave.Query('//System/Annotation/*');
end

function query=i_createPathQuery
    query=i_createValueQuery;
    query.Modifier=Simulink.loadsave.Modifier.AnnotationPath;
end

