classdef BusObjectHandle<handle



    properties(GetAccess=public,SetAccess=private)

        busName='';


        busObjContextModel='';


        ContextName='';


        WorkspaceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.Unknown;


        busObj=[];



        leafChildIndices=[];


        nonLeafChildIndices=[];





        leafChildName2IndexMap=containers.Map('KeyType','char','ValueType','double');






        nonLeafChildName2IndexMap=containers.Map('KeyType','char','ValueType','double');






        leafChildInitialConditionRange=[];


        elementNames='';


        specifiedDTs='';


        designMins='';


        designMaxs='';
    end
    methods
        function busObjectHandle=BusObjectHandle(busName,contextModelName,busObjectNameList)





















            if isempty(busName)
                return;
            end

            busObjectHandle.busName=busName;

            busObjectHandle.ContextName=contextModelName;
            if~isempty(contextModelName)
                busObjectHandle.busObjContextModel=get_param(contextModelName,'Object');
            else
                busObjectHandle.busObjContextModel=[];
            end

            reservedBusTypes=SimulinkFixedPoint.AutoscalerUtils.ReservedBusTypes.getInstance();
            [busObject,nameFound]=getBusObject(reservedBusTypes,busName);

            if nameFound
                busObjectHandle.busObj=busObject;
            else
                if isempty(contextModelName)
                    busObjectHandle.busObj=evalin('base',busName);
                    busObjectHandle.WorkspaceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.Base;
                else
                    busObjectHandle.busObj=evalinGlobalScope(contextModelName,busName);



                    dataSource=Simulink.data.DataSource.create(contextModelName);
                    if isa(dataSource,'Simulink.data.BaseWorkspace')
                        busObjectHandle.WorkspaceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.Base;
                    else
                        busObjectHandle.WorkspaceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.DataDictionary;
                    end
                end
            end


            numberOfChildren=0;


            if~isempty(busObjectHandle.busObj)&&(numel(busObjectHandle.busObj)==1)
                numberOfChildren=length(busObjectHandle.busObj.Elements);
            end

            if numberOfChildren==0

                return;
            end


            busObjectHandle.leafChildInitialConditionRange{numberOfChildren}=[];

            busNameSet=containers.Map(busObjectNameList,...
            zeros(1,length(busObjectNameList)));

            [eleDT{1:numberOfChildren}]=deal(busObjectHandle.busObj.Elements.DataType);

            eleDT=regexprep(eleDT,'^Bus\s*:\s*','');
            busObjectHandle.leafChildIndices=find(cellfun(@(x)~(busNameSet.isKey(x)),eleDT));

            nonLeafEle=ones(1,numberOfChildren)*true;
            nonLeafEle(busObjectHandle.leafChildIndices)=false;
            busObjectHandle.nonLeafChildIndices=find(nonLeafEle);

            if~isempty(busObjectHandle.leafChildIndices)
                leafChildElements=busObjectHandle.busObj.Elements(busObjectHandle.leafChildIndices);
                [leafchildNames{1:length(leafChildElements)}]=deal(leafChildElements.Name);
                busObjectHandle.leafChildName2IndexMap=containers.Map(...
                leafchildNames,busObjectHandle.leafChildIndices);
            end

            if~isempty(busObjectHandle.nonLeafChildIndices)
                nonLeafChildElements=busObjectHandle.busObj.Elements(busObjectHandle.nonLeafChildIndices);
                [nonLeafchildNames{1:length(nonLeafChildElements)}]=deal(nonLeafChildElements.Name);
                busObjectHandle.nonLeafChildName2IndexMap=containers.Map(...
                nonLeafchildNames,busObjectHandle.nonLeafChildIndices);
            end

            elements=busObjectHandle.busObj.Elements;
            [specDTs{1:numberOfChildren}]=deal(elements.DataType);
            [dMin{1:numberOfChildren}]=deal(elements.Min);
            [dMax{1:numberOfChildren}]=deal(elements.Max);
            [name{1:numberOfChildren}]=deal(elements.Name);
            busObjectHandle.specifiedDTs=specDTs;
            busObjectHandle.designMins=dMin;
            busObjectHandle.designMaxs=dMax;
            busObjectHandle.elementNames=name;
        end
    end
    methods(Hidden,Access=public)
        setElementDataType(this,elementName,elementDataType);
        updateLeafChildInitCondRange(this,elementIdx,newRange);

        hModifyOrigObject(this);
        hVerifyElementName(this,elementName);
    end

    methods

        function object=Object(this)



            object=this.busObj;
        end

        function object=Name(this)



            object=this.busName;
        end
    end

end


