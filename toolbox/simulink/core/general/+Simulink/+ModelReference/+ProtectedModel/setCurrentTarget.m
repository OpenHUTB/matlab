function setCurrentTarget(modelName,target,varargin)









    import Simulink.ModelReference.ProtectedModel.*;
    narginchk(2,3);
    skipModifiableCheck=false;
    modelName=getCharArray(modelName);
    target=getCharArray(target);
    if nargin==3
        skipModifiableCheck=strcmpi(getCharArray(varargin{1}),'skipModifiableCheck');
    end

    [isProtected,fullName]=slInternal('getReferencedModelFileInformation',modelName);
    if isProtected&&~isempty(fullName)

        if~isempty(varargin)
            if strcmp(varargin{1},'runConsistencyChecksNoPlatform')
                [gi,fullName]=getOptions(modelName,'runConsistencyChecksNoPlatform');
            else
                [gi,fullName]=getOptions(modelName);
            end
        else
            [gi,fullName]=getOptions(modelName);
        end

        if strcmp(target,'sim')||strcmp(target,'viewonly')
            CurrentTarget.set(gi.modelName,target);
        elseif isempty(intersect({target},getSupportedTargets(fullName)))

            DAStudio.error('Simulink:protectedModel:TargetNotFoundInPackage',target,fullName);
        elseif strcmp(CurrentTarget.get(gi.modelName),target)


            return;
        elseif~skipModifiableCheck&&~isModifiable(gi)&&~strcmp(CurrentTarget.get(gi.modelName),'sim')



            DAStudio.error('Simulink:protectedModel:NotModfiableCannotSwitch',fullName,target);
        else

            CurrentTarget.set(gi.modelName,target);
        end
    else
        CurrentTarget.set(modelName,target);
    end
end

