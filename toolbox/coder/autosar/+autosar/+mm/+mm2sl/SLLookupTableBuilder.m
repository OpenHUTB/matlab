classdef SLLookupTableBuilder<handle






    properties(Access=private)
        ChangeLogger;
        SLModelBuilder;
        SlModelName;
        SlLUTParam2BlkPropsMap;
        SlBreakpoint2BlkHsMap;
        SlTypeBuilder;
    end
    methods
        function this=SLLookupTableBuilder(changeLogger,slModelBuilder,slTypeBuilder,slModelName)
            this.ChangeLogger=changeLogger;
            this.SLModelBuilder=slModelBuilder;
            this.SlModelName=slModelName;
            this.SlTypeBuilder=slTypeBuilder;
            this.SlLUTParam2BlkPropsMap=containers.Map();
            this.SlBreakpoint2BlkHsMap=containers.Map();
        end

        function deferLookupTableBlockAddition(this,slLUTParamName,m3iAccess,currentSys,typeStr)




            if this.SlLUTParam2BlkPropsMap.isKey(slLUTParamName)
                existingBlkProps=this.SlLUTParam2BlkPropsMap(slLUTParamName);
                this.SlLUTParam2BlkPropsMap(slLUTParamName)=[existingBlkProps...
                ,struct('M3iAccess',m3iAccess,'CurrentSys',currentSys,'TypeStr',typeStr,'BlkH',[])];
            else
                this.SlLUTParam2BlkPropsMap(slLUTParamName)={struct('M3iAccess',m3iAccess,...
                'CurrentSys',currentSys,'TypeStr',typeStr,'BlkH',[])};
            end
        end

        function lookupTableBlockUpdate(this,slCalPrmName,m3iAccess,currentSys)

            [~,slCalPrm]=...
            autosar.utils.Workspace.objectExistsInModelScope(this.SlModelName,slCalPrmName);

            if~isa(slCalPrm,'Simulink.Parameter')


                return;
            end

            paramUsageInfo=Simulink.findVars(currentSys,'Name',slCalPrmName,...
            'SearchMethod','cached');
            lutBlkPaths=paramUsageInfo.Users;
            if isempty(lutBlkPaths)
                return;
            end

            m3iType=m3iAccess.instanceRef.DataElements.Type;
            expectedBlockType=this.getLookupTableBlockType(m3iType);
            for blkIdx=1:numel(lutBlkPaths)
                lutBlkH=get_param(lutBlkPaths{blkIdx},'Handle');
                blockType=get_param(lutBlkH,'BlockType');
                if~strcmp(blockType,expectedBlockType)
                    continue;
                end
                this.setFixAxisLookupTableBlockParameters(lutBlkH,m3iType,slCalPrm);
            end
        end

        function addLookupTableBlocks(this)





            for key=keys(this.SlLUTParam2BlkPropsMap)
                bpParamName=key{1};
                [paramExists,bpObj]=autosar.utils.Workspace.objectExistsInModelScope(this.SlModelName,bpParamName);

                if~paramExists
                    this.SlLUTParam2BlkPropsMap.remove(bpParamName);
                    continue;
                end

                if~isa(bpObj,'Simulink.Breakpoint')
                    continue;
                end

                blkPropsList=this.SlLUTParam2BlkPropsMap(bpParamName);
                updatedBlkPropsList=cell(numel(blkPropsList),1);
                for blkPropIndex=1:numel(blkPropsList)
                    blkProps=blkPropsList{blkPropIndex};
                    blkH=this.createLookupTableBlock(blkProps);


                    if this.setObjNameInBlockAndVerify(blkH,bpParamName)
                        m3iType=blkProps.M3iAccess.instanceRef.DataElements.Type;
                        isIFLBaseType=isa(m3iType.Axis.BaseType,'Simulink.metamodel.types.FloatingPoint');
                        this.setDefaultPreLookupBlockParameters(blkH,isIFLBaseType);
                        blkProps.BlkH=blkH;
                        if isKey(this.SlBreakpoint2BlkHsMap,bpParamName)
                            blks=this.SlBreakpoint2BlkHsMap(bpParamName);
                        else
                            blks=[];
                        end
                        this.SlBreakpoint2BlkHsMap(bpParamName)=[blks,blkH];
                    end
                    updatedBlkPropsList{blkPropIndex}=blkProps;
                end
                this.SlLUTParam2BlkPropsMap(bpParamName)=updatedBlkPropsList;
            end



            for key=keys(this.SlLUTParam2BlkPropsMap)
                lutParamName=key{1};
                [~,lutObj]=autosar.utils.Workspace.objectExistsInModelScope(this.SlModelName,lutParamName);
                if~this.canCreateLookupNDOrInterpBlock(lutParamName)
                    continue;
                end

                blkPropsList=this.SlLUTParam2BlkPropsMap(lutParamName);
                updatedBlkPropsList=cell(numel(blkPropsList),1);
                for blkPropIndex=1:numel(blkPropsList)
                    blkProps=blkPropsList{blkPropIndex};
                    blkH=this.createLookupTableBlock(blkProps);

                    this.setDefaultLookupTableBlockParameters(blkH,numel(lutObj.Breakpoints));


                    if this.setObjNameInBlockAndVerify(blkH,lutParamName)
                        blkProps.BlkH=blkH;
                    end
                    updatedBlkPropsList{blkPropIndex}=blkProps;
                end
                this.SlLUTParam2BlkPropsMap(lutParamName)=updatedBlkPropsList;
            end


            for key=keys(this.SlLUTParam2BlkPropsMap)
                slCalPrmName=key{1};
                [~,slCalPrm]=...
                autosar.utils.Workspace.objectExistsInModelScope(this.SlModelName,slCalPrmName);

                if~isa(slCalPrm,'Simulink.Parameter')



                    continue;
                end

                blkPropsList=this.SlLUTParam2BlkPropsMap(slCalPrmName);
                updatedBlkPropsList=cell(numel(blkPropsList),1);
                for blkPropIndex=1:numel(blkPropsList)
                    blkProps=blkPropsList{blkPropIndex};
                    m3iType=blkProps.M3iAccess.instanceRef.DataElements.Type;

                    if~autosar.mm.mm2sl.utils.LookupTableUtils.isFixAxisLUT(m3iType)


                        updatedBlkPropsList{blkPropIndex}=blkProps;
                        continue;
                    end

                    blkH=this.createLookupTableBlock(blkProps);
                    this.setFixAxisLookupTableBlockParameters(blkH,m3iType,slCalPrm);


                    set_param(blkH,'Table',slCalPrmName);
                    blkProps.BlkH=blkH;
                    updatedBlkPropsList{blkPropIndex}=blkProps;
                end
                this.SlLUTParam2BlkPropsMap(slCalPrmName)=updatedBlkPropsList;
            end
        end

        function connectLookupTableBlocks(this,slPort2RefBiMap,modelPeriodicRunnablesAs,updateMode)

            for key=keys(this.SlLUTParam2BlkPropsMap)
                lutParamName=key{1};
                [~,lutObj]=autosar.utils.Workspace.objectExistsInModelScope(this.SlModelName,lutParamName);
                blkPropsList=this.SlLUTParam2BlkPropsMap(lutParamName);
                for blkPropIndex=1:numel(blkPropsList)
                    blkProps=blkPropsList{blkPropIndex};
                    lutBlkH=blkProps.BlkH;
                    if isempty(lutBlkH)
                        continue;
                    end

                    if~updateMode&&strcmp(modelPeriodicRunnablesAs,'AtomicSubsystem')

                        refInstanceRef=blkProps.M3iAccess.instanceRef.SwDataDefPropsInstanceRef;
                        srcBlkHs=[];
                        for idx=1:refInstanceRef.size()
                            refInstanceRefIns=refInstanceRef.at(idx);
                            if isa(refInstanceRefIns,'Simulink.metamodel.arplatform.instance.FlowDataPortInstanceRef')...
                                &&isa(refInstanceRefIns.DataElements,'Simulink.metamodel.arplatform.interface.FlowData')
                                srcBlkHs=[srcBlkHs,slPort2RefBiMap.getRight(refInstanceRefIns)];%#ok<AGROW>
                            end
                        end
                        if~isempty(srcBlkHs)
                            this.connectLUTBlockToSrcBlock(lutBlkH,srcBlkHs);
                        end
                    end




                    blockType=get_param(lutBlkH,'BlockType');
                    cLine=get_param(lutBlkH,'LineHandles');
                    if~updateMode&&strcmp(blockType,'PreLookup')&&(cLine.Inport==-1)
                        blkName=get_param(lutBlkH,'Name');
                        parentModel=get_param(lutBlkH,'Parent');
                        sigSpecBlkPath=this.SLModelBuilder.createOrUpdateSimulinkBlock(parentModel,...
                        'SignalSpecification',[blkName,'_Spec'],[],...
                        [],{});
                        srcBlkPortH=get_param(sigSpecBlkPath,'PortHandles');
                        destBlkPortH=get_param(lutBlkH,'PortHandles');
                        autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentModel,srcBlkPortH.Outport,destBlkPortH.Inport(1));
                        autosar.mm.mm2sl.MRLayoutManager.homeBlk(sigSpecBlkPath);
                        [paramExists,bpObj]=autosar.utils.Workspace.objectExistsInModelScope(this.SlModelName,lutParamName);
                        if paramExists
                            set_param(sigSpecBlkPath,'OutDataTypeStr',bpObj.Breakpoints.DataType);
                        end
                    end

                    if isa(lutObj,'Simulink.LookupTable')&&...
                        strcmp(lutObj.BreakpointsSpecification,'Reference')
                        this.connectInterpolationBlock(lutBlkH,lutObj,this.SlBreakpoint2BlkHsMap)
                    end
                end
            end
        end
    end

    methods(Access=private)
        function isValid=canCreateLookupNDOrInterpBlock(this,lutParamName)



            isValid=true;

            [~,lutObj,isLutObjInModelWS]=...
            autosar.utils.Workspace.objectExistsInModelScope(this.SlModelName,lutParamName);
            isLutObjInGlobalWS=~isLutObjInModelWS;

            if~isa(lutObj,'Simulink.LookupTable')
                isValid=false;
                return;
            end

            if~strcmp(lutObj.BreakpointsSpecification,'Reference')
                return;
            end




            slBPNames=lutObj.Breakpoints;
            numberOfBreakpoints=numel(slBPNames);
            numberOfPreLookupBlks=0;
            for bpIndex=1:numberOfBreakpoints
                slBPName=slBPNames{bpIndex};
                if this.SlBreakpoint2BlkHsMap.isKey(slBPName)

                    numberOfPreLookupBlks=numberOfPreLookupBlks+1;
                end
                if isLutObjInGlobalWS



                    [~,~,isBPObjInModelWS]=...
                    autosar.utils.Workspace.objectExistsInModelScope(this.SlModelName,slBPName);
                    if isBPObjInModelWS
                        isValid=false;
                        return;
                    end
                end
            end

            if numberOfBreakpoints~=numberOfPreLookupBlks



                MSLDiagnostic('autosarstandard:importer:UnableToAddInterpolationBlock',...
                lutParamName).reportAsWarning;
                if this.SlLUTParam2BlkPropsMap.isKey(lutParamName)
                    this.SlLUTParam2BlkPropsMap.remove(lutParamName);
                end
                isValid=false;
                return;
            end
        end

        function success=setObjNameInBlockAndVerify(this,blkH,lutObjName)

            blockType=get_param(blkH,'BlockType');
            success=true;
            try
                if strcmp(blockType,'PreLookup')
                    set_param(blkH,'BreakpointsSpecification','Breakpoint object',...
                    'BreakpointObject',lutObjName);
                elseif strcmp(blockType,'Interpolation_n-D')
                    set_param(blkH,'TableSpecification','Lookup table object',...
                    'LookuptableObject',lutObjName);
                else
                    set_param(blkH,'DataSpecification','Lookup Table Object',...
                    'LookupTableObject',lutObjName);
                end
            catch ME
                success=false;
                if this.SlLUTParam2BlkPropsMap.isKey(lutObjName)
                    this.SlLUTParam2BlkPropsMap.remove(lutObjName);
                end
                if contains(ME.identifier,'NonMonotonic')






                    MSLDiagnostic('autosarstandard:importer:UnableToImportNonMonotonicLUT',...
                    blockType,lutObjName).reportAsWarning;
                    delete_block(blkH);
                else
                    rethrow(ME);
                end
            end
        end

        function blkH=createLookupTableBlock(this,blkProps)
            m3iType=blkProps.M3iAccess.instanceRef.DataElements.Type;
            blockType=this.getLookupTableBlockType(m3iType);
            lutBlkPath=this.SLModelBuilder.createOrUpdateSimulinkBlock(blkProps.CurrentSys,...
            blockType,blkProps.M3iAccess.Name,blkProps.TypeStr,[],{});
            blkH=get_param(lutBlkPath,'Handle');
        end

        function setDefaultPreLookupBlockParameters(this,blkH,isIFLBaseType)
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            blkH,'BreakpointDataTypeStr','Inherit: Inherit from ''Breakpoint data''');
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            blkH,'ExtrapMethod','Clip');
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            blkH,'UseLastBreakpoint','on');
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            blkH,'RndMeth','Round');

            if isIFLBaseType

                this.SLModelBuilder.set_param(this.ChangeLogger,...
                blkH,'IndexDataTypeStr','uint32');
                this.SLModelBuilder.set_param(this.ChangeLogger,...
                blkH,'FractionDataTypeStr','single');
            else

                this.SLModelBuilder.set_param(this.ChangeLogger,...
                blkH,'IndexDataTypeStr','uint16');
                this.SLModelBuilder.set_param(this.ChangeLogger,...
                blkH,'FractionDataTypeStr','fixdt(0,16,16)');
            end
        end

        function setDefaultLookupTableBlockParameters(this,lutBlkH,numberOfAxes)
            blockType=get_param(lutBlkH,'BlockType');
            if strcmp(blockType,'Lookup_n-D')
                this.SLModelBuilder.set_param(this.ChangeLogger,...
                lutBlkH,'InputSameDT','off');
                this.SLModelBuilder.set_param(this.ChangeLogger,...
                lutBlkH,'UseLastTableValue','on');
            else
                this.SLModelBuilder.set_param(this.ChangeLogger,...
                lutBlkH,'ValidIndexMayReachLast','on');
            end
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            lutBlkH,'NumberOfTableDimensions',num2str(numberOfAxes));
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            lutBlkH,'OutDataTypeStr','Inherit: Inherit from ''Table data''');
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            lutBlkH,'TableDataTypeStr','Inherit: Inherit from ''Table data''');
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            lutBlkH,'InterpMethod','Linear point-slope');
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            lutBlkH,'ExtrapMethod','Clip');
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            lutBlkH,'InternalRulePriority','Precision');
            this.SLModelBuilder.set_param(this.ChangeLogger,...
            lutBlkH,'RndMeth','Round');
        end

        function setFixAxisLookupTableBlockParameters(this,lutBlkH,m3iLUTType,slCalPrm)
            blockType=get_param(lutBlkH,'BlockType');
            assert(strcmp(blockType,'Lookup_n-D'),'Expect block type to be Lookup_n-D');

            numberOfAxes=m3iLUTType.Axes.size();
            this.setDefaultLookupTableBlockParameters(lutBlkH,numberOfAxes);

            this.SLModelBuilder.set_param(this.ChangeLogger,...
            lutBlkH,'DataSpecification','Table and breakpoints');



            if this.hasAxisWithListCategory(m3iLUTType)
                this.SLModelBuilder.set_param(this.ChangeLogger,...
                lutBlkH,'BreakpointsSpecification','Explicit values');
                this.SLModelBuilder.set_param(this.ChangeLogger,...
                lutBlkH,'IndexSearchMethod','Linear search');
                for axisIdx=1:numberOfAxes
                    m3iAxis=m3iLUTType.Axes.at(axisIdx);
                    listValues=this.convertToListValues(m3iAxis);

                    bpIdx=autosar.mm.util.getLookupTableMemberSwappedIndex(numberOfAxes,axisIdx);
                    bpParamStr=this.getBreakpointParamStr(bpIdx);
                    this.SLModelBuilder.set_param(this.ChangeLogger,...
                    lutBlkH,bpParamStr,mat2str(listValues));
                end
            else
                this.SLModelBuilder.set_param(this.ChangeLogger,...
                lutBlkH,'BreakpointsSpecification','Even spacing');
                for axisIdx=1:numberOfAxes
                    m3iAxis=m3iLUTType.Axes.at(axisIdx);
                    bpIdx=autosar.mm.util.getLookupTableMemberSwappedIndex(numberOfAxes,axisIdx);


                    [offset,distance]=this.getOffsetAndDistance(m3iAxis);
                    firstPointParamStr=this.getBreakpointParamStr(bpIdx,'FirstPoint');
                    this.SLModelBuilder.set_param(this.ChangeLogger,...
                    lutBlkH,firstPointParamStr,mat2str(offset));

                    spacingParamStr=this.getBreakpointParamStr(bpIdx,'Spacing');
                    this.SLModelBuilder.set_param(this.ChangeLogger,...
                    lutBlkH,spacingParamStr,mat2str(distance));
                end
            end


            for axisIdx=1:numberOfAxes
                m3iAxisType=m3iLUTType.Axes.at(axisIdx);
                breakpointDataTypeStr=...
                this.SlTypeBuilder.getSLBlockDataTypeStr(m3iAxisType);
                bpIdx=autosar.mm.util.getLookupTableMemberSwappedIndex(numberOfAxes,axisIdx);

                bpDataTypeParamStr=this.getBreakpointParamStr(bpIdx,'DataTypeStr');
                this.SLModelBuilder.set_param(this.ChangeLogger,...
                lutBlkH,bpDataTypeParamStr,breakpointDataTypeStr);

                [minMaxIsSupported,minVal,maxVal]=...
                autosar.mm.util.MinMaxHelper.getMinMaxValuesFromM3iType(m3iAxisType,slCalPrm);
                if minMaxIsSupported
                    bpMinParamStr=this.getBreakpointParamStr(bpIdx,'Min');
                    this.SLModelBuilder.set_param(this.ChangeLogger,...
                    lutBlkH,bpMinParamStr,mat2str(minVal));

                    bpMaxParamStr=this.getBreakpointParamStr(bpIdx,'Max');
                    this.SLModelBuilder.set_param(this.ChangeLogger,...
                    lutBlkH,bpMaxParamStr,mat2str(maxVal));
                end
            end
        end
    end
    methods(Access=private,Static)
        function connectInterpolationBlock(interpBlkH,lutObj,slBreakpoint2BlkHsMap)


            interpBlkPortH=get_param(interpBlkH,'PortHandles');
            interpBlkParent=get_param(interpBlkH,'Parent');
            slBreakpoints=lutObj.Breakpoints;


            for bpIdx=1:numel(slBreakpoints)
                interpBlkIndexPortH=interpBlkPortH.Inport(bpIdx*2-1);
                interpBlkFractionPortH=interpBlkPortH.Inport(bpIdx*2);

                preLookupBlks=slBreakpoint2BlkHsMap(slBreakpoints{bpIdx});
                for preLookupBlkIdx=1:numel(preLookupBlks)
                    preLookupBlk=preLookupBlks(preLookupBlkIdx);


                    if strcmp(interpBlkParent,get_param(preLookupBlk,'Parent'))
                        prelookupH=get_param(preLookupBlk,'PortHandles');


                        autosar.mm.mm2sl.layout.LayoutHelper.addLine(interpBlkParent,...
                        prelookupH.Outport(1),interpBlkIndexPortH);
                        autosar.mm.mm2sl.layout.LayoutHelper.addLine(interpBlkParent,...
                        prelookupH.Outport(2),interpBlkFractionPortH);
                        break;
                    else


                    end
                end
            end
        end


        function connectLUTBlockToSrcBlock(lutBlkH,srcBlkHs)
            destBlkPortH=get_param(lutBlkH,'PortHandles');
            blockType=get_param(lutBlkH,'BlockType');
            parentSystem=get_param(lutBlkH,'Parent');

            if strcmp(blockType,'PreLookup')
                for idx=1:numel(srcBlkHs)
                    srcBlkH=srcBlkHs(idx);
                    if autosar.mm.mm2sl.SLLookupTableBuilder.connectLUTBlkInportToSrcBlkOutport(...
                        parentSystem,destBlkPortH.Inport(1),srcBlkH)
                        break;
                    end
                end
            elseif strcmp(blockType,'Lookup_n-D')
                for idx=1:numel(srcBlkHs)
                    if idx>numel(destBlkPortH.Inport)


                        break;
                    end
                    srcBlkH=srcBlkHs(idx);
                    destBlkInportH=destBlkPortH.Inport(idx);
                    autosar.mm.mm2sl.SLLookupTableBuilder.connectLUTBlkInportToSrcBlkOutport(...
                    parentSystem,destBlkInportH,srcBlkH);
                end
            end
        end


        function success=connectLUTBlkInportToSrcBlkOutport(parentSystem,lutBlkInportH,srcBlkH)
            success=false;

            srcBlkPortH=get_param(srcBlkH,'PortHandles');
            if~isempty(srcBlkPortH.Outport)


                outLine=get(srcBlkPortH.Outport,'Line');
                portHandle=get(outLine,'DstPortHandle');
                portNum=get(portHandle,'PortNumber');
                inputPortInsideParent=find_system(parentSystem,'SearchDepth',1,...
                'BlockType','Inport','Port',num2str(portNum));
                if~isempty(inputPortInsideParent)
                    inputPortHandles=get_param(inputPortInsideParent{1},'PortHandles');
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentSystem,inputPortHandles.Outport,lutBlkInportH);
                    success=true;
                end
            end
        end

        function blockType=getLookupTableBlockType(m3iType)
            if isa(m3iType,'Simulink.metamodel.types.LookupTableType')
                isSharedAxis=m3iType.Axes.at(1).SharedAxis.isvalid();
                if isSharedAxis
                    blockType='Interpolation_n-D';
                else
                    blockType='Lookup_n-D';
                end
            elseif isa(m3iType,'Simulink.metamodel.types.SharedAxisType')
                blockType='PreLookup';
            end
        end

        function isTrue=hasAxisWithListCategory(m3iLUTType)


            isTrue=false;
            for axisIdx=1:m3iLUTType.Axes.size()
                m3iAxis=m3iLUTType.Axes.at(axisIdx);
                if m3iAxis.SwGenericAxisParamType.at(1).Category==...
                    Simulink.metamodel.types.SwGenericAxisParamTypeCategory.List
                    isTrue=true;
                    break;
                end
            end
        end

        function listValues=convertToListValues(m3iFixAxis)


            axisDimensions=m3iFixAxis.Dimensions;
            listValues=zeros(1,axisDimensions);

            isListCategory=m3iFixAxis.SwGenericAxisParamType.at(1).Category==...
            Simulink.metamodel.types.SwGenericAxisParamTypeCategory.List;
            if isListCategory
                for valIdx=1:axisDimensions
                    listValues(valIdx)=m3iFixAxis.Vf.at(valIdx);
                end
            else

                [offset,distance]=...
                autosar.mm.mm2sl.SLLookupTableBuilder.getOffsetAndDistance(m3iFixAxis);
                listValues=zeros(1,axisDimensions);
                listValues(1)=offset;
                for valIdx=2:axisDimensions
                    listValues(valIdx)=listValues(valIdx-1)+distance;
                end
            end
        end

        function[offset,distance]=getOffsetAndDistance(m3iFixAxis)


            distance=0;offset=0;
            for paramTypeIndex=1:m3iFixAxis.SwGenericAxisParamType.size()
                switch m3iFixAxis.SwGenericAxisParamType.at(paramTypeIndex).Category
                case Simulink.metamodel.types.SwGenericAxisParamTypeCategory.Distance
                    distance=m3iFixAxis.Vf.at(paramTypeIndex);
                case Simulink.metamodel.types.SwGenericAxisParamTypeCategory.Shift
                    distance=pow2(m3iFixAxis.Vf.at(paramTypeIndex));
                case Simulink.metamodel.types.SwGenericAxisParamTypeCategory.Offset
                    offset=m3iFixAxis.Vf.at(paramTypeIndex);
                otherwise
                    assert(false,sprintf('Unexpected swGenericAxisParam category'));
                end
            end
        end

        function bpParamStr=getBreakpointParamStr(bpIndex,suffix)
            if nargin<2
                suffix='';
            end
            bpForDimensionStr=strcat('BreakpointsForDimension',num2str(bpIndex));
            bpParamStr=strcat(bpForDimensionStr,suffix);
        end
    end
end


