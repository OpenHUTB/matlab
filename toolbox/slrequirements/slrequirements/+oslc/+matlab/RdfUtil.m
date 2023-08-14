classdef RdfUtil<handle






    properties(Access=private)
isValid
resource
head
inner
tail
nodes
links
nextNodeId
xmlNamespaces
ibmNSPrefix
    end

    properties(Constant,Access=private)
        rdfStatementType='http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement';
        ibmNS='http://www.ibm.com/xmlns/rdm/types/';
        ibmLinkType='http://www.ibm.com/xmlns/rdm/types/Link';
        linkTagPattern='<[^:]+:Link rdf:resource="([^"]+)"/>';
        nodeTagPattern='<rdf:Description rdf:nodeID="A(\d+)">(.+?)</rdf:Description>';
        rdfDescriptionTag='rdf:Description';
        rdfTag='rdf:RDF';
    end

    methods(Static)

        function rdf=addLink(rdf,url,label,linkType)


            instance=oslc.matlab.RdfUtil(rdf);
            if~instance.isValid
                rmiut.warnNoBacktrace('RdfUtil parser error');
                return;
            end
            if~isempty(linkType)
                label=[linkType,': ',label];
            end
            linkAdded=instance.addOutgoingLink(url,label);
            if linkAdded
                rdf=instance.toRdfString();
            else
                rdf='';
            end

        end

    end

    methods(Access=private)


        function this=RdfUtil(rdf)
            this.isValid=false;
            mainBodyTag=oslc.matlab.RdfUtil.rdfDescriptionTag;
            pattern=['^(.+)<',mainBodyTag,' rdf:about="([^"]+)">(.+?)</',mainBodyTag,'>(\s.+)$'];
            matched=regexp(rdf,pattern,'tokens');
            if isempty(matched)
                return;
            end
            this.head=matched{1}{1};
            this.resource=matched{1}{2};
            this.inner=matched{1}{3};
            this.tail=matched{1}{4};
            this.parseSupportingNodes();
            this.parseLinks();
            this.setNextNodeId();
            this.isValid=true;
            this.parseXmlNamespaces();
        end

        function parseXmlNamespaces(this)
            this.xmlNamespaces=containers.Map('KeyType','char','ValueType','char');



            matches=regexp(this.head,'\s(xmlns:[^=]+)="([^"]+)"','tokens');
            for i=1:length(matches)
                this.xmlNamespaces(matches{i}{2})=matches{i}{1};
            end
        end

        function parseSupportingNodes(this)

            this.nodes={};
            matched=regexp(this.head,oslc.matlab.RdfUtil.nodeTagPattern,'tokens');
            if~isempty(matched)
                for i=1:size(matched,2)
                    this.nodes{end+1}=struct('id',matched{i}{1},'data',matched{i}{2});
                end
            end
            matched=regexp(this.tail,oslc.matlab.RdfUtil.nodeTagPattern,'tokens');
            if~isempty(matched)
                for i=1:size(matched,2)
                    this.nodes{end+1}=struct('id',matched{i}{1},'data',matched{i}{2});
                end
            end
        end

        function setNextNodeId(this)
            this.nextNodeId=0;
            for i=1:length(this.nodes)
                j=str2num(this.nodes{i}.id);%#ok<ST2NM>
                if j>=this.nextNodeId
                    this.nextNodeId=j+1;
                end
            end
        end

        function parseLinks(this)
            this.links={};
            matched=regexp(this.inner,oslc.matlab.RdfUtil.linkTagPattern,'tokens');
            if~isempty(matched)
                for i=1:size(matched,2)
                    this.links{end+1}=matched{i}{1};
                end
            end
        end

        function tf=linkExists(this,url)
            tf=any(contains(this.links,url));
        end

        function result=addOutgoingLink(this,url,label)

            if this.linkExists(url)
                result=false;
            else
                this.ensureNameSpaceInfo();
                this.addLinkReference(url);
                this.addLinkNodeData(url,label);
                result=true;
            end
        end

        function result=outgoingLinkProperties(this,url,label)
            subject=sprintf('<rdf:subject rdf:resource="%s"/>',this.resource);
            predicate=sprintf('<rdf:predicate rdf:resource="%s"/>',oslc.matlab.RdfUtil.ibmLinkType);
            object=sprintf('<rdf:object rdf:resource="%s"/>',url);
            type=sprintf('<rdf:type rdf:resource="%s"/>',oslc.matlab.RdfUtil.rdfStatementType);
            title=sprintf('<dcterms:title>%s</dcterms:title>',this.sanitise(label));
            result=sprintf('\n       %s\n       %s\n       %s\n       %s\n       %s\n',...
            subject,predicate,object,type,title);
        end

        function result=toRdfString(this)
            mainBodyTag=oslc.matlab.RdfUtil.rdfDescriptionTag;
            result=sprintf('%s<%s rdf:about="%s">%s  </%s>%s',...
            this.head,mainBodyTag,this.resource,this.inner,mainBodyTag,this.tail);
        end

        function addLinkReference(this,url)



            [~,linkTag]=strtok(this.ibmNSPrefix,':');
            if~isempty(linkTag)
                linkTag(1)=[];
                newLink=sprintf('<%s:Link rdf:resource="%s"/>',linkTag,url);
                this.inner=[this.inner,'  ',newLink,newline];
            end
        end

        function addLinkNodeData(this,url,label)









            newNode=oslc.matlab.RdfUtil.nodeTagPattern;
            qwts=find(newNode=='"');
            nextIdString=sprintf('A%d',this.nextNodeId);
            newNode=[newNode(1:qwts(1)),nextIdString,newNode(qwts(end):end)];
            propsRDF=this.outgoingLinkProperties(url,label);
            gt=find(newNode=='>');
            lt=find(newNode=='<');
            newNode=[newNode(1:gt(1)),propsRDF,'  ',newNode(lt(2):end)];
            rdfEndPattern=['\s+</',oslc.matlab.RdfUtil.rdfTag,'>'];
            this.tail=regexprep(this.tail,rdfEndPattern,[newline,'  ',newNode,'$0']);
        end

        function ensureNameSpaceInfo(this)



            if any(strcmp(this.xmlNamespaces.keys,this.ibmNS))
                this.ibmNSPrefix=this.xmlNamespaces(this.ibmNS);
            else
                this.setNextNSPrefix();
                rdfStartTag=['<',oslc.matlab.RdfUtil.rdfTag];
                rdfStartPattern=[rdfStartTag,'\s+'];
                rdfStart=[rdfStartTag,newline,'    '];
                this.head=regexprep(this.head,rdfStartPattern,...
                [rdfStart,this.ibmNSPrefix,'="',this.ibmNS,'"',newline,'    ']);
            end
        end

        function setNextNSPrefix(this)

            count=0;
            this.ibmNSPrefix=sprintf('xmlns:j.%d',count);
            while any(strcmp(this.xmlNamespaces.values,this.ibmNSPrefix))
                count=count+1;
                this.ibmNSPrefix=sprintf('xmlns:j.%d',count);
            end
        end

        function out=sanitise(~,in)
            out=in;


            badChars='<>&';
            for i=1:length(badChars)
                badChar=badChars(i);
                if any(out==badChar)
                    replacement=urlencode(badChar);
                    out=strrep(out,badChar,replacement);
                end
            end
        end

    end

end



































