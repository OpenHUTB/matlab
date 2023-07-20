classdef Info<matlab.mixin.SetGet




    methods(Static)
        function addNewElementToArrayProperty(obj,propertyName,valueToSet)
            if isempty(obj.(propertyName))
                obj.(propertyName)=valueToSet;
            else
                obj.(propertyName)(end+1)=valueToSet;
            end
        end
        function ret=getElement(parentNode,name,format,indexNo)
            narginchk(2,4);
            isWithinACell=false;


            if parentNode.getNodeType==parentNode.ELEMENT_NODE
                elements=evaluate(matlab.io.xml.xpath.Evaluator,name,parentNode);
            else
                elements=[];
            end

            isWithinSubtree=false;
            if numel(elements)==0







                elementsInSubtree=evaluate(matlab.io.xml.xpath.Evaluator,['//',name],parentNode);
                isWithinSubtree=numel(elementsInSubtree)>0;
            end


            if nargin<4
                indexNo=0;
            else
                isWithinACell=true;
            end



            if(indexNo<numel(elements))&&hasSubNodes(elements(indexNo+1))
                formatGuess='struct';
                ret=[];
            elseif isWithinACell||numel(elements)<=1
                formatGuess='char';
                ret='';
            else
                formatGuess='cell';
                ret={};
            end
            if nargin<3||isempty(format)
                format=formatGuess;
            end


            if isequal(formatGuess,'struct')&&~ismember(format,{'struct','cell'})
                warning(['The format of the XML property ''%s'' cannot be'...
                ,'read as a ''%s'', using the format ''%s'' instead',...
                name,format,formatGuess]);
                format=formatGuess;
            end
            if numel(elements)>0||isWithinSubtree
                switch format
                case{'char','string'}
                    ret='';
                    if numel(elements)>0
                        item=elements(indexNo+1);
                        if~isempty(item.getFirstChild)
                            ret=char(item.getFirstChild.getData);
                        end
                    end
                case{'logical'}
                    ret=false;
                    if numel(elements)>0
                        item=elements(indexNo+1);
                        if~isempty(item.getFirstChild)
                            ret=isequal(char(item.getFirstChild.getData),'true');
                        end
                    end
                case{'struct','structure'}
                    if isWithinACell


                        ret=getStructureElement(elements(indexNo+1));
                    else


                        for i=1:numel(elements)

                            item=elements(i);
                            if i==1
                                ret=getStructureElement(item);
                            else
                                p=getStructureElement(item);
                                fr=fieldnames(ret);
                                fp=fieldnames(p);
                                if isequal(fr,fp)
                                    ret(i)=p;%#ok<AGROW>
                                else
                                    ufn=union(fr,fp);
                                    tmpRet1=[];
                                    tmpRet2=[];
                                    for jj=1:i-1
                                        for kk=1:numel(ufn)
                                            if ismember(ufn{kk},fr)
                                                tmpRet1(jj).(ufn{kk})=ret(jj).(ufn{kk});%#ok<AGROW>
                                            else
                                                tmpRet1(jj).(ufn{kk})='';%#ok<AGROW>
                                            end
                                        end
                                    end
                                    for kk=1:numel(ufn)
                                        if ismember(ufn{kk},fp)
                                            tmpRet2.(ufn{kk})=p.(ufn{kk});
                                        else
                                            tmpRet2.(ufn{kk})='';
                                        end
                                    end
                                    ret=[tmpRet1,tmpRet2];
                                end
                            end
                        end
                    end
                case{'double','numeric'}
                    ret=[];
                    for i=1:numel(elements)
                        item=elements(i);
                        if~isempty(item.getFirstChild)
                            ret=str2double(char(item.getFirstChild.getData));
                            assert(~isnan(ret),...
                            DAStudio.message('codertarget:build:DatatypeError',class(ret)));
                        end
                    end
                otherwise
                    ret={};
                    for i=1:numel(elements)
                        ret{end+1}=codertarget.Info.getElement(parentNode,name,'',i-1);%#ok<AGROW> 
                    end
                end
            end
            function ret=getStructureElement(item)
                if item.hasAttributes
                    theAttributes=item.getAttributes();
                    for k=1:theAttributes.getLength()
                        attrib=theAttributes.item(k-1);


                        attribName=char(attrib.getName);
                        attribName=regexprep(attribName,'[^\w]','_');
                        ret.(attribName)=char(attrib.getValue);
                    end
                end
                if item.hasChildNodes
                    childNodes=item.getChildNodes;
                    childNodeNames={};
                    formatToPassNode={};
                    count=1;


                    for j=0:childNodes.getLength-1
                        newChildNodeName=char(childNodes.item(j).getNodeName);
                        if nnz(ismember(childNodeNames,newChildNodeName))>0||...
                            childNodes.item(j).getNodeType~=1
                            continue;
                        end
                        childNodeNames{count}=newChildNodeName;%#ok<AGROW>
                        if childNodes.item(j).getChildNodes.getLength>1
                            formatToPassNode{count}='struct';%#ok<AGROW>
                        else
                            formatToPassNode{count}=[];%#ok<AGROW>
                        end
                        count=count+1;
                    end
                    for j=1:numel(childNodeNames)

                        nodeName=childNodeNames{j};
                        nodeName=regexprep(nodeName,'[^\w]','_');
                        ret.(nodeName)=...
                        codertarget.Info.getElement(item,...
                        childNodeNames{j},formatToPassNode{j});
                    end
                end
            end
            function ret=hasSubNodes(item)
                ret=~isempty(item)&&(~isempty(item.getFirstElementChild)||item.hasAttributes);
            end
        end
        function setElement(docObj,name,value,docNode)
            narginchk(3,4);
            if~isempty(value)
                if nargin<4||isempty(docNode)
                    docNode=docObj.getDocumentElement;
                end
                propElement=[];
                propNode=[];
                switch class(value)
                case 'struct'
                    structFieldNames=fieldnames(value);
                    attribOrSubnode=codertarget.Info.determineStructFieldsAttributesOrSubnodes(value,structFieldNames);
                    for ii=1:numel(value)
                        propElement=docObj.createElement(name);
                        for jj=1:numel(structFieldNames)
                            if attribOrSubnode(jj)
                                propElement.setAttribute(structFieldNames{jj},value(ii).(structFieldNames{jj}));
                            else
                                codertarget.Info.setElement(docObj,structFieldNames{jj},value(ii).(structFieldNames{jj}),propElement)
                            end
                        end
                        docNode.appendChild(propElement);
                    end
                case 'logical'
                    if value
                        text='true';
                    else
                        text='false';
                    end
                    propElement=docObj.createElement(name);
                    propNode=docObj.createTextNode(text);
                case 'char'
                    propElement=docObj.createElement(name);
                    propNode=docObj.createTextNode(value);
                case 'cell'
                    for i=1:numel(value)


                        if ischar(value{i})
                            valueToPass=codertarget.utils.replacePathSep(value{i});
                        else
                            valueToPass=value{i};
                        end
                        codertarget.Info.setElement(docObj,name,valueToPass,docNode);
                    end
                otherwise
                    for i=1:numel(value)
                        assert(isnumeric(value),...
                        DAStudio.message('codertarget:build:DatatypeError',class(value(i))));
                        codertarget.Info.setElement(docObj,name,num2str(value(i)),docNode);
                    end
                end
                if~isempty(propElement)&&~isempty(propNode)
                    propElement.appendChild(propNode);
                    docNode.appendChild(propElement);
                end
            end
        end

        function docObj=read(fileName)

            parser=matlab.io.xml.dom.Parser;
            docObj=parser.parseFile(fileName);
        end

        function write(fileName,docObj)


            writer=matlab.io.xml.dom.DOMWriter;
            writer.Configuration.FormatPrettyPrint=true;
            [~,~,~]=mkdir(fileparts(fileName));
            writer.writeToFile(docObj,fileName);
        end

        function docObj=createDocument(groupName)


            docObj=matlab.io.xml.dom.Document(groupName);
        end

        function group=createParameterGroup(docObj,parent,groupName)


            group=docObj.createElement(groupName);
            parent.appendChild(group);
        end

        function parameter=createParameter(docObj,parent,name)


            parameter=docObj.createElement(name);
            parent.appendChild(parameter);
        end

        function setAttribute(parameter,name,value)


            parameter.setAttribute(name,value);
        end
    end

    methods(Static,Hidden)
        function output=determineStructFieldsAttributesOrSubnodes(lStruct,lStructFieldNames)
            output=true(size(lStructFieldNames));
            for ii=1:numel(lStruct)
                for jj=1:numel(lStructFieldNames)





                    if~ischar(lStruct(ii).(lStructFieldNames{jj}))||...
                        (~isempty(lStruct(ii).(lStructFieldNames{jj}))&&...
                        isempty(regexp(lStruct(ii).(lStructFieldNames{jj}),'^[\w\.\$\(\)]*?$','once')))
                        output(jj)=false;
                    end
                end
            end
        end
    end
end