classdef Specification<handle




    methods
        function updateWidgets(this,propertySheet)
            ids=getPropertyNames(this);
            type=getType(this);


            for indx=1:numel(ids)
                hWidget=getWidget(propertySheet,type,ids{indx});
                set(hWidget,'String',this.(ids{indx}));
            end
        end
    end

    methods(Static)
        function status=validateProperty(val,validClasses,validAttributes)
            status=true;
            try
                validateattributes(val,validClasses,validAttributes);
            catch me
                status=false;
                uiwait(errordlg(me.message,getString(message('comm_demos:LinkBudgetApp:LinkBudgetAnalyzer')),'modal'));
            end

        end
    end
end


