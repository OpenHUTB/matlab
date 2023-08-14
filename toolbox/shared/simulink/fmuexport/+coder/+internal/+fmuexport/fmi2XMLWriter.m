


classdef(Hidden=true)fmi2XMLWriter<coder.internal.fmuexport.CodeWriter
    properties(Access=private)
ModelInfoUtils
FMUType
    end


    methods(Access=public)
        function this=fmi2XMLWriter(modelInfoUtils,fileName)
            this=this@coder.internal.fmuexport.CodeWriter(fileName);
            this.ModelInfoUtils=modelInfoUtils;
            this.FMUType='CS';
            if(strcmp(this.ModelInfoUtils.BuildOpts.sysTargetFile,'fmu2me.tlc'))
                this.FMUType='ME';
            end
            this.writeXMLBody;
        end
    end



    methods(Access=private)
        function writeXMLBody(this)
            content=this.writeHeader;
            if strcmp(this.FMUType,'CS')
                content=[content;
                this.writeCoSimulationElement;
                ];
            else
                content=[content;
                this.writeModelExchangeElement;
                ];
            end
            content=[content;
            this.writeUnitDefinitionsElement;
            this.writeTypeDefinitionsElement;
            this.writeDefaultExperimentElement;
            this.writeVendorAnnotationsElement;
            this.writeModelVariableElement;
            this.writeModelStructureElement;
            this.writeTrailer;
            ];
            cellfun(@(aLine)this.writeString(aLine),content);
        end

        function content=writeHeader(this)
            name=this.ModelInfoUtils.CodeInfo.Name;
            guid=coder.internal.fmuexport.ModelChecksumToGUID(this.ModelInfoUtils.CodeInfo.Checksum);
            description=this.xmlCharEscape(get_param(name,'Description'));

            content={...
            '<?xml version="1.0" encoding="utf-8"?>';
            '<fmiModelDescription';
            '  fmiVersion="2.0"';
            ['  modelName="',name,'"'];
            ['  guid="{',guid,'}"'];
            ['  description="',description,'"'];
            ['  generationTool="',this.ModelInfoUtils.getGenerationTool,'"'];
            ['  version="',this.ModelInfoUtils.getVersion,'"'];
            '  variableNamingConvention="structured"';
            ['  generationDateAndTime="',this.ModelInfoUtils.getGenerationDateAndTime,'"'];
            '  numberOfEventIndicators="0">';
            '';
            };
        end

        function content=writeTrailer(~)
            content={...
            '</fmiModelDescription>';
            '';
            };
        end

        function content=writeCoSimulationElement(this)
            content={
            '<CoSimulation';
            ['  modelIdentifier="',this.ModelInfoUtils.CodeInfo.Name,'"'];
            };





            if this.ModelInfoUtils.canBeInstantiatedOnlyOncePerProcessOverride
                content=[...
                content;
                '  canBeInstantiatedOnlyOncePerProcess="false"';];
            else
                content=[...
                content;
                '  canBeInstantiatedOnlyOncePerProcess="true"';];
            end
            if this.ModelInfoUtils.SaveSourceCode
                content=[...
                content;
                '  canNotUseMemoryManagementFunctions="true">';
                '   <SourceFiles>'];
                SourceFileTags=cellfun(@(x)sprintf('      <File name="%s"/>',x),this.ModelInfoUtils.SourceFileList,'un',0);
                content=[content;SourceFileTags(:)];
                content=[content
                '   </SourceFiles>';
                '</CoSimulation>';
                ];
            else
                content=[...
                content;
                '  canNotUseMemoryManagementFunctions="true"';
                '  />';
                '';
                ];
            end
        end

        function content=writeModelExchangeElement(this)
            content={
            '<ModelExchange';
            ['  modelIdentifier="',this.ModelInfoUtils.CodeInfo.Name,'"'];
            };





            content=[...
            content;
            '  canBeInstantiatedOnlyOncePerProcess="true"';];

            content=[...
            content;
            '  canNotUseMemoryManagementFunctions="true"';
            '  />';
            '';
            ];
        end

        function content=writeUnitDefinitionsElement(this)
            if this.ModelInfoUtils.UnitDefinitions.isempty
                content={};
                return;
            end

            content={
            '<UnitDefinitions>';
            };
            for unit=this.ModelInfoUtils.UnitDefinitions.keys
                content=[...
                content;
                ['  <Unit name="',this.xmlCharEscape(unit{1}),'" />'];
                ];
            end
            content=[...
            content;
            '</UnitDefinitions>';
            ];
        end

        function content=writeTypeDefinitionsElement(this)
            if this.ModelInfoUtils.EnumTypeMap.isempty
                content={};
                return;
            end

            content={
            '<TypeDefinitions>';
            };
            for enumName=this.ModelInfoUtils.EnumTypeMap.keys
                enumType=this.ModelInfoUtils.EnumTypeMap(enumName{1});
                content=[...
                content;
                ['  <SimpleType name="',this.xmlCharEscape(enumName{1}),'">'];
                '    <Enumeration>';
                ];
                for i=1:length(enumType.Strings)
                    content=[...
                    content;
                    ['      <Item name="',this.xmlCharEscape(enumType.Strings{i}),'" value="',num2str(enumType.Values(i)),'"/>'];
                    ];
                end
                content=[...
                content;
                '    </Enumeration>';
                '  </SimpleType>';
                ];
            end
            content=[...
            content;
            '</TypeDefinitions>';
            ];
        end

        function content=writeVendorAnnotationsElement(this)
            busObjects=writeSimulinkModelInterface(this,'      ');
            content=[
            '<VendorAnnotations>';
            '  <Tool name="Simulink">';
            '    <Simulink>';
            '      <ImportCompatibility requireRelease="all" requireMATLABOnPath="no" />';
            busObjects;
            ];
            if this.ModelInfoUtils.AddProtectedModel


                protectedModelInfo=writeProtectedModelInfo(this,'      ');
                content=[
                content;
                protectedModelInfo;
                ];
            end
            content=[
            content;
            '    </Simulink>';
            '  </Tool>';
            '</VendorAnnotations>';
            ];
        end
        function content=writeProtectedModelInfo(this,prefixSpace)
            if this.ModelInfoUtils.AddProtectedModel
                Platform=computer('arch');
                switch Platform
                case 'glnxa64'
                    Platform='linux64';
                case 'maci64'
                    Platform='darwin64';
                end
                content={[prefixSpace...
                ,'<ProtectedModel '...
                ,'" platform="'...
                ,Platform...
                ,'"/>'];
                };
            else
                content={};
            end
        end
        function content=writeSimulinkModelInterface(this,prefixSpace)
            Inports=this.ModelInfoUtils.CodeInfo.Inports;
            Outports=this.ModelInfoUtils.CodeInfo.Outports;
            if isempty(Inports)&&isempty(Outports)
                content={};
                return;
            end
            content={[prefixSpace,'<SimulinkModelInterface>'];
            };
            elementQueue={};

            portElementXML=@(port,name,uniqueName,type,idx,space)(...
            [space...
            ,'  <',port,' dataType="',type,'"'...
            ,' portNumber="',num2str(idx),'"'...
            ,' uniquePortName="',uniqueName,'"'...
            ,' portName="',name,'"/>']);
            for i=1:length(Inports)
                portElement=Inports(i);
                portName=portElement.GraphicalName;
                uniqueName=this.ModelInfoUtils.graphicalNameMap([portName,', input']);
                portType=portElement.Type;
                while isa(portType,'coder.types.Matrix')

                    portType=portType.BaseType;
                end
                portBusName=portType.Name;
                content=[content;
                portElementXML('Inport',portName,uniqueName,portBusName,i,prefixSpace);
                ];
                if isprop(portType,'Elements')&&length(portType.Elements)>=1
                    elementQueue{end+1}=portElement;
                end
            end
            for i=1:length(Outports)
                portElement=Outports(i);
                portName=portElement.GraphicalName;
                uniqueName=this.ModelInfoUtils.graphicalNameMap([portName,', output']);
                portType=portElement.Type;
                while isa(portType,'coder.types.Matrix')

                    portType=portType.BaseType;
                end
                portBusName=portType.Name;
                content=[content;
                portElementXML('Outport',portName,uniqueName,portBusName,i,prefixSpace);
                ];
                if isprop(portType,'Elements')&&length(portType.Elements)>=1
                    elementQueue{end+1}=portElement;
                end
            end


            BusObjectXML=@(space,name,busObject)(...
            [space...
            ,'  <BusObject name="',name,'"'...
            ,' description="',this.xmlCharEscape(busObject.Description),'"'...
            ,' dataScope="',busObject.DataScope,'"'...
            ,' headerFile="',busObject.HeaderFile,'"'...
            ,' alignment="',num2str(busObject.Alignment),'">']);
            BusElementXML=@(space,busElement)(...
            [space...
            ,'    <BusElement name="',busElement.Name,'"'...
            ,' complexity="',busElement.Complexity,'"'...
            ,' dimensions="',num2str(busElement.Dimensions),'"'...
            ,' dataType="',busElement.DataType,'"'...
            ,' min="',num2str(busElement.Min),'"'...
            ,' max="',num2str(busElement.Max),'"'...
            ,' dimensionsMode="',busElement.DimensionsMode,'"'...
            ,this.createUnitAttribute(busElement.Unit,true)...
            ,' description="',this.xmlCharEscape(busElement.Description),'"/>']);
            visitedBusObject={};
            while(~isempty(elementQueue))
                element=elementQueue{end};
                type=element.Type;
                elementQueue(end)=[];
                busObject=coder.internal.fmuexport.searchObjectsInWorkspace(this.ModelInfoUtils.CodeInfo.Name,type.Name,'Simulink.Bus');
                if~isempty(busObject)
                    if(find(strcmp(visitedBusObject,type.Name),1))
                        continue;
                    end
                    visitedBusObject{end+1}=type.Name;
                    content=[content;
                    BusObjectXML(prefixSpace,type.Name,busObject);
                    ];
                    assert(length(type.Elements)==length(busObject.Elements));

                    for i=1:length(type.Elements)
                        subElement=type.Elements(i);
                        busElement=busObject.Elements(i);
                        subType=subElement.Type;
                        content=[content;
                        BusElementXML(prefixSpace,busElement);
                        ];
                        if isprop(subType,'Elements')&&length(subType.Elements)>=1
                            elementQueue{end+1}=subElement;
                        end
                    end
                    content=[content;
                    [prefixSpace,'  </BusObject>'];
                    ];
                end
            end


            for i=1:length(this.ModelInfoUtils.ModelVariableList)
                it=this.ModelInfoUtils.ModelVariableList(i);
            end
            content=[
            content;
            [prefixSpace,'</SimulinkModelInterface>'];
            ];
        end

        function content=writeModelVariableElement(this)
            content={
            '<ModelVariables>';
            };
            for i=1:length(this.ModelInfoUtils.ModelVariableList)
                it=this.ModelInfoUtils.ModelVariableList(i);

                startAttribute='';
                initialAttribute='';
                unitAttribute='';
                typeAttribute='';
                minAttribute='';
                maxAttribute='';
                if ismember(it.dt,{'Integer','Boolean','String','Enumeration'})
                    variabilityAttribute='variability="discrete"';
                else
                    variabilityAttribute='variability="continuous"';
                end
                if strcmp(it.causality,'input')
                    startAttribute='start="0" ';
                    if strcmp(it.dt,'Real')
                        unitAttribute=this.createUnitAttribute(this.ModelInfoUtils.ModelVariableList(i).unit,false);
                        minAttribute=this.createMinAttribute(this.ModelInfoUtils.ModelVariableList(i).min,false);
                        maxAttribute=this.createMaxAttribute(this.ModelInfoUtils.ModelVariableList(i).max,false);
                    end
                    if strcmp(it.dt,'Enumeration')
                        enumName=this.ModelInfoUtils.ModelVariableList(i).enumName;
                        enumObj=this.ModelInfoUtils.EnumTypeMap(enumName);
                        typeAttribute=coder.internal.fmuexport.fmi2XMLWriter.createTypeAttribute(enumName);
                        startAttribute=['start="',num2str(enumObj.Values(enumObj.DefaultMember)),'"'];
                    end
                elseif strcmp(it.causality,'parameter')
                    evalStr=strrep(strrep(it.g_name,'[','('),']',')');
                    [var,idx]=strtok(it.g_name,'[');
                    if isempty(it.flag)
                        evalVal=Simulink.data.evalinGlobal(this.ModelInfoUtils.CodeInfo.Name,var);
                    elseif length(it.flag)>=8&&strcmp(it.flag(1:8),'InstArg_')
                        blkPath=it.flag(9:end);
                        bps=strsplit(blkPath,':');
                        names=strsplit(evalStr,':');
                        evalStr=names{end};
                        [var,idx]=strtok(evalStr,'[');
                        evalVal=this.getInstArgValue(this,bps,var);
                    else
                        evalWS=get_param(it.flag,'ModelWorkspace');
                        evalVal=evalWS.evalin(var);
                    end
                    if isa(evalVal,'Simulink.LookupTable')
                        evalVal=evalVal.Table.Value(str2num(idx));
                    elseif isa(evalVal,'Simulink.Breakpoint')
                        evalVal=evalVal.Breakpoints.Value(str2num(idx));
                    elseif isa(evalVal,'Simulink.Parameter')
                        if isa(evalVal.Value,'Simulink.data.Expression')

                            c_expr=char(evalVal.Value.ExpressionString);
                            evalVal.Value=slResolve(c_expr,this.ModelInfoUtils.CodeInfo.Name,'expression');
                            evalVal.Dimensions=size(evalVal.Value);
                        end
                        v=reshape(evalVal.Value,evalVal.Dimensions);
                        index=str2num(idx);
                        if isempty(index)
                            evalVal=v;
                        elseif length(index)==1
                            evalVal=v(index);
                        else
                            evalVal=v(index(1),index(2));
                        end
                    else
                        if isempty(it.flag)
                            evalVal=Simulink.data.evalinGlobal(this.ModelInfoUtils.CodeInfo.Name,evalStr);
                        elseif contains(it.flag,'InstArg_')

                        else
                            evalWS=get_param(it.flag,'ModelWorkspace');
                            evalVal=evalWS.evalin(evalStr);
                        end
                    end
                    if strcmp(it.dt,'Real')
                        startAttribute=sprintf('%.16g',(double(evalVal)));
                        unitAttribute=this.createUnitAttribute(this.ModelInfoUtils.ModelVariableList(i).unit,false);
                        minAttribute=this.createMinAttribute(this.ModelInfoUtils.ModelVariableList(i).min,false);
                        maxAttribute=this.createMaxAttribute(this.ModelInfoUtils.ModelVariableList(i).max,false);
                    elseif strcmp(it.dt,'Integer')||strcmp(it.dt,'Enumeration')
                        startAttribute=num2str(int32(evalVal));
                    elseif strcmp(it.dt,'Boolean')
                        startAttribute=num2str(boolean(evalVal));
                    else
                        assert(strcmp(it.dt,'String'));
                        startAttribute=Simulink.data.evalinGlobal(this.ModelInfoUtils.CodeInfo.Name,evalVal);
                    end
                    startAttribute=strcat('start="',startAttribute,'"');
                    initialAttribute='initial="exact"';
                    variabilityAttribute='variability="tunable"';
                    if strcmp(it.dt,'Enumeration')
                        typeAttribute=coder.internal.fmuexport.fmi2XMLWriter.createTypeAttribute(this.ModelInfoUtils.ModelVariableList(i).enumName);
                    end
                elseif strcmp(it.causality,'output')
                    initialAttribute='initial="calculated"';
                    if strcmp(it.dt,'Real')
                        unitAttribute=this.createUnitAttribute(this.ModelInfoUtils.ModelVariableList(i).unit,false);
                        minAttribute=this.createMinAttribute(this.ModelInfoUtils.ModelVariableList(i).min,false);
                        maxAttribute=this.createMaxAttribute(this.ModelInfoUtils.ModelVariableList(i).max,false);
                    end
                    if strcmp(it.dt,'Enumeration')
                        typeAttribute=coder.internal.fmuexport.fmi2XMLWriter.createTypeAttribute(this.ModelInfoUtils.ModelVariableList(i).enumName);
                    end
                elseif strcmp(it.causality,'local')
                    variabilityAttribute='variability="continuous"';
                    initialAttribute='initial="calculated"';
                    if strcmp(it.dt,'Real')
                        unitAttribute=this.createUnitAttribute(this.ModelInfoUtils.ModelVariableList(i).unit,false);
                    end
                    if strcmp(it.dt,'Enumeration')
                        typeAttribute=coder.internal.fmuexport.fmi2XMLWriter.createTypeAttribute(this.ModelInfoUtils.ModelVariableList(i).enumName);
                    end
                end

                derivAttribute='';
                if(it.is_derivative)







                    deriv_place=0;
                    for j=1:i
                        itj=this.ModelInfoUtils.ModelVariableList(j);
                        if(itj.is_derivative)
                            deriv_place=deriv_place+1;
                        end
                    end
                    assert(deriv_place>0);
                    cont_state_place=0;
                    for j=1:length(this.ModelInfoUtils.ModelVariableList)
                        itj=this.ModelInfoUtils.ModelVariableList(j);
                        if(itj.is_cont_state)
                            cont_state_place=cont_state_place+1;
                        end
                        if(cont_state_place==deriv_place)
                            derivAttribute=['derivative="',num2str(j),'"'];
                            break;
                        end
                    end
                    assert(~isempty(derivAttribute));
                end

                if~isempty(it.description)
                    svDescription=this.xmlCharEscape(it.description);
                else
                    svDescription=it.g_name;
                end
                content=[content;
                ['  <ScalarVariable name="',it.xml_name,'"'...
                ,' valueReference="',num2str(it.vr),'"'...
                ,' description="',svDescription,'"'...
                ,' causality="',it.causality,'"'...
                ,' ',variabilityAttribute...
                ,' ',initialAttribute,'>']
                ['    <',it.dt...
                ,' ',startAttribute...
                ,unitAttribute...
                ,typeAttribute...
                ,minAttribute...
                ,maxAttribute...
                ,' ',derivAttribute,'/>']
                ['  </ScalarVariable> <!-- index="',num2str(i),'" -->']
                ];
            end
            content=[
            content;
            '</ModelVariables>';
            ];
        end

        function content=writeModelStructureElement(this)
            contentO={};
            contentI={};
            contentD={};










            for i=1:length(this.ModelInfoUtils.ModelVariableList)
                if(strcmp(this.ModelInfoUtils.ModelVariableList(i).causality,'output'))
                    contentO=[contentO;
                    ['    <Unknown index="',num2str(i),'" />'];
                    ];

                    if this.ModelInfoUtils.initialUnknownDependenciesOverride
                        contentI=[contentI;
                        ['    <Unknown index="',num2str(i),'" dependencies="" />'];
                        ];
                    else
                        contentI=[contentI;
                        ['    <Unknown index="',num2str(i),'" />'];
                        ];
                    end
                elseif(strcmp(this.ModelInfoUtils.ModelVariableList(i).causality,'local'))
                    if this.ModelInfoUtils.initialUnknownDependenciesOverride
                        contentI=[contentI;
                        ['    <Unknown index="',num2str(i),'" dependencies="" />'];
                        ];
                    else
                        contentI=[contentI;
                        ['    <Unknown index="',num2str(i),'" />'];
                        ];
                    end
                end
                if(this.ModelInfoUtils.ModelVariableList(i).is_derivative)
                    contentD=[contentD;
                    ['    <Unknown index="',num2str(i),'" />'];
                    ];
                end
            end
            content={
            '<ModelStructure>';
            };
            if(~isempty(contentO))
                content=[
                content;
                '  <Outputs>';
                contentO;
                '  </Outputs>';
                '';
                ];
            end
            if(~isempty(contentI))
                content=[
                content;
                '  <InitialUnknowns>';
                contentI;
                '  </InitialUnknowns>';
                '';
                ];
            end
            if(~isempty(contentD))
                content=[
                content;
                '  <Derivatives>';
                contentD;
                '  </Derivatives>';
                '';
                ];
            end
            content=[
            content;
            '</ModelStructure>';
            '';
            ];
        end

        function content=writeDefaultExperimentElement(this)
            attrStr='';

            if~isinf(this.ModelInfoUtils.RTWInfo.StartTime)
                valStr=sprintf('%.16g',this.ModelInfoUtils.RTWInfo.StartTime);
                attrStr=[attrStr,' startTime="',valStr,'"'];
            end

            if~isinf(this.ModelInfoUtils.RTWInfo.StopTime)
                valStr=sprintf('%.16g',this.ModelInfoUtils.RTWInfo.StopTime);
                attrStr=[attrStr,' stopTime="',valStr,'"'];
            end

            if~isinf(this.ModelInfoUtils.RTWInfo.FundamentalStepSize)
                valStr=sprintf('%.16g',this.ModelInfoUtils.RTWInfo.FundamentalStepSize);
                attrStr=[attrStr,' stepSize="',valStr,'"'];
            end

            content=['<DefaultExperiment',attrStr,'/>';
            '';
            ];

        end

    end

    methods(Static)
        function str=xmlCharEscape(str)
            if~isempty(str)

                str=strrep(str,char(13),'&#13;');
                str=strrep(str,char(10),'&#10;');
                str=strrep(str,'&','&amp;');
                str=strrep(str,'"','&quot;');
                str=strrep(str,'''','&apos;');
                str=strrep(str,'<','&lt;');
                str=strrep(str,'>','&gt;');
            end
        end

        function unitAttribute=createUnitAttribute(unit,allowEmpty)
            unitAttribute='';
            if strcmp(unit,'inherit')
                unit='';
            end
            if~isempty(unit)||allowEmpty
                unitAttribute=strcat(' unit="',coder.internal.fmuexport.fmi2XMLWriter.xmlCharEscape(unit),'"');
            end
        end

        function typeAttribute=createTypeAttribute(type)
            typeAttribute='';
            if~isempty(type)
                typeAttribute=strcat(' declaredType="',coder.internal.fmuexport.fmi2XMLWriter.xmlCharEscape(type),'"');
            end
        end

        function minAttribute=createMinAttribute(min,allowEmpty)
            minAttribute='';
            if strcmp(min,'[]')
                min='';
            end
            if~isempty(min)||allowEmpty
                minAttribute=strcat(' min="',coder.internal.fmuexport.fmi2XMLWriter.xmlCharEscape(min),'"');
            end
        end

        function maxAttribute=createMaxAttribute(max,allowEmpty)
            maxAttribute='';
            if strcmp(max,'[]')
                max='';
            end
            if~isempty(max)||allowEmpty
                maxAttribute=strcat(' max="',coder.internal.fmuexport.fmi2XMLWriter.xmlCharEscape(max),'"');
            end
        end

        function evalVal=getInstArgValue(this,bps,var)
            instArgs=get_param(bps{1},'InstanceParameters');
            for j=1:length(instArgs)
                isSamePath=false;
                path=instArgs(j).Path.convertToCell;
                if(isempty(path)&&length(bps)==1)||(~isempty(path)&&isequal(intersect(bps,path),path))
                    isSamePath=true;
                end
                if strcmp(instArgs(j).Name,var)&&isSamePath

                    if isempty(instArgs(j).Value)


                        if length(bps)==1
                            submdl=get_param(bps{1},'ModelName');
                            evalWS=get_param(submdl,'ModelWorkspace');
                            evalVal=evalWS.evalin(var);
                        else
                            bps(1)=[];
                            evalVal=this.getInstArgValue(this,bps,var);
                        end
                    else

                        evalVal=slResolve(instArgs(j).Value,bps{1});
                    end
                end
            end
        end
    end
end
