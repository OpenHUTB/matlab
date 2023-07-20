function groups=getPropertyGroups(obj)






    if isscalar(obj)
        groups=matlab.mixin.util.PropertyGroup(...
        {'Name','Type','IndexNames','LowerBound','UpperBound'});
    else
        groups=getPropertyGroups@matlab.mixin.CustomDisplay(obj);

        [StrongStartTag,StrongEndTag]=optim.internal.problemdef.createStrongTags;


        if obj.IsSubsref
            arrayWideMsgId='shared_adlib:OptimizationVariable:ReadOnlyArrayWideHeader';
        else
            arrayWideMsgId='shared_adlib:OptimizationVariable:ArrayWideHeader';
        end
        groups.Title=getString(message(arrayWideMsgId,StrongStartTag,StrongEndTag));



        namesToRemove={'LowerBound','UpperBound','Variables'};
        idxBounds=ismember(groups.PropertyList,namesToRemove);
        groups.PropertyList(idxBounds)=[];


        boundsGroup=matlab.mixin.util.PropertyGroup({'LowerBound','UpperBound'},...
        getString(message('shared_adlib:OptimizationVariable:ElementwiseHeader',...
        StrongStartTag,StrongEndTag)));


        groups=[groups,boundsGroup];

    end


