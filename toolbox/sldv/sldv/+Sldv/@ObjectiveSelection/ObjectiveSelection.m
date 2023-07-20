




classdef ObjectiveSelection<handle











    methods(Static)
        elem=sldvPickObjectives(hdls,varargin)

        stmt=sldvPickMcdcObjectives(hdl,portNo)

        stmt=sldvPickMcdcForPort(blkH,portNo)

        stmt=sldvCompose(varargin)

        stmt=sldvGroupCompose(group,varargin)

        stmt=addPathInformation(group,pathList,outValue)

        elem=addDelay(hdl,numSteps)

        value=getConstraintValue(constraint)
    end
end
