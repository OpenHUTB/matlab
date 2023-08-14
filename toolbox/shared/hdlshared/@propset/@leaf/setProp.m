function[success,err]=setProp(h,prop,value)





















    for i=1:numel(h.prop_sets)
        if h.prop_set_enables(i)



            try




                h.prop_sets{i}.(prop)=value;


                success=true;
                err=[];
                return
            catch me

                err=me;
                success=strcmpi(me.identifier,'MATLAB:noPublicFieldForClass');
                if~success
                    return
                end
            end
        end
    end


    success=false;


