function appendCommentsAfterTracing(obj)





    tracingComments=obj.TracingComments;
    if isempty(tracingComments)






        if obj.ParameterNotPropagatedToLink


            tracingComments{end+1}=DAStudio.message('SimulinkFixedPoint:autoscaling:topLinkNotMask');

        else



            changeNotAllowed=SimulinkFixedPoint.TracingUtils.ChangeNotAllowedByBlockMask(obj.BlkObjToBeSet,obj.ParamNameToBeSet,obj.MaskDataList);

            if changeNotAllowed
                tracingComments{end+1}=DAStudio.message('SimulinkFixedPoint:autoscaling:blockDTCantAutoscale');
            end
        end
    end

    obj.TracingComments=tracingComments;
end


