classdef DDSModelToSimulinkListener<handle




    properties(Access=private)
        MF0Model;
        ddfilepath;
        ListenerFunction;
    end

    properties(Hidden)
        Debug;
        InSync=false;
    end

    methods
        function this=DDSModelToSimulinkListener(model,filepath)
            sys=dds.internal.getSystemInModel(model);
            if~isempty(sys)
                this.MF0Model=model;
                sys(1).Listener=this;

                this.ddfilepath=filepath;
                this.GetDDSMap;
                this.StartListener;
            end
            this.Debug=false;
        end

        function StartListener(this)
            this.ListenerFunction=@(changeReport)this.syncDataDictionary(changeReport);
            this.MF0Model.addObservingListener(this.ListenerFunction);
        end

        function clnup=PauseListener(this)
            clnup=onCleanup(@()this.StartListener);
            this.MF0Model.removeListener(this.ListenerFunction);
        end

        function map=GetDDSMap(this)
            catalogContainer=sldd.mapping.CatalogContainer.getCatalogContainer(this.ddfilepath);
            map=catalogContainer.catalog;
        end

        function setInSync(this)
            assert(~this.InSync);
            this.InSync=true;
        end

        function clearInSync(this)
            assert(this.InSync);
            this.InSync=false;
        end
    end

    methods(Access='private')
        function getSimObjectFrom=getTheSimObject(~,element)
            getSimObjectFrom=[];
            switch(class(element))
            case 'dds.datamodel.types.EnumMember'
                if~isempty(element.Parent)
                    getSimObjectFrom=element.Parent;
                end
            case 'dds.datamodel.types.StructMember'
                if~isempty(element.ParentStruct)
                    getSimObjectFrom=element.ParentStruct;
                end
            case 'dds.datamodel.types.UnionMember'
                if~isempty(element.ParentUnion)
                    getSimObjectFrom=element.ParentUnion;
                end
            otherwise
                getSimObjectFrom=element;
            end
        end

        function SLDD_UUID=getSlddUuidFromMap(~,ddsMap,dd_uuid)
            tmpMdl=mf.zero.Model.createTransientModel;
            SLDD_UUID=[];
            ddsVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,dd_uuid,'','DDS');
            associations=ddsMap.getAssociations(ddsVarId);
            if isempty(associations)
                return
            end
            SLDD_UUID=associations.id;
        end

        function updateSimObject(this,ds,getSimObjectFrom,ddConn,DDSMap)
            entryUUID=this.getSlddUuidFromMap(DDSMap,getSimObjectFrom.UUID);
            if this.Debug
                fprintf('Modifying: Entry(%s)->(%s)(%s)(%s)\n',entryUUID,getSimObjectFrom.UUID,class(getSimObjectFrom),getSimObjectFrom.Name);
            end
            theMdl=mf.zero.getModel(getSimObjectFrom);
            if~isempty(entryUUID)
                entryName=ddConn.getEntryNameByUUID(entryUUID);
                entry=ds.getEntry(entryName);
                ddConn.setIsEntryDerived(entry.ID,false);
                simObjName=dds.internal.getFullNameForType(getSimObjectFrom);
                if~strcmp(entry.Name,simObjName)
                    entry.Name=simObjName;
                end
                entry.setValue(dds.internal.simulink.getSimObjectFor(theMdl,getSimObjectFrom));
                ddConn.setIsEntryDerived(entry.ID,true);
            else

                if ismethod(getSimObjectFrom,'acceptVisitor')&&...
                    ~isempty(getSimObjectFrom.Name)&&...
                    ~isa(getSimObjectFrom,'dds.datamodel.types.Alias')&&...
                    ~isa(getSimObjectFrom,'dds.datamodel.types.TypeMap')

                    element=dds.internal.simulink.getSimObjectFor(theMdl,getSimObjectFrom);
                    if isempty(element)
                        if isprop(getSimObjectFrom,'Elements')
                            keys=getSimObjectFrom.Elements.keys;
                            for i=1:getSimObjectFrom.Elements.Size
                                elem=getSimObjectFrom.Elements{keys{i}};
                                this.updateSimObject(ds,elem,ddConn,DDSMap);
                            end
                        end
                        return;
                    end
                    simObjName=dds.internal.getFullNameForType(getSimObjectFrom);
                    entry=ds.addEntry(simObjName,element);
                    ddConn.setIsEntryDerived(entry.ID,true);


                    tmpMdl=mf.zero.Model.createTransientModel;
                    entryVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,entry.UUID,'','SLDD');
                    ddsVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,getSimObjectFrom.UUID,'','DDS');
                    DDSMap.addAssociation(ddsVarId,entryVarId);
                end
            end
        end

        function printTransaction(this,transaction)
            if~this.Debug
                return;
            end
            i=0;
            function name=getName(el)
                if any(contains(properties(el),'Name'))
                    name=el.Name;
                else
                    name='';
                end
            end
            fprintf('Created: %d, Destroyed: %d, Modified: %d\n',...
            numel(transaction.Created),numel(transaction.Destroyed),...
            numel(transaction.Modified));
            for obj=transaction.Created
                i=i+1;
                if startsWith(class(obj),'dds.datamodel.types')&&~startsWith(class(obj),'dds.datamodel.types.TypeMap')
                    fprintf('(%d)Created:   %s->%s (%s)\n',i,getName(obj),obj.UUID,class(obj));
                else
                    fprintf('(%d)>>Created: %s\n',i,class(obj));
                end
            end
            for obj=transaction.Destroyed
                i=i+1;
                if startsWith(obj.MetaClass.mcosName,'dds.datamodel.types')&&~startsWith(obj.MetaClass.mcosName,'dds.datamodel.types.TypeMap')
                    fprintf('(%d)Destroyed: %s->%s (%s)\n',i,'',obj.UUID,obj.MetaClass.mcosName);
                else
                    fprintf('(%d)>>Destroyed: %s\n',i,obj.MetaClass.mcosName);
                end
            end
            for obj=transaction.Modified
                i=i+1;
                if startsWith(class(obj.Element),'dds.datamodel.types')&&~startsWith(class(obj.Element),'dds.datamodel.types.TypeMap')
                    fprintf('(%d)Modified:  %s->%s (%s)\n',i,getName(obj.Element),obj.Element.UUID,class(obj.Element));
                else
                    fprintf('(%d)>>Modified: %s\n',i,class(obj.Element));
                end
            end
        end

        function syncDataDictionary(this,transaction)


            ddDict=[];
            ddConn=[];
            ds=[];
            DDSMap=[];

            if this.InSync
                return;
            end
            this.setInSync();
            clnUp=onCleanup(@()this.clearInSync());

            function openDictionary


                if isempty(ddConn)
                    [ddpath,~,~]=fileparts(this.ddfilepath);
                    origPath=addpath(ddpath);
                    ddDict=Simulink.data.dictionary.open(this.ddfilepath);
                    ddConn=Simulink.dd.open(this.ddfilepath);
                    path(origPath);
                    ds=ddDict.getSection('Design Data');
                    DDSMap=this.GetDDSMap;
                end
            end

            function doDestroyTransactions(theList)
                for objD=theList
                    try
                        openDictionary();
                        entryUUID=this.getSlddUuidFromMap(DDSMap,objD.UUID);
                        if~isempty(entryUUID)
                            if this.Debug
                                fprintf('Destroying: Entry(%s)->(%s)\n',entryUUID,objD.UUID);
                            end
                            entryName=ddConn.getEntryNameByUUID(entryUUID);
                            entry=ds.getEntry(entryName);
                            ddConn.setIsEntryDerived(entry.ID,false);
                            if~isempty(entry)
                                entry.deleteEntry();
                            end

                            tmpMdl=mf.zero.Model.createTransientModel;
                            varId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,objD.UUID,'','DDS');
                            DDSMap.removeAssociations(varId);
                        end
                    catch MED %#ok<NASGU> Need for debugging

                    end
                end
            end

            this.printTransaction(transaction);

            doDestroyTransactions(transaction.Destroyed);
            doDestroyTransactions(transaction.Created);

            for obj=transaction.Created
                try
                    clz=class(obj);
                    if~startsWith(clz,'dds.datamodel.types')||...
                        isequal(clz,'dds.datamodel.types.Alias')||...
                        startsWith(clz,'dds.datamodel.types.TypeMap')
                        continue;
                    end
                    getSimObjectFrom=this.getTheSimObject(obj);
                    if ismethod(getSimObjectFrom,'acceptVisitor')&&...
                        ~isempty(getSimObjectFrom.Name)

                        openDictionary();
                        theMdl=mf.zero.getModel(getSimObjectFrom);
                        element=dds.internal.simulink.getSimObjectFor(theMdl,getSimObjectFrom);
                        if isempty(element)
                            continue;
                        end
                        simObjName=dds.internal.getFullNameForType(getSimObjectFrom);
                        entry=ds.addEntry(simObjName,element);
                        ddConn.setIsEntryDerived(entry.ID,true);


                        tmpMdl=mf.zero.Model.createTransientModel;
                        entryVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,entry.UUID,'','SLDD');
                        ddsVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,getSimObjectFrom.UUID,'','DDS');
                        DDSMap.addAssociation(ddsVarId,entryVarId);
                        if this.Debug
                            fprintf('Adding: Entry(%s)->(%s)\n',entry.UUID,obj.UUID);
                        end
                    end
                catch ME %#ok<NASGU> Need for debugging

                end
            end

            modList={};
            for obj=transaction.Modified
                try
                    if~startsWith(class(obj.Element),'dds.datamodel.types')||...
                        startsWith(class(obj.Element),'dds.datamodel.types.TypeMap')
                        continue;
                    end
                    getSimObjectFrom=this.getTheSimObject(obj.Element);
                    UUID=getSimObjectFrom.UUID;
                    if any(contains(modList,UUID))


                        continue;
                    end
                    if ismethod(getSimObjectFrom,'acceptVisitor')&&...
                        ~isempty(getSimObjectFrom.Name)
                        modList=[modList,UUID];%#ok<AGROW>
                        if~isempty(getSimObjectFrom)
                            openDictionary();
                            this.updateSimObject(ds,getSimObjectFrom,ddConn,DDSMap);
                        end
                    end
                catch ME %#ok<NASGU> Need for debugging

                end
            end

            doDestroyTransactions(transaction.Destroyed);

            ddConn=[];
            ddDict=[];
        end
    end
end

