function out=getConfigSet(modelName,varargin)




    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;


    narginchk(1,2);
    modelName=getCharArray(modelName);
    out=[];
    if nargin==2
        tmpTgt=getCharArray(varargin{1});
        if~ischar(tmpTgt)||(~isempty(varargin{1})&&isempty(tmpTgt))
            DAStudio.error('Simulink:protectedModel:InvalidTargetName');
        elseif~locHasTarget(modelName,tmpTgt)

            DAStudio.error('Simulink:protectedModel:TargetNotFoundInPackage',tmpTgt,modelName);
        elseif locIsViewOnly(modelName)
            DAStudio.error('Simulink:protectedModel:InvalidModeForConfigSet',modelName);
        end
        target=tmpTgt;
    else
        target=getCurrentTarget(modelName);
        if~locHasTarget(modelName,target)

            DAStudio.error('Simulink:protectedModel:TargetNotFoundInPackage',target,modelName);
        elseif locIsViewOnly(modelName)
            DAStudio.error('Simulink:protectedModel:InvalidModeForConfigSet',modelName);
        end
    end
    [opts,fullName]=getOptions(modelName);

    if strcmp(target,'sim')


        if~slInternal('isProtectedModelFromThisSimulinkVersion',fullName)&&...
            ~opts.report&&strcmp(opts.modes,'Normal')
            versionStr=slInternal('getProtectedModelVersion',fullName);
            protectedModelVersion=simulink_version(versionStr);
            if(protectedModelVersion<simulink_version('R2020a'))
                DAStudio.error('Simulink:protectedModel:InvalidModeForConfigSetForModelsBefore20a',modelName);
            end
        end
        relName='configset';
        year=RelationshipConfigSet.getRelationshipYear();
    elseif strcmp(target,'viewonly')
        DAStudio.error('Simulink:protectedModel:InvalidModeForConfigSet',modelName);

    else


        relName=constructTargetRelationshipName('configset',target);

        if~opts.hasCSupport&&opts.hasHDLSupport
            relName='configset';
        end
        year=RelationshipConfigSetCodegen.getRelationshipYear();
    end

    rootSimDir=tempname;

    try

        writeRelationship(fullName,rootSimDir,relName,year);
        cleanup=onCleanup(@()slprivate('removeDir',rootSimDir));
        cs=load(fullfile(rootSimDir,'cs.mat'));
        out=cs.protectedModelConfigSet;
        out.lock;
    catch me
        if strcmp(me.identifier,'Simulink:protectedModel:ProtectedModelWrongPassword')

            if strcmp(target,'sim')
                myException=getWrongPasswordDetailedException(opts.modelName,'SIM');
            else
                myException=getWrongPasswordDetailedException(opts.modelName,'RTW');
            end
            myException.throw;
        else
            rethrow(me);
        end
    end

end

function out=locHasTarget(modelName,target)

    import Simulink.ModelReference.ProtectedModel.*;
    supportedTargets=getSupportedTargets(modelName);
    out=~isempty(intersect(supportedTargets,target));
end

function out=locIsViewOnly(modelName)

    import Simulink.ModelReference.ProtectedModel.*;
    supportedTargets=getSupportedTargets(modelName);


    out=(length(supportedTargets)==1&&strcmp(supportedTargets{1},'viewonly'));
end


