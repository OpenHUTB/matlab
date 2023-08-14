classdef XmlReader




    properties(Access=private)
XmlFile
        Evaluator=matlab.io.xml.xpath.Evaluator;
    end

    properties(Access=private,Constant)
        PartSpecificationNames={'Manufacturer','PartNumber','PartSeries','PartType',...
        'WebLink','ParameterizationNote','ParameterizationDate'};
    end

    properties(Dependent)
Manufacturer
PartType

PartNumber
PartSpecification
BlockInformation
SimulinkRelease
    end

    methods
        function obj=XmlReader(xmlFile)

            if~contains(xmlFile,'.xml')
                xmlFile=[xmlFile,'.xml'];
            end

            obj.XmlFile=xmlFile;



        end

        function blockInformation=get.BlockInformation(obj)


            blockInformation.BlockType=obj.readBlockType();
            blockInformation.ReferenceBlock=obj.readSpecificationData('ReferenceBlock');
            blockInformation.SourceFile=obj.readSpecificationData('SourceFile');
        end

        function manufacturer=get.Manufacturer(obj)

            manufacturer=obj.readSpecificationData('Manufacturer');
        end

        function partNumber=get.PartNumber(obj)

            partNumber=obj.readSpecificationData('PartNumber');
        end

        function partType=get.PartType(obj)

            partType=obj.readSpecificationData('PartType');
        end

        function partSpecification=get.PartSpecification(obj)

            partSpecification=struct();



            for ii=1:length(obj.PartSpecificationNames)
                specName=obj.PartSpecificationNames{ii};
                partSpecification.(specName)=obj.readSpecificationData(specName);
            end
        end

        function simulinkRelease=get.SimulinkRelease(obj)

            simulinkRelease=obj.readSpecificationData('SimulinkRelease');
        end

        function instanceData=getInstanceData(obj)

            instanceData=obj.readInstanceData();
        end

        function partTypeData=getPartTypeData(obj)

            partTypeData=obj.readPartTypeData();
        end
    end

    methods(Access=private)
        function parameterValue=readSpecificationData(obj,propertyName)



            xPathString=sprintf('.//P[@Name="%s"]',propertyName);
            node=evaluate(obj.Evaluator,xPathString,obj.XmlFile);


            nodeAttribute=foundation.internal.parameterization.XmlReader.parseAttribute(node);
            parameterValue=nodeAttribute.Value;
        end

        function instanceData=readInstanceData(obj)



            xPathString='.//InstanceData/P';
            nodes=evaluate(obj.Evaluator,xPathString,obj.XmlFile);
            nodesCount=width(nodes);
            instanceData=repmat(struct('Name',[],'Value',[]),1,nodesCount);


            for ii=1:nodesCount
                nodeAttribute=foundation.internal.parameterization.XmlReader.parseAttribute(nodes(ii));
                instanceData(ii).Name=nodeAttribute.Name;
                instanceData(ii).Value=nodeAttribute.Value;
            end
        end

        function partTypeData=readPartTypeData(obj)

            xPathString='.//PartTypeData/P';
            nodes=evaluate(obj.Evaluator,xPathString,obj.XmlFile);
            if~isempty(nodes)
                nodesCount=width(nodes);
                partTypeData=repmat(struct('PartTypeName',[],'PartTypeValue',[]),1,nodesCount);


                for ii=1:nodesCount
                    nodeAttribute=foundation.internal.parameterization.XmlReader.parseAttribute(nodes(ii));
                    partTypeData(ii).PartTypeName=nodeAttribute.Name;
                    partTypeData(ii).PartTypeValue=nodeAttribute.Value;
                end
            else
                partTypeData(1).PartTypeName={'Part Type'};
                partTypeData(1).PartTypeValue={obj.PartType};
            end
        end

        function blockType=readBlockType(obj)

            xPathString='/Block';
            node=evaluate(obj.Evaluator,xPathString,obj.XmlFile);
            blockType=node.getAttribute('BlockType');
        end

        function rootNode=verifyRootNodeName(obj)

            rootNode=evaluate(obj.Evaluator,'/*',obj.XmlFile);
            if~isequal(rootNode.getTagName,'Block')
                pm_error('physmod:simscape:utils:BlockParameterSet:InvalidXmlFile');
            end
        end
    end

    methods(Static,Access=private)
        function attribute=parseAttribute(theNode)

            attribute=[];
            if theNode.hasAttributes
                theAttributes=theNode.getAttributes;
                numAttributes=theAttributes.getLength;
                if numAttributes>1
                    pm_error('physmod:simscape:utils:BlockParameterSet:OneAttributePerEntry')
                end
                attrib=theAttributes.item(0);
                attribute=struct('Name',...
                char(attrib.getValue),'Value',char(theNode.getTextContent));
            end
        end
    end
end
