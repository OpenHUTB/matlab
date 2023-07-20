function refresh_hook(this,dlg,hierarchy,forceRefresh)






    hierarchy=refactorTree(this,dlg,hierarchy,forceRefresh);
    if isempty(hierarchy)
        return;
    end


    setBusItem(this,hierarchy);

    this.signalSelector.TCPeer.update;

    widgetName='MatchInputsString';
    if~dlg.getWidgetValue(widgetName)
        entries={hierarchy(:).SignalName};
    else
        [~,entries]=this.retrieveSelection(dlg);
    end
    this.updateSelectedSignalList(dlg,entries);

    dlg.refresh;

    this.inheritNames(dlg,widgetName);

end

function hierarchy=refactorTree(this,dlg,hierarchy,forceRefresh)
    if(isempty(this.state.InputsString))
        inputs=this.state.Inputs;
    else
        inputs=this.state.InputsString;
    end
    handle=this.getBlock.Handle;




    if isempty(hierarchy);return;end

    num=this.str2doubleNoComma(inputs);
    if isnan(num)&&~isempty(inputs)
        num=length(strfind(inputs,','))+1;
    elseif isnan(num)
        num=0;
    end


    if isfinite(num)&&num>0&&num~=length(hierarchy)
        signalNames={hierarchy(:).name};

        currentNum=length(signalNames);
        if currentNum<num
            if num==this.str2doubleNoComma(inputs)
                [~,names]=this.retrieveSelection(dlg);
            else
                names=this.str2CellArr(inputs);
            end
            count=0;
            for i=1:length(names)
                if i>length(signalNames)&&count~=(length(names)-...
                    length(signalNames))
                    newhierarchy(i).name=names{i};
                    newhierarchy(i).src=handle;
                    newhierarchy(i).srcPort=i;
                    newhierarchy(i).signals=[];
                else
                    if~strcmp(names{i},signalNames{i-count})
                        newhierarchy(i).name=names{i};
                        newhierarchy(i).src=handle;
                        newhierarchy(i).srcPort=i;
                        newhierarchy(i).signals=[];
                        count=count+1;
                    else
                        newhierarchy(i)=hierarchy(i-count);
                    end
                end
            end
        elseif currentNum>num
            newhierarchy=hierarchy;
            if isnan(this.str2doubleNoComma(inputs))
                cellStr=strsplit(inputs,',');
                for i=currentNum:-1:1
                    if~strcmp(signalNames{i},cellStr)
                        newhierarchy(i)=[];
                    end
                end
            else
                for i=currentNum:-1:num+1
                    newhierarchy(i)=[];
                end
            end
        end
    elseif num==length(hierarchy)
        newhierarchy=hierarchy;
        if~forceRefresh
            if num==this.str2doubleNoComma(inputs)
                [~,names]=this.retrieveSelection(dlg);
            else
                names=this.str2CellArr(inputs);
            end
            hiername={hierarchy(:).name};
            [~,~,IB]=intersect(names,hiername,'stable');
            if length(IB)==length(names)
                newhierarchy=hierarchy(IB);
            else

                newhierarchy(IB)=hierarchy(IB);
            end
        end
    else
        newhierarchy=[];
    end

    hierarchy=newhierarchy;

    this.getBlock.UserData.signalHierarchy=hierarchy;
    hierarchy=this.oldFormat2NewFormat(hierarchy);

end
