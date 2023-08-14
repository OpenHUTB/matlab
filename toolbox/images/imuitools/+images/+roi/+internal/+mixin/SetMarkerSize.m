classdef(Abstract)SetMarkerSize<handle




    properties(Dependent)






MarkerSize

    end

    properties(Hidden,Dependent)











MarkersVisible

    end

    methods




        function set.MarkerSize(self,val)


            setMarkerSize(self,val);

        end

        function val=get.MarkerSize(self)
            val=getMarkerSize(self);
        end




        function set.MarkersVisible(self,val)


            setMarkersVisible(self,val);

        end

        function val=get.MarkersVisible(self)

            val=getMarkersVisible(self);

        end

    end

end
