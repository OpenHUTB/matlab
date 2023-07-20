function out=execute(c,d,varargin)





    adSL=rptgen_sl.appdata_sl;

    wBlk=findContextBlocks(adSL,'BlockType','\<ToWorkspace\>');
    fBlk=findContextBlocks(adSL,'BlockType','\<ToFile\>');

    if(isempty(wBlk)&&isempty(fBlk))
        out=[];
        return;
    end

    out=createDocumentFragment(d);

    figH=rptgen_hg.makeTempCanvas;
    set(figH,'Color','white','InvertHardcopy','off');
    axH=axes('Parent',figH,'box','on');
    lineH=line('Parent',axH,'color','black');

    lineStyles={'-','--',':','-.'};

    for i=1:length(wBlk)
        varName=get_param(wBlk{i},'VariableName');
        try
            varValue=evalin('base',varName);
        catch ex
            varValue=[];
            c.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_toworkspace:cannotResolveVariableLabel')),...
            varName,ex.message),6);
        end

        if isempty(varValue)
            c.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_toworkspace:variableEmptyLabel')),...
            varName,wBlk{i}),2);
        else
            formatType=get_param(wBlk{i},'SaveFormat');
            if strcmpi(formatType,'array')
                yVal=varValue;
                tVal=[];
            else
                yVal=varValue.signals.values;
                tVal=varValue.time;
            end


            if isempty(tVal)

                tVal=1:length(yVal);
            end


            numYValCols=size(yVal,2);
            for j=1:numYValCols


                if(j==1)
                    newline=lineH;

                else
                    newline=line('Parent',axH,'color','black','linestyle',lineStyles{mod(j,length(lineStyles))});
                end

                set(newline,'xdata',tVal,'ydata',yVal(:,j));
            end

            gTag=c.gr_makeGraphic(d,...
            figH,...
            varName,...
            wBlk{i},...
            'To Workspace:');

            if~isempty(gTag)
                out.appendChild(gTag);
            end
        end
    end


    for i=1:length(fBlk)
        fileName=get_param(fBlk{i},'FileName');
        varName=get_param(fBlk{i},'MatrixName');

        try
            fileContents=load(fileName,'-mat');
        catch ex
            fileContents=[];
            c.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_toworkspace:cannotLoadFileLabel')),...
            fileName,ex.message),6);
        end

        if isempty(fileContents)||~isfield(fileContents,varName)
            c.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_toworkspace:missingFileLabel')),...
            fileName,varName,fBlk{i}),2);
        else
            allVal=fileContents.(varName);

            if isa(allVal,'timeseries')
                time=allVal.time;
                data=allVal.data;
            else
                time=allVal(1,:);
                data=allVal(2,:);
            end

            set(lineH,'xdata',time,'ydata',data);

            gTag=c.gr_makeGraphic(d,...
            figH,...
            varName,...
            fBlk{i},...
            'To File:');

            if~isempty(gTag)
                out.appendChild(gTag);
            end
        end
    end

    delete(figH);