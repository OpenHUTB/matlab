classdef fmi2ModelDescriptionWriter<handle
    properties(Access=private)
ModelInfoUtils
fileName
varStepFMUPortIdx
    end


    methods(Access=public)
        function this=fmi2ModelDescriptionWriter(modelInfoUtils,fileName)
            this.fileName=fileName;
            this.ModelInfoUtils=modelInfoUtils;
            this.varStepFMUPortIdx=-1;

        end
    end



    methods(Access=public)
        function write(this)
            import matlab.io.xml.dom.*
            rootNode=Document('fmiModelDescription');
            mdNode=getDocumentElement(rootNode);

            this.writeHeader(mdNode);
            if strcmp(this.ModelInfoUtils.FMUType,'CS')
                this.writeCoSimulationElement(mdNode,rootNode);
            else
                this.writeModelExchangeElement(mdNode,rootNode);
            end
            this.writeUnitDefinitionsElement(mdNode,rootNode);
            this.writeTypeDefinitionsElement(mdNode,rootNode);
            this.writeLogCategoriesElement(mdNode,rootNode);
            this.writeDefaultExperimentElement(mdNode,rootNode);
            this.writeVendorAnnotationsElement(mdNode,rootNode);
            this.writeModelVariablesElement(mdNode,rootNode);
            this.writeModelStructureElement(mdNode,rootNode);


            writer=DOMWriter;
            writer.Configuration.FormatPrettyPrint=true;
            writeToURI(writer,rootNode,this.fileName,'UTF-8');
        end

        function writeHeader(this,mdNode)
            mdNode.setAttribute('fmiVersion','2.0');
            mdNode.setAttribute('modelName',this.ModelInfoUtils.ModelIdentifier);
            mdNode.setAttribute('guid',['{',this.ModelInfoUtils.GUID,'}']);
            if~isempty(this.ModelInfoUtils.Description)
                mdNode.setAttribute('description',this.ModelInfoUtils.Description);
            end
            mdNode.setAttribute('variableNamingConvention','structured');
            mdNode.setAttribute('version',this.ModelInfoUtils.Version);
            mdNode.setAttribute('generationTool',this.ModelInfoUtils.GenerationTool);
            mdNode.setAttribute('generationDateAndTime',this.ModelInfoUtils.GenerationDateAndTime);

            if~isempty(this.ModelInfoUtils.Author)
                mdNode.setAttribute('author',this.ModelInfoUtils.Author);
            end
            if~isempty(this.ModelInfoUtils.Copyright)
                mdNode.setAttribute('copyright',this.ModelInfoUtils.Copyright);
            end
            if~isempty(this.ModelInfoUtils.License)
                mdNode.setAttribute('license',this.ModelInfoUtils.License);
            end
            mdNode.setAttribute('numberOfEventIndicators','0');
        end

        function writeCoSimulationElement(this,parentNode,rootNode)
            cosimNode=rootNode.createElement('CoSimulation');
            cosimNode.setAttribute('modelIdentifier',this.ModelInfoUtils.ModelIdentifier);
            if this.ModelInfoUtils.canBeInstantiatedOnlyOncePerProcessOverride
                cosimNode.setAttribute('canBeInstantiatedOnlyOncePerProcess','false');
            else
                cosimNode.setAttribute('canBeInstantiatedOnlyOncePerProcess','true');
            end
            cosimNode.setAttribute('canNotUseMemoryManagementFunctions','true');
            if this.ModelInfoUtils.isFixedStepSolver
                cosimNode.setAttribute('canHandleVariableCommunicationStepSize','false');
            else
                cosimNode.setAttribute('canHandleVariableCommunicationStepSize','true');
            end
            if~isempty(this.ModelInfoUtils.SourceFileList)
                sfNode=rootNode.createElement('SourceFiles');
                fNodes=cellfun(@(x)rootNode.createElement('File'),this.ModelInfoUtils.SourceFileList,'un',0);
                cellfun(@(y,x)y.setAttribute("name",x),fNodes,this.ModelInfoUtils.SourceFileList,'un',0);
                cellfun(@(x)sfNode.appendChild(x),fNodes,'un',0);
                cosimNode.appendChild(sfNode);
            end

            parentNode.appendChild(cosimNode);
        end

        function writeModelExchangeElement(this,parentNode,rootNode)
            mdlexNode=rootNode.createElement('ModelExchange');
            mdlexNode.setAttribute('modelIdentifier',this.ModelInfoUtils.ModelIdentifier);
            if this.ModelInfoUtils.canBeInstantiatedOnlyOncePerProcessOverride
                mdlexNode.setAttribute('canBeInstantiatedOnlyOncePerProcess','false');
            else
                mdlexNode.setAttribute('canBeInstantiatedOnlyOncePerProcess','true');
            end
            mdlexNode.setAttribute('canNotUseMemoryManagementFunctions','true');
            if~isempty(this.ModelInfoUtils.SourceFileList)
                sfNode=rootNode.createElement('SourceFiles');
                fNodes=cellfun(@(x)rootNode.createElement('File'),this.ModelInfoUtils.SourceFileList,'un',0);
                cellfun(@(y,x)y.setAttribute("name",x),fNodes,this.ModelInfoUtils.SourceFileList,'un',0);
                cellfun(@(x)sfNode.appendChild(x),fNodes,'un',0);
                mdlexNode.appendChild(sfNode);
            end

            parentNode.appendChild(mdlexNode);
        end

        function writeTypeDefinitionsElement(this,parentNode,rootNode)
            if this.ModelInfoUtils.EnumTypeMap.isempty
                return;
            end
            typedefNode=rootNode.createElement('TypeDefinitions');
            for enumName=this.ModelInfoUtils.EnumTypeMap.keys
                enumType=this.ModelInfoUtils.EnumTypeMap(enumName{1});
                simTypeNode=rootNode.createElement('SimpleType');
                simTypeNode.setAttribute('name',this.xmlCharEscape(enumName{1}));
                if~isempty(enumType.Strings)
                    enumNode=rootNode.createElement('Enumeration');
                    for i=1:length(enumType.Strings)
                        itemNode=rootNode.createElement('Item');
                        itemNode.setAttribute('name',this.xmlCharEscape(enumType.Strings{i}));
                        itemNode.setAttribute('value',this.xmlCharEscape(num2str(enumType.Values(i))));
                        enumNode.appendChild(itemNode);
                    end
                    simTypeNode.appendChild(enumNode);
                end
                typedefNode.appendChild(simTypeNode);
            end
            parentNode.appendChild(typedefNode);
        end

        function writeUnitDefinitionsElement(this,parentNode,rootNode)
            if this.ModelInfoUtils.UnitDefinitions.Count==0

                return;
            end

            unitdefNode=rootNode.createElement('UnitDefinitions');
            for u=this.ModelInfoUtils.UnitDefinitions.keys
                uStruct=this.ModelInfoUtils.UnitDefinitions(u{1});

                unitNode=rootNode.createElement('Unit');
                unitNode.setAttribute('name',this.xmlCharEscape(uStruct.name));
                unitdefNode.appendChild(unitNode);
            end
            parentNode.appendChild(unitdefNode);
        end

        function writeLogCategoriesElement(this,parentNode,rootNode)
            if~isempty(this.ModelInfoUtils.logCategory)
                lcNode=rootNode.createElement('LogCategories');
                for name=this.ModelInfoUtils.logCategory.keys
                    leNode=rootNode.createElement('Category');
                    leNode.setAttribute('name',name{1});
                    leNode.setAttribute('description',this.ModelInfoUtils.logCategory(name{1}));
                    lcNode.appendChild(leNode);
                end
                parentNode.appendChild(lcNode);
            end
        end

        function writeDefaultExperimentElement(this,parentNode,rootNode)
            deNode=rootNode.createElement('DefaultExperiment');
            if~isinf(this.ModelInfoUtils.StartTime)
                deNode.setAttribute('startTime',num2str(this.ModelInfoUtils.StartTime,'%.16g'));
            end
            if~isinf(this.ModelInfoUtils.StopTime)
                deNode.setAttribute('stopTime',num2str(this.ModelInfoUtils.StopTime,'%.16g'));
            end

            if this.ModelInfoUtils.isFixedStepSolver
                deNode.setAttribute('stepSize',num2str(this.ModelInfoUtils.FixedStepSize,'%.16g'));
            end
            parentNode.appendChild(deNode);
        end

        function writeVendorAnnotationsElement(this,parentNode,rootNode)
            vaNode=rootNode.createElement('VendorAnnotations');
            toolNode=rootNode.createElement('Tool');
            toolNode.setAttribute('name','Simulink');
            slNode=rootNode.createElement('Simulink');
            icNode=rootNode.createElement('ImportCompatibility');
            icNode.setAttribute('requireRelease',this.ModelInfoUtils.CompatibleRelease);
            icNode.setAttribute('requireMATLABOnPath',this.ModelInfoUtils.requireMATLAB);
            slNode.appendChild(icNode);

            if isprop(this.ModelInfoUtils,'ProjectFileName')
                spNode=rootNode.createElement('SimulinkProject');
                spNode.setAttribute('projectName',this.ModelInfoUtils.ProjectFileName);
                spNode.setAttribute('modelName',this.ModelInfoUtils.ModelFileName);
                slNode.appendChild(spNode);
            end

            siNode=rootNode.createElement('SimulinkModelInterface');
            for i=1:length(this.ModelInfoUtils.InportList)
                p=this.ModelInfoUtils.InportList(i);
                pNode=rootNode.createElement('Inport');
                pNode.setAttribute('blockPath',p.blockPath);
                pNode.setAttribute('portName',p.graphicalName);
                pNode.setAttribute('uniquePortName',this.ModelInfoUtils.graphicalNameMap([strtrim(p.graphicalName),', input']));
                pNode.setAttribute('portNumber',p.portNumber);
                if isfield(p,'tag')&&~isempty(p.tag)
                    pNode.setAttribute('tag',p.tag);
                end
                pNode.setAttribute('sampleTime',p.sampleTime);
                pNode.setAttribute('dimension',p.dimension);
                pNode.setAttribute('dataType',p.dataType);
                pNode.setAttribute('unit',p.unit);
                siNode.appendChild(pNode);
            end
            for i=1:length(this.ModelInfoUtils.OutportList)
                p=this.ModelInfoUtils.OutportList(i);
                pNode=rootNode.createElement('Outport');
                pNode.setAttribute('blockPath',p.blockPath);
                pNode.setAttribute('portName',p.graphicalName);
                pNode.setAttribute('uniquePortName',this.ModelInfoUtils.graphicalNameMap([strtrim(p.graphicalName),', output']));
                pNode.setAttribute('portNumber',p.portNumber);
                if isfield(p,'tag')&&~isempty(p.tag)
                    pNode.setAttribute('tag',p.tag);
                end
                pNode.setAttribute('sampleTime',p.sampleTime);
                pNode.setAttribute('dimension',p.dimension);
                pNode.setAttribute('dataType',p.dataType);
                pNode.setAttribute('unit',p.unit);
                siNode.appendChild(pNode);
            end
            if isprop(this.ModelInfoUtils,"ModelArgumentList")
                for i=1:length(this.ModelInfoUtils.ModelArgumentList)
                    p=this.ModelInfoUtils.ModelArgumentList(i);
                    pNode=rootNode.createElement('ModelArgument');
                    pNode.setAttribute('tag',p.tag);
                    pNode.setAttribute('dimension',p.dimension);
                    siNode.appendChild(pNode);
                end
            end
            assert(length(this.ModelInfoUtils.BusObjectList)==length(this.ModelInfoUtils.BusNameList));
            for i=1:length(this.ModelInfoUtils.BusObjectList)
                p=this.ModelInfoUtils.BusObjectList{i};
                pName=this.ModelInfoUtils.BusNameList{i};
                pNode=rootNode.createElement('BusObject');
                pNode.setAttribute('name',pName);
                pNode.setAttribute('description',p.Description);
                pNode.setAttribute('dataScope',p.DataScope);
                pNode.setAttribute('headerFile',p.HeaderFile);
                pNode.setAttribute('alignment',num2str(p.Alignment));
                if isprop(this.ModelInfoUtils,"busObjSizeMap")&&isKey(this.ModelInfoUtils.busObjSizeMap,pName)
                    pNode.setAttribute('signalSize',num2str(this.ModelInfoUtils.busObjSizeMap(pName)));
                end
                if isprop(this.ModelInfoUtils,"busEleInfoTypeMap")
                    busEleInfo=this.ModelInfoUtils.busEleInfoTypeMap(pName);
                else
                    busEleInfo={};
                end
                for j=1:length(p.Elements)
                    qNode=rootNode.createElement('BusElement');
                    q=p.Elements(j);
                    qNode.setAttribute('name',q.Name);
                    qNode.setAttribute('complexity',q.Complexity);
                    qNode.setAttribute('dimensions',num2str(q.Dimensions));
                    qNode.setAttribute('dataType',q.DataType);
                    qNode.setAttribute('min',num2str(q.Min));
                    qNode.setAttribute('max',num2str(q.Max));
                    qNode.setAttribute('dimensionsMode',q.DimensionsMode);
                    qNode.setAttribute('unit',q.Unit);
                    qNode.setAttribute('description',q.Description);
                    if~isempty(busEleInfo)
                        qNode.setAttribute('signalSize',num2str(busEleInfo(j).Size));
                        qNode.setAttribute('signalOffset',num2str(busEleInfo(j).Offset));
                    end
                    pNode.appendChild(qNode);
                end
                siNode.appendChild(pNode);
            end
            slNode.appendChild(siNode);

            if isprop(this.ModelInfoUtils,'AddProtectedModel')&&...
                this.ModelInfoUtils.AddProtectedModel
                pMNode=rootNode.createElement('ProtectedModel');
                platformStr=computer('arch');
                switch platformStr
                case 'glnxa64'
                    platformStr='linux64';
                case 'maci64'
                    platformStr='darwin64';
                end
                pMNode.setAttribute('platform',platformStr);
                slNode.appendChild(pMNode);
            end
            toolNode.appendChild(slNode);
            vaNode.appendChild(toolNode);
            parentNode.appendChild(vaNode);
        end

        function writeModelVariablesElement(this,parentNode,rootNode)
            mvNode=rootNode.createElement('ModelVariables');
            for i=1:length(this.ModelInfoUtils.ModelVariableList)
                it=this.ModelInfoUtils.ModelVariableList(i);
                if strcmp(it.xml_name,'ToolCouplingFMU_VariableStepSolver_Inport')
                    this.varStepFMUPortIdx=i;
                    continue;
                end

                varNode=rootNode.createElement('ScalarVariable');
                varNode.setAttribute('name',it.xml_name);
                varNode.setAttribute('valueReference',num2str(it.vr));
                varNode.setAttribute('causality',it.causality);
                varNode.setAttribute('variability',it.variability);
                if~isempty(it.initial)&&~strcmp(it.initial,'(null)')
                    varNode.setAttribute('initial',it.initial);
                end
                varNode.setAttribute('description',it.description);

                subNode1=rootNode.createElement(it.dt);
                if~isempty(it.start)&&~strcmp(it.start,'(null)')
                    subNode1.setAttribute('start',it.start);
                end
                if~isempty(it.unit)&&~strcmp(it.unit,'(null)')&&strcmp(it.dt,'Real')
                    subNode1.setAttribute('unit',it.unit);
                end
                if isfield(it,'min')
                    if~isempty(it.min)&&~strcmp(it.min,'(null)')&&(strcmp(it.dt,'Real')||strcmp(it.dt,'Integer'))
                        subNode1.setAttribute('min',it.min);
                    end
                end
                if isfield(it,'max')
                    if~isempty(it.max)&&~strcmp(it.max,'(null)')&&(strcmp(it.dt,'Real')||strcmp(it.dt,'Integer'))
                        subNode1.setAttribute('max',it.max);
                    end
                end
                if strcmp(it.dt,'Enumeration')
                    subNode1.setAttribute('declaredType',it.enumName);
                end

                varNode.appendChild(subNode1);
                varNode.appendChild(subNode1);
                svIdx=i;
                if this.varStepFMUPortIdx>=0



                    svIdx=i-1;
                end
                commNode=rootNode.createComment(['Index = ',num2str(svIdx)]);
                varNode.appendChild(commNode);
                if isfield(it,'tag')&&~isempty(it.tag)
                    subNode2=rootNode.createElement('Annotations');
                    subNode3=rootNode.createElement('Tool');
                    subNode3.setAttribute('name','Simulink');
                    subNode4=rootNode.createElement('Data');
                    subNode4.setAttribute('tag',it.tag);
                    subNode4.setAttribute('elementAccess',it.elementAccess);
                    subNode3.appendChild(subNode4);
                    subNode2.appendChild(subNode3);
                    varNode.appendChild(subNode2);
                end

                mvNode.appendChild(varNode);
            end
            parentNode.appendChild(mvNode);
        end

        function writeModelStructureElement(this,parentNode,rootNode)
            msNode=rootNode.createElement('ModelStructure');

            outputNode=rootNode.createElement('Outputs');
            initNode=rootNode.createElement('InitialUnknowns');
            derivativeNode=rootNode.createElement('Derivatives');

            for i=1:length(this.ModelInfoUtils.ModelVariableList)
                it=this.ModelInfoUtils.ModelVariableList(i);
                svIdx=i;
                if this.varStepFMUPortIdx>=0&&i>this.varStepFMUPortIdx



                    svIdx=i-1;
                end
                if strcmp(it.causality,'output')
                    pNode=rootNode.createElement('Unknown');
                    pNode.setAttribute('index',num2str(svIdx));

                    outputNode.appendChild(pNode);
                end

                if strcmp(it.causality,'output')&&strcmp(it.initial,'calculated')
                    pNode=rootNode.createElement('Unknown');
                    pNode.setAttribute('index',num2str(svIdx));
                    if this.ModelInfoUtils.initialUnknownDependenciesOverride
                        pNode.setAttribute('dependencies',"");
                    end





                    initNode.appendChild(pNode);
                end
                if strcmp(it.causality,'local')
                    pNode=rootNode.createElement('Unknown');
                    pNode.setAttribute('index',num2str(svIdx));
                    initNode.appendChild(pNode);
                end
                if it.is_derivative







                    pNode=rootNode.createElement('Unknown');
                    pNode.setAttribute('index',num2str(svIdx));
                    derivativeNode.appendChild(pNode);
                end
            end
            msNode.appendChild(outputNode);
            msNode.appendChild(initNode);
            if derivativeNode.getChildElementCount>0
                msNode.appendChild(derivativeNode);
            end

            parentNode.appendChild(msNode);
        end

    end

    methods(Static)
        function str=xmlCharEscape(str)

            new_line=sprintf('\n');
            if(~isempty(str))
                str=strrep(str,new_line,'. ');
                str=strrep(str,'. . ','. ');

                str=strrep(str,'&','&amp;');
                str=strrep(str,'"','&quot;');
                str=strrep(str,'''','&apos;');
                str=strrep(str,'<','&lt;');
                str=strrep(str,'>','&gt;');
            end
        end
    end
end

