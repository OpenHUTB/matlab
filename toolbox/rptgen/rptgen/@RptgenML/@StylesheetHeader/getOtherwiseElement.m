function oEl=getOtherwiseElement(this,chEl)




    if nargin<2
        chEl=this.getChooseElement;
    end

    if isempty(chEl)
        oEl=[];
        return;
    end

    oEl=com.mathworks.toolbox.rptgencore.tools.RgXmlUtils.findNextElementByTagName(chEl.getFirstChild,'xsl:otherwise');
    if isempty(oEl)
        oEl=chEl.getOwnerDocument.createElement('xsl:otherwise');
        chEl.appendChild(oEl);
    end

