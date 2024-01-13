classdef XmlHelper

    methods(Static=true)

        function str=getURIpath(str,escapeSpecialChars)
            if nargin<2
                escapeSpecialChars=true;
            end

            try
                str=char(mlreportgen.utils.fileToURI(str));
                if~escapeSpecialChars
                    str=polyspace.util.XmlHelper.unEscapeCharacterForXml(str,true);
                end

                if~isempty(regexp(str,'file://\w','once'))
                    str=regexprep(str,'file://','file:////','once');
                end
            catch mExc
                error('polyspace:pscore:cannotConvertToUri',...
                message('polyspace:pscore:cannotConvertToUri',strrep(str,'\','\\'),mExc.message).getString())
            end
        end


        function path=getPathFromURI(uri)

            obj=matlab.net.URI(uri);
            if ispc

                path=fullfile(obj.Path{:});
            else
                path=fullfile('/',obj.Path{:});
            end
            path=urldecode(path);
        end


        function str=escapeCharacterForXml(str,isURI)
            if nargin<2
                isURI=false;
            end

            if isURI
                str=strrep(str,' ','%20');
                str=strrep(str,'\','/');
            end

            str=strrep(str,'&','&amp;');
            str=strrep(str,'<','&#60;');
            str=strrep(str,'>','&#62;');
            str=strrep(str,'"','&quot;');
            str=strrep(str,'''','&apos;');
        end


        function str=unEscapeCharacterForXml(str,isURI)
            if nargin<2
                isURI=false;
            end

            if isURI
                str=strrep(str,'%20',' ');
            end

            str=strrep(str,'&amp;','&');
            str=strrep(str,'&#60;','<');
            str=strrep(str,'&#62;','>');
            str=strrep(str,'&quot;','"');
            str=strrep(str,'&apos;','''');
        end


        function nodeList=getNodesList(parentNode,nodeTag,nodeAttribName,nodeAttribValue)
            import matlab.io.xml.dom.*

            if nargin<4
                nodeAttribValue=[];
            end
            if nargin<3
                nodeAttribName=[];
            end

            useAttrib=~isempty(nodeAttribName);

            xmlDoc=parentNode.getOwnerDocument();

            nodeList={};
            expr=['.//',nodeTag];
            if isa(parentNode,'matlab.io.xml.dom.Document')
                nodeResult=evaluate(xmlDoc,expr,matlab.io.xml.dom.XPathResult.ORDERED_NODE_SNAPSHOT_TYPE);
            else
                nodeResult=evaluate(xmlDoc,expr,parentNode,matlab.io.xml.dom.XPathResult.ORDERED_NODE_SNAPSHOT_TYPE);
            end
            nNodes=nodeResult.getSnapshotLength();
            for i=1:nNodes
                snapshotItem(nodeResult,i-1);
                node=getNodeValue(nodeResult);
                if useAttrib
                    attr=node.getAttributes();
                    currFlagname=attr.getNamedItem(nodeAttribName);
                    if~isempty(currFlagname)&&strcmpi(currFlagname.Value,nodeAttribValue)

                        nodeList{end+1}=node;%#ok<AGROW>
                    end
                else

                    nodeList{end+1}=node;%#ok<AGROW>
                end
            end
        end


        function selectedNode=selectNode(parentNode,nodeTag,nodeAttribName,nodeAttribValue)
            import matlab.io.xml.dom.*

            if nargin<4
                nodeAttribValue=[];
            end
            if nargin<3
                nodeAttribName=[];
            end

            useAttrib=~isempty(nodeAttribName);

            xmlDoc=parentNode.getOwnerDocument();

            selectedNode=[];
            expr=['./',nodeTag];
            if isa(parentNode,'matlab.io.xml.dom.Document')
                nodeResult=evaluate(xmlDoc,expr,matlab.io.xml.dom.XPathResult.ORDERED_NODE_SNAPSHOT_TYPE);
            else
                nodeResult=evaluate(xmlDoc,expr,parentNode,matlab.io.xml.dom.XPathResult.ORDERED_NODE_SNAPSHOT_TYPE);
            end
            nNodes=nodeResult.getSnapshotLength();
            for i=1:nNodes
                snapshotItem(nodeResult,i-1);
                node=getNodeValue(nodeResult);
                if useAttrib
                    attr=node.getAttributes();
                    currFlagname=attr.getNamedItem(nodeAttribName);
                    if~isempty(currFlagname)&&strcmpi(currFlagname.Value,nodeAttribValue)

                        selectedNode=node;
                        return
                    end
                else

                    selectedNode=node;
                    return
                end
            end
        end


        function newNode=getOrAddNode(parentNode,nodeTag,nodeValue,nodeAttribName,nodeAttribValue,allowDuplicate)
            import matlab.io.xml.dom.*

            if nargin<6
                allowDuplicate=false;
            end

            useAttrib=~isempty(nodeAttribName);
            newNode=polyspace.util.XmlHelper.selectNode(parentNode,nodeTag,nodeAttribName,nodeAttribValue);
            if~isempty(newNode)&&(allowDuplicate==false)
                return
            end
            xmlDoc=parentNode.getOwnerDocument();
            newNode=createElement(xmlDoc,nodeTag);
            if useAttrib
                newNode.setAttribute(nodeAttribName,nodeAttribValue);
            end
            if~isempty(nodeValue)
                newNode.setTextContent(nodeValue);
            end
            appendChild(parentNode,newNode);
        end


        function existingList=getNamedElements(node,eName)
            import matlab.io.xml.dom.*
            elementsList=polyspace.util.XmlHelper.getNodesList(node,eName);
            existingList=cell(1,numel(elementsList));
            for kk=1:numel(elementsList)
                thisElementItem=elementsList{kk};
                existingList{kk}=thisElementItem.getTextContent();
            end
        end


        function ret=isXML(fileName)
            xmlTag='<?xml';
            ret=false;
            if exist(fileName,'file')
                fid=fopen(fileName,'r','native','UTF-8');

                tline=fgetl(fid);

                if~isempty(tline)&&ischar(tline)&&contains(tline,xmlTag)
                    ret=true;
                end
                fclose(fid);
            end
        end


        function xmlDoc=readXmlFile(fileName)
            import matlab.io.xml.dom.*

            try
                xmlParser=Parser;
                xmlParser.Configuration.Namespaces=false;
                xmlDoc=parseFile(xmlParser,fileName);
            catch Me
                msg=message('polyspace:gui:pslink:failOpenXml',fileName,Me.message).getString();
                newMe=MException('pslink:failOpenXml',msg);
                throwAsCaller(newMe);
            end
        end


        function prettyWrite(xmlDoc,fileName)
            import matlab.io.xml.dom.*

            writer=matlab.io.xml.dom.DOMWriter;
            writer.Configuration.FormatPrettyPrint=true;
            writeToURI(writer,xmlDoc,fileName);


            dstName=tempname;
            fidSrc=fopen(fileName,'rt','native','UTF-8');
            fidDst=fopen(dstName,'w','native','UTF-8');
            while 1
                tline=fgetl(fidSrc);
                if~ischar(tline)
                    break
                end
                if~all(isspace(tline))
                    fprintf(fidDst,'%s\n',tline);
                end
            end
            fclose(fidSrc);
            fclose(fidDst);
            copyfile(dstName,fileName,'f');
        end
    end
end
