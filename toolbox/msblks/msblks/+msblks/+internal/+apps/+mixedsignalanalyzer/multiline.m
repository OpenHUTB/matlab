function[fig,sortedT,plotHandle]=multiline(T,SortXCellArray,Ycol_Name,figAxes,varargin)



















    drawnow limitrate;

    nSortVar=length(SortXCellArray);


    if nargin<5
        filterY='';
    else
        filterY=varargin{1};
        name_exist=ismember(filterY,T.Properties.VariableNames);


        if~name_exist
            error(strcat(filterY,' is not part of the input table'));
        end
    end










    xAxisNamesForNumericValues{length(SortXCellArray)}=SortXCellArray{end};
    for i=1:length(SortXCellArray)
        xAxisNamesForNumericValues{i}=[' ',SortXCellArray{i},' '];
    end
    sortedT=sortTable(T,[SortXCellArray,filterY],xAxisNamesForNumericValues);

    [AllPossibleXLabel,stringDataBase]=createAllPossibleXlabel(sortedT,nSortVar,SortXCellArray);
    MaxXValue=size(AllPossibleXLabel,1);

    yAxisNamesForNumericValues{length(Ycol_Name)}=Ycol_Name{end};
    for i=1:length(Ycol_Name)
        yAxisNamesForNumericValues{i}=[' ',Ycol_Name{i},' '];
    end
    yAxisNamesForNumericValues=unique(string(yAxisNamesForNumericValues),'stable');
    name_exist=ismember(yAxisNamesForNumericValues,sortedT.Properties.VariableNames);
    if sum(name_exist)~=length(yAxisNamesForNumericValues)
        ii=find(~name_exist);
        error(strcat("""",yAxisNamesForNumericValues(ii(1)),""" column is not part of the input table"));
    else
        Ydata=zeros(size(sortedT,1),length(yAxisNamesForNumericValues));
        for ii=1:length(yAxisNamesForNumericValues)
            stringValues=sortedT{:,Ycol_Name(ii)};
            numberValues=sortedT{:,yAxisNamesForNumericValues(ii)};
            for jj=1:min(length(stringValues),length(numberValues))
                if isnan(numberValues(jj))&&~isempty(stringValues{jj})&&~strcmpi(stringValues{jj},'NaN')
                    error(strcat("""",yColumnNames(ii(1)),""" column contains non-numerical data, can't plot"));
                end
            end
            Ydata(:,ii)=numberValues;
        end
        clear temp;
    end



    if~isempty(figAxes)
        fig=figAxes.Parent;
    else
        fig=figure;
        if isempty(fig.CurrentAxes)
            fig.CurrentAxes=axes('Parent',fig);
        end
        figAxes=fig.CurrentAxes;
    end

    if isempty(filterY)
        xvalue=find_xvalue(sortedT(:,1:nSortVar),stringDataBase);
        x=categorical(xvalue);
        plotHandle=plot(figAxes,x,Ydata,'o-');
        orderedTicks=figAxes.XAxis.TickValues;
        orderedLabels=getOrderedUsedLabels(orderedTicks,AllPossibleXLabel);
        figAxes.XAxis.setHierarchicalTicks(orderedTicks,orderedLabels);
        figAxes.XTickLabel=[];
        leg_str=yAxisNamesForNumericValues;
    else
        filterY_labels=string(sortedT{:,filterY});
        uniqueFilterY=unique(filterY_labels,'rows');
        leg_str="";
        for col=1:size(Ydata,2)
            for ii=1:length(uniqueFilterY)
                row_idx=find(filterY_labels==uniqueFilterY(ii));
                for jj=2:size(uniqueFilterY,2)
                    rows=find(filterY_labels(:,jj)==uniqueFilterY(ii,jj));
                    row_idx=intersect(row_idx,rows);
                end
                xvalue=find_xvalue(sortedT(row_idx,1:nSortVar),stringDataBase);
                x=categorical(xvalue);
                plotHandle=plot(figAxes,x,Ydata(row_idx,col),'o-');
                orderedTicks=figAxes.XAxis.TickValues;
                orderedLabels=getOrderedUsedLabels(orderedTicks,AllPossibleXLabel);
                figAxes.XAxis.setHierarchicalTicks(orderedTicks,orderedLabels);
                figAxes.XTickLabel=[];
                legendLine=strcat(yAxisNamesForNumericValues(col));
                for jj=1:length(filterY)
                    legendLine=strcat(legendLine,", ",filterY(jj),"=",string(uniqueFilterY(ii,jj)));
                end
                leg_str=[leg_str;legendLine];%#ok<AGROW>
                hold(figAxes,'on');
            end
        end
        leg_str=leg_str(2:end);
    end
    legend(figAxes,strrep(leg_str,'_','\_'));
    hold(figAxes,'on');
    drawnow limitrate;



    grid(figAxes,'on');
    if length(yAxisNamesForNumericValues)==1
        ylabel(figAxes,yAxisNamesForNumericValues);
    end


    figAxes.OuterPosition=[0,0,1,1];
    drawnow;
    [xt,~]=msblks.internal.apps.mixedsignalanalyzer.getTickLabelRowCoordinates(figAxes);
    xAxisLabelsString{numel(xt)}=[];
    for i=1:numel(xt)
        xAxisLabelsString{i}=SortXCellArray{numel(xt)-i+1};
    end
    msblks.internal.apps.mixedsignalanalyzer.View.setXAxisLabels(figAxes,xAxisLabelsString);
end

function orderedUsedLabels=getOrderedUsedLabels(orderedUsedTicks,allPossibleXlabel)

    [~,columnCount]=size(allPossibleXlabel);
    orderedUsedLabels(length(orderedUsedTicks),columnCount)="";
    for i=1:length(orderedUsedTicks)

        orderedUsedLabels(i,:)=allPossibleXlabel(double(string(orderedUsedTicks(i))),:);


    end
end

function[AllPossibleXlabel,stringDataBase]=createAllPossibleXlabel(sortedT,nSortVar,SortXCellArray)


    inTable=sortedT(:,1:nSortVar);
    inStringArray=string(inTable{:,:});
    numCol=size(inStringArray,2);


    sortTableColumns{nSortVar}=[];
    for column=1:nSortVar
        sortTableColumns{column}=sortedT.([' ',SortXCellArray{column},' ']);
    end





    uqS=cell(1,numCol);
    uqV=cell(1,numCol);















    for i=1:numCol
        uqS{i}=[];
        uqV{i}=[];
        for row=1:size(inStringArray,1)
            if isempty(uqS{i})||~any(ismember(uqS{i},inStringArray(row,i)))
                uqS{i}=[uqS{i};inStringArray(row,i)];
                uqV{i}=[uqV{i};sortTableColumns{i}(row)];
            end
        end
    end


    for column=1:numCol

        for i=1:length(uqV{column})-1
            for j=i+1:length(uqV{column})
                swap=false;
                if isnumeric(uqV{column})
                    swap=uqV{column}(i)>uqV{column}(j);
                elseif ischar(uqV{column}{1})
                    swap=string(uqV{column}{i})>string(uqV{column}{j});
                end
                if swap

                    temp=uqV{column}(i);
                    uqV{column}(i)=uqV{column}(j);
                    uqV{column}(j)=temp;

                    temp=uqS{column}(i);
                    uqS{column}(i)=uqS{column}(j);
                    uqS{column}(j)=temp;
                end
            end
        end
    end

    cmd_str="tmp = generateLabel(";
    for i=1:numCol-1
        cmd_str=strcat(cmd_str,"uqS{",num2str(i),"},");
    end
    cmd_str=strcat(cmd_str,"uqS{",num2str(numCol),"});");
    eval(cmd_str);
    drawnow limitrate;

    AllPossibleXlabel=tmp(:,end:-1:1);
    stringDataBase=combineStrings(AllPossibleXlabel(:,end:-1:1));

...
...
...
...
...
...
end

function out=combineStrings(inTable)

    if istable(inTable)
        in=string(inTable{:,:});
    end
    if isstring(inTable)
        in=inTable;
    end
    if~exist("in",'var')
        error("combineStrings function expects input to be either table or string array");
    else
        if size(in,2)>1
            out=join(string(in),'_');
        else
            out=in;
        end
    end
end


function y=generateLabel(varargin)
    if nargin==1
        y=varargin{1}(:);
        return;
    else
        call_next=generateLabel(varargin{2:end});
        numRow=size(call_next,1);

        len1=length(varargin{1});

        rowVec=[varargin{1}(:)]';
        first_column=reshape(repmat(rowVec,numRow,1),len1*numRow,1);

        y=[first_column,repmat(call_next,len1,1)];
    end
end

function xvalue=find_xvalue(inTable,stringDataBase)
    search_str=combineStrings(inTable);
    [~,idx]=ismember(search_str,stringDataBase);
    xvalue=idx;
end







function outT=sortTable(inT,varNameList,varNameList_ForSorting)

    varNameCheck=ismember(varNameList,inT.Properties.VariableNames);


    if sum(varNameCheck)~=length(varNameList)
        error('some of the names in the varNameList are not part of the input table')
    end

    outT=movevars(inT,varNameList,'Before',1);












    outT=sortrows(outT,varNameList_ForSorting);




    pvt_cell=outT{:,varNameList};
    pvt_str=string(pvt_cell);
    if size(pvt_str,2)>1
        pvt_str=join(pvt_str,'_');
    end
    pvt_str=replace(pvt_str,'-','m');

    outT.pvt_str=pvt_str;

end
