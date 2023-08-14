function found_handle=getLineUnique(lineInfo)



















    import slxmlcomp.internal.line.getLine;

    linePath=lineInfo.Path;
    lineHandle=getLine(linePath);

    if numel(lineHandle)>1


        for i=1:numel(lineHandle)
            found_handle=findSegment(lineHandle(i),lineInfo,[]);
            if~isempty(found_handle)
                found_handle=lineHandle(i);
                return
            end
        end

        found_handle=[];
        return
    elseif numel(lineHandle)<1||~ishandle(lineHandle)

        error('SimulinkXMLComparison:line:locate',getErrorMessage(linePath));
    else
        found_handle=lineHandle;
    end
end

function message=getErrorMessage(argument)
    locale=java.util.Locale.getDefault();
    loader=java.lang.ClassLoader.getSystemClassLoader();
    resourcePath='com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.customization.type.line.resources.RES_Line';
    bundle=java.util.ResourceBundle.getBundle(resourcePath,locale,loader);
    key='unable.to.locate.line';
    message=char(java.text.MessageFormat.format(bundle.getString(key),argument));
end

function[foundHandle,handlesSearched]=findSegment(sourceHandle,lineInfo,handlesSearched)
    foundHandle=[];

    slLine=slxmlcomp.internal.line.Line(sourceHandle);
    handlesSearched=[handlesSearched,sourceHandle];
    if get_param(sourceHandle,'ZOrder')==slLine.ZOrder...
        &&strcmp(slLine.Points,lineInfo.Points)
        foundHandle=sourceHandle;
        return
    end

    children=get_param(sourceHandle,'LineChildren');

    for ii=1:numel(children)
        if~any(handlesSearched==children(ii))
            [foundHandle,handlesSearched]=findSegment(children(ii),lineInfo,handlesSearched);
        end

        if~isempty(foundHandle)
            return
        end
    end

end
