classdef(Hidden)LiveTaskBaseInterface<handle






    methods(Abstract)

        generateScript(obj);






        generateVisualizationScript(obj);




        generateSummary(obj);





        getState(obj);



        setState(obj);



        reset(obj);

    end


    events
StateChanged
    end


end

