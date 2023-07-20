classdef Image<Rptgen.TitlePage.Element&Rptgen.TitlePage.HTML.ElementLayout




    methods

        function this=Image(side)
            this=this@Rptgen.TitlePage.Element('image',side);
            this=this@Rptgen.TitlePage.HTML.ElementLayout();
            this.RowNum=3;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/mediaobject';
        end

        function xform=getDefaultXForm(this)


            srcAttr=sprintf('<xsl:attribute name="src"><xsl:value-of select="%s/imageobject/imagedata/@fileref"/></xsl:attribute>',...
            getXPath(this));
            widthAttr=sprintf('<xsl:attribute name="width"><xsl:value-of select="%s/imageobject/imagedata/@width"/></xsl:attribute>',...
            getXPath(this));
            heightAttr=sprintf('<xsl:attribute name="height"><xsl:value-of select="%s/imageobject/imagedata/@depth"/></xsl:attribute>',...
            getXPath(this));
            xform=sprintf('<xsl:element name="img">%s%s%s</xsl:element>',...
            srcAttr,widthAttr,heightAttr);
        end


        function appendFormat(this,cell,jDoc)
            appendFormat@Rptgen.TitlePage.HTML.ElementLayout(this,cell,jDoc);
            div=jDoc.createElement('div');
            div.setAttribute('style','text-align:center');
            cell.appendChild(div);
            choose=jDoc.createElement('xsl:choose');
            div.appendChild(choose);
            when=jDoc.createElement('xsl:when');
            when.setAttribute('test',getXPath(this));
            choose.appendChild(when);
            apply=getParsedXForm(this,jDoc);
            when.appendChild(apply);
        end

        function save(this,elCE)
            save@Rptgen.TitlePage.Element(this,elCE);
            save@Rptgen.TitlePage.HTML.ElementLayout(this,elCE);
        end

        function loadSelf(this,elCE)
            loadSelf@Rptgen.TitlePage.Element(this,elCE);
            loadSelf@Rptgen.TitlePage.HTML.ElementLayout(this,elCE);
        end



    end




end