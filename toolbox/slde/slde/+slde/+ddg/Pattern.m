classdef Pattern<handle





    properties

        mRequiresStatTbx=false;

    end




    methods(Abstract=true)



        schema=getDialogSchema(this);
        mlcode=generate(this,dialog,existingVars,outVar);



    end


    methods


        function handleEditActions(this,dialog,param,value)

            this.(param)=value;

        end


        function handleComboSelectionAction(this,dialog,param,value)

            this.(param)=value;

        end



    end



end

