classdef writeDataInterfacesToCodeDescriptor<handle








    properties
fSLModel
fPath
fInternalDataMap
fMF0Model
fTxn
fFullModel
fInportArgs
fInportIndices
fOutportArgs
fOutportIndices
fInternalData
fCPPModelObject
fFPCInportIdxToOutportIdxMap
fProcessedCanonicalParameters
fOptimizedDWorkIndicies
fUnusedSubsystemArgumentMap
fModelRefDWorkVar
fModelRefDWorkMembers
fIsAutosar
fIsModelRefSimTarget
fIsMultiInstanceModelRef
fFunctionInterfacesToDestroy
fDataInterfacesToDestroy
        fRTMForSubsystemInterface;
        fRTMAddedMap;
        fIsLibraryCodegen;
    end
    methods
        function ret=findLUTOrBPInterface(obj,grName)
            lutI=coder.descriptor.LookupTableDataInterface.findByGraphicalName(obj.fMF0Model,grName);
            bpI=coder.descriptor.BreakpointDataInterface.findByGraphicalName(obj.fMF0Model,grName);
            assert(isempty(lutI)||isempty(bpI)||lutI.Implementation==bpI.Implementation);
            if~isempty(lutI)
                ret=lutI;
            else
                ret=bpI;
            end
        end
        function isOkayToUpdateImpls=shouldUpdateImplementationReferences(~,originalImpl,fixedImplRef)
            isOkayToUpdateImpls=~isempty(fixedImplRef)&&originalImpl~=fixedImplRef;
        end
        function isVariable=isVariableImpl(~,actualImpl)
            isVariable=(isa(actualImpl,'RTW.Variable')&&~isa(actualImpl,'RTW.CustomVariable'))||isa(actualImpl,'RTW.PointerVariable');
        end
        function serActualRef=fixImplementationRefForVariables(obj,actual,serActualRef)
            fixedRef=[];
            if obj.isVariableImpl(actual.Implementation)
                fixedRef=coder.descriptor.Variable.findVariableByIdentifier(obj.fMF0Model,actual.Implementation.Identifier);
            end





            if obj.shouldUpdateImplementationReferences(serActualRef.Implementation,fixedRef)
                DIsWithSameImplRef=coder.descriptor.DataInterface.findDataInterfacesWithSameImplReference(obj.fMF0Model,serActualRef.Implementation);
                serActualRef.Implementation.destroy();
                for i=1:length(DIsWithSameImplRef)
                    DIsWithSameImplRef(i).Implementation=fixedRef;
                end
            end
        end
        function serActualRef=fixReferenceForActualInterface(obj,actual,serActual)
            lutI=obj.findLUTOrBPInterface(actual.GraphicalName);
            fixedDataIntRef=coder.descriptor.DataInterface.findDataInterface(obj.fMF0Model,serActual);
            if~isempty(lutI)
                interfaceToUse=lutI;
            else
                interfaceToUse=fixedDataIntRef;
            end
            if~isempty(interfaceToUse)&&interfaceToUse~=serActual
                obj.removeDuplicateDataInterfaces(serActual);
                serActualRef=interfaceToUse;
            else
                serActualRef=serActual;
            end
            serActualRef=obj.fixImplementationRefForVariables(actual,serActualRef);
        end
        function ret=createFunctionInterface(obj,functionInterface,model)
            ret=functionInterface.serializeMF0(model);
            if~isempty(obj.fCPPModelObject)&&~isempty(ret.FunctionOwner)


                assert(~isempty(obj.fFullModel.componentInterface.ConstructorFunction));
                ret.FunctionOwner.destroy;
                ret.FunctionOwner=obj.fCPPModelObject;
            end
            if~isempty(functionInterface.ActualReturn)
                ret.ActualReturn=obj.fixReferenceForActualInterface(functionInterface.ActualReturn,ret.ActualReturn);
            end
            for i=1:numel(functionInterface.ActualArgs)
                ret.ActualArgs(i)=obj.fixReferenceForActualInterface(functionInterface.ActualArgs(i),ret.ActualArgs(i));
            end
            for i=1:numel(functionInterface.DirectReads)
                ret.DirectReads(i)=obj.fixReferenceForActualInterface(functionInterface.DirectReads(i),ret.DirectReads(i));
            end
            for i=1:numel(functionInterface.DirectWrites)
                ret.DirectWrites(i)=obj.fixReferenceForActualInterface(functionInterface.DirectWrites(i),ret.DirectWrites(i));
            end
        end
        function fixupTargetVariableReference(obj,impl)
            if~isa(impl,'coder.descriptor.PointerExpression')
                return;
            end
            if(isa(impl.TargetRegion,'coder.descriptor.Variable'))
                fixedRef=coder.descriptor.Variable.findVariableByIdentifier(obj.fMF0Model,impl.TargetRegion.Identifier);
                if obj.shouldUpdateImplementationReferences(impl.TargetRegion,fixedRef)
                    impl.TargetRegion=fixedRef;
                end
            end
        end
        function fixupBaseRegionVariableReference(obj,impl)
            if~isa(impl,'coder.descriptor.PointerExpression')
                return;
            end
            if(isa(impl.BaseRegion,'coder.descriptor.Variable'))
                fixedRef=coder.descriptor.Variable.findVariableByIdentifier(obj.fMF0Model,impl.BaseRegion.Identifier);
                if obj.shouldUpdateImplementationReferences(impl.BaseRegion,fixedRef)
                    impl.BaseRegion=fixedRef;
                end
            end
        end
        function obj=writeDataInterfacesToCodeDescriptor(model,buildPath)
            obj.fInternalDataMap=containers.Map('KeyType','char','ValueType','any');
            obj.fSLModel=model;
            obj.fPath=buildPath;
            obj.fMF0Model=mf.zero.Model;
            mfdatasource.attachDMRDataSource(fullfile(char(obj.fPath),'codedescriptor.dmr'),obj.fMF0Model,mfdatasource.ToModelSync.None,mfdatasource.ToDataSourceSync.AllElements);
            obj.fFullModel=coder.descriptor.Model.findModel(obj.fMF0Model);
            obj.fInportArgs={};
            obj.fInportIndices=[];
            obj.fOutportArgs={};
            obj.fOutportIndices=[];
            obj.fInternalData=RTW.DataInterface.empty;
            obj.fCPPModelObject=obj.initModelObject();
            obj.fFPCInportIdxToOutportIdxMap={};
            obj.fProcessedCanonicalParameters=[];
            obj.fTxn=obj.fMF0Model.beginTransaction;
            obj.fOptimizedDWorkIndicies=[];
            obj.fUnusedSubsystemArgumentMap={};
            obj.fModelRefDWorkVar=[];
            obj.fModelRefDWorkMembers={};
            obj.fIsAutosar=false;
            obj.fIsModelRefSimTarget=false;
            obj.fIsMultiInstanceModelRef=false;
            obj.fFunctionInterfacesToDestroy=coder.descriptor.FunctionInterface.empty;
            obj.fDataInterfacesToDestroy=coder.descriptor.DataInterface.empty;
            obj.fRTMForSubsystemInterface=coder.descriptor.DataInterface.empty;
            obj.fRTMAddedMap=containers.Map;
            obj.fIsLibraryCodegen=false;
        end
        function closeRepo(obj)
            obj.fTxn.commit;
        end

        function obj=retryTransaction(obj)

        end
        function modelObj=initModelObject(obj)
            modelObj=[];



            if(obj.fFullModel.componentInterface.InternalData.Size>0)
                modelObj=obj.fFullModel.componentInterface.InternalData(1).Implementation;
            end
        end
        function setImplementationOnAllDataInterfaceCopies(obj,origDI,newImpl)
            new=coder.descriptor.DataInterface.findAllWithSameGraphicalNameAndSID(obj.fMF0Model,origDI.GraphicalName,origDI.SID);
            for k=1:numel(new)
                cur=new(k);
                if cur~=origDI
                    cur.Implementation=newImpl;
                end
            end
        end
        function isCollection=isDataInterfaceImplementationCollectionType(~,impl)
            isCollection=rtw.connectivity.CodeInfoUtils.isa(impl,'TypedCollection')||...
            rtw.connectivity.CodeInfoUtils.isa(impl,'BasicAccessFunctionExpressionCollection');
        end
        function updateImplementationWithCSCSource(obj,ssIntFieldDI,SSIntDstInfoElement,aSrcCSCImpl)
            ssIntFieldImpl=ssIntFieldDI.Implementation;
            if isempty(aSrcCSCImpl)
                return;
            end
            if SSIntDstInfoElement.isTypedCollection&&obj.isDataInterfaceImplementationCollectionType(ssIntFieldImpl)
                ssIntFieldDI.Implementation.Elements(SSIntDstInfoElement.elementIdx)=aSrcCSCImpl;
                obj.setImplementationOnAllDataInterfaceCopies(ssIntFieldDI,aSrcCSCImpl);
            elseif~isempty(ssIntFieldImpl)&&isa(ssIntFieldImpl,'coder.descriptor.ArrayExpression')
                ssIntFieldDI.Implementation.BaseRegion=aSrcCSCImpl;
            else
                ssIntFieldDI.Implementation=aSrcCSCImpl;
            end
        end
        function assignSrcDIToSSInterfaceFields(obj,aSourceDI,SSIntDstInfoVec)
            for j=1:length(SSIntDstInfoVec)
                SSIntDstInfoElement=SSIntDstInfoVec(j);
                ssInterface=coder.descriptor.SubsystemInterface.findSubsystemInterfaceBySubsystemSID(obj.fMF0Model,SSIntDstInfoElement.SubsysSID);
                if isequal(SSIntDstInfoElement.fieldType,coder.descriptor.DataInterfaceFieldType.Input)
                    updateSSIntFieldDI=ssInterface.Inports(SSIntDstInfoElement.fieldIdx);
                    obj.updateImplementationWithCSCSource(updateSSIntFieldDI,SSIntDstInfoElement,aSourceDI.Implementation);
                elseif isequal(SSIntDstInfoElement.fieldType,coder.descriptor.DataInterfaceFieldType.Output)
                    updateSSIntFieldDI=ssInterface.Outports(SSIntDstInfoElement.fieldIdx);
                    obj.updateImplementationWithCSCSource(updateSSIntFieldDI,SSIntDstInfoElement,aSourceDI.Implementation);
                elseif isequal(SSIntDstInfoElement.fieldType,coder.descriptor.DataInterfaceFieldType.ActualArg)
                    functionInt=ssInterface.findFunctionInterfaceByFunctionName(SSIntDstInfoElement.functionName);
                    if isempty(functionInt)
                        return;
                    end
                    assert(functionInt.ActualArgs.Size>SSIntDstInfoElement.fieldIdx&&uint64(SSIntDstInfoElement.fieldIdx)>0);
                    updateSSIntFieldDI=functionInt.ActualArgs(SSIntDstInfoElement.fieldIdx);
                    obj.updateImplementationWithCSCSource(updateSSIntFieldDI,SSIntDstInfoElement,aSourceDI.Implementation);
                end
            end
        end
        function CopySourceDIToSubsystemInterface(obj,aSrcDI)
            aSSInterfaceParameterCopyMap=obj.fFullModel.componentInterface.SubsystemInterfaceSourceDICopyMap;
            if aSSInterfaceParameterCopyMap.Size==0
                return;
            end
            aSSInterfacePrmMap=aSSInterfaceParameterCopyMap.getByKey(aSrcDI);
            if isempty(aSSInterfacePrmMap)
                return;
            end
            SSIntDstInfoVec=aSSInterfacePrmMap.SubsystemInterfaceFields.toArray;
            obj.assignSrcDIToSSInterfaceFields(aSrcDI,SSIntDstInfoVec);
        end
        function obj=writeRootInport(obj,regObj,inport)

            fRootInport=coder.descriptor.DataInterface.findByGraphicalNameAndSID(obj.fMF0Model,inport.GraphicalName,inport.SID);



            if(~isempty(fRootInport))
                if isempty(regObj)


                    fRootInport.Implementation=coder.descriptor.DataImplementation.empty;
                    return;
                end
                fRootInport.Implementation=regObj.serializeMF0(obj.fMF0Model);
                fRootInport.Type=inport.Type.serializeMF0(obj.fMF0Model);
            end
            obj.CopySourceDIToSubsystemInterface(fRootInport);
            blocks=obj.fFullModel.BlockHierarchyMap.getBlocksBySID(inport.SID);
            for i=1:numel(blocks)
                blocks(i).DataOutputPorts(1).DataInterfaces.add(fRootInport);
            end
        end

        function obj=writeRootOutport(obj,regObj,outport)
            fRootOutport=coder.descriptor.DataInterface.findByGraphicalNameAndSID(obj.fMF0Model,outport.GraphicalName,outport.SID);



            if(~isempty(fRootOutport))
                if isempty(regObj)


                    fRootOutport.Implementation=coder.descriptor.DataImplementation.empty;
                    return
                end
                fRootOutport.Implementation=regObj.serializeMF0(obj.fMF0Model);
                fRootOutport.Type=outport.Type.serializeMF0(obj.fMF0Model);
            end
            obj.CopySourceDIToSubsystemInterface(fRootOutport);
            blocks=obj.fFullModel.BlockHierarchyMap.getBlocksBySID(outport.SID);
            for i=1:numel(blocks)
                blocks(i).DataInputPorts(1).DataInterfaces.add(fRootOutport);
            end
        end

        function obj=writeDataStore(obj,regObj,dataStore)
            fDataStore=coder.descriptor.ReadWriteDataInterface.findByGraphicalNameAndSID(obj.fMF0Model,dataStore.GraphicalName,dataStore.SID);
            assert(fDataStore.isReadWriteDataInterface());


            if(~isempty(fDataStore))
                if isempty(regObj)


                    fDataStore.Implementation=coder.descriptor.DataImplementation.empty;
                    return
                end
                fDataStore.Implementation=regObj.serializeMF0(obj.fMF0Model);
                fDataStore.Type=dataStore.Type.serializeMF0(obj.fMF0Model);
                obj.CopySourceDIToSubsystemInterface(fDataStore);
            end
        end

        function di=getParameterDataInterfaceToWrite(obj,existingDataInt)
            if~isempty(existingDataInt)
                di=existingDataInt;
            else
                di=coder.descriptor.DataInterface(obj.fMF0Model);
            end
        end

        function param=getParameterToWrite(obj,paramName)
            param=obj.fFullModel.getModelParameterByName(paramName);



            if(isempty(param))
                param=coder.descriptor.ModelParameter.findByOriginalName(obj.fMF0Model,paramName);



                if(isempty(param))
                    param=coder.descriptor.ModelParameter(obj.fMF0Model);
                end
            end
        end

        function obj=writeParameter(obj,regObj,paramName,sid)

            fParam=obj.getParameterToWrite(paramName);



            if isempty(fParam)
                return;
            end


            if isempty(fParam.DataInterface)




                existingDataInt=...
                coder.descriptor.DataInterface.findAllWithSameGraphicalNameAndSID(...
                obj.fMF0Model,paramName,sid);

                assert(numel(existingDataInt)<2,'Found multiple DataInterfaces with same graphical name and SID');
                fParam.DataInterface=obj.getParameterDataInterfaceToWrite(existingDataInt);
                fParam.DataInterface.GraphicalName=paramName;
                fParam.DataInterface.SID=sid;
            end
            dataIntsToUpdate=coder.descriptor.LookupTableDataInterface.getParametersToUpdate(obj.fMF0Model,fParam.DataInterface);
            if~isempty(regObj)
                ser=regObj.serializeMF0(obj.fMF0Model);
            else
                ser=coder.descriptor.DataImplementation.empty;
            end
            origImpl=fParam.DataInterface.Implementation;
            for i=1:numel(dataIntsToUpdate)
                curDataInt=dataIntsToUpdate(i);
                opaqueR=[];
                if isa(curDataInt.Implementation,'coder.descriptor.TypedRegion')
                    opaqueR=curDataInt.Implementation.OpaqueRegion;
                end
                curDataInt.Implementation=ser;
                if~isempty(opaqueR)&&isa(curDataInt.Implementation,'coder.descriptor.TypedRegion')
                    curDataInt.Implementation.OpaqueRegion=opaqueR;
                end
                curDataInt.GraphicalName=paramName;

                if~isempty(regObj)&&~isempty(regObj.Type)&&isempty(curDataInt.Type)
                    curDataInt.Type=regObj.Type.serializeMF0(obj.fMF0Model);
                end
                obj.CopySourceDIToSubsystemInterface(curDataInt);
            end
            if~isempty(origImpl)
                origImpl.destroy;
            end
        end

        function obj=writeParameterArgument(obj,regObj,paramName,SID)
            if isempty(regObj)


                return
            end

            fParam=obj.fFullModel.getModelParameterByName(paramName);

            if isempty(fParam)
                tempDi=coder.descriptor.DataInterface(obj.fMF0Model);
                tempDi.Implementation=regObj.serializeMF0(obj.fMF0Model);
                tempDi.Type=regObj.Type.serializeMF0(obj.fMF0Model);
                tempDi.GraphicalName=paramName;
                tempDi.SID=SID;
                obj.fFullModel.componentInterface.Parameters.add(tempDi);
            else
                if isempty(fParam.DataInterface)
                    fParam.DataInterface=coder.descriptor.DataInterface(obj.fMF0Model);
                end
                fParam.DataInterface.Implementation=regObj.serializeMF0(obj.fMF0Model);
                fParam.DataInterface.Type=regObj.Type.serializeMF0(obj.fMF0Model);
                fParam.DataInterface.SID=SID;
            end

        end

        function obj=writeInstanceSpecificParameterArgument(obj,codeInfoDataInt)
            if isempty(codeInfoDataInt.Implementation)


                return
            end


            obj.writeParameter(codeInfoDataInt.Implementation,codeInfoDataInt.GraphicalName,codeInfoDataInt.SID);


            existingDataInt=...
            coder.descriptor.DataInterface.findAllWithSameGraphicalNameAndSID(...
            obj.fMF0Model,codeInfoDataInt.GraphicalName,codeInfoDataInt.SID);

            assert(numel(existingDataInt)==1);

            MF0Var=existingDataInt.Implementation;
            while~isa(MF0Var.BaseRegion,'coder.descriptor.Variable')&&~isa(MF0Var.BaseRegion,'coder.descriptor.ClassMemberExpression')...
                &&~isa(MF0Var.BaseRegion,'coder.descriptor.ClassMethodExpression')
                MF0Var=MF0Var.BaseRegion;
            end

            if isa(MF0Var.BaseRegion,'coder.descriptor.ClassMethodExpression')
                implToUse=MF0Var.BaseRegion.BaseRegion;
            else
                implToUse=MF0Var.BaseRegion;
            end
            propName=obj.getInstPIdentifierPropName(implToUse);

            internalDataVar=obj.fInternalDataMap(implToUse.(propName));

            MF0Var.BaseRegion=internalDataVar.Implementation;

            if isa(implToUse,'coder.descriptor.ClassMemberExpression')&&internalDataVar.Implementation.BaseRegion~=obj.fCPPModelObject

                internalDataVar.Implementation.BaseRegion.destroy;
                internalDataVar.Implementation.BaseRegion=obj.fCPPModelObject;
            end


        end

        function obj=writeBlockOutput(obj,regObj,Idx,isExternal)
            if isempty(regObj)


                return;
            end

            fCompInt=obj.fFullModel.componentInterface;
            if isExternal
                bo=fCompInt.ExternalBlockOutputs(Idx+1);
            else
                bo=fCompInt.GlobalBlockOutputs(Idx+1);
            end
            bo.Implementation=regObj.serializeMF0(obj.fMF0Model);
            if~isempty(regObj.Type)
                bo.Type=regObj.Type.serializeMF0(obj.fMF0Model);
            end
            obj.CopySourceDIToSubsystemInterface(bo);
        end


        function obj=writeExternalBlockOutput(obj,regObj,Idx)
            obj.writeBlockOutput(regObj,Idx,true);
        end

        function obj=writeGlobalBlockOutput(obj,regObj,Idx)
            obj.writeBlockOutput(regObj,Idx,false);
        end

        function propName=getInstPIdentifierPropName(~,impl)
            if isprop(impl,'Identifier')
                propName='Identifier';
            elseif isprop(impl,'ElementIdentifier')
                propName='ElementIdentifier';
            end
            assert(~isempty(propName));
        end

        function obj=writeDWork(obj,regObj,Idx)
            if isempty(regObj)


                return;
            end

            fCompInt=obj.fFullModel.componentInterface;
            dWork=fCompInt.DWorks(Idx+1);
            dWork.Implementation=regObj.serializeMF0(obj.fMF0Model);
            if~isempty(regObj.Type)
                dWork.Type=regObj.Type.serializeMF0(obj.fMF0Model);
            end
            obj.CopySourceDIToSubsystemInterface(dWork);
        end

        function obj=writeInternalData(obj,regObj)
            if isa(regObj.Implementation,'RTW.ClassMethodExpression')
                implToUse=regObj.Implementation.BaseRegion;
            else
                implToUse=regObj.Implementation;
            end
            propName=obj.getInstPIdentifierPropName(implToUse);
            assert(~isempty(propName));
            if~isempty(obj.fFullModel.componentInterface.InternalData.toArray)
                for i=1:size(obj.fFullModel.componentInterface.InternalData.toArray,2)
                    curDataInt=obj.fFullModel.componentInterface.InternalData(i);
                    if isprop(curDataInt.Implementation,propName)&&strcmp(curDataInt.Implementation.(propName),implToUse.(propName))
                        obj.fInternalDataMap(regObj.Implementation.(propName))=curDataInt;
                        return;
                    end
                end
            end
            itemToAdd=regObj.serializeMF0(obj.fMF0Model);
            obj.fFullModel.componentInterface.InternalData.add(itemToAdd);
            obj.fInternalDataMap(implToUse.(propName))=itemToAdd;
        end

        function obj=writeName(obj,nameFromTLC)



            obj.fFullModel.componentInterface.Name=nameFromTLC;
        end

        function di=getModelRefRootIOExistingInterface(obj,isInports,idx)
            if isInports
                di=obj.fFullModel.componentInterface.Inports(idx);
            else
                di=obj.fFullModel.componentInterface.Outports(idx);
            end
        end

        function updateModelRefRootIOImplementations(obj,idxVec,args,isInports)
            for i=1:numel(idxVec)
                dataIntToAdd=coder.descriptor.DataInterface.empty;
                if~isempty(args{i})
                    dataIntToAdd=args{i}.serializeMF0(obj.fMF0Model);
                    dataIntToAdd=obj.fixReferenceForActualInterface(args{i},dataIntToAdd);
                end
                if isempty(dataIntToAdd.Implementation)
                    continue
                end
                existingDI=obj.getModelRefRootIOExistingInterface(isInports,idxVec(i));
                dataIntToAdd.Implementation.OpaqueRegion=existingDI.Implementation.OpaqueRegion;
                dataIntToAdd.Implementation.Type=existingDI.Implementation.Type;
                dataIntToAdd.Implementation.CodeType=existingDI.Implementation.CodeType;





                DIsWithSameImplRef=coder.descriptor.DataInterface.findDataInterfacesWithSameImplReference(obj.fMF0Model,existingDI.Implementation);
                for j=1:length(DIsWithSameImplRef)
                    DIsWithSameImplRef(j).Implementation=dataIntToAdd.Implementation;
                end
            end
        end

        function obj=writeRTMToSubsystemInterfaceIfNeccessary(obj,itemToAdd)
            if~obj.fIsLibraryCodegen&&strcmp(itemToAdd.GraphicalName,'RTModel')
                if~isempty(obj.fRTMForSubsystemInterface)
                    obj.fRTMForSubsystemInterface.Implementation=itemToAdd.Implementation;
                end
                coder.descriptor.SubsystemInterface.addRTM(obj.fMF0Model,itemToAdd);
            end
        end

        function obj=writeDataInterfacesLate(obj)
            fCompInt=obj.fFullModel;
            obj.updateModelRefRootIOImplementations(obj.fInportIndices,obj.fInportArgs,true);
            obj.updateModelRefRootIOImplementations(obj.fOutportIndices,obj.fOutportArgs,false);


            for i=1:numel(fCompInt.componentInterface.InternalData.toArray)
                di=fCompInt.componentInterface.InternalData(i);
                if(strcmp(di.GraphicalName,'HierarchicalCoderDataGroup')&&isa(di.Implementation,'coder.descriptor.Variable'))
                    di.Implementation=coder.descriptor.Variable.findVariableByIdentifier(obj.fMF0Model,di.Implementation.Identifier);
                end
            end


            for i=1:numel(obj.fInternalData)
                itemToAdd=obj.fInternalData(i).serializeMF0(obj.fMF0Model);
                obj.fixReferenceForActualInterface(obj.fInternalData(i),itemToAdd);
                obj.fixupTargetVariableReference(itemToAdd.Implementation);
                obj.fixupBaseRegionVariableReference(itemToAdd.Implementation);
                obj.writeRTMToSubsystemInterfaceIfNeccessary(itemToAdd);
                fCompInt.componentInterface.InternalData.add(itemToAdd);
            end



            obj.fTxn.commit;
            obj.fTxn=obj.fMF0Model.beginTransaction;
        end
        function replaceCodegenTypeIdent(obj,codegenTypeIdent,replacedTypeIdent)
            types=coder.descriptor.types.Type.findTypesByIdentifier(obj.fMF0Model,codegenTypeIdent);
            for t=1:numel(types)
                types(t).Identifier=replacedTypeIdent;
            end
        end
        function fixupTypesForDataTypeReplacements(obj)

            enableReplacement=strcmp(get_param(obj.fSLModel,'IsERTTarget'),'on')&&...
            strcmp(get_param(obj.fSLModel,'EnableUserReplacementTypes'),'on');
            if~enableReplacement
                return;
            end

            codeGenTypes={'real_T','real32_T','int32_T','int16_T','int8_T','uint32_T',...
            'uint16_T','uint8_T','boolean_T','int_T','uint_T','char_T',...
            'uint64_T','int64_T'};

            replacements=get_param(obj.fSLModel,'ReplacementTypes');
            fnames=fieldnames(replacements);
            slToCodeGenTypes=containers.Map(fnames,codeGenTypes);
            for k=1:numel(fnames)
                if isempty(replacements.(fnames{k}))
                    continue;
                end
                codegenTypeIdent=slToCodeGenTypes(fnames{k});
                replacedTypeIdent=replacements.(fnames{k});
                obj.replaceCodegenTypeIdent(codegenTypeIdent,replacedTypeIdent);
            end
        end
        function obj=writeFunctionInterfaces(obj,codeInfo)

            obj.writeDataInterfacesLate();

            fCompInt=obj.fFullModel;

            for i=1:numel(codeInfo.OutputFunctions)
                fCompInt.componentInterface.OutputFunctions(i)=...
                obj.createFunctionInterface(codeInfo.OutputFunctions(i),obj.fMF0Model);
            end

            for i=1:numel(codeInfo.UpdateFunctions)
                fCompInt.componentInterface.UpdateFunctions(i)=...
                obj.createFunctionInterface(codeInfo.UpdateFunctions(i),obj.fMF0Model);
            end

            for i=1:numel(codeInfo.TerminateFunctions)
                fCompInt.componentInterface.TerminateFunctions(i)=...
                obj.createFunctionInterface(codeInfo.TerminateFunctions(i),obj.fMF0Model);
            end

            for i=1:numel(codeInfo.InitializeFunctions)
                fCompInt.componentInterface.InitializeFunctions(i)=...
                obj.createFunctionInterface(codeInfo.InitializeFunctions(i),obj.fMF0Model);
            end

            if~isempty(codeInfo.AllocationFunction)
                fCompInt.componentInterface.AllocationFunction=...
                obj.createFunctionInterface(codeInfo.AllocationFunction,obj.fMF0Model);
            end

            if~isempty(codeInfo.ConstructorFunction)
                fCompInt.componentInterface.ConstructorFunction=...
                obj.createFunctionInterface(codeInfo.ConstructorFunction,obj.fMF0Model);
            end

            for i=1:numel(codeInfo.EnableFunction)
                fCompInt.componentInterface.EnableFunction(i)=...
                obj.createFunctionInterface(codeInfo.EnableFunction(i),obj.fMF0Model);
            end

            for i=1:numel(codeInfo.DisableFunction)
                fCompInt.componentInterface.DisableFunction(i)=...
                obj.createFunctionInterface(codeInfo.DisableFunction(i),obj.fMF0Model);
            end

            for i=1:numel(codeInfo.Code.GlobalVariables)
                toAdd=codeInfo.Code.GlobalVariables(i).serializeMF0(obj.fMF0Model);
                if i>fCompInt.componentInterface.Code.GlobalVariables.Size
                    fCompInt.componentInterface.Code.GlobalVariables.add(toAdd);
                else
                    fCompInt.componentInterface.Code.GlobalVariables(i)=toAdd;
                end
            end

            for i=1:numel(codeInfo.Code.MutuallyExclusiveVariables)
                fCompInt.componentInterface.Code.MutuallyExclusiveVariables.add(string(codeInfo.Code.MutuallyExclusiveVariables(i)));
            end

            if~isempty(codeInfo.EventsFunction)
                fCompInt.componentInterface.EventsFunction=...
                obj.createFunctionInterface(codeInfo.EventsFunction,obj.fMF0Model);
            end

            if~isempty(codeInfo.DerivativeFunction)
                fCompInt.componentInterface.DerivativeFunction=...
                obj.createFunctionInterface(codeInfo.DerivativeFunction,obj.fMF0Model);
            end

            if~isempty(codeInfo.InitConditionsFunction)
                fCompInt.componentInterface.InitConditionsFunction=...
                obj.createFunctionInterface(codeInfo.InitConditionsFunction,obj.fMF0Model);
            end

            if~isempty(codeInfo.SystemResetFunction)
                fCompInt.componentInterface.SystemResetFunction=...
                obj.createFunctionInterface(codeInfo.SystemResetFunction,obj.fMF0Model);
            end

            if~isempty(codeInfo.SystemInitializeFunction)
                fCompInt.componentInterface.SystemInitializeFunction=...
                obj.createFunctionInterface(codeInfo.SystemInitializeFunction,obj.fMF0Model);
            end

            if~isempty(codeInfo.SetupRuntimeResourcesFunction)
                fCompInt.componentInterface.SetupRuntimeResourcesFunction=...
                obj.createFunctionInterface(codeInfo.SetupRuntimeResourcesFunction,obj.fMF0Model);
            end

            if~isempty(codeInfo.CleanupRuntimeResourcesFunction)
                fCompInt.componentInterface.CleanupRuntimeResourcesFunction=...
                obj.createFunctionInterface(codeInfo.CleanupRuntimeResourcesFunction,obj.fMF0Model);
            end

            if~isempty(obj.fFPCInportIdxToOutportIdxMap)
                for i=1:size(obj.fFPCInportIdxToOutportIdxMap,2)
                    mapEntry=obj.fFPCInportIdxToOutportIdxMap{i};
                    fCompInt.componentInterface.Outports(mapEntry.OutportIdx).Implementation=...
                    fCompInt.componentInterface.Inports(mapEntry.InportIdx).Implementation;
                end
            end
            if~isempty(obj.fOptimizedDWorkIndicies)
                dworks=fCompInt.componentInterface.DWorks;
                arrayfun(@(x)destroy(x),dworks(obj.fOptimizedDWorkIndicies));
            end

            if~isempty(obj.fUnusedSubsystemArgumentMap)
                for i=1:size(obj.fUnusedSubsystemArgumentMap,2)
                    mapEntry=obj.fUnusedSubsystemArgumentMap{i};
                    if~isvalid(mapEntry.FunctionInterface)


                        continue;
                    end
                    mapEntry.FunctionInterface.Prototype.Arguments.remove(mapEntry.ArgToRemove);
                    if isfield(mapEntry,'ActualArgToRemove')
                        mapEntry.FunctionInterface.ActualArgs.remove(mapEntry.ActualArgToRemove);
                    end
                end
            end

            obj.destroyUnsedSerializedObjects();
            obj.fixupInternalDataForMultiInstance();
            obj.fixupInternalDataForNonReusableModelRef();
            obj.fixupTypesForDataTypeReplacements();

            coder.descriptor.types.Opaque.replaceOpaqueTypes(obj.fMF0Model);
            obj.fFullModel.componentInterface.SubsystemInterfaceSourceDICopyMap.destroyAllContents;
        end

        function obj=writeServerCallPoints(obj,codeInfo)

            txn=obj.fMF0Model.beginTransaction;

            fCompInt=obj.fFullModel.componentInterface;

            for i=1:numel(codeInfo.ServerCallPoints)
                fCompInt.ServerCallPoints.add(...
                codeInfo.ServerCallPoints(i).serializeMF0(obj.fMF0Model));
            end

            txn.commit;
        end

        function obj=updateInportArg(obj,arg,index)
            obj.fInportArgs{end+1}=arg;
            obj.fInportIndices(end+1)=index;
        end

        function obj=updateOutportArg(obj,arg,index)
            obj.fOutportArgs{end+1}=arg;
            obj.fOutportIndices(end+1)=index;
        end

        function obj=updateParamArg(obj,arg,paramIdx)
            if(ismember(paramIdx,obj.fProcessedCanonicalParameters))
                return;
            end
            obj.fProcessedCanonicalParameters(end+1)=paramIdx;
            paramName=arg.GraphicalName;
            sid=arg.SID;
            obj.writeParameter(arg.Implementation,paramName,sid);
        end

        function obj=addInternalData(obj,data)
            obj.fInternalData(end+1)=data;
        end


        function obj=removeSkippedParameters(obj,skippedParameters)
            for i=1:numel(skippedParameters)
                dataInt=coder.descriptor.DataInterface.findByGraphicalNameAndSID(obj.fMF0Model,skippedParameters(i).GraphicalName,...
                skippedParameters(i).SID);
                if(~isempty(dataInt))
                    obj.fFullModel.removeModelParametersWithDataInterface(dataInt);
                    dataInt.destroy;
                end
            end
        end

        function obj=ConstructorArgumentFixup(obj)



            fCompInt=obj.fFullModel.componentInterface;

            txn=obj.fMF0Model.beginTransaction;


            if~isempty(fCompInt.ConstructorFunction)
                constructorFcn=fCompInt.ConstructorFunction;
                if~isempty(constructorFcn.ActualArgs.toArray)
                    for i=1:size(constructorFcn.ActualArgs.toArray,2)
                        curArg=constructorFcn.ActualArgs(i);
                        if contains(curArg.GraphicalName,'Storage class')
                            internalData=fCompInt.InternalData;
                            for j=1:size(internalData.toArray,2)
                                curDataInt=internalData(j);
                                if isa(curDataInt.Implementation,'coder.descriptor.Variable')&&...
                                    strcmp(curDataInt.Implementation.Identifier,curArg.Implementation.TargetVariable.Identifier)

                                    fCompInt.ConstructorFunction.ActualArgs(i).Implementation.TargetVariable=...
                                    curDataInt.Implementation;
                                    break;
                                end
                            end
                        end

                    end
                end
            end
            txn.commit;
        end

        function obj=updateInternalData(obj,impl,dataInterfaceName)
            dataInterface=coder.descriptor.DataInterface.findAllWithSameGraphicalName(obj.fMF0Model,dataInterfaceName);
            if~isempty(dataInterface)
                dataInterface.Implementation=impl.serializeMF0(obj.fMF0Model);
                obj.fixupTargetVariableReference(dataInterface.Implementation);
            end
        end
        function obj=addAsyncFunctionInterfaces(obj,functionName,taskIdx,priority)
            fCompInt=obj.fFullModel.componentInterface;

            fInt=coder.descriptor.FunctionInterface(obj.fMF0Model);
            fProto=coder.descriptor.types.Prototype(obj.fMF0Model);
            fProto.Name=functionName;
            fInt.Prototype=fProto;
            fInt.Timing=coder.descriptor.TimingInterface.findByTaskIndex(obj.fMF0Model,taskIdx);
            fInt.Timing.Priority=priority;
            fCompInt.OutputFunctions.add(fInt);
        end
        function methods=createRTMMethods(obj,fCompInt,fcnName)
            assert(fCompInt.InternalData(1).Implementation.Type.isClass);
            typeMethod=coder.descriptor.types.ClassMethod(obj.fMF0Model);
            codeTypeMethod=coder.descriptor.types.ClassMethod(obj.fMF0Model);
            typeMethod.Name=fcnName;
            codeTypeMethod.Name=fcnName;
            methods=[typeMethod,codeTypeMethod];
        end
        function obj=addGetRTMToModelClass(obj,fcnName,returnType)
            fCompInt=obj.fFullModel.componentInterface;
            methods=createRTMMethods(obj,fCompInt,fcnName);
            methodReturnType=returnType.serializeMF0(obj.fMF0Model);
            for methodIdx=1:length(methods)
                methods(methodIdx).Type=methodReturnType;
                methods(methodIdx).ReadOnly=true;
            end
            fCompInt.InternalData(1).Implementation.Type.addMethod(methods(1));
            fCompInt.InternalData(1).Implementation.CodeType.addMethod(methods(2));
        end
        function obj=addSetRTMToModelClass(obj,fcnName,inputType)
            fCompInt=obj.fFullModel.componentInterface;
            methods=createRTMMethods(obj,fCompInt,fcnName);
            methodInputType=inputType.serializeMF0(obj.fMF0Model);
            methodReturnType=coder.descriptor.types.Void(obj.fMF0Model);
            for methodIdx=1:length(methods)
                methods(methodIdx).addArgument(methodInputType);
                methods(methodIdx).Type=methodReturnType;
                methods(methodIdx).ReadOnly=false;
            end
            fCompInt.InternalData(1).Implementation.Type.addMethod(methods(1));
            fCompInt.InternalData(1).Implementation.CodeType.addMethod(methods(2));
        end
        function obj=updateSIDForSubsystemBuild(obj,dataIntType,index,newSID,varargin)
            fCompInt=obj.fFullModel.componentInterface;

            if strcmp(dataIntType,'Inport')
                fCompInt.Inports(index).SID=newSID;
            elseif strcmp(dataIntType,'Outport')
                fCompInt.Outports(index).SID=newSID;
            elseif strcmp(dataIntType,'Parameter')
                dataInterfaces=coder.descriptor.DataInterface.findAllWithSameGraphicalName(obj.fMF0Model,varargin{1}.GraphicalName);
                dataIntToUse=[];
                for i=1:numel(dataInterfaces)
                    if(isempty(dataInterfaces(i).SID)&&isempty(varargin{1}.SID))
                        dataIntToUse=dataInterfaces(i);
                        break;
                    end
                    locOfColon=strfind(varargin{1}.SID,':');
                    colonToEnd=varargin{1}.SID(locOfColon:end);
                    if(contains(dataInterfaces(i).SID,colonToEnd))
                        dataIntToUse=dataInterfaces(i);
                        break;
                    end
                end
                lutI=obj.findLUTOrBPInterface(varargin{1}.GraphicalName);
                if~isempty(lutI)
                    dataIntToUse=lutI;
                end
                dataIntToUse.SID=newSID;
            elseif strcmp(dataIntType,'DataStore')
                fCompInt.DataStores(index).SID=newSID;
            end
        end

        function obj=updateOutportImplementationForFPC(obj,outportIdx,inportIdx)
            map.OutportIdx=outportIdx;
            map.InportIdx=inportIdx;
            obj.fFPCInportIdxToOutportIdxMap{end+1}=map;
        end
        function fullSID=getFullBlockSID(obj,blkSID)
            fullSID=[obj.fFullModel.modelName,':',blkSID];
        end
        function obj=writeModelBlockClassVariableName(obj,modelBlkSID,classVarName)
            fullSID=obj.getFullBlockSID(modelBlkSID);
            mdlRefBlks=obj.fFullModel.BlockHierarchyMap.getBlocksBySID(fullSID);
            for i=1:numel(mdlRefBlks)
                mdlRefBlks(i).ModelClassInstanceVariableName=classVarName;
            end
        end

        function obj=removeDWorkOptimizedInTLC(obj,dworkIdx)
            assert(dworkIdx<=obj.fFullModel.componentInterface.DWorks.Size);
            obj.fOptimizedDWorkIndicies(end+1)=dworkIdx;
        end

        function obj=removeUnusedArgumentFromSubsystemInterface(obj,subsysSID,fcnName,argIndex)
            [~,functionInt]=obj.getSubsystemFcnInterface(subsysSID,fcnName);
            if isempty(functionInt)
                return;
            end

            prototype=functionInt.Prototype;
            assert(strcmp(prototype.Name,fcnName));
            map.FunctionInterface=functionInt;
            if argIndex>prototype.Arguments.Size
                return;
            end
            map.ArgToRemove=prototype.Arguments(argIndex);
            if argIndex<=functionInt.ActualArgs.Size
                map.ActualArgToRemove=functionInt.ActualArgs(argIndex);
            end
            obj.fUnusedSubsystemArgumentMap{end+1}=map;

        end

        function dataInt=createFakeActualArgForLibraryCodegen(obj,prototypeArg)
            dataInt=coder.descriptor.DataInterface(obj.fMF0Model);
            isPointer=prototypeArg.Type.isPointer;
            var=coder.descriptor.Variable(obj.fMF0Model);

            if isPointer


                ptrvar=coder.descriptor.PointerVariable(obj.fMF0Model);
                ptrvar.TargetVariable=var;
                baseType=prototypeArg.Type.BaseType;
                var.Type=baseType;
                var.CodeType=baseType;
                var.Identifier=[prototypeArg.Name,'_targetVar'];
                var=ptrvar;
            end
            var.Identifier=prototypeArg.Name;
            var.Type=prototypeArg.Type;
            var.CodeType=prototypeArg.Type;
            dataInt.Implementation=var;
        end

        function ret=serializeRTMArgForFunctionParamIfNeccessary(obj,rtmMaybe)
            ret=[];
            if~isempty(rtmMaybe)
                ret=rtmMaybe.serializeMF0(obj.fMF0Model);
            end
        end

        function ret=getActualArgForFunctionParameter(obj,prototypeArg,rtmMaybe)
            rtmDI=obj.serializeRTMArgForFunctionParamIfNeccessary(rtmMaybe);
            if~isempty(rtmDI)
                ret=rtmDI;
            else
                ret=obj.createFakeActualArgForLibraryCodegen(prototypeArg);
            end
        end

        function obj=addFunctionParameterToCodeDescriptor(obj,subsysSID,fcnName,typeObj,argName,isArgAddedAtEnd,rtmMaybe)
            [subsysInt,functionInterface]=obj.getSubsystemFcnInterface(subsysSID,fcnName);

            assert(numel(functionInterface)<2);

            if isempty(functionInterface)
                return;
            end

            prototype=functionInterface.Prototype;

            newPrototypeArg=coder.descriptor.types.Argument(obj.fMF0Model);
            argNameToUse=argName;
            if strcmp(argNameToUse(1),"*")
                argNameToUse=argNameToUse(2:end);
            end
            newPrototypeArg.Name=argNameToUse;
            newPrototypeArg.IOType=coder.descriptor.types.IOTypes.INPUT_OUTPUT;
            newPrototypeArg.Type=typeObj.serializeMF0(obj.fMF0Model);
            prototype.Arguments.add(newPrototypeArg);
            actualArg=obj.getActualArgForFunctionParameter(newPrototypeArg,rtmMaybe);
            if isArgAddedAtEnd
                functionInterface.ActualArgs.add(actualArg);
            else
                actualArgs=functionInterface.ActualArgs;

                actualArgs.add(actualArgs(actualArgs.Size));
                for i=actualArgs.Size:-1:1
                    if i==1

                        actualArgs.insertAt(actualArg,1);
                    else

                        actualArts.insertAt(i,actualArgs(i-1));
                    end
                end

            end

            subsysInt.InternalData.add(actualArg);
        end

        function obj=removeEmptyFunctionFromSubsystemInterface(obj,subsysSID,fcnName)
            [~,functionInterface]=obj.getSubsystemFcnInterface(subsysSID,fcnName);

            if~isempty(functionInterface)
                obj.fFunctionInterfacesToDestroy(end+1)=functionInterface;
            end
        end
        function obj=removeDuplicateDataInterfaces(obj,dataInterface)
            if~isempty(dataInterface)
                obj.fDataInterfacesToDestroy(end+1)=dataInterface;
            end
        end
        function obj=addStructExpressionForSingleInstanceModelRef(obj,dworkStructTypeName,structExpressionString,finalVarGroupTypeName)
            if~contains(structExpressionString,'.')
                return;
            end
            dworkStructName=split(structExpressionString,'.');
            dworkStructName=dworkStructName{1};
            if isempty(obj.fModelRefDWorkVar)



                dworkStruct=coder.descriptor.Variable(obj.fMF0Model);
                dworkStruct.Identifier=dworkStructName;


                dworkStructType=coder.descriptor.types.Struct(obj.fMF0Model);
                dworkStructType.Identifier=dworkStructTypeName;
                dworkStructType.Name=dworkStructTypeName;
                dworkStruct.Type=dworkStructType;
                dworkStruct.CodeType=dworkStructType;
                if~obj.fIsMultiInstanceModelRef
                    dworkStruct.VarOwner=obj.fFullModel.modelName;
                end
                dataInterface=coder.descriptor.DataInterface(obj.fMF0Model);
                dataInterface.Implementation=dworkStruct;
                dataInterface.Type=dworkStructType;
                dataInterface.GraphicalName='MdlRefDWork';
                obj.fFullModel.componentInterface.InternalData.add(dataInterface);
                obj.fModelRefDWorkVar=dworkStruct;
            end

            map.DWorkVarGroupMemberTypeName=finalVarGroupTypeName;
            map.DWorkVarGroupMemberExpression=structExpressionString;
            obj.fModelRefDWorkMembers{end+1}=map;

        end

        function[var,obj]=findInternalDataVar(obj,graphicalName,varName)
            var=[];




            if~isempty(varName)
                var=coder.descriptor.Variable.findVariableByIdentifier(obj.fMF0Model,varName);
                if~isempty(var)
                    return;
                end
            end
            internalData=obj.fFullModel.componentInterface.InternalData.toArray;
            for i=1:numel(internalData)
                if strcmp(internalData(i).GraphicalName,graphicalName)
                    var=internalData(i).Implementation;
                    return;
                end
            end
        end

        function out=alreadyHandledCoderGroupVar(~,var,implDIs)








            out=false;
            for j=1:numel(implDIs)
                impl=implDIs(j).Implementation;
                if isa(impl,'coder.descriptor.PointerExpression')&&...
                    impl.TargetRegion==var
                    out=true;
                end
            end
        end

        function[res,obj]=findCoderGroupVars(obj)
            compInt=obj.fFullModel.componentInterface;
            intData=compInt.InternalData;






            rtm=obj.findInternalDataVar('RTModel','');
            ei=obj.findInternalDataVar('ExternalInput','');
            eo=obj.findInternalDataVar('ExternalOutput','');
            er=obj.findInternalDataVar('','rt_errorStatus');

            res=coder.descriptor.DataImplementation.empty;

            for i=1:compInt.InternalData.Size
                impl=intData(i).Implementation;
                if(isequal(impl,rtm)||...
                    isequal(impl,ei)||...
                    isequal(impl,eo)||...
                    isequal(impl,er))
                    continue
                end
                if(isa(impl,'coder.descriptor.Variable')||...
                    isa(impl,'coder.descriptor.StructExpression'))&&...
                    ~obj.alreadyHandledCoderGroupVar(impl,compInt.InternalData.toArray)
                    res(end+1)=impl;%#ok
                end
            end

        end

        function shouldSkip=shouldSkipFixupInternalDataForMultiInstance(obj)
            shouldSkip=false;
            if obj.fFullModel.IsSingleInstance
                shouldSkip=true;
            end
            if obj.fIsModelRefSimTarget
                shouldSkip=true;
            end
            if obj.fIsAutosar

                shouldSkip=true;
            end
        end

        function[curVar,varName,ptrExpr]=createStructExpressionForMulitiInstance(obj,curVar,rtm)
            varName='';

            if isa(curVar,'coder.descriptor.PointerExpression')


                ptrExpr=curVar;
                curVar=curVar.TargetRegion;
            elseif isa(curVar,'coder.descriptor.StructExpression')
                ptrExpr=curVar;
                varName=ptrExpr.ElementIdentifier;
            else
                ptrExpr=coder.descriptor.StructExpression(obj.fMF0Model);
                ptrExpr.Type=curVar.Type;
                ptrExpr.CodeType=curVar.CodeType;
                ptrExpr.BaseRegion=rtm;
                ptrExpr.ElementIdentifier=curVar.Identifier;
            end
        end
        function destroyUnsedSerializedObjects(obj)
            for i=1:numel(obj.fFunctionInterfacesToDestroy)
                obj.fFunctionInterfacesToDestroy(i).destroy;
            end
            for i=1:numel(obj.fDataInterfacesToDestroy)
                obj.fDataInterfacesToDestroy(i).destroy;
            end
        end
        function obj=fixupInternalDataForMultiInstance(obj)





            if obj.shouldSkipFixupInternalDataForMultiInstance()
                return;
            end
            compInt=obj.fFullModel.componentInterface;
            rtm=obj.findInternalDataVar('RTModel','');
            if isempty(compInt.InternalData.toArray)||isempty(rtm)
                return;
            end

            blockIOVar=obj.findInternalDataVar('Block signals','blockIO');
            dworkVar=obj.findInternalDataVar('Block states','dwork');
            coderGroupVars=obj.findCoderGroupVars();
            vars=[blockIOVar,dworkVar,coderGroupVars];
            for i=1:size(vars,2)
                curVar=vars(i);
                if isempty(curVar)
                    continue
                end
                [curVar,varName,ptrExpr]=obj.createStructExpressionForMulitiInstance(curVar,rtm);

                internalData=compInt.getComponentData('InternalData');
                for j=1:size(internalData,2)
                    impl=internalData(j).Implementation;

                    while isa(impl,'coder.descriptor.StructExpression')
                        matchingBaseRegVar=curVar==impl.BaseRegion||...
                        (isa(impl.BaseRegion,'coder.descriptor.Variable')&&strcmp(varName,impl.BaseRegion.Identifier));
                        if matchingBaseRegVar
                            impl.BaseRegion=ptrExpr;
                        end
                        impl=impl.BaseRegion;
                    end
                end
            end
        end

        function obj=fixupInternalDataForNonReusableModelRef(obj)
            if~isempty(obj.fModelRefDWorkMembers)
                internalData=obj.fFullModel.componentInterface.getComponentData('InternalData');
                for i=1:numel(internalData)



                    for j=1:size(obj.fModelRefDWorkMembers,2)
                        mapEntry=obj.fModelRefDWorkMembers{j};
                        impl=internalData(i).Implementation;
                        if~isa(internalData(i).Implementation,'coder.descriptor.StructExpression')
                            continue;
                        end

                        while isa(impl.BaseRegion,'coder.descriptor.StructExpression')
                            impl=impl.BaseRegion;
                        end
                        if strcmp(impl.BaseRegion.Type.Identifier,mapEntry.DWorkVarGroupMemberTypeName)
                            structExprToDworkStruct=coder.descriptor.StructExpression(obj.fMF0Model);
                            structExprToDworkStruct.Type=impl.BaseRegion.Type;
                            structExprToDworkStruct.CodeType=impl.BaseRegion.CodeType;
                            structExprToDworkStruct.BaseRegion=obj.fModelRefDWorkVar;
                            elementIdent=strsplit(mapEntry.DWorkVarGroupMemberExpression,'.');
                            elementIdent=elementIdent{2};
                            structExprToDworkStruct.ElementIdentifier=elementIdent;
                            impl.BaseRegion=structExprToDworkStruct;
                        end
                    end
                end
                obj.updateMdlrefDworkTypeAndFixMemberImplementations();
            end
        end
        function updateMdlrefDworkTypeAndFixMemberImplementations(obj)
            memberNameToLocalNameMap=obj.populateMemberNameToLocalNameMap();
            for i=1:size(obj.fModelRefDWorkMembers,2)
                mapEntry=obj.fModelRefDWorkMembers{i};


                memberTypes=coder.descriptor.types.Type.findTypesByIdentifier(obj.fMF0Model,mapEntry.DWorkVarGroupMemberTypeName);
                if isempty(memberTypes)
                    continue;
                end
                memberType=memberTypes(1);




                aggEl=coder.descriptor.types.AggregateElement(obj.fMF0Model);


                split=strsplit(mapEntry.DWorkVarGroupMemberExpression,'.');

                memberName=split{2};
                aggEl.Identifier=memberName;
                aggEl.Type=memberType;
                obj.fModelRefDWorkVar.Type.Elements=[obj.fModelRefDWorkVar.Type.Elements,aggEl];
                obj.fModelRefDWorkVar.CodeType.Elements=[obj.fModelRefDWorkVar.Type.Elements,aggEl];







                if memberNameToLocalNameMap.isKey(memberName)

                    di=coder.descriptor.DataInterface.findByGraphicalNameAndSID(obj.fMF0Model,memberNameToLocalNameMap(memberName),'');
                    if isempty(di)
                        continue;
                    end


                    newImpl=coder.descriptor.StructExpression(obj.fMF0Model);
                    newImpl.BaseRegion=obj.fModelRefDWorkVar;
                    newImpl.ElementIdentifier=memberName;

                    newImpl.Type=aggEl.Type;
                    newImpl.CodeType=aggEl.Type;

                    di.Implementation=newImpl;
                end
            end
        end
        function map=populateMemberNameToLocalNameMap(~)


            map=containers.Map;
            map('rtdw')='localDW';
            map('rtb')='localB';
            map('rtzce')='localZCE';
        end
        function obj=writeSubsystemFileInformation(obj,subsysSID,headerName,srcName)
            subsysSID=obj.getFullBlockSID(subsysSID);
            subsysInt=coder.descriptor.SubsystemInterface.findSubsystemInterfaceBySubsystemSID(obj.fMF0Model,subsysSID);
            if isempty(subsysInt)
                return;
            end



            props=properties(subsysInt);
            res=cellfun(@(propName)contains(propName,'Function'),props);
            funcProps=props(res);



            for i=1:numel(funcProps)
                propValue=subsysInt.(funcProps{i});
                if isa(propValue,'mf.zero.Sequence')
                    propValue=propValue.toArray;
                end
                if isempty(propValue)
                    continue;
                end
                for j=1:numel(propValue)
                    prototype=propValue.Prototype;
                    prototype.SourceFile=srcName;
                    prototype.HeaderFile=headerName;
                end
            end
        end
        function obj=setIsAutosar(obj,val)
            obj.fIsAutosar=val;
        end
        function obj=setIsModelRefSimTarget(obj,val)
            obj.fIsModelRefSimTarget=val;
        end
        function obj=writeAUTOSARPerInstanceParameterImplementation(obj,portName,groupTypeName,memberName,parameter)
            param=coder.descriptor.DataInterface.findByGraphicalNameAndSID(obj.fMF0Model,parameter.GraphicalName,parameter.SID);


            param.Implementation.Port=portName;





            newType=coder.descriptor.types.Struct(obj.fMF0Model);
            newType.Identifier=groupTypeName;
            newType.Name=groupTypeName;

            aggrEl=coder.descriptor.types.AggregateElement(obj.fMF0Model);
            aggrEl.Identifier=memberName;
            aggrEl.Type=param.Implementation.CodeType;
            newType.Elements=[newType.Elements,aggrEl];
            param.Implementation.CodeType=newType;
        end
        function obj=setIsMultiInstanceModelRef(obj,val)
            obj.fIsMultiInstanceModelRef=val;
        end
        function[subsysInt,functionInt]=getSubsystemFcnInterface(obj,subsysSID,fcnName)
            functionInt=[];
            subsysSID=obj.getFullBlockSID(subsysSID);
            subsysInt=coder.descriptor.SubsystemInterface.findSubsystemInterfaceBySubsystemSID(obj.fMF0Model,subsysSID);
            if isempty(subsysInt)
                return;
            end
            functionInt=subsysInt.findFunctionInterfaceByFunctionName(fcnName);
            if isempty(functionInt)
                return;
            end
        end
        function obj=updateRTMImplementationForSubsystemInterface(obj,subsysSID,fcnName,argIdx)
            if obj.fIsLibraryCodegen

                return;
            end
            [ssInt,functionInt]=obj.getSubsystemFcnInterface(subsysSID,fcnName);
            if isempty(functionInt)
                return;
            end


            if isempty(obj.fRTMForSubsystemInterface)
                obj.fRTMForSubsystemInterface=functionInt.ActualArgs(argIdx);
                rtm=obj.fRTMForSubsystemInterface.Implementation;
            else
                rtm=obj.fRTMForSubsystemInterface.Implementation;
            end
            if~isempty(rtm)

                actualArgs=functionInt.ActualArgs;
                if~isequal(rtm,actualArgs(argIdx).Implementation)
                    actualArgs(argIdx).destroy;
                    actualArgs(argIdx)=obj.fRTMForSubsystemInterface;
                end

                if~obj.fRTMAddedMap.isKey(subsysSID)
                    ssInt.InternalData.add(actualArgs(argIdx));
                    obj.fRTMAddedMap(subsysSID)=true;
                end
            end
        end
        function obj=setIsLibraryCodegen(obj,val)
            obj.fIsLibraryCodegen=val;
        end
        function obj=destroyAllSubsystemInterfaces(obj)
            obj.fFullModel.componentInterface.Subsystems.destroyAllContents;
        end
    end

end
