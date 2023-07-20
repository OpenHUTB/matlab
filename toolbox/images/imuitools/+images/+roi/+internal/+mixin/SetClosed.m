classdef(Abstract)SetClosed<handle




    properties(Dependent)









Closed

    end

    properties(Hidden,Access=protected)
        ClosedInternal=true;
    end

    methods





        function set.Closed(self,TF)

            validateattributes(TF,{'logical','numeric'},...
            {'nonempty','real','scalar','nonsparse'},...
            mfilename,'Closed');

            TF=logical(TF);
            if self.ClosedInternal~=TF
                self.ClosedInternal=logical(TF);
                updateROIWhenClosedSet(self);


                update(self);
            end

        end

        function TF=get.Closed(self)
            TF=self.ClosedInternal;
        end

    end

    methods(Hidden,Access=protected)


        function updateROIWhenClosedSet(~)





        end

    end

    methods(Sealed,Hidden,Access=protected)


        function TF=isFreehandClosed(self)
            TF=self.ClosedInternal;
        end

    end

end