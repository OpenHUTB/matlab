function chEl=getChooseElement(this)




    import com.mathworks.toolbox.rptgencore.tools.RgXmlUtils;
    foEl=RgXmlUtils.findNextElementByTagName(this.JavaHandle.getFirstChild,'fo:block');
    if isempty(foEl)
        chEl=[];
    else
        chEl=RgXmlUtils.findNextElementByTagName(foEl.getFirstChild,'xsl:choose');
    end
