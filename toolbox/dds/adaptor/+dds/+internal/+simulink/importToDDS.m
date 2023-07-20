function success=importToDDS(ddConn,ddEntryOrID)



    success=false;


    if~isa(ddConn,'Simulink.dd.Connection')||...
        ~(isa(ddEntryOrID,'Simulink.data.dictionary.Entry')||isnumeric(ddEntryOrID))
        return
    end
    if isnumeric(ddEntryOrID)
        ddEntry=ddConn.getEntryInfo(ddEntryOrID);
        ddEntryID=ddEntryOrID;
        ddEntryValue=ddEntry.Value;
        ddEntryUUID=ddEntry.UUID.char;
    else
        ddEntry=ddEntryOrID;
        ddEntryID=ddEntry.ID;
        ddEntryValue=ddEntry.getValue;
        ddEntryUUID=ddEntry.UUID;
    end


    if ddConn.getIsEntryDerived(ddEntryID)


        return
    end


    source=ddConn.filespec;
    if Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filespec)
        ddsModel=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(source);
    else
        ddsModel=mf.zero.Model;
        Simulink.DDSDictionary.ModelRegistry.registerWithDD(ddsModel,ddConn.filespec);
        ddConn.saveChanges;
    end
    txn=ddsModel.beginTransaction;
    sys=dds.internal.getSystemInModel(ddsModel);
    if isempty(sys)

        sys=dds.datamodel.system.System(ddsModel);
    end
    if sys(1).TypeLibraries.Size==0


        typeLibNode=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsModel,[],'dds.datamodel.types.TypeLibrary','');
        sys(1).TypeLibraries.add(typeLibNode);
        dds.internal.simulink.DDSModelToSimulinkListener(ddsModel,ddConn.filespec);
    else
        typeLibNode=sys(1).TypeLibraries(1);
    end


    if~isempty(sys(1).Listener)

        pauseObj=sys(1).Listener.PauseListener();%#ok<NASGU>
    end

    ddsName=ddEntry.Name;
    ddsNode=sys(1);


    if slfeature('DDSImportCreateModules')>0
        while contains(ddsName,'_')
            moduleName=extractBefore(ddsName,'_');
            new_ddsNode=dds.internal.simulink.Util.findType(ddsNode,moduleName);
            if~isa(new_ddsNode,'dds.datamodel.types.Module')
                if ddsNode==sys(1)
                    ddsNode=typeLibNode;
                end
                new_ddsNode=dds.internal.simulink.ui.internal.dds.datamodel.types.Module.create(ddsModel,[],ddsNode,moduleName);
                ddsNode.Elements.add(new_ddsNode);
            end
            ddsNode=new_ddsNode;
            ddsName=extractAfter(ddsName,'_');
        end
    end

    if ddsNode==sys(1)
        ddsNode=typeLibNode;
    end


    types=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList(ddsNode);
    if isa(ddEntryValue,'Simulink.Bus')
        ddsObject=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsModel,types,'dds.datamodel.types.Struct',ddsName);


        element=dds.datamodel.types.StructMember(ddsModel);
        element.Name='Element1';
        element.Id=0;
        element.Index=1;
        element.Key=1;
        element.Type=dds.datamodel.types.Integer(ddsModel);
        ddsObject.Members.add(element);

    elseif isa(ddEntryValue,'Simulink.data.dictionary.EnumTypeDefinition')
        ddsObject=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsModel,types,'dds.datamodel.types.Enum',ddsName);
        ddsObject.Base=dds.datamodel.types.Integer(ddsModel);

        element=dds.datamodel.types.EnumMember(ddsModel);
        element.Name='Element1';
        element.Index=1;
        element.ValueStr='0';
        ddsObject.Members.add(element);

    else
        ddsObject=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsModel,types,'dds.datamodel.types.Const',ddsName);
        ddsObject.Type=dds.datamodel.types.Integer(ddsModel);
        ddsObject.ValueStr='0';
    end


    ddsNode.Elements.add(ddsObject);

    updateVisitor=dds.internal.simulink.UpdateSimObjectsVisitor();
    updateVisitor.addSimObject(ddsObject,ddEntryValue,true);
    updateVisitor.visitModel(ddsModel);
    txn.commit;
    success=true;


    ddConn.setIsEntryDerived(ddEntryID,true);


    catalogContainer=sldd.mapping.CatalogContainer.getCatalogContainer(source);
    ddsMap=catalogContainer.catalog;
    tmpMdl=mf.zero.Model.createTransientModel;
    ddsVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,ddsObject.UUID,'','DDS');
    entryVarId=sl.data.mapping.VariableIdentifier.createVariableIdentifier(tmpMdl,ddEntryUUID,'','SLDD');
    ddsMap.addAssociation(ddsVarId,entryVarId);
end