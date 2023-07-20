classdef(Sealed=true,Hidden=true)GroupedBatteryWriter<simscape.battery.builder.internal.export.SSCWriter




    properties
SeriesGrouping
ParallelGrouping
    end

    properties(Constant,Access=protected)
        ModelResolution=getString(message("physmod:battery:builder:blocks:ModelResolutionGrouped"),...
        matlab.internal.i18n.locale('en_US'));
    end

    properties(Dependent,Access=protected)
CoolingPathResistanceParameters
AmbientPathResistanceParameters
ParallelAssemblyVariables
    end

    methods
        function obj=GroupedBatteryWriter()


            obj.BatteryType="Module";
        end

        function resistanceParameters=get.CoolingPathResistanceParameters(obj)

            childComponentParams=simscape.battery.builder.internal.export.ComponentParameters;
            if obj.CoolantThermalPath~=""
                id="CoolantResistance";
                label=string(getString(message('physmod:battery:builder:blocks:CoolantResistance'),matlab.internal.i18n.locale('en_US')));
                defaultValue="1.2";
                defaultUnit="K/W";
                group="Thermal";
                childComponentParams=childComponentParams.addParameters(id,label,defaultValue,defaultUnit,group,"M");
            else

            end
            resistanceParameters=childComponentParams.getDefaultCompositeComponentParameters();
        end

        function resistanceParameters=get.AmbientPathResistanceParameters(obj)

            childComponentParams=simscape.battery.builder.internal.export.ComponentParameters;
            if obj.AmbientThermalPath~=""
                id="AmbientResistance";
                label=string(getString(message('physmod:battery:builder:blocks:AmbientThermalPathResistance'),matlab.internal.i18n.locale('en_US')));
                defaultValue="25";
                defaultUnit="K/W";
                group="Thermal";
                childComponentParams=childComponentParams.addParameters(id,label,defaultValue,defaultUnit,group,"M");
            else

            end
            resistanceParameters=childComponentParams.getDefaultCompositeComponentParameters();
        end

        function variables=get.ParallelAssemblyVariables(~)


            variables=simscape.battery.builder.internal.export.ComponentVariables();
            voltageDescription=getString(message('physmod:battery:builder:blocks:ParallelAssemblyVoltage'),matlab.internal.i18n.locale('en_US'));
            variables=variables.addVariables("vParallelAssembly",voltageDescription,"0","S","V","priority.none");
            socDescription=getString(message('physmod:battery:builder:blocks:ParallelAssemblySOC'),matlab.internal.i18n.locale('en_US'));
            variables=variables.addVariables("socParallelAssembly",socDescription,"1","S","1","priority.none");
        end
    end

    methods(Hidden)
        function component=addChildComponent(obj,component)


            lumpingFactors=obj.getParameterLumpingFactors();


            forLoop=simscape.battery.internal.sscinterface.ForLoop("modelIdx","1:TotalNumModels");
            componentsSection=simscape.battery.internal.sscinterface.ComponentsSection(CompileReuse="true");
            compositeComponentParameters=[obj.BatteryCompositeComponentParameters.IDs,obj.BatteryCompositeComponentParameters.Values+lumpingFactors;obj.ControlParameters];
            variableCount=length(obj.BatteryCompositeComponentVariables.IDs);
            variablePriority=[obj.BatteryCompositeComponentVariables.IDs,repmat("priority.none",variableCount,1)];
            childComponent=obj.ChildComponentIdentifier.append("(modelIdx)");

            compositeComponent=simscape.battery.internal.sscinterface.CompositeComponent(childComponent,obj.ChildComponent,...
            Parameters=compositeComponentParameters,VariablePriority=variablePriority);
            componentsSection=componentsSection.addComponent(compositeComponent);

            forLoop=forLoop.addSection(componentsSection);
            component=component.addForLoop(forLoop);
        end

        function component=addCompositeComponentVariables(obj,component)

            variableAssignment=simscape.battery.internal.sscinterface.EquationsSection();
            compositeComponentVariables=obj.BatteryCompositeComponentVariables.IDs;


            loopingIndex="modelIdx";
            for variableIdx=1:length(compositeComponentVariables)
                variableAssignment=variableAssignment.addEquation(obj.BatteryCompositeComponentVariables.Values(variableIdx).append("(",loopingIndex,")"),...
                obj.ChildComponentIdentifier.append("(",loopingIndex,")",".",compositeComponentVariables(variableIdx)));
            end

            forLoop=simscape.battery.internal.sscinterface.ForLoop(loopingIndex,"1:TotalNumModels");
            forLoop=forLoop.addSection(variableAssignment);
            component=component.addForLoop(forLoop);
        end

        function component=addNonCellResistor(obj,component)

            if~isempty(obj.NonCellResistanceParameters.IDs)
                componentsSection=simscape.battery.internal.sscinterface.ComponentsSection();
                resistanceValue=obj.NonCellResistanceParameters.IDs;
                switch obj.NonCellResistanceParameters.IDs
                case "NonCellResistanceParallelAssembly"
                    scalingFactor="*S";
                otherwise
                    scalingFactor="";
                end
                nonCellResistor=simscape.battery.internal.sscinterface.CompositeComponent(obj.NonCellResistanceIdentifier,"foundation.electrical.elements.resistor",...
                Parameters=["R",resistanceValue.append(scalingFactor)]);
                componentsSection=componentsSection.addComponent(nonCellResistor);
                component=component.addSection(componentsSection);
            else

            end
        end


        function component=addConnection(obj,component)

            connectionsSection=simscape.battery.internal.sscinterface.ConnectionsSection;
            if~isempty(obj.NonCellResistanceParameters.IDs)
                connectionsSection=connectionsSection.addConnection("p",obj.NonCellResistanceIdentifier.append(".p"));
                connectionsSection=connectionsSection.addConnection(obj.NonCellResistanceIdentifier.append(".n"),obj.ChildComponentIdentifier.append("(1).p"));
            else
                connectionsSection=connectionsSection.addConnection("p",obj.ChildComponentIdentifier.append("(1).p"));
            end
            connectionsSection=connectionsSection.addConnection("n",obj.ChildComponentIdentifier.append("(TotalNumModels).n"));
            component=component.addSection(connectionsSection);


            parallelIndexVariable="parallelConnectionsIdx";
            parallelConnectionsLoop=simscape.battery.internal.sscinterface.ForLoop(parallelIndexVariable,"ParallelConnections");
            parallelConnections=simscape.battery.internal.sscinterface.ConnectionsSection();
            parallelConnections=parallelConnections.addConnection(obj.ChildComponentIdentifier.append("(",parallelIndexVariable,"-1).p"),...
            obj.ChildComponentIdentifier.append("(",parallelIndexVariable,").p"));
            parallelConnections=parallelConnections.addConnection(obj.ChildComponentIdentifier.append("(",parallelIndexVariable,"-1).n"),...
            obj.ChildComponentIdentifier.append("(",parallelIndexVariable,").n"));
            parallelConnectionsLoop=parallelConnectionsLoop.addSection(parallelConnections);
            component=component.addForLoop(parallelConnectionsLoop);


            seriesIndexVariable="seriesConnectionsIdx";
            seriesConnectionsLoop=simscape.battery.internal.sscinterface.ForLoop(seriesIndexVariable,"SeriesConnections");
            seriesConnections=simscape.battery.internal.sscinterface.ConnectionsSection();
            seriesConnections=seriesConnections.addConnection(obj.ChildComponentIdentifier.append("(",seriesIndexVariable,"-1).n"),...
            obj.ChildComponentIdentifier.append("(",seriesIndexVariable,").p"));
            seriesConnectionsLoop=seriesConnectionsLoop.addSection(seriesConnections);
            component=component.addForLoop(seriesConnectionsLoop);

        end

        function component=addCoolingPlateConnections(obj,component)

            import simscape.battery.internal.sscinterface.*
            coolingPlateId=obj.CoolingPlateLocation;
            coolingPlatePort=repmat("",size(coolingPlateId));

            forLoop=ForLoop("modelIdx","1:TotalNumModels");

            if obj.CoolantThermalPath=="CellBasedThermalResistance"

                componentsSection=ComponentsSection;
                connectionsSection=ConnectionsSection;
                for coolingPlateIdx=1:length(coolingPlateId)

                    memberComponentName="CoolantResistor"+coolingPlateId(coolingPlateIdx).append("(modelIdx)");
                    resistanceParameter=obj.CoolingPathResistanceParameters.Values.append("(modelIdx)");
                    memberParameters=["resistance",resistanceParameter];
                    compositeComponent=CompositeComponent(memberComponentName,"foundation.thermal.elements.resistance","Parameters",memberParameters);
                    componentsSection=componentsSection.addComponent(compositeComponent);


                    connectionsSection=connectionsSection.addConnection(obj.ChildComponentIdentifier.append("(modelIdx).H"),memberComponentName.append(".A"));
                    coolingPlatePort(coolingPlateIdx)=memberComponentName.append(".B");
                end

                forLoop=forLoop.addSection(componentsSection);
                forLoop=forLoop.addSection(connectionsSection);
            else

                coolingPlatePort(:)=obj.ChildComponentIdentifier.append("(modelIdx).H");
            end

            nodesSection=NodesSection();
            connectionsSection=ConnectionsSection();
            annotationsSection=AnnotationsSection;

            for coolingPlateIdx=1:length(coolingPlateId)

                nodeName=coolingPlateId(coolingPlateIdx).append("ExtClnt");
                indexedNode=nodeName.append("(modelIdx)");
                nodeLabel="CP"+coolingPlateId(coolingPlateIdx).extract(1);
                nodesSection=nodesSection.addNode(indexedNode,"foundation.thermal.thermal",Label=nodeLabel);
                annotationsSection=annotationsSection.addPortLocation(nodeName,lower(coolingPlateId(coolingPlateIdx)));


                connectionsSection=connectionsSection.addConnection(indexedNode,coolingPlatePort(coolingPlateIdx));
            end

            forLoop=forLoop.addSection(nodesSection);
            forLoop=forLoop.addSection(connectionsSection);
            component=component.addForLoop(forLoop);
            component=component.addSection(annotationsSection);
        end

        function component=addLumpedThermalPort(obj,component,portName,portLabel,resistanceName,resistanceParameter)

            import simscape.battery.internal.sscinterface.*


            nodesSection=NodesSection();
            nodesSection=nodesSection.addNode(portName,"foundation.thermal.thermal",Label=portLabel);
            component=component.addSection(nodesSection);


            forLoop=ForLoop("modelIdx","1:TotalNumModels");
            componentsSection=ComponentsSection;
            memberParameters=["..."+newline+"resistance",resistanceParameter.append("(modelIdx)")];
            compositeComponent=CompositeComponent(resistanceName.append("(modelIdx)"),"foundation.thermal.elements.resistance",Parameters=memberParameters);
            componentsSection=componentsSection.addComponent(compositeComponent);
            forLoop=forLoop.addSection(componentsSection);


            compositeComponentConnections=ConnectionsSection;
            compositeComponentConnections=compositeComponentConnections.addConnection(obj.ChildComponentIdentifier.append("(modelIdx).H"),resistanceName.append("(modelIdx).A"));
            forLoop=forLoop.addSection(compositeComponentConnections);


            componentConnections=ConnectionsSection;
            componentConnections=componentConnections.addConnection(resistanceName.append("(modelIdx).B"),portName);
            forLoop=forLoop.addSection(componentConnections);
            component=component.addForLoop(forLoop);
        end

        function component=addParallelAssemblyVariables(~,component)

            loopingVariable="lumpIdx";
            forLoop=simscape.battery.internal.sscinterface.ForLoop(loopingVariable,"1:length(SeriesGrouping)");
            equationsSection=simscape.battery.internal.sscinterface.EquationsSection;


            voltageVariable="vParallelAssembly((CumNumModules(lumpIdx)-SeriesGrouping(lumpIdx)+1):CumNumModules(lumpIdx))";
            voltageValue="(sum([battery(find(lumpIdx==ModelToLumpMapping)).v]) ./ (sum(double(lumpIdx==ModelToLumpMapping))*SeriesGrouping(lumpIdx))) * ones(SeriesGrouping(lumpIdx),1)";
            equationsSection=equationsSection.addEquation(voltageVariable,voltageValue);


            socVariable="socParallelAssembly((CumNumModules(lumpIdx)-SeriesGrouping(lumpIdx)+1):CumNumModules(lumpIdx))";
            socValue="(sum([battery(find(lumpIdx==ModelToLumpMapping)).stateOfCharge]) / ParallelGrouping(lumpIdx)) * ones(SeriesGrouping(lumpIdx),1)";
            equationsSection=equationsSection.addEquation(socVariable,socValue);

            forLoop=forLoop.addSection(equationsSection);
            component=component.addForLoop(forLoop);
        end

        function component=addScalingParameters(obj,component)




            component=addScalingParameters@simscape.battery.builder.internal.export.SSCWriter(obj,component);


            parametersSection=simscape.battery.internal.sscinterface.ParametersSection(ExternalAccess="none");
            parametersSection=parametersSection.addParameter("SeriesGrouping",mat2str(obj.SeriesGrouping),...
            string(getString(message('physmod:battery:builder:blocks:SeriesGrouping'),matlab.internal.i18n.locale('en_US'))));
            parametersSection=parametersSection.addParameter("ParallelGrouping",mat2str(obj.ParallelGrouping),...
            string(getString(message('physmod:battery:builder:blocks:ParallelGrouping'),matlab.internal.i18n.locale('en_US'))));
            component=component.addSection(parametersSection);

            privateParametersSection=simscape.battery.internal.sscinterface.ParametersSection(Access="private");
            privateParametersSection=privateParametersSection.addParameter("CumNumModules","cumsum(SeriesGrouping)",...
            string(getString(message('physmod:battery:builder:blocks:CumulativeModules'),matlab.internal.i18n.locale('en_US'))));
            privateParametersSection=privateParametersSection.addParameter("TotalNumModels","sum(ParallelGrouping)",...
            string(getString(message('physmod:battery:builder:blocks:TotalNumModels'),matlab.internal.i18n.locale('en_US'))));


            privateParametersSection=privateParametersSection.addParameter("ModelToLumpMapping",mat2str(obj.getModelToLumpMapping),...
            string(getString(message('physmod:battery:builder:blocks:ModelToLumpMapping'),matlab.internal.i18n.locale('en_US'))));


            privateParametersSection=privateParametersSection.addParameter("SeriesConnections","find(diff(ModelToLumpMapping)) + 1",...
            string(getString(message('physmod:battery:builder:blocks:SeriesConnections'),matlab.internal.i18n.locale('en_US'))));
            privateParametersSection=privateParametersSection.addParameter("ParallelConnections","find(~diff(ModelToLumpMapping)) + 1",...
            string(getString(message('physmod:battery:builder:blocks:ParallelConnections'),matlab.internal.i18n.locale('en_US'))));


            component=component.addSection(privateParametersSection);
        end

        function component=addCellBalancing(obj,component)

            switch obj.CellBalancing
            case "Passive"


                forLoop=simscape.battery.internal.sscinterface.ForLoop("lumpIdx","1:length(SeriesGrouping)");
                balancingComponents=obj.getCellBalancingComponents("(lumpIdx)","*SeriesGrouping(lumpIdx)");
                batteryIdx="(CumNumModules(lumpIdx)-SeriesGrouping(lumpIdx)+1)";

                balancingConnections=obj.getCellBalancingConnections(batteryIdx,...
                BalancingComponentsIndex="(lumpIdx)",ChildBatteryIndex="(find(lumpIdx==ModelToLumpMapping))");

                forLoop=forLoop.addSection(balancingComponents);
                forLoop=forLoop.addSection(balancingConnections);
                component=component.addForLoop(forLoop);
            otherwise
            end
        end


        function component=addScaledParameters(obj,component)

            compositeComponenParameters=obj.ComponentParameters.getDefaultCompositeComponentParameters;
            isScaledParameter=find(compositeComponenParameters.Scaling=="M");
            if~isempty(isScaledParameter)
                scaledParametersSection=simscape.battery.internal.sscinterface.ParametersSection(Access="private");
                for scaledParameterIdx=isScaledParameter'
                    defaultDescription=compositeComponenParameters.Labels(scaledParameterIdx);
                    scaledDescription="Scaled "+lower(defaultDescription.extractBefore(2))+defaultDescription.extractAfter(1);
                    scaledParametersSection=scaledParametersSection.addParameter(compositeComponenParameters.Values(scaledParameterIdx),...
                    compositeComponenParameters.IDs(scaledParameterIdx).append(" .* ParallelGrouping(ModelToLumpMapping) ./ (P .* SeriesGrouping(ModelToLumpMapping))"),scaledDescription);
                end
                component=component.addSection(scaledParametersSection);
            end
        end

        function component=addScaledParameterAssertions(obj,component)


            isScaledParameter=obj.ComponentParameters.Scaling~="1";

            if any(isScaledParameter)
                scalingParameterIDs=obj.ComponentParameters.IDs(isScaledParameter);
                scalingParameterLabels=obj.ComponentParameters.Labels(isScaledParameter);
                equationsSection=simscape.battery.internal.sscinterface.EquationsSection;
                for parameterIdx=1:length(scalingParameterIDs)
                    condition="isequal(size("+scalingParameterIDs(parameterIdx)+"),[1,1]) || isequal(size("+scalingParameterIDs(parameterIdx)+"),[1,TotalNumModels])";
                    diagnostic=getString(message('physmod:battery:builder:blocks:ScaledParameterAssertion',scalingParameterLabels(parameterIdx),"total number of cell models"),...
                    matlab.internal.i18n.locale('en_US'));
                    equationsSection=equationsSection.addAssertion(condition,ErrorMessage=diagnostic);
                end
                component=component.addSection(equationsSection);
            else

            end
        end
    end

    methods(Access=private)
        function lumpingFactors=getParameterLumpingFactors(obj)


            lumpingFactors=repmat("",size(obj.BatteryCompositeComponentParameters.IDs));


            resistanceParameterIdx=ismember(obj.BatteryCompositeComponentParameters.IDs,obj.ResistanceParameters);
            lumpingFactors(resistanceParameterIdx)="*((SeriesGrouping(ModelToLumpMapping(modelIdx))*ParallelGrouping(ModelToLumpMapping(modelIdx)))/P)";


            capacityParameterIdx=ismember(obj.BatteryCompositeComponentParameters.IDs,obj.CapacityParameter);
            lumpingFactors(capacityParameterIdx)="*P/ParallelGrouping(ModelToLumpMapping(modelIdx))";


            thermalMassIdx=ismember(obj.BatteryCompositeComponentParameters.IDs,obj.ThermalMassParameter);
            lumpingFactors(thermalMassIdx)="*(SeriesGrouping(ModelToLumpMapping(modelIdx))*P/ParallelGrouping(ModelToLumpMapping(modelIdx)))";


            voltageIndex=ismember(obj.BatteryCompositeComponentParameters.IDs,obj.VoltageParameters);
            lumpingFactors(voltageIndex)="*SeriesGrouping(ModelToLumpMapping(modelIdx))";
        end

        function modelToLumpMapping=getModelToLumpMapping(obj)

            cumNumModels=cumsum(obj.ParallelGrouping);
            newModelIdx=cumNumModels(1:end-1)+1;
            isNewModel=zeros(1,cumNumModels(end));
            isNewModel(newModelIdx)=true;
            modelToLumpMapping=cumsum(isNewModel)+1;
        end
    end

    methods(Access=protected)
        function numericalSizes=getVariableNumericalSize(obj)


            sizeMapping=dictionary(["1","S","TotalNumModels"],...
            ["1",string(obj.ChildrenInSeries),string(sum(obj.ParallelGrouping))]);
            numericalSizes=sizeMapping(obj.ComponentVariables.DefaultValuesSize);
        end

        function description=getResolutionDescription(obj)



            seriesGrouping="["+num2str(obj.SeriesGrouping)+"]";
            description=newline+"   "+getString(message("physmod:battery:builder:blocks:SeriesGrouping"),...
            matlab.internal.i18n.locale('en_US'))+": "+seriesGrouping;

            description=description.append(newline,"   ");
            parallelGrouping="["+num2str(obj.ParallelGrouping)+"]";
            description=description.append(getString(message("physmod:battery:builder:blocks:ParallelGrouping"),...
            matlab.internal.i18n.locale('en_US')),": ",parallelGrouping);
        end
    end
end


