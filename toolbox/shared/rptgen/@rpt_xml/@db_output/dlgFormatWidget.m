function wFormat=dlgFormatWidget(this,varargin)







    formatID=set(this,'Format');formatID=formatID(:)';


    visibleIndex=[];
    for i=1:length(formatID)
        id=formatID{i};
        switch id
        case{'dom-docx','dom-html-file','dom-htmx','dom-pdf-direct'}
            visibleIndex(end+1)=i;%#ok<AGROW>
        case 'dom-pdf'
            if ispc
                visibleIndex(end+1)=i;%#ok<AGROW>
            end
        otherwise
            if rptgen.use_java
                format=com.mathworks.toolbox.rptgencore.output.OutputFormat.getFormat(formatID(i));
            else
                format=rptgen.internal.output.OutputFormat.getFormat(formatID(i));
            end
            if getVisible(format)||...
                strcmp(id,this.Format)
                visibleIndex(end+1)=i;%#ok<AGROW>
            end
        end
    end

    theProp=struct(findprop(this,'Format'));
    theEnum=findtype(theProp.DataType);
    allValues=[theEnum.Strings(:),theEnum.DisplayNames(:)];
    allValues=allValues(visibleIndex,:);
    theProp.DataType=allValues;

    wFormat=this.dlgWidget(theProp,...
    'DialogRefresh',true,...
    varargin{:});
