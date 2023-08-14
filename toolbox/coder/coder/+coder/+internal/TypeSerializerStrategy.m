classdef(Abstract=true)TypeSerializerStrategy<handle
    methods(Abstract,Access=public)
        doc=createXMLDocument(obj,name);
        node=createXMLNode(obj,name);
        node=getXMLRootNode(obj,xmlDoc);
        setXMLNodeTextContent(obj,node,content);
        setXMLNodeAttribute(obj,node,attr,value);
        appendXMLNodeChild(obj,parent,child);
        xml=writeXML(obj);
    end

    properties(Access=protected)
        xmlDoc;
        userDefined;
    end

    methods(Static)
        function serializer=create()
            if coderapp.internal.globalconfig('JavaFreePrjParser')
                serializer=coder.internal.JavaFreeTypeSerializer();
            else
                javachk('jvm');
                serializer=coder.internal.JavaTypeSerializer();
            end
        end
    end

    methods
        function xmlDoc=serialize(obj,xmlDoc,element,iTc,inputNames)
            obj.xmlDoc=xmlDoc;

            if isa(iTc,'coder.type.Base')
                iTc=iTc.getCoderType();
            end
            if isa(iTc,'coder.Constant')
                obj.const2xml(element,iTc);
                obj.serialize(obj.xmlDoc,element,coder.typeof(iTc.Value),inputNames);
                return
            end
            obj.setXMLNodeAttribute(element,'Name',inputNames);
            obj.addItyProperty(element,iTc,'ClassName','Class');
            obj.addXMLNodeProperty(element,'UserDefined',obj.userDefined);
            obj.size2xml(element,iTc);

            switch class(iTc)
            case 'coder.EnumType'
                obj.enum2xml(element,iTc);
            case 'coder.FiType'
                obj.fi2xml(element,iTc);
            case 'coder.PrimitiveType'
                obj.numeric2xml(element,iTc);
            case 'coder.StructType'
                obj.struct2xml(element,iTc);
            case 'coder.CellType'
                obj.cell2xml(element,iTc);
            case{'coder.ClassType','coder.StringType'}
                obj.class2xml(element,iTc);
            case 'coder.OutputType'
                obj.outputType2xml(element,iTc);
            otherwise
                assert(false,['Do not know how to serialize type: ',class(iTc)]);
            end
        end

        function setUserDefined(obj,isUserDefined)
            obj.userDefined=isUserDefined;
        end
    end

    methods(Access=private)


        function addXMLNodeProperty(obj,element,propName,propValue)
            switch class(propValue)
            case 'logical'
                if propValue
                    text='true';
                else
                    text='false';
                end
                propNode=text;
            case 'double'
                propNode=num2str(propValue,20);
            case 'int32'
                propNode=num2str(propValue);
            otherwise
                propNode=propValue;
            end

            propElement=obj.createXMLNode(propName);
            obj.setXMLNodeTextContent(propElement,propNode);
            obj.appendXMLNodeChild(element,propElement);
        end



        function addItyProperty(obj,element,iTy,propName,propNameToUse)
            propValue=iTy.(propName);
            if(nargin==4)
                obj.addXMLNodeProperty(element,propName,propValue);
            else
                obj.addXMLNodeProperty(element,propNameToUse,propValue);
            end
        end



        function q=quote(~,s)
            q=['''',s,''''];
        end



        function q=Quote(obj,s)
            q=obj.quote([upper(s(1)),s(2:end)]);
        end



        function addContainerProperties(obj,element,iTy)
            obj.addItyProperty(element,iTy,'TypeName');
            obj.addItyProperty(element,iTy,'Extern');
            obj.addItyProperty(element,iTy,'HeaderFile');
            obj.addItyProperty(element,iTy,'Alignment');
        end

        function const2xml(obj,element,iTc)
            obj.addXMLNodeProperty(element,'Constant','true');


            valueConstructor=iTc.ValueConstructor;
            if isempty(valueConstructor)
                valueConstructor=coderapp.internal.value.valueToExpression(iTc.Value,Inf,true);
            end
            if~isempty(valueConstructor)
                obj.addXMLNodeProperty(element,'InitialValue',valueConstructor);
            end
        end



        function struct2xml(obj,element,iTy)
            obj.addContainerProperties(element,iTy);
            iTyFieldNames=fieldnames(iTy.Fields);

            for i=1:numel(iTyFieldNames)
                fldITY=iTy.Fields.(iTyFieldNames{i});
                fldElement=obj.createXMLNode('Field');
                obj.appendXMLNodeChild(element,fldElement);
                obj.serialize(obj.xmlDoc,fldElement,fldITY,iTyFieldNames{i});
            end
        end



        function numeric2xml(obj,element,iTy)
            obj.addItyProperty(element,iTy,'Complex');
            obj.addItyProperty(element,iTy,'Sparse');
            obj.addItyProperty(element,iTy,'Gpu');
        end



        function numerictype2xml(obj,element,nt)
            function addNTProperty(propName,propValue)
                obj.addXMLNodeProperty(ntElement,propName,propValue)
            end

            function b=hasSignednessAndWordLength()
                b=~nt.isboolean&&~nt.isfloat;
            end

            function b=hasFractionLength()
                b=nt.isscalingbinarypoint;
            end

            function b=hasSlopeAndBias()
                b=nt.isscalingslopebias;
            end

            ntElement=obj.createXMLNode('numerictype');
            obj.appendXMLNodeChild(element,ntElement);

            addNTProperty('DataTypeMode',obj.quote(nt.DataTypeModeNoWarning));

            if hasSignednessAndWordLength()
                addNTProperty('Signedness',obj.quote(nt.Signedness));
                addNTProperty('WordLength',nt.WordLength);
            end

            if hasFractionLength()
                addNTProperty('FractionLength',nt.FractionLength);
            end

            if hasSlopeAndBias()
                addNTProperty('Slope',nt.Slope);
                addNTProperty('Bias',nt.Bias);
            end
        end



        function fimath2xml(obj,element,fm)
            function addFMProperty(propName,propValue)
                obj.addXMLNodeProperty(fmElement,propName,propValue)
            end

            fmElement=obj.createXMLNode('fimath');
            obj.appendXMLNodeChild(element,fmElement);

            addFMProperty('RoundMode',obj.Quote(fm.RoundingMethod));
            addFMProperty('OverflowMode',obj.Quote(fm.OverflowAction));
            addFMProperty('ProductMode',obj.quote(fm.ProductMode));
            if strcmp(fm.ProductMode,'FullPrecision')
                addFMProperty('MaxProductWordLength',fm.MaxProductWordLength);
            else
                addFMProperty('ProductWordLength',fm.ProductWordLength);
                if strcmp(fm.ProductMode,'SpecifyPrecision')
                    addFMProperty('ProductFractionLength',fm.ProductFractionLength);
                end
            end

            addFMProperty('SumMode',obj.quote(fm.SumMode));
            if strcmp(fm.SumMode,'FullPrecision')
                addFMProperty('MaxSumWordLength',fm.MaxSumWordLength);
            else
                addFMProperty('SumWordLength',fm.SumWordLength);
                if strcmp(fm.SumMode,'SpecifyPrecision')
                    addFMProperty('SumFractionLength',fm.SumFractionLength);
                end
            end

            addFMProperty('CastBeforeSum',fm.CastBeforeSum);
        end



        function fi2xml(obj,element,iTy)
            obj.addItyProperty(element,iTy,'Complex');
            obj.numerictype2xml(element,iTy.NumericType);

            if~isempty(iTy.Fimath)
                obj.fimath2xml(element,iTy.Fimath);
                obj.addXMLNodeProperty(element,'fimathislocal',true);
            else
                obj.addXMLNodeProperty(element,'fimathislocal',false);
            end
        end



        function enum2xml(obj,element,~)
            obj.addXMLNodeProperty(element,'Enum',true);
        end



        function cell2xml(obj,element,iTy)
            obj.addXMLNodeProperty(element,'Homogeneous',iTy.isHomogeneous());
            obj.addContainerProperties(element,iTy);
            cellVariableName='';
            if~isempty(iTy.Cells)
                if(iTy.isHomogeneous())
                    cellElement=obj.createXMLNode('Field');
                    obj.appendXMLNodeChild(element,cellElement);
                    baseType=iTy.Cells{1};
                    for i=2:numel(iTy.Cells)
                        baseType=baseType.union(iTy.Cells{i});
                    end
                    obj.serialize(obj.xmlDoc,cellElement,baseType,[cellVariableName,'{:}']);
                else
                    indices=cell(1,numel(iTy.SizeVector));
                    for i=1:numel(iTy.Cells)
                        cellITy=iTy.Cells{i};
                        cellElement=obj.createXMLNode('Field');
                        obj.appendXMLNodeChild(element,cellElement);
                        [indices{:}]=ind2sub(iTy.SizeVector,i);
                        cellName=[cellVariableName,'{'];
                        for k=1:numel(indices)
                            if(k==numel(indices))
                                cellName=sprintf('%s%d',cellName,indices{k});
                            else
                                cellName=sprintf('%s%d, ',cellName,indices{k});
                            end
                        end
                        cellName=[cellName,'}'];%#ok<AGROW>
                        obj.serialize(obj.xmlDoc,cellElement,cellITy,cellName);
                    end
                end
            end
        end



        function class2xml(obj,element,iTy)
            if strcmp(iTy.ClassName,'string')
                propertyElement=obj.createXMLNode('Field');
                obj.appendXMLNodeChild(element,propertyElement);
                obj.serialize(obj.xmlDoc,propertyElement,iTy.Properties.Value,'{1}');
            else
                propertyNames=fieldnames(iTy.Properties);
                for i=1:length(propertyNames)
                    propertyElement=obj.createXMLNode('Field');
                    obj.addXMLNodeProperty(propertyElement,'ClassDefinedIn',iTy.getClassDefinedIn(i));
                    obj.appendXMLNodeChild(element,propertyElement);
                    obj.serialize(obj.xmlDoc,propertyElement,iTy.Properties.(propertyNames{i}),propertyNames{i});
                end
            end
        end



        function size2xml(obj,element,iTy)
            dimSizes=cell(length(iTy.SizeVector),1);
            for i=1:length(iTy.SizeVector)
                if~isempty(iTy.VariableDims)&&iTy.VariableDims(i)
                    prefix=':';
                else
                    prefix='';
                end
                if iTy.SizeVector(i)==intmax('int32')
                    dimSizes{i}=[prefix,'inf'];
                else
                    dimSizes{i}=[prefix,num2str(iTy.SizeVector(i))];
                end
            end
            delim='';
            sizeStr='';
            for i=1:numel(dimSizes)
                sizeStr=[sizeStr,delim,dimSizes{i}];%#ok<AGROW>
                delim=' x ';
            end
            sizeElement=obj.createXMLNode('Size');
            obj.setXMLNodeTextContent(sizeElement,sizeStr);
            obj.appendXMLNodeChild(element,sizeElement);
        end



        function outputType2xml(obj,element,iTy)
            refElement=obj.createXMLNode('OutputReference');
            obj.setXMLNodeAttribute(refElement,'FunctionName',iTy.FunctionName);
            obj.setXMLNodeAttribute(refElement,'OutputIndex',num2str(iTy.OutputIndex));
            obj.appendXMLNodeChild(element,refElement);
        end
    end
end
