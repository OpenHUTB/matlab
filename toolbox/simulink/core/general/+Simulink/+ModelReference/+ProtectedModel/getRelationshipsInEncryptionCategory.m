function out=getRelationshipsInEncryptionCategory(fullName,category,varargin)




    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;





    if~isempty(varargin)
        opts=varargin{1};
    else
        [opts,~]=getOptions(fullName);
    end
    tgtRelName=getCurrentTarget(opts.modelName);
    if strcmp(category,'RTW')&&strcmpi(tgtRelName,'sim')
        supportedTgts=getSupportedTargets(fullName);


        if length(supportedTgts)<=1
            out={};
            return;
        end


        for i=1:length(supportedTgts)
            if~strcmpi(supportedTgts{i},'sim')
                tgtRelName=supportedTgts{i};
                Simulink.ModelReference.ProtectedModel.CurrentTarget.set(opts.modelName,tgtRelName);
                break;
            end
        end
    end



    out={};
    if strcmp(category,'SIM')
        if supportsAccel(opts)
            out{end+1}='sim';
            out{end+1}='simsharedutils';
        end
        out{end+1}='modelReferenceSimTarget';
        out{end+1}='configset';
        if opts.report
            out{end+1}='html';
        end
    elseif strcmp(category,'RTW')
        out{end+1}=constructTargetRelationshipName('rtwsharedutils',tgtRelName);
        if opts.hasCustomRTWFiles()
            out{end+1}=constructTargetRelationshipName('custom',tgtRelName);
        end
        out{end+1}=tgtRelName;
        out{end+1}=constructTargetRelationshipName('simCG',tgtRelName);
        out{end+1}=constructTargetRelationshipName('simsharedutilsCG',tgtRelName);
        out{end+1}=constructTargetRelationshipName('modelReferenceSimTargetCG',tgtRelName);
        out{end+1}=constructTargetRelationshipName('configset',tgtRelName);

        if opts.report
            out{end+1}=constructTargetRelationshipName('htmlcodegen',tgtRelName);
            out{end+1}=constructTargetRelationshipName('rtwsharedutilshtml',tgtRelName);
        end
    elseif strcmp(category,'VIEW')
        out{end+1}='webview';
    elseif strcmp(category,'NONE')
        out{end+1}='extraInformation';
    elseif strcmp(category,'MODIFY')
        out{end+1}='modifyPermission';
    elseif strcmp(category,'HDL')
        out{end+1}='hdl';
    else
        DAStudio.error('Simulink:protectedModel:ProtectedModelInvalidEncryptionCategory',category);
    end
end


