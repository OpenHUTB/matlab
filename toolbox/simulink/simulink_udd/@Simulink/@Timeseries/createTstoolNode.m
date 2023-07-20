function node=createTstoolNode(ts,h,varargin)







    node=[];

    status=prepareTsDataforImport(ts);
    if~status
        return
    end







    if localDoesNameExist(h,ts.Name)


        tmpname=ts.name;
        Namestr=sprintf('Simulink Time Series object ''%s'' is already defined.\n\nSpecify a different name for the new object to be imported :\n',...
        tmpname);
        while true
            answer=inputdlg(Namestr,'Enter Unique Name');


            if isempty(answer)
                return;
            end
            tmpname=strtrim(cell2mat(answer));
            if isempty(tmpname)
                Namestr=sprintf('%s \n\n %s','Empty names are not allowed.',...
                'Specify a different name for the new object to be imported :');
            else
                tmpname=strtrim(cell2mat(answer));

                if localDoesNameExist(h,tmpname)
                    Namestr=sprintf('Simulink Time Series object  ''%s''  is already defined.\n\nPlease give a different name for the new object to be imported :\n',tmpname);
                    continue;
                else
                    ts.name=tmpname;
                    break;
                end
            end
        end
    end



    node=tsguis.simulinkTsNode(ts);



    node.Tslistener=handle.listener(node.Timeseries,'datachange',{@localUpdatePanel,node});
    node.DataNameChangeListener=handle.listener(node.Timeseries,...
    node.Timeseries.findprop('Name'),'PropertyPostSet',{@localUpdateNodeName,node});


    function localUpdateNodeName(es,ed,node)

        newName=node.Timeseries.Name;
        node.updateNodeNameCallback(newName);


        function localUpdatePanel(es,ed,node)

            node.updatePanel(node.getContainerNodeName,node.Timeseries);


            function Flag=localDoesNameExist(h,name)

                nodes=h.getChildren('Label',name);
                Flag=false;
                if~isempty(nodes)
                    for k=1:length(nodes)
                        if strcmp(class(nodes(k)),'tsguis.simulinkTsNode')
                            Flag=true;
                            break;
                        end
                    end
                end