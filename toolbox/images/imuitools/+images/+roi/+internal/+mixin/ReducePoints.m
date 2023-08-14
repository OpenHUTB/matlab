classdef(Abstract)ReducePoints<handle




    methods




        function reduce(self,varargin)










            reduceClosed(self,varargin{:});

        end

    end

    methods(Access=protected)

        function reduceOpen(self,varargin)

            [xROI,yROI]=getLineData(self);
            posreduced=reducepoly([xROI,yROI],varargin{:});
            self.Position=posreduced;

        end
        function reduceClosed(self,varargin)


            [xROI,yROI]=getLineData(self);
            posreduced=reducepoly([xROI,yROI],varargin{:});
            pos=self.Position;
            if(~(isempty(posreduced)))
                if(~(isequal(pos(1,:),pos(end,:))))



                    posreduced(end,:)=[];

                end
            end
            self.Position=posreduced;
        end

    end

end