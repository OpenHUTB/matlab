classdef CorrelationOperator<images.internal.app.registration.model.RigidWarpOperator





    properties


correlationProperty
    end

    methods
        function self=CorrelationOperator(varargin)
            self.tformType='rigid';
            self.correlationProperty=images.internal.app.registration.model.CorrelationProperty;
            if(nargin==0)
                self.correlationProperty.window=true;
            elseif(nargin==1)
                if islogical(varargin{1})
                    self.correlationProperty.window=varargin{1};
                else
                    assert(false,'phaseCorrelation expects only logical inputs.');
                end
            else
                assert(false,'Incorrect number of inputs for phaseCorrelation constructor. Expected 0 or 1');
            end
        end

        function[registeredImage,movingRGB]=run(self,fixed,moving,movingRGB,fixedRefObj,movingRefObj)

            tform=imregcorr(moving,movingRefObj,fixed,fixedRefObj,...
            'transformType',self.tformType,...
            'Window',self.correlationProperty.window);
            self.tform=tform;




            registeredImage=imwarp(moving,movingRefObj,self.tform,'OutputView',fixedRefObj,'SmoothEdges',true);

            if~isempty(movingRGB)
                movingRGB=imwarp(movingRGB,movingRefObj,self.tform,'OutputView',fixedRefObj,'SmoothEdges',true);
            end

        end
    end

end
