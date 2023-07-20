function result=getAsHTML(this,modelName,varargin)








    narginchk(2,3);
    filename=[];
    if nargin==3
        filename=varargin{1};
    end

    result=[];

    if strcmp(get_param(modelName,'SampleTimesAreReady'),'off')
        MSLDiagnostic('Simulink:utility:NoSampleTimeLegendDataToPrint').reportAsWarning;
        return
    end
    import matlab.io.xml.dom.*
    docNode=Document('http://www.w3.org/1999/xhtml','html');
    doctype=createDocumentType(docNode,'html',...
    '-//W3C//DTD XHTML 1.0 Strict//EN',...
    'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd');
    appendChild(docNode,doctype);
    htmlNode=docNode.getDocumentElement;
    htmlNode.setAttribute('xmlns','http://www.w3.org/1999/xhtml');

    head=docNode.createElement('head');
    htmlNode.appendChild(head);

    title=docNode.createElement('title');
    title.appendChild(docNode.createTextNode(DAStudio.message('Simulink:utility:SampleTimeLegendTitleWithModel',modelName)));
    head.appendChild(title);

    style=docNode.createElement('style');
    style.setAttribute('type','text/css');
    style.appendChild(docNode.createTextNode([...
'body{font-family:sans-serif;font-size:9pt}'...
    ,'td,th{padding:4px;vertical-align:top}']...
    ));
    head.appendChild(style);

    body=docNode.createElement('body');
    htmlNode.appendChild(body);

    h4=docNode.createElement('h4');
    h4.setAttribute('style','text-align:center');
    h4.appendChild(docNode.createTextNode(DAStudio.message('Simulink:utility:SampleTimesFor',modelName)));
    body.appendChild(h4);

    table=docNode.createElement('table');
    table.setAttribute('style','text-align:left;margin:auto');
    body.appendChild(table);

    tr=docNode.createElement('tr');
    table.appendChild(tr);

    th=docNode.createElement('th');
    th.appendChild(docNode.createTextNode(DAStudio.message('Simulink:utility:ColorWithoutColon')));
    tr.appendChild(th);

    th=docNode.createElement('th');
    th.appendChild(docNode.createTextNode(DAStudio.message('Simulink:utility:AnnotationWithoutColon')));
    tr.appendChild(th);

    th=docNode.createElement('th');
    th.appendChild(docNode.createTextNode(DAStudio.message('Simulink:utility:DescriptionWithoutColon')));
    tr.appendChild(th);

    th=docNode.createElement('th');
    th.appendChild(docNode.createTextNode(DAStudio.message('Simulink:utility:ValueWithoutColon')));
    tr.appendChild(th);

    legendData=get_param(modelName,'SampleTimes');
    numTs=length(legendData);

    if isempty(this.modelList)
        tabIdx=0;
    else
        tabIdx=find(strcmp(this.modelList,modelName));
        if isempty(tabIdx)
            tabIdx=0;
        end
    end

    for idx=1:numTs
        color=uint32(legendData(idx).ColorRGBValue*255);
        colorStr=sprintf('rgb(%d,%d,%d)',color(1),color(2),color(3));

        tr=docNode.createElement('tr');
        table.appendChild(tr);

        td=docNode.createElement('td');
        tr.appendChild(td);

        div=docNode.createElement('div');
        div.setAttribute('style',['background-color:',colorStr]);
        div.appendChild(docNode.createTextNode(char(160)));
        td.appendChild(div);

        td=docNode.createElement('td');
        td.appendChild(docNode.createTextNode(legendData(idx).Annotation));
        tr.appendChild(td);

        td=docNode.createElement('td');
        td.appendChild(docNode.createTextNode(legendData(idx).Description));
        tr.appendChild(td);

        td=docNode.createElement('td');
        tr.appendChild(td);


        invertTime=strcmp(get_param(modelName,'ShowInverseOfPeriodInSampleTimeLegend'),'on');
        [valData,valDataInv]=Simulink.SampleTimeLegend.getValueStringAllowInv(this,legendData(idx),1,tabIdx);

        if(invertTime)
            valData=valDataInv;
        end

        if~iscell(valData)
            valData={valData};
        end
        if(length(valData)>1)
            if(whichExpanded(this,idx,tabIdx)>0)
                div=docNode.createElement('div');
                div.appendChild(docNode.createTextNode('<<'));
                td.appendChild(div);

                for varIdx=1:length(valData)
                    valueString=valData{length(valData)-varIdx+1}.Name;
                    if varIdx~=1
                        valueString=[DAStudio.message('Simulink:utility:InBlock')...
                        ,' ',valueString];%#ok<AGROW>
                    end
                    div=docNode.createElement('div');
                    div.appendChild(docNode.createTextNode(valueString));
                    td.appendChild(div);
                end
            else
                div=docNode.createElement('div');
                div.appendChild(docNode.createTextNode('>>'));
                td.appendChild(div);
            end
        else
            td.appendChild(docNode.createTextNode(valData{1}.Name));
        end
    end

    if isempty(filename)
        result=writeToFile(DOMWriter,docNode);
    else
        writeToFile(DOMWriter,docNode,filename);
        result=true;
    end
end
