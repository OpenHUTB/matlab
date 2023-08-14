classdef FunctionInfoTab<swarch.internal.spreadsheet.AbstractSoftwareModelingTab





    properties(Constant,Abstract,Access=protected)
FunctionType
DefaultName
    end

    methods(Abstract,Access=protected)
        createFunctionDataSource(this,functionObj,swComp);
    end

    methods
        function requiresUpdate=processChangeReport(this,changeReport)
            if this.hasDestroyedChildren(changeReport)||...
                this.hasCreatedChildren(changeReport)
                requiresUpdate=true;
                this.refreshChildren();
            else
                requiresUpdate=this.hasModifiedChildren(changeReport);
            end
        end

        function refreshChildren(this)

            swTrait=...
            this.getRootArchitecture().getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
            this.pChildren=arrayfun(@(f)this.createFunctionDataSource(f),...
            swTrait.getFunctionsOfType(this.FunctionType));
        end

        function addChildToArchitecture(this)
            selectedComps=getSelectedInlineComponents(this.getSpreadsheet().getStudio().App.getActiveEditor());

            if~isempty(selectedComps)
                parentComp=selectedComps(1);
            else
                comps=swarch.utils.getAllSoftwareComponents(this.getRootArchitecture());
                comps=comps(arrayfun(@(c)swarch.utils.isInlineSoftwareComponent(c),comps));
                if~isempty(comps)
                    parentComp=comps(1);
                else
                    error(message('SoftwareArchitecture:ArchEditor:NoSoftwareComponents'));
                end
            end

            swTrait=this.getRootArchitecture().getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);

            set_param(this.getRootArchitecture().getName(),'SuspendBlockValidation','on');
            cleanupBlockValidation=onCleanup(@()set_param(this.getRootArchitecture().getName(),'SuspendBlockValidation','off'));


            functionName=[parentComp.getName(),'_',this.DefaultName];
            if~strcmpi(get_param(this.getBdHandle(),'SimulinkSubDomain'),'AUTOSARArchitecture')||...
                isequal(slfeature('FunctionsModelingAutosar'),0)
                inportName=[this.getRootArchitecture().getName(),'/',functionName];
                inpBlock=add_block('built-in/Inport',inportName,...
                'MakeNameUnique','on',...
                'OutputFunctionCall','on');


                functionName=get_param(inpBlock,'Name');
            end


            txn=mf.zero.getModel(swTrait).beginTransaction();
            calledFunc=parentComp.getArchitecture().getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).createFunction(...
            functionName,this.FunctionType(1));

            rootFunc=swTrait.createFunction(functionName,this.FunctionType(1));
            rootFunc.setCalledFunctionInfo(parentComp,calledFunc);


            swarch.utils.applyDefaultStereotypesToFunction(calledFunc);
            txn.commit();
        end

        function removeChildFromArchitecture(this,~)
            selectedFunc=this.getCurrentSelection();
            if isempty(selectedFunc)
                return;
            end
            func=selectedFunc{1}.get();


            swarch.internal.spreadsheet.FunctionSelectedStyler.removeStyle(...
            systemcomposer.utils.getSimulinkPeer(func.calledFunctionParent));

            swarch.utils.destroyFunctionAndRootInportBlock(func);
        end

        function created=hasCreatedChildren(~,changeReport)


            allCreatedElems=changeReport.Created;
            isChild=@(el)isa(el,'systemcomposer.architecture.model.swarch.Function');
            created=any(arrayfun(isChild,allCreatedElems));
        end

        function modified=hasModifiedChildren(this,changeReport)


            if isempty(changeReport.Modified)
                modified=false;
                return;
            end

            allModifiedElems=[changeReport.Modified.Element];
            allModifiedUUIDs={allModifiedElems.UUID};
            isModified=@(child)containsModifiedChild(child.get(),allModifiedUUIDs);
            modified=any(arrayfun(isModified,this.pChildren));
        end

        function destroyed=hasDestroyedChildren(this,~)

            isDestroyed=@(child)~isvalid(child.get());
            destroyed=any(arrayfun(isDestroyed,this.pChildren));
        end
    end
end

function modified=containsModifiedChild(mfFunction,allModifiedUUIDs)

    modified=false;
    for idx=1:numel(allModifiedUUIDs)
        curUUID=allModifiedUUIDs{idx};
        if strcmpi(mfFunction.UUID,curUUID)||...
            (~isempty(mfFunction.calledFunctionParent)&&...
            strcmpi(mfFunction.calledFunctionParent.UUID,curUUID)||...
            (~isempty(mfFunction.task)&&...
            strcmpi(mfFunction.task.UUID,curUUID)))
            modified=true;
            break;
        end
    end
end

function comps=getSelectedInlineComponents(editor)

    comps=[];

    for idx=1:editor.getSelection.size
        blockHandle=editor.getSelection.at(idx).handle;
        if~swarch.utils.isInlineSoftwareComponentBlock(blockHandle)
            continue;
        end

        comp=systemcomposer.utils.getArchitecturePeer(blockHandle);
        if comp.isServiceComponent()
            continue;
        end

        comps=[comps,comp];%#ok<AGROW>
    end
end


