classdef(Abstract)Workspace<handle




    methods(Abstract)
        variables=whos(this)



        value=importVariable(this,name)


    end

end