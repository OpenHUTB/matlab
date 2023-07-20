

classdef CoSimToolCouplingFMU2XMLWriter<handle
    properties(Access=private)
ModelInfoUtils
fileName
varStepFMUPortSkipped

    end


    methods(Access=public)
        function this=CoSimToolCouplingFMU2XMLWriter(modelInfoUtils,fileName)
            this.fileName=fileName;
            this.ModelInfoUtils=modelInfoUtils;
            this.varStepFMUPortSkipped=false;

        end
    end



    methods(Access=public)
        function write(this)
            import matlab.io.xml.dom.*
            rootNode=Document('fmiModelDescription');
            mdNode=getDocumentElement(rootNode);
            mdNode.setAttribute('fmiVersion','2.0');
            mdNode.setAttribute('modelName',this.ModelInfoUtils.getName);
            mdNode.setAttribute('guid',this.ModelInfoUtils.getGUID);
            mdNode.setAttribute('description',this.ModelInfoUtils.getDescription);
            mdNode.setAttribute('author',this.ModelInfoUtils.getAuthor);
            mdNode.setAttribute('variableNamingConvention','structured');
            mdNode.setAttribute('version',this.ModelInfoUtils.getVersion);
            mdNode.setAttribute('copyright',this.ModelInfoUtils.getCopyright);
            mdNode.setAttribute('license',this.ModelInfoUtils.getLicense);
            mdNode.setAttribute('generationTool',this.ModelInfoUtils.getGenerationTool);
            mdNode.setAttribute('generationDateAndTime',this.ModelInfoUtils.getGenerationDateAndTime);

            this.addCoSimulationElement(mdNode,rootNode);
            this.addUnitDefinitionsElement(mdNode,rootNode);
            this.addTypeDefinitionsElement(mdNode,rootNode);
            this.addLogCategoriesElement(mdNode,rootNode);
            this.addDefaultExperimentElement(mdNode,rootNode);
            this.addVendorAnnotationsElement(mdNode,rootNode);
            this.addModelVariablesElement(mdNode,rootNode);
            this.addModelStructureElement(mdNode,rootNode);


            writer=DOMWriter;
            writer.Configuration.FormatPrettyPrint=true;
            writeToURI(writer,rootNode,this.fileName,'UTF-8');
        end

        function addCoSimulationElement(this,parentNode,rootNode)
            cosimNode=rootNode.createElement('CoSimulation');
            cosimNode.setAttribute('modelIdentifier',this.ModelInfoUtils.getModelIdentifier);
            cosimNode.setAttribute('canBeInstantiatedOnlyOncePerProcess','false');
            cosimNode.setAttribute('canNotUseMemoryManagementFunctions','true');
            cosimNode.setAttribute('canHandleVariableCommunicationStepSize','true');

            parentNode.appendChild(cosimNode);
        end

        function addVendorAnnotationsElement(this,parentNode,rootNode)
            vaNode=rootNode.createElement('VendorAnnotations');
            toolNode=rootNode.createElement('Tool');
            toolNode.setAttribute('name','Simulink');
            slNode=rootNode.createElement('Simulink');
            icNode=rootNode.createElement('ImportCompatibility');
            icNode.setAttribute('requireRelease',this.ModelInfoUtils.getCompatibleRelease);
            icNode.setAttribute('requireMATLABOnPath','yes');
            slNode.appendChild(icNode);

            spNode=rootNode.createElement('SimulinkProject');
            spNode.setAttribute('projectName',this.ModelInfoUtils.getProjectFileName);
            spNode.setAttribute('modelName',this.ModelInfoUtils.getModelFileName);
            slNode.appendChild(spNode);

            siNode=rootNode.createElement('SimulinkModelInterface');
            for i=1:length(this.ModelInfoUtils.InportList)
                p=this.ModelInfoUtils.InportList(i);
                pNode=rootNode.createElement('Inport');
                pNode.setAttribute('blockPath',p.blockPath);
                pNode.setAttribute('portNumber',p.portNumber);
                pNode.setAttribute('tag',p.tag);
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
                pNode.setAttribute('portNumber',p.portNumber);
                pNode.setAttribute('tag',p.tag);
                pNode.setAttribute('sampleTime',p.sampleTime);
                pNode.setAttribute('dimension',p.dimension);
                pNode.setAttribute('dataType',p.dataType);
                pNode.setAttribute('unit',p.unit);
                siNode.appendChild(pNode);
            end
            for i=1:length(this.ModelInfoUtils.ModelArgumentList)
                p=this.ModelInfoUtils.ModelArgumentList(i);
                pNode=rootNode.createElement('ModelArgument');
                pNode.setAttribute('tag',p.tag);
                pNode.setAttribute('dimension',p.dimension);
                siNode.appendChild(pNode);
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
                if isKey(this.ModelInfoUtils.busObjSizeMap,pName)
                    pNode.setAttribute('signalSize',num2str(this.ModelInfoUtils.busObjSizeMap(pName)));
                end
                busEleInfo=this.ModelInfoUtils.busEleInfoTypeMap(pName);
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
                    qNode.setAttribute('signalSize',num2str(busEleInfo(j).Size));
                    qNode.setAttribute('signalOffset',num2str(busEleInfo(j).Offset));
                    pNode.appendChild(qNode);
                end
                siNode.appendChild(pNode);
            end
            slNode.appendChild(siNode);
            toolNode.appendChild(slNode);
            vaNode.appendChild(toolNode);
            parentNode.appendChild(vaNode);
        end

        function addModelVariablesElement(this,parentNode,rootNode)
            mvNode=rootNode.createElement('ModelVariables');
            for i=1:length(this.ModelInfoUtils.ModelVariableList)
                it=this.ModelInfoUtils.ModelVariableList(i);
                if strcmp(it.xml_name,'ToolCouplingFMU_VariableStepSolver_Inport')
                    this.varStepFMUPortSkipped=true;
                    continue;
                end

                varNode=rootNode.createElement('ScalarVariable');
                varNode.setAttribute('name',it.xml_name);
                varNode.setAttribute('valueReference',num2str(it.vr));
                varNode.setAttribute('causality',it.causality);
                varNode.setAttribute('variability',it.variability);
                if~strcmp(it.initial,'(null)')
                    varNode.setAttribute('initial',it.initial);
                end
                varNode.setAttribute('description',it.description);

                subNode1=rootNode.createElement(it.dt);
                if~strcmp(it.start,'(null)')
                    subNode1.setAttribute('start',it.start);
                end
                if~strcmp(it.unit,'(null)')
                    subNode1.setAttribute('unit',it.unit);
                end

                varNode.appendChild(subNode1);

                svIdx=i;
                if this.varStepFMUPortSkipped



                    svIdx=i-1;
                end
                commNode=rootNode.createComment(['Index = ',num2str(svIdx)]);
                varNode.appendChild(commNode);

                subNode2=rootNode.createElement('Annotations');
                subNode3=rootNode.createElement('Tool');
                subNode3.setAttribute('name','Simulink');
                subNode4=rootNode.createElement('Data');
                subNode4.setAttribute('tag',it.tag);
                subNode4.setAttribute('elementAccess',it.elementAccess);
                subNode3.appendChild(subNode4);
                subNode2.appendChild(subNode3);

                varNode.appendChild(subNode1);
                varNode.appendChild(subNode2);
                mvNode.appendChild(varNode);
            end
            parentNode.appendChild(mvNode);
        end

        function addDefaultExperimentElement(this,parentNode,rootNode)
            deNode=rootNode.createElement('DefaultExperiment');

            deNode.setAttribute('startTime',this.ModelInfoUtils.getStartTime);
            if this.ModelInfoUtils.hasStopTime
                deNode.setAttribute('stopTime',this.ModelInfoUtils.getStopTime);
            end

            if this.ModelInfoUtils.isFixedStepSolver
                deNode.setAttribute('stepSize',this.ModelInfoUtils.getCompiledFixedStepSize);
            end

            parentNode.appendChild(deNode);
        end

        function addModelStructureElement(this,parentNode,rootNode)
            msNode=rootNode.createElement('ModelStructure');

            outputNode=rootNode.createElement('Outputs');
            initNode=rootNode.createElement('InitialUnknowns');

            for i=1:length(this.ModelInfoUtils.ModelVariableList)
                it=this.ModelInfoUtils.ModelVariableList(i);
                svIdx=i;
                if this.varStepFMUPortSkipped



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





                    initNode.appendChild(pNode);
                end
            end
            msNode.appendChild(outputNode);
            msNode.appendChild(initNode);

            parentNode.appendChild(msNode);
        end

        function addLogCategoriesElement(this,parentNode,rootNode)
            lcNode=rootNode.createElement('LogCategories');

            leNode=rootNode.createElement('Category');
            leNode.setAttribute('name','logStatusError');
            leNode.setAttribute('description','Error message from FMU or MATLAB exceptions.');
            lcNode.appendChild(leNode);

            laNode=rootNode.createElement('Category');
            laNode.setAttribute('name','logAll');
            laNode.setAttribute('description','All messages from FMU, MATLAB exceptions, and MATLAB command window.');
            lcNode.appendChild(laNode);

            parentNode.appendChild(lcNode);
        end

        function addTypeDefinitionsElement(this,parentNode,rootNode)
        end

        function addUnitDefinitionsElement(this,parentNode,rootNode)
            if this.ModelInfoUtils.UnitDefinitions.Count==0

                return;
            end

            unitdefNode=rootNode.createElement('UnitDefinitions');
            for u=this.ModelInfoUtils.UnitDefinitions.keys
                uStruct=this.ModelInfoUtils.UnitDefinitions(u{1});

                unitNode=rootNode.createElement('Unit');
                unitNode.setAttribute('name',uStruct.name);
                unitdefNode.appendChild(unitNode);
            end
            parentNode.appendChild(unitdefNode);
        end
    end
end
