function storedValue=setJavaHandle(this,proposedValue)





    parentDoc=[];
    parentNode=[];

    if~isempty(this.up)
        try
            if isa(this.up,'RptgenML.StylesheetHeader')
                parentNode=getChooseElement(this.up);
            else
                parentNode=this.up.JavaHandle;
                if(rptgen.use_java&&isa(parentNode,'com.mathworks.toolbox.rptgen.xml.StylesheetEditor'))||...
                    isa(parentNode,'mlreportgen.re.internal.ui.StylesheetEditor')
                    try
                        parentNode=parentNode.getCode;
                    catch ME
                        warning(ME.message);
                    end
                end
            end
            try
                parentDoc=getOwnerDocument(parentNode);
            catch ME %#ok
            end
        catch ME %#ok
        end
    end


    if(isempty(parentDoc)||...
        (~isempty(proposedValue.getOwnerDocument)&&...
        (proposedValue.getOwnerDocument==parentDoc)))

    else
        try
            proposedValue=parentDoc.importNode(proposedValue,...
            true);
        catch ME
            warning(ME.message);
        end
    end


    if(isempty(parentNode)||...
        (~isempty(proposedValue.getParentNode)&&...
        (proposedValue.getParentNode==parentNode)))

    else
        try
            parentNode.appendChild(proposedValue);

        catch ME
            warning(ME.message);
        end
    end

    storedValue=proposedValue;

