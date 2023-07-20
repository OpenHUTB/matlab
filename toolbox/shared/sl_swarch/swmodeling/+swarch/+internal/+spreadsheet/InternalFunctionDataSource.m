classdef InternalFunctionDataSource<swarch.internal.spreadsheet.FunctionInfoDataSource




    properties(Constant)
        PeriodCol=getString(message('SoftwareArchitecture:ArchEditor:PeriodColumn'));
        MappedToCol=getString(message('SoftwareArchitecture:ArchEditor:MappedToColumn'));
    end

    properties(Access=private)
        pMimeData;
    end

    methods(Access=protected)
        function propVal=getSubclassPropAllowedValues(this,propName)
            switch propName
            case this.MappedToCol
                rootArch=this.pParent.getRootArchitecture();
                tasks=rootArch.getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).p_Tasks.toArray;
                propVal=arrayfun(@(t)t.taskName,tasks,'UniformOutput',false);
            otherwise
                propVal={};
            end
        end

        function propValue=getSubclassPropValue(this,propName)
            switch propName
            case this.ExecutionOrderCol
                propValue=num2str(this.pFunction.executionOrder);
            case this.PeriodCol
                propValue=this.pFunction.period;
            case this.MappedToCol
                if isempty(this.pFunction.task)
                    propValue=getString(...
                    message('SoftwareArchitecture:ArchEditor:MappedToNothing'));
                else
                    propValue=this.pFunction.task.taskName;
                end
            otherwise
                propValue={};
            end
        end

        function setSubclassPropValue(this,propName,propValue)
            switch propName
            case this.MappedToCol
                newTask=this.pParent.getRootArchitecture().getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).p_Tasks.getByKey(propValue);
                if~isempty(newTask)
                    this.pFunction.task=newTask;
                end
            case this.ExecutionOrderCol
                this.pFunction.setOrder(uint64(str2double(propValue)));
                this.syncBlockPriorities();
            case this.PeriodCol
                try
                    swarch.utils.setFunctionAndRootInportBlockPeriod(this.pFunction,propValue);
                catch me


                    Simulink.output.error(me);
                end
            end
        end
    end

    methods
        function this=InternalFunctionDataSource(parentTab,functionObj)
            this=this@swarch.internal.spreadsheet.FunctionInfoDataSource(parentTab,functionObj);


            if slfeature('SoftwareModeling')>0
                columns=[...
                this.ExecutionOrderCol,'<*>'...
                ,this.FunctionNameCol,'<*>'...
                ,this.SoftwareComponentCol,'<*>'...
                ,this.PeriodCol,'<*>'...
                ,this.MappedToCol...
                ];
            else
                columns=[...
                this.ExecutionOrderCol,'<*>'...
                ,this.FunctionNameCol,'<*>'...
                ,this.SoftwareComponentCol,'<*>'...
                ,this.PeriodCol...
                ];
            end

            kvPairsList=GLEE.ByteArrayList;
            pair1=GLEE.ByteArrayPair(...
            GLEE.ByteArray(columns),...
            GLEE.ByteArray('internal.swarch.FunctionInfoDataSource'));
            kvPairsList.add(pair1);
            this.pMimeData=kvPairsList;
        end

        function isEditable=isEditableProperty(this,propName)
            isEditable=isEditableProperty@swarch.internal.spreadsheet.FunctionInfoDataSource(this,propName);

            if strcmpi(propName,this.PeriodCol)
                if this.pFunction.type==systemcomposer.architecture.model.swarch.FunctionType.Server||...
                    this.pFunction.type==systemcomposer.architecture.model.swarch.FunctionType.Message

                    isEditable=false;
                else

                    rootArch=this.pParent.getRootArchitecture();
                    if(slfeature('FunctionsModelingAutosar')>0)&&...
                        strcmpi(get_param(rootArch.getName(),'SimulinkSubDomain'),...
                        'AUTOSARArchitecture')
                        isEditable=false;
                    else
                        inpBlock=swarch.utils.getFcnCallInport(this.pFunction);

                        isEditable=isempty(inpBlock)||...
                        strcmpi(this.pFunction.period,get_param(inpBlock,'SampleTime'));
                    end
                end
            end
        end

        function isAllowed=isDragAllowed(this)
            isAllowed=strcmp(get_param(this.pParent.getBdHandle(),'OrderFunctionsByDependency'),'off');
        end

        function isAllowed=isDropAllowed(this)
            isAllowed=strcmp(get_param(this.pParent.getBdHandle(),'OrderFunctionsByDependency'),'off');
        end

        function allowed=performDrag(this,source)
            allowed=all(cellfun(@(from)isa(from,class(this)),source));
        end

        function allowed=performDrop(this,source)
            desiredOrder=this.pFunction.executionOrder;
            [~,sorted]=sort(cellfun(@(x)x.pFunction.executionOrder,source));
            source=source(sorted);
            txn=mf.zero.getModel(source{1}.pFunction).beginTransaction();
            for idx=1:numel(source)
                source{idx}.pFunction.setOrder(desiredOrder);
                desiredOrder=desiredOrder+1;
            end
            txn.commit();
            this.pParent.getSpreadsheet().getComponent().imSpreadSheetComponent.select(source);


            this.syncBlockPriorities();

            allowed=true;
        end


        function data=getMimeData(this)
            data=this.pMimeData;
        end


        function mimeType=getMimeType(~)
            mimeType='application/swarch-mimetype';
        end

        function syncBlockPriorities(this)
            rootArch=this.pParent.getRootArchitecture();

            if(slfeature('CompositeFunctionElements')&&slfeature('AsyncClientServer'))||...
                (strcmpi(get_param(rootArch.getName(),'SimulinkSubDomain'),'AUTOSARArchitecture')&&...
                (slfeature('FunctionsModelingAutosar')>0))



                fcns=rootArch.getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).getSchedulableFunctions();
                schedule=get_param(rootArch.getName(),'Schedule');
                order=schedule.Order;
                for fcn=fcns
                    idx=strcmp(order.Partition,fcn.getName());
                    order.Index(idx)=fcn.executionOrder;
                end
                schedule.Order=order;
                set_param(rootArch.getName(),'Schedule',schedule);
            else
                osFuncs=rootArch.getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).getFunctionsOfType(...
                systemcomposer.architecture.model.swarch.FunctionType.OSFunction...
                );
                for os=osFuncs
                    set_param(swarch.utils.getFcnCallInport(os),'Priority',num2str(os.executionOrder));
                end
            end
        end
    end
end


