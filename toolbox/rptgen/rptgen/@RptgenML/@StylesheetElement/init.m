function this=init(this,parentObj,javaHandle,ssPosition,varargin)






    insertBeforeNode=[];
    if~isempty(parentObj)


        if nargin<4||isempty(ssPosition)||(ischar(ssPosition)&&strcmpi(ssPosition,'-last'))
            connect(this,parentObj,'up');
        elseif(rptgen.use_java&&isa(ssPosition,'org.w3c.dom.Node'))||isa(ssPosition,'matlab.io.xml.dom.Node')
            firstChild=parentObj.down;
            if isempty(firstChild)
                connect(this,parentObj,'up');
            else
                connect(this,firstChild,'right');
            end
            insertBeforeNode=ssPosition;
        elseif ischar(ssPosition)&&strcmpi(ssPosition,'-first')
            firstChild=parentObj.down;
            if isempty(firstChild)
                connect(this,parentObj,'up');
            else
                connect(this,firstChild,'right');
                insertBeforeNode=firstChild.JavaHandle;
            end
        elseif isa(ssPosition,'RptgenML.StylesheetElement')
            connect(this,ssPosition,'left');
            insertBeforeNode=ssPosition.JavaHandle.getNextSibling;
            if isempty(insertBeforeNode)

                insertBeforeNode=ssPosition.JavaHandle.getOwnerDocument.createTextNode(' ');
                ssPosition.JavaHandle.getParentNode.appendChild(insertBeforeNode);
            end
        else
            warning(message('rptgen:RptgenML_StylesheetElement:unknownDataTypeMsg'));
        end

    end

    if(rptgen.use_java&&isa(javaHandle,'com.mathworks.toolbox.rptgen.xml.StylesheetCustomizationParser'))||...
        isa(javaHandle,'mlreportgen.re.internal.ui.StylesheetCustomizationParser')
        this.JavaHandle=javaHandle.getParamStylesheetElement;
        this.DescriptionShort=javaHandle.getParamDescriptionShort;
        this.DescriptionLong=javaHandle.getParamDescriptionLong;
        this.DataType=javaHandle.getParamDataType;
    elseif(rptgen.use_java&&isa(javaHandle,'org.w3c.dom.Element'))||isa(javaHandle,'matlab.io.xml.dom.Element')
        this.JavaHandle=javaHandle;
    elseif isa(javaHandle,'RptgenML.StylesheetElement')
        this.JavaHandle=javaHandle.JavaHandle;
        this.DescriptionShort=javaHandle.DescriptionShort;
        this.DescriptionLong=javaHandle.DescriptionLong;
        this.DataType=javaHandle.DataType;

        if isLibrary(javaHandle)

        else

            doDelete(javaHandle);
        end
    else
        warning(message('rptgen:RptgenML_StylesheetElement:invalidInputArguments'));
    end

    if~isempty(insertBeforeNode)

        insertBeforeNode.getParentNode.insertBefore(this.JavaHandle,insertBeforeNode);
    end

    RptgenML.checkDuplicateStylesheetID(this);



