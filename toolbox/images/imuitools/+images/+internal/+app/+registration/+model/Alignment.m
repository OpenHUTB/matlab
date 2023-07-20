classdef Alignment<handle





    properties
rigidOperation
nonrigidOperation
useNonrigidOperation
useOnlyNonrigidOperation

metrics
elapsedTime
registeredImage
registeredRGBImage

entryNumber
entryName
        entryStatus=true;
        statusMessage='';
    end

    methods
        function self=Alignment(varargin)

            params=parse_inputs(varargin{:});

            self.rigidOperation=params.Results.rigidOperation;
            self.nonrigidOperation=params.Results.nonrigidOperation;
            self.useNonrigidOperation=params.Results.useNonrigidOperation;
            self.useOnlyNonrigidOperation=false;

            self.metrics=images.internal.app.registration.model.Metrics;
        end

        function[]=runAlignment(self,fixed,moving,movingRGB,fixedRefObj,movingRefObj)



            tic;
            if~isempty(self.rigidOperation)&&~self.useOnlyNonrigidOperation
                [self.registeredImage,self.registeredRGBImage]=self.rigidOperation.run(fixed,moving,movingRGB,fixedRefObj,movingRefObj);
            end

            if self.useNonrigidOperation&&~isempty(self.nonrigidOperation)
                if isempty(self.registeredImage)

                    [self.registeredImage,self.registeredRGBImage]=self.nonrigidOperation.run(fixed,moving,movingRGB);
                else

                    [self.registeredImage,self.registeredRGBImage]=self.nonrigidOperation.run(fixed,self.registeredImage,self.registeredRGBImage);
                end
            end
            self.elapsedTime=toc;
            self.metrics.getAlignmentQuality(self.registeredImage,fixed);
        end

        function set.registeredImage(self,imageInput)
            self.registeredImage=imageInput;
        end

    end

end

function params=parse_inputs(varargin)


    params=inputParser;

    params.FunctionName=mfilename;

    defaultrigidOperation=images.internal.app.registration.model.FeatureOperator;
    defaultnonrigidOperation=images.internal.app.registration.model.NonrigidWarpOperator;
    defaultuseNonrigidOperation=false;

    addOptional(params,'rigidOperation',defaultrigidOperation,@(x)isa(x,'images.internal.app.registration.model.RigidWarpOperator'));
    addOptional(params,'nonrigidOperation',defaultnonrigidOperation,@(x)isa(x,'images.internal.app.registration.model.NonrigidWarpOperator'));
    addOptional(params,'useNonrigidOperation',defaultuseNonrigidOperation,@islogical);

    parse(params,varargin{:});
end
