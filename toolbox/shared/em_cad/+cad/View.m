classdef(Abstract)View<handle&matlab.mixin.Heterogeneous




    properties
Controller

    end

    methods
        function modelChanged(self)




        end
        function setModel(self,Model)
        end
        function rtn=checkValid(~,tHandle)
            if~isempty(tHandle)
                if isvalid(tHandle)
                    rtn=true;
                else
                    rtn=false;
                end
            else
                rtn=false;
            end
        end

        function setLayout(self,obj,row,column)
            obj.Layout.Row=row;
            obj.Layout.Column=column;
        end

        function updateView(self,vm)



        end
    end

    events
DialogClosed
    end
end

