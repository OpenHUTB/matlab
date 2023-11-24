function batchApplyStereotype(this,varargin)

    narginchk(3,8);
    inputAsStr=string(varargin);

    keys=inputAsStr(1:2:end);

    isRecurse=false;
    foundMatch=arrayfun(@(x)strcmpi(x,'Recurse'),keys,'UniformOutput',false);
    foundMatch=[foundMatch{:}];
    if any(foundMatch)
        idx=find(foundMatch==1);
        isRecurse=inputAsStr(idx*2)=="true";

    end
    for i=1:numel(keys)
        prop=keys(i);
        stereotypeFQN=inputAsStr(i*2);
        switch lower(prop)
        case 'component'
            childComps=[];
            isVariant=this.getImpl.isVariantArchitecture;
            isReference=false;
            if~isempty(this.Parent)
                isReference=this.Parent.getImpl.isReferenceComponent;
            end
            if~isVariant&&~isReference
                childComps=this.Components;
            end
            for m=1:numel(childComps)
                childComp=childComps(m);

                if~childComp.getImpl.isReferenceComponent&&...
                    ~childComp.getImpl.isAdapterComponent&&...
                    ~isVariantComponent(childComp.getImpl)
                    if childComp.getImpl.isImplComponent
                        thatZCModel=childComp.Architecture.Model;
                        profInfo=strsplit(stereotypeFQN,'.');
                        thatZCModel.applyProfile(profInfo(1));
                    end
                    childComp.applyStereotype(stereotypeFQN);
                    if isRecurse
                        batchApplyStereotype(childComp.Architecture,'Component',stereotypeFQN,'Recurse',isRecurse)
                    end
                end
            end
        case 'port'
            isVariant=this.getImpl.isVariantArchitecture;
            isReference=false;
            if~isempty(this.Parent)
                isReference=this.Parent.getImpl.isReferenceComponent;
            end
            if~isVariant&&~isReference
                childComps=this.Components;
                childPorts=this.Ports;
                for n=1:numel(childComps)
                    childComp=childComps(n);

                    if~childComp.getImpl.isReferenceComponent&&...
                        ~childComp.getImpl.isAdapterComponent&&...
                        ~isVariantComponent(childComp.getImpl)
                        if childComp.getImpl.isImplComponent
                            thatZCModel=childComp.Architecture.Model;
                            profInfo=strsplit(stereotypeFQN,'.');
                            thatZCModel.applyProfile(profInfo(1));
                        end
                        compPorts=childComp.Ports;
                        for m=1:numel(compPorts)
                            compPorts(m).ArchitecturePort.applyStereotype(stereotypeFQN);
                        end
                        if isRecurse
                            batchApplyStereotype(childComp.Architecture,'Port',stereotypeFQN,'Recurse',isRecurse);
                        end
                    end
                end
                for k=1:numel(childPorts)
                    childPorts(k).applyStereotype(stereotypeFQN);
                end
            end
        case 'connector'
            isVariant=this.getImpl.isVariantArchitecture;
            isReference=false;
            if~isempty(this.Parent)
                isReference=this.Parent.getImpl.isReferenceComponent;
            end
            if~isVariant&&~isReference
                childConn=this.Connectors;
                for m=1:numel(childConn)
                    childConn(m).applyStereotype(stereotypeFQN);
                end
                if isRecurse
                    childComps=this.Components;
                    for n=1:numel(childComps)
                        childComp=childComps(n);
                        if~childComp.getImpl.isReferenceComponent&&~isVariantComponent(childComp.getImpl)...
                            &&~childComp.getImpl.isImplComponent
                            batchApplyStereotype(childComp.Architecture,'Connector',stereotypeFQN,'Recurse',isRecurse);
                        end
                    end
                end
            end
        case 'function'
            batchApplyFunctionStereotype(this,stereotypeFQN);
        otherwise
        end

    end
end

function isVar=isVariantComponent(comp)
    isVar=isa(comp,'systemcomposer.architecture.model.design.VariantComponent');
end

function batchApplyFunctionStereotype(rootArch,stereotypeFQN)
    allFunctions=rootArch.Functions;

    [~,uniqueIdxs]=unique([arrayfun(@(f)f.getPrototypable(),allFunctions)]);
    for i=1:numel(uniqueIdxs)
        allFunctions(uniqueIdxs(i)).applyStereotype(stereotypeFQN);
    end
end


