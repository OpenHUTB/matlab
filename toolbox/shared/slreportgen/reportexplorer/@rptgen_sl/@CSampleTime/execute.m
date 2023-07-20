function out=execute(this,d,varargin)




    out=[];
    imageSize=this.ImageSize;
    imageFormat=this.ImageFormat;
    psSL=rptgen_sl.propsrc_sl_sys;


    adSL=rptgen_sl.appdata_sl();
    currentModel=adSL.CurrentModel;
    if isempty(currentModel)
        this.status('No model to get sample time',2);
        return;
    end

    sampleTimeColor=psSL.getPropValue(currentModel,'SampleTimeColors');
    sampleTimeColor=sampleTimeColor{1};
    sampleTimeAnnotations=psSL.getPropValue(currentModel,'SampleTimeAnnotations');
    sampleTimeAnnotations=sampleTimeAnnotations{1};

    if(strcmpi(sampleTimeColor,'off')&&strcmpi(sampleTimeAnnotations,'off'))
        this.status('Skipping.  Sample time colors or annotation are not enabled',2);
        return
    end


    sampleTimeData=psSL.getPropValue(currentModel,'SampleTimes');
    sampleTimeData=sampleTimeData{1};

    if isempty(sampleTimeData)
        this.status('Model needs to be compiled to get sample time data',2);
        return
    end


    theTable=cell(length(sampleTimeData)+1,4);
    [theTable{1,:}]=deal('Color','Annotation','Description','Value');


    for i=1:length(sampleTimeData)
        [theTable{i+1,:}]=deal(...
        locGetImage(sampleTimeData(i),imageSize,imageFormat,d),...
        sampleTimeData(i).Annotation,...
        sampleTimeData(i).Description,...
        locGetValue(sampleTimeData(i),psSL,d,i));
    end


    tm=makeNodeTable(d,...
    theTable,...
    0,...
    true);

    tm.setTitle(this.Title);
    tm.setBorder(this.isBorder);
    tm.setPageWide(this.isPgwide);
    tm.setGroupAlign(this.AllAlign);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);
    tm.setColWidths(this.ColumnWidths);


    out=tm.createTable;


    function value=locGetValue(sampleTimeData,psSL,d,i)

        valueStruct=Simulink.SampleTimeLegend.getValueString(slroot,sampleTimeData,true,1,i);
        if iscell(valueStruct)
            lenValueStruct=length(valueStruct);
            value=cell(lenValueStruct,1);
            for varIndex=1:lenValueStruct
                eachST=valueStruct{lenValueStruct+1-varIndex};
                value{varIndex}=psSL.makeLink(eachST.MatlabArgs{4},'block','link',d);
            end
        else
            if strcmpi(valueStruct.Type,'text')
                value=valueStruct.Name;
            elseif strcmpi(valueStruct.Type,'hyperlink')
                value=psSL.makeLink(sampleTimeData.Owner,'block','link',d);
            else
                error(message('Simulink:rptgen_sl:UnexpectedSampleTimeValue'));
            end
        end


        function img=locGetImage(sampleTimeData,imageSize,imageFormat,d)


            color=zeros([imageSize,3]);
            color(:,:,1)=sampleTimeData.ColorRGBValue(1);
            color(:,:,2)=sampleTimeData.ColorRGBValue(2);
            color(:,:,3)=sampleTimeData.ColorRGBValue(3);
            imFile=getImgName(rptgen.appdata_rg,imageFormat,'sampletime');
            imwrite(color,imFile.fullname,imageFormat);

            if rptgen.use_java
                gm=javaObject('com.mathworks.toolbox.rptgencore.docbook.GraphicMaker',...
                java(d),imFile.relname);
            else
                gm=mlreportgen.re.internal.db.GraphicMaker(d.Document,imFile.relname);
            end
            gm.setInline(true);
            img=gm.createGraphic();
