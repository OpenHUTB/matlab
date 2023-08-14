classdef Element<handle



    properties

Name
Side
        XPath=''
        XForm=''

    end

    methods

        function this=Element(name,side)
            this.Name=name;
            this.Side=side;
        end

        function xform=getXForm(this)
            if isempty(this.XForm)
                xform=getDefaultXForm(this);
            else
                xform=this.XForm;
            end
        end

        function xpath=getXPath(this)
            if isempty(this.XPath)
                xpath=getDefaultXPath(this);
            else
                xpath=this.XPath;
            end
        end

        function xform=getParsedXForm(this,jDoc)


            xformStr=sprintf('<xsl:if test="1">%s</xsl:if>',getXForm(this));
            xFormReader=java.io.StringReader(xformStr);
            xFormSrc=org.xml.sax.InputSource(xFormReader);
            factory=javax.xml.parsers.DocumentBuilderFactory.newInstance();
            builder=factory.newDocumentBuilder();
            xFormDoc=builder.parse(xFormSrc);
            xform=jDoc.importNode(xFormDoc.getDocumentElement(),true);
        end

        function save(this,elCE)
            elCE.setAttribute('mcos-class',class(this));
            elCE.setAttribute('name',this.Name);
            elCE.setAttribute('side',this.Side);
            if~isempty(this.XPath)
                elCE.setAttribute('xpath',this.XPath);
            end
            if~isempty(this.XForm)
                elCE.setAttribute('xform',this.XForm);
            end
        end

        function loadSelf(this,elCE)
            this.Name=char(elCE.getAttribute('name'));
            this.Side=char(elCE.getAttribute('side'));
            this.XPath=char(elCE.getAttribute('xpath'));
            this.XForm=char(elCE.getAttribute('xform'));
        end


    end

    methods(Static)

        function tagName=getTagName
            tagName='tp_element';
        end

        function ce=load(elCE)
            ctor=str2func(char(elCE.getAttribute('mcos-class')));
            ce=ctor();
            ce.loadSelf(elCE);
        end


    end

    methods(Abstract)

        getDefaultXPath(this)
        getDefaultXForm(this)
        appendFormat(this,cell,jDoc)

    end


end