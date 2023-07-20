function varargout=rftool(varargin)




























    gui_Singleton=1;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@rftool_OpeningFcn,...
    'gui_OutputFcn',@rftool_OutputFcn,...
    'gui_LayoutFcn',@rftool_LayoutFcn,...
    'gui_Callback',[]);
    if nargin&&ischar(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end


end



function rftool_OpeningFcn(hObject,eventdata,handles,varargin)

    warning(message('rf:rftool:Sunset'))


    handles.output=hObject;



    if isfield(handles,'Tab')

        figure(handles.rftoolfig);
    else


        set(hObject,'Visible','off');


        hrftoolfig=handles.rftoolfig;



        rftooluserdatastruct.isFirstSave=true;
        rftooluserdatastruct.isModified=false;
        set(hrftoolfig,'Name','RF Design and Analysis');
        set(hrftoolfig,'userdata',rftooluserdatastruct);













        orig_state=warning('off','MATLAB:uitable:DeprecatedFunction');
        hTab=uitable('v0',hObject,12,9);
        warning(orig_state);








        hTab.setColumnNames({'Freq','20log10|S11|','<S11',...
        '20log10|S21|','<S21','20log10|S12|','<S12',...
        '20log10|S22|','<S22'});
        hTab.setEditable(0);

        handles.Tab=hTab;



        hTab.setVisible(0);













        orig_state=warning('off','MATLAB:uitable:DeprecatedFunction');
        hTab1=uitable('v0',hObject,12,2);
        warning(orig_state);



        hTab1.setColumnNames({'Parameter name','Value'});









        hTab1.setEditable(1,false);



        hTab1.setEnabled(1,false);



        hTab1.setVisible(0);










        handles.Tab1=hTab1;


        orig_state=warning;
        warning('off','MATLAB:uitree:DeprecatedFunction');
        warning('off','MATLAB:uitreenode:DeprecatedFunction');
        huiroot=uitreenode('v0','untitled session','untitled session',[],false);
        huitree=uitree('v0','Root',huiroot,...
        'SelectionChangeFcn',{@selcallback,hObject},'Parent',hrftoolfig,...
        'Position',[25,380,250,215]);
        warning(orig_state);
        tr=huitree.getTree;


        x=tr.getSelectionModel;
        x.setSelectionMode(1);

        awtinvoke(tr,'setShowsRootHandles(Z)',true);
        handles.uiroot=huiroot;
        handles.uitree=huitree;

        entireFigPosition=get(handles.rftoolfig,'Position');

        currPanelPosition=get(handles.rfdatdisptxt,'Position');
        newPos=currPanelPosition.*entireFigPosition([3,4,3,4]);
        subPanelPosition=get(handles.RFDataTable,'position');
        newPos=[newPos(1:2),0,0]+subPanelPosition.*newPos([3,4,3,4]);
        hTab=handles.Tab;



        hTab.setPosition(newPos);



        hTab.setColumnWidth((newPos(3)-40)/9);

        currPanelPosition=get(handles.rfcomlistfrm,'Position');
        newPos=currPanelPosition.*entireFigPosition([3,4,3,4]);
        subPanelPosition=get(handles.RFCompTree,'position');
        newPos=[newPos(1:2),0,0]+subPanelPosition.*newPos([3,4,3,4]);
        huitree=handles.uitree;
        huitree.setPosition(newPos);

        currPanelPosition=get(handles.compparamfrm,'Position');
        newPos=currPanelPosition.*entireFigPosition([3,4,3,4]);
        subPanelPosition=get(handles.RFCompParams,'position');
        newPos=[newPos(1:2),0,0]+subPanelPosition.*newPos([3,4,3,4]);
        hTab1=handles.Tab1;



        hTab1.setPosition(newPos);



        hTab1.setColumnWidth(newPos(3)/2.2);

        handles.uitree=huitree;
        handles.Tab1=hTab1;
        handles.Tab=hTab;

        handles.ckts={};


        hinsertpushb=handles.insertpushb;
        set(hinsertpushb,'Enable','Off');


        huppushb=handles.uppushb;
        set(huppushb,'Enable','Off');


        hdownpushb=handles.downpushb;
        set(hdownpushb,'Enable','Off');



        hdeletepushb=handles.deletepushb;
        set(hdeletepushb,'Enable','Off');


        hcompnameedt=handles.compnameedt;
        set(hcompnameedt,'Enable','On');


        hcomptypeedt=handles.comptypeedt;


        happlypushb=handles.applypushb;
        set(happlypushb,'Enable','Off');


        hanalpushb=handles.analyzepushb;
        set(hanalpushb,'Enable','On');


        hplotpushb=handles.plotpushb;
        set(hplotpushb,'Enable','Off');


        hdatapushb=handles.datapushb;
        set(hdatapushb,'Enable','Off');


        hfreqedt=handles.freqedt;
        set(hfreqedt,'Enable','Off');


        hcharimpedt=handles.charimpedt;
        set(hcharimpedt,'Enable','Off');


        handles.freq=1e8:5e6:2e9;

        handles.plotoptions.smithyztypemenu.enable='on';
        handles.plotoptions.smithyztypemenu.value=2;




        handles.plotoptions.xymagphsmenu.enable='on';
        handles.plotoptions.xymagphsmenu.value=1;
        handles.plotoptions.xylinlogdegradmenu.enable='on';
        handles.plotoptions.xylinlogdegradmenu.value=2;
        handles.plotoptions.ylinlogmenu.enable='on';
        handles.plotoptions.ylinlogmenu.value=1;

        obj=rfckt.seriesrlc;
        analyze(obj,2e9*[1,1+eps]);
        handles.dummy=obj;


        guidata(hObject,handles);





        huitree.setSelectedNode(huiroot);

        drawnow;

        plotpushb_Callback(handles.rftoolfig,0,handles);

        drawnow;
        if~ispc
            set(findall(hObject,'type','uicontrol'),'fontname','arial');
        end
        set(hObject,'Visible','on');

        hTab.setVisible(0);


    end
end


function varargout=rftool_OutputFcn(hObject,eventdata,handles)





    varargout{1}=handles.output;
end

function rfcomplist_CreateFcn(hObject,eventdata,handles)





    set(hObject,'BackgroundColor','white');



end

function createpushb_Callback(hObject,eventdata,handles)




    freeze(handles);
    huitree=handles.uitree;
    root=huitree.getRoot;
    isRootLoaded=huitree.isLoaded(root);


    hrftoolfig=handles.rftoolfig;





    handles.new_data={};
    guidata(hrftoolfig,handles);

    createcompwin(hrftoolfig);
    drawnow;

    if(ishghandle(hrftoolfig))
        handles=guidata(hrftoolfig);

        if(~isempty(handles.new_data))
            hcompname=handles.new_data{1};
            hcomptype=handles.new_data{2};
            newrfdata=handles.new_data{3};
            try
                newrfdata=cell2proppair(newrfdata,hcomptype);
                handles.new_data{3}=newrfdata;

                object=addobject(root,handles);

                idx=length(handles.ckts)+1;
                handles.ckts{idx}.object=object;
                handles.ckts{idx}.name=hcompname;
                handles.new_data={};



                rftooluserdatastruct=get(hrftoolfig,'userdata');
                rftooluserdatastruct.isModified=true;
                set(hrftoolfig,'Name','RF Design and Analysis*');
                set(hrftoolfig,'userdata',rftooluserdatastruct);
                guidata(hrftoolfig,handles);
                guidata(hObject,handles);

                huitree.nodeStructureChangeCompleted(root);
                drawnow;
                huitree.setSelectedNode(getLastChild(root));



            catch creatRFOBJException
                errordlg(creatRFOBJException.message,'Error creating RF component');
                nodes=huitree.getSelectedNodes;
                if numel(nodes)>0
                    set_enable(handles,nodes(1));
                end
            end
        else
            nodes=huitree.getSelectedNodes;
            if numel(nodes)>0
                set_enable(handles,nodes(1));
            end
            guidata(hObject,handles);

        end

    end

    unfreeze(handles);









end

function deletepushb_Callback(hObject,eventdata,handles)




    freeze(handles);

    huitree=handles.uitree;
    root=huitree.getRoot;
    nodes=huitree.getSelectedNodes;
    selNode=nodes(1);




    if(strcmp(selNode.getName,root.getName))
        errordlg('The session node cannot be deleted.');
        return;
    end

    try
        if(selNode.getLevel==1)


            parentNode=root;
            nodeidx=parentNode.getIndex(selNode);
            handles.ckts(nodeidx+1)=[];
        else

            parentNode=selNode.getParent;
            parentNodeObj=handle(parentNode.getUserObject);
            nodeidx=parentNode.getIndex(selNode);
            parentNodeObj.Ckts(nodeidx+1)=[];

            if~isempty(parentNodeObj.AnalyzedResult)
                parentNodeObj.AnalyzedResult.S_Parameters=[];
            end


            handles=UpdateAncestors(selNode,2,handles);
            handles=ClearAncestorPlots(selNode,handles);
        end
    catch
    end


    huitree.remove(parentNode,selNode);
    huitree.nodesWereRemoved(parentNode,nodeidx);




    totalnumnodes=parentNode.getChildCount;

    if totalnumnodes
        if totalnumnodes==nodeidx
            nodeTosel=parentNode.getChildAt(nodeidx-1);
        else
            nodeTosel=parentNode.getChildAt(nodeidx);
        end
    else
        nodeTosel=parentNode;
    end

    huitree.setSelectedNode(nodeTosel);

    hrftoolfig=handles.rftoolfig;


    rftooluserdatastruct=get(hrftoolfig,'userdata');
    rftooluserdatastruct.isModified=true;
    set(hrftoolfig,'Name','RF Design and Analysis*');
    set(hrftoolfig,'userdata',rftooluserdatastruct);
    guidata(hrftoolfig,handles);

    unfreeze(handles);

end



function insertpushb_Callback(hObject,eventdata,handles)

    freeze(handles);

    huitree=handles.uitree;
    root=huitree.getRoot;


    hrftoolfig=handles.rftoolfig;
    handles.new_data={};

    guidata(hrftoolfig,handles);

    createcompwin(hrftoolfig);
    drawnow;
    if(ishghandle(hrftoolfig))
        handles=guidata(hrftoolfig);

        if(~isempty(handles.new_data))

            try
                nodes=huitree.getSelectedNodes;
                selNode=nodes(1);
                selObjNode=handle(selNode.getUserObject);
                hcomptype=handles.new_data{2};
                newrfdata=handles.new_data{3};
                newrfdata=cell2proppair(newrfdata,hcomptype);
                handles.new_data{3}=newrfdata;

                object=addobject(selNode,handles);

                numCkts=length(selObjNode.Ckts);
                selObjNode.Ckts{numCkts+1}=object;

                handles=UpdateAncestors(selNode,1,handles);
                handles=ClearAncestorPlots(selNode,handles);

                if~isempty(selObjNode.AnalyzedResult)
                    selObjNode.AnalyzedResult.S_Parameters=[];
                end





                hrftoolfig=handles.rftoolfig;
                rftooluserdatastruct=get(hrftoolfig,'userdata');
                rftooluserdatastruct.isModified=true;
                set(hrftoolfig,'Name','RF Design and Analysis*');
                set(hrftoolfig,'userdata',rftooluserdatastruct);
                guidata(hrftoolfig,handles);

                huitree.nodeStructureChangeCompleted(root);
                huitree.setSelectedNode(selNode);



                huitree.expand(selNode);

            catch insertRFOBJException
                errordlg(insertRFOBJException.message,'Error inserting RF component');
                nodes=huitree.getSelectedNodes;
                if numel(nodes)>0
                    set_enable(handles,nodes(1));
                end
            end
        else
            nodes=huitree.getSelectedNodes;
            if numel(nodes)>0
                set_enable(handles,nodes(1));
            end
        end
    end

    unfreeze(handles);
end


function applypushb_Callback(hObject,eventdata,handles)




    hrftoolfig=handles.rftoolfig;
    rftooluserdatastruct=get(hrftoolfig,'userdata');

    try
        name=get(handles.compnameedt,'String');


        huitree=handles.uitree;
        root=handle(huitree.getRoot);
        nodes=huitree.getSelectedNodes;
        selNode=handle(nodes(1));

        if strcmp(name,selNode.getName)

        else


            if isempty(name)
                errordlg('Please choose a name for this component or network.');
                return
            end


            nextNode=handle(get(root,'NextNode'));
            while~isempty(nextNode)
                if(name==nextNode.getName)
                    errordlg(['This name is already in use.  '
'Please choose a unique name   '
                    'for this component or network.']);
                    return
                end
                nextNode=handle(get(nextNode,'NextNode'));
            end


            selNode.setName(name);


            if(selNode~=root)
                nodePath=getPath(selNode);
                if length(nodePath)==2,
                    idx=root.getIndex(selNode);
                    handles.ckts{idx+1}.name=name;
                end
            end

            rftooluserdatastruct.isModified=true;
            set(hrftoolfig,'Name','RF Design and Analysis*');
            set(hrftoolfig,'userdata',rftooluserdatastruct);
        end





        hrftool=guidata(handles.rftoolfig);
        selNodes=getSelectedNodes(hrftool.uitree);
        hTab1=hrftool.Tab1;




        ce=hTab1.Table.getCellEditor;



        if~isempty(selNodes)&&~isRoot(selNodes(1))


            clearSParamTable=0;



            if~isempty(ce)


                awtinvoke(ce,'stopCellEditing');
                drawnow;
            end



            params=hTab1.getData;

            selObj=handle(getUserObject(selNodes(1)));
            settable_props=set(selObj);
            fn=fieldnames(settable_props);

            if~any(strcmp(fn,'Ckts'))




                hTab1.setEditable(2,true);

                for idx=1:length(params)
                    tempname=param_name_map(params(idx,1),0);
                    if isempty(tempname)
                        continue
                    end
                    param_names(idx)=tempname;
                    curr_val=get(selObj,param_names{idx});
                    new_val=str2property(param_names(idx),...
                    curr_val,params(idx,2));


                    if~isequal(new_val(:),curr_val(:))&&...
                        ~isequal(new_val,'no change')
                        set(selObj,param_names{idx},new_val);

                        clearSParamTable=1;

                        rftooluserdatastruct=get(hrftoolfig,'userdata');
                        rftooluserdatastruct.isModified=true;
                        set(hrftoolfig,'Name','RF Design and Analysis*');
                        set(hrftoolfig,'userdata',rftooluserdatastruct);
                    end

                end



                if clearSParamTable

                    if~isempty(selObj.AnalyzedResult)
                        selObj.AnalyzedResult.S_Parameters=[];
                    end
                    temp_userdata=getappdata(handle(selNodes(1)),'UserData');
                    temp_userdata.analyzed=false;
                    setappdata(handle(selNodes(1)),'UserData',temp_userdata);
                    selNodes(1).setUserObject(selObj);
                    handles=UpdateAncestors(selNodes(1),1,handles);
                    handles=ClearAncestorPlots(selNodes(1),handles);


                    hplotpushb=handles.plotpushb;
                    set(hplotpushb,'Enable','Off');

                    hdatapushb=handles.datapushb;
                    set(hdatapushb,'Enable','Off');


                    plotpushb_Callback(hrftoolfig,0,handles);
                end

            else




                hTab1.setEditable(2,false);
            end
        end


        huitree.setVisible(0);
        huitree.reloadNode(selNode);
        huitree.setSelectedNode(selNode);
        huitree.setVisible(1);


        guidata(handles.rftoolfig,handles);

    catch changePropertyException
        errordlg(changePropertyException.message,'Error changing property');
    end


end


function analyzepushb_Callback(hObject,eventdata,handles)

    freeze(handles);
    try
        uitree=handles.uitree;


        sc=uitree.getScrollPane;
        v=awtinvoke(sc,'getComponents()');
        tr=awtinvoke(v(1),'getComponent(I)',0);

        p=tr.getSelectionPath;
        selNode=handle(p.getPathComponent(p.getPathCount-1));
        selObjNode=handle(selNode.getValue);

        freq=handles.freq;
        freq=evalin('base',['[',get(handles.freqedt,'String'),']']);
        z0=evalin('base',['[',get(handles.charimpedt,'String'),']']);




        if isempty(selObjNode.AnalyzedResult)
            setrfdata(selObjNode,rfdata.data);
        end

        set(selObjNode.AnalyzedResult,'Freq',freq);
        set(selObjNode.AnalyzedResult,'Z0',z0);

        orig_warn=lastwarn;
        lastwarn('');
        warningId{1}=strcat('rf:',strrep(class(selObjNode),'.',':'),':calczin:TerminationEmpty');
        warningId{2}='rf:rfckt:basetxline:nwa:TerminationIgnored';
        warningId{3}='rf:rfckt:txline:nwa:TerminationIgnored';
        warningId{4}='MATLAB:nearlySingularMatrix';
        warningId{5}='MATLAB:SingularMatrix';
        warningId{6}='rf:rfckt:datafile:checkproperty:NeedNoiseDataInDATAFILE';
        warningId{7}='MATLAB:illConditionedMatrix';
        warningId{8}='rf:rfckt:txline:calczin:TerminationEmpty';
        warningId{9}='rf:rfckt:basetxline:calczin:TerminationEmpty';

        for idx=1:length(warningId)
            current_state{idx}=warning('query',warningId{idx});


            if strcmp(current_state{idx}.state,'on')
                warning('off',warningId{idx});
            end
        end

        zs=get(selObjNode.AnalyzedResult,'ZS');
        zl=get(selObjNode.AnalyzedResult,'ZL');

        try
            analyze(selObjNode,freq,zs,zl,z0);

        catch analyzeException
















            switch analyzeException.identifier
            case{'rf:rfckt:cascade:checkproperty:EmptyCKTS',...
                'rf:rfckt:parallel:checkproperty:EmptyCKTS',...
                'rf:rfckt:series:checkproperty:EmptyCKTS',...
                'rf:rfckt:hybrid:checkproperty:EmptyCKTS',...
                'rf:rfckt:hybridg:checkproperty:EmptyCKTS'}
                newExc=MException(analyzeException.identifier,...
                'A leaf node of RF Component List cannot be an empty network.');
            case 'rf:rfdata:rfdata:convertcorrelationmatrix:MatrixNotExist'
                newExc=MException(analyzeException.identifier,...
                'Unable to analyze data. It is possible the network parameters are singular or nearly singular.');
            otherwise
                newExc=analyzeException;
            end
            throw(newExc);
        end

        nodedata.analyzed=true;
        setappdata(handle(selNode),'UserData',nodedata);


        hplotpushb=handles.plotpushb;
        set(hplotpushb,'Enable','On');
        hdatapushb=handles.datapushb;
        set(hdatapushb,'Enable','On');

        handles=UpdateAncestors(selNode,1,handles);




        hrftoolfig=handles.rftoolfig;
        rftooluserdatastruct=get(hrftoolfig,'userdata');
        rftooluserdatastruct.isModified=true;
        set(hrftoolfig,'Name','RF Design and Analysis*');
        set(hrftoolfig,'userdata',rftooluserdatastruct);
        guidata(hrftoolfig,handles);


        plotpushb_Callback(hrftoolfig,1,handles);

    catch analyzeRFOBJException
        errordlg(analyzeRFOBJException.message,'Error analyzing RF component');

    end
    unfreeze(handles);
    set_enable(handles,selNode);

end


function compnameedt_CreateFcn(hObject,eventdata,handles)


    set(hObject,'BackgroundColor','white');



end


function freqedt_Callback(hObject,eventdata,handles)
end


function freqedt_CreateFcn(hObject,eventdata,handles)


    set(hObject,'BackgroundColor','white');



end


function charimpedt_Callback(hObject,eventdata,handles)
end


function charimpedt_CreateFcn(hObject,eventdata,handles)


    set(hObject,'BackgroundColor','white');



end


function uppushb_Callback(hObject,eventdata,handles)









    huitree=handles.uitree;
    huiroot=handles.uiroot;
    nodes=huitree.getSelectedNodes;

    selNode=nodes(1);


    hTab1=handles.Tab1;

    htt=get(hTab1.Table);



    selRow=htt.SelectedRow;


    if(selRow>0)


        selNodeObj=handle(selNode.getUserObject);
        temp=selNodeObj.Ckts(selRow+1);
        selNodeObj.Ckts(selRow+1)=selNodeObj.Ckts(selRow);
        selNodeObj.Ckts(selRow)=temp;


        if~isempty(selNodeObj.AnalyzedResult)
            selNodeObj.AnalyzedResult.S_Parameters=[];
        end
        selNode.setUserObject(selNodeObj);


        handles=UpdateAncestors(selNode,1,handles);
        userdata=getappdata(handle(selNode),'UserData');
        handles=ClearAncestorPlots(selNode,handles);

        if userdata.analyzed
            plotpushb_Callback(handles.rftoolfig,1,handles);
        end


        selChildNode=getChildAt(selNode,selRow);
        selNode.insert(selChildNode,selRow-1);
        huitree.setSelectedNode(selNode);
        huitree.reloadNode(selNode);

        refreshTable(selNode,handles);





        awtinvoke(hTab1.Table,'changeSelection(IIZZ)',selRow-1,0,0,0);





        hrftoolfig=handles.rftoolfig;
        rftooluserdatastruct=get(hrftoolfig,'userdata');
        rftooluserdatastruct.isModified=true;
        set(hrftoolfig,'Name','RF Design and Analysis*');
        set(hrftoolfig,'userdata',rftooluserdatastruct);
        guidata(hrftoolfig,handles);

    end

end


function comptypeedt_CreateFcn(hObject,eventdata,handles)

    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    set(hObject,'Foregroundcolor',[0,0,0]);
end


function downpushb_Callback(hObject,eventdata,handles)


    huitree=handles.uitree;
    huiroot=handles.uiroot;
    nodes=huitree.getSelectedNodes;


    selNode=nodes(1);

    hTab1=handles.Tab1;


    pos=hTab1.getColumnWidth;


    htt=get(hTab1.Table);



    selRow=htt.SelectedRow;


    if(selRow<htt.RowCount-1)


        selNodeObj=handle(selNode.getUserObject);
        temp=selNodeObj.Ckts(selRow+1);
        selNodeObj.Ckts(selRow+1)=selNodeObj.Ckts(selRow+2);
        selNodeObj.Ckts(selRow+2)=temp;


        if~isempty(selNodeObj.AnalyzedResult)
            selNodeObj.AnalyzedResult.S_Parameters=[];
        end
        selNode.setUserObject(selNodeObj);


        handles=UpdateAncestors(selNode,1,handles);
        userdata=getappdata(handle(selNode),'UserData');
        handles=ClearAncestorPlots(selNode,handles);

        if userdata.analyzed
            plotpushb_Callback(handles.rftoolfig,1,handles);
        end


        selChildNode=getChildAt(selNode,selRow);
        selNode.insert(selChildNode,selRow+1);
        huitree.setSelectedNode(selNode);
        huitree.reloadNode(selNode);

        refreshTable(selNode,handles)







        awtinvoke(hTab1.Table,'changeSelection(IIZZ)',selRow+1,0,0,0);






        hrftoolfig=handles.rftoolfig;
        rftooluserdatastruct=get(hrftoolfig,'userdata');
        rftooluserdatastruct.isModified=true;
        set(hrftoolfig,'Name','RF Design and Analysis*');
        set(hrftoolfig,'userdata',rftooluserdatastruct);
        guidata(hrftoolfig,handles);

    end

end


function selcallback(src,evd,hfig)

    if isempty(findstr(class(src),'mathworks.hg.peer.UITreePeer'))
        return
    end

    selnodes=src.getSelectedNodes;
    if isempty(findstr(class(selnodes),'mathworks.hg.peer.UITreeNode'))
        return
    end
    selNode=handle(selnodes(1));

    handles=guidata(hfig);
    [handles,plotFlag]=set_enable(handles,selNode);


    guidata(hfig,handles);

    plotpushb_Callback(handles.rftoolfig,plotFlag,handles);


end


function node_release(node)
    numChildren=node.getChildCount;
    for c_idx=numChildren:-1:1
        childNode=node.getChildAt(c_idx-1);
        node_release(childNode)
    end
    node.getUserObject.releaseReference
end



function rftoolfig_CloseRequestFcn(hObject,eventdata,handles)


    rftooluserdatastruct=get(handles.rftoolfig,'userdata');
    huiroot=handles.uiroot;
    numChildren=getChildCount(huiroot);
    if(rftooluserdatastruct.isModified&&numChildren)

        saveResponse=questdlg('Do you want to save the current session?','Save Current Session');

        switch saveResponse,
        case 'Yes',
            rftool('savesessas_filemenu_Callback',gcbo,[],guidata(gcbo));
        case 'No',
            drawnow;
        case 'Cancel',
            return;
        end

    end




    for c_idx=numChildren:-1:1

        node_release(huiroot.getChildAt(c_idx-1));


    end







    if isfield(handles,'hcreatewin')
        try
            uiresume(handles.hcreatewin);
        end
    end
    if isfield(handles,'xyplot')
        try
            delete(handles.xyplot);
        end
    end
    if isfield(handles,'polarplot')
        try
            delete(handles.polarplot);
        end
    end
    if isfield(handles,'smithchart')
        try
            delete(handles.smithchart);
        end
    end

    delete(handles.rftoolfig);


    clear rftool;
end

function opensess_filemenu_Callback(hObject,eventdata,handles)

    freeze(handles);
    hrftoolfig=handles.rftoolfig;
    huitree=handles.uitree;
    huiroot=handles.uiroot;


    rftooluserdatastruct=get(hrftoolfig,'userdata');
    if(rftooluserdatastruct.isModified&&getChildCount(huiroot))

        saveResponse=questdlg('Do you want to save the current session?','Save Current Session');

        switch saveResponse
        case 'Yes'
            rftool('savesessas_filemenu_Callback',gcbo,[],guidata(gcbo));
        case 'No'
            drawnow;
        case 'Cancel'
            unfreeze(handles);
            return;
        end

    end


    [fname,pname]=uigetfile('*.rf','Open Session');
    drawnow;

    if~isequal(fname,0)


        numCkts=length(handles.ckts);
        for idx=numCkts:-1:1
            handles.ckts{idx}=[];
        end
        handles.ckts={};

        numChildren=getChildCount(huiroot);
        for idx=numChildren:-1:1
            childNode=huiroot.getChildAt(idx-1);

            huitree.remove(huiroot,childNode);
            huitree.nodesWereRemoved(huiroot,[],childNode);
        end



        handles.savefile=[pname,fname];

        guidata(handles.rftoolfig,handles);



        load([pname,fname],'-mat');
        setName(handles.uiroot,rftoolnames{1});

        for idx=1:length(rftoolckts)

            objname=rftoolckts{idx}.name;
            hobject=copy(rftoolckts{idx}.object);




            handles.createobjstr=objname;
            importobjectintotree(hobject,handles);


            handles=guidata(hrftoolfig);
        end
        huitree.setSelectedNode(huiroot);

        idx=2;
        currNode=handles.uiroot;
        finalNode=getLastLeaf(handles.uiroot);
        while~isequal(currNode,finalNode)
            currNode=getNextNode(currNode);
            setName(currNode,rftoolnames{idx});
            idx=idx+1;
        end

        rftooluserdatastruct.isModified=false;
        rftooluserdatastruct.isFirstSave=false;
        set(hrftoolfig,'userdata',rftooluserdatastruct);
        set(hrftoolfig,'Name','RF Design and Analysis');
    else
        nodes=huitree.getSelectedNodes;
        if numel(nodes)>0
            set_enable(handles,nodes(1));
        end
    end
    unfreeze(handles);
end

function savesess_filemenu_Callback(hObject,eventdata,handles)


    if~getChildCount(handles.uiroot)
        errordlg('Unable to save empty session');
        return
    end

    hrftoolfig=handles.rftoolfig;
    rftooluserdatastruct=get(hrftoolfig,'userdata');
    isFirstSave=rftooluserdatastruct.isFirstSave;
    isModified=rftooluserdatastruct.isModified;

    rootname=char(getName(handles.uiroot));
    rootname(~isstrprop(rootname,'alphanum'))=95;
    rootname=rootname(1:min(length(rootname),28));

    rftoolckts=handles.ckts;

    rftoolnames{1}=getName(handles.uiroot);
    idx=2;
    currNode=handles.uiroot;
    finalNode=getLastLeaf(handles.uiroot);
    while~isequal(currNode,finalNode)
        currNode=getNextNode(currNode);
        rftoolnames{idx}=getName(currNode);
        idx=idx+1;
    end



    if isFirstSave

        [fname,pname]=uiputfile('*.rf','Save Session',[rootname,'.rf']);
        if~isequal(fname,0)

            handles.savefile=[pname,fname];



            try
                save(handles.savefile,'rftoolckts','rftoolnames','-mat');

                rftooluserdatastruct.isFirstSave=false;
                rftooluserdatastruct.isModified=false;
                set(hrftoolfig,'Name','RF Design and Analysis');

            catch saveException

                if strcmp(saveException.identifier,'MATLAB:save:permissionDenied')
                    errordlg('Unable to save session: permission denied');
                else
                    errordlg(saveException.message);
                end
                return
            end
        end

    else



        try
            save(handles.savefile,'rftoolckts','rftoolnames','-mat');

            rftooluserdatastruct.isModified=false;
            set(hrftoolfig,'Name','RF Design and Analysis');

        catch saveException

            if strcmp(saveException.identifier,'MATLAB:save:permissionDenied')
                errordlg('Unable to save session: permission denied');
            else
                errordlg(saveException.message);
            end
            return
        end
    end

    set(hrftoolfig,'userdata',rftooluserdatastruct);


    guidata(hrftoolfig,handles);
    drawnow;
end

function savesessas_filemenu_Callback(hObject,eventdata,handles)


    if~getChildCount(handles.uiroot)
        errordlg('Unable to save empty session');
        return
    end

    hrftoolfig=handles.rftoolfig;
    rftooluserdatastruct=get(hrftoolfig,'userdata');
    isFirstSave=rftooluserdatastruct.isFirstSave;

    rftoolckts=handles.ckts;

    rftoolnames{1}=getName(handles.uiroot);
    idx=2;
    currNode=handles.uiroot;
    finalNode=getLastLeaf(handles.uiroot);
    while~isequal(currNode,finalNode)
        currNode=getNextNode(currNode);
        rftoolnames{idx}=getName(currNode);
        idx=idx+1;
    end

    [fname,pname]=uiputfile('*.rf','Save Session As');
    if~isequal(fname,0)

        handles.savefile=[pname,fname];



        try
            save(handles.savefile,'rftoolckts','rftoolnames','-mat');
            rftooluserdatastruct.isFirstSave=false;
            rftooluserdatastruct.isModified=false;
            set(hrftoolfig,'Name','RF Design and Analysis');
        catch saveException

            if strcmp(saveException.identifier,'MATLAB:save:permissionDenied')
                errordlg('Unable to save session: permission denied');
            else
                errordlg(saveException.message);
            end
            return
        end

    end
    set(hrftoolfig,'userdata',rftooluserdatastruct);

    guidata(handles.rftoolfig,handles);
    drawnow;
end

function importfromfile_filemenu_Callback(hObject,eventdata,handles)

    freeze(handles);
    huitree=handles.uitree;
    huiroot=handles.uiroot;
    try
        [fname,pname]=uigetfile({'*.s2p';'*.y2p';'*.z2p';'*.h2p';'*.g2p'},...
        'Import from File');
        if(ischar(fname))

            objname=fname(1:find(fname=='.')-1);

            if isempty(which(fname))
                fname=[pname,fname];
            end
            hobject=rfckt.datafile('File',['',fname,'']);

            handles.createobjstr=objname;
            importobjectintotree(hobject,handles);

            handles=guidata(handles.rftoolfig);





            hrftoolfig=handles.rftoolfig;
            rftooluserdatastruct=get(hrftoolfig,'userdata');
            rftooluserdatastruct.isModified=true;
            set(hrftoolfig,'Name','RF Design and Analysis*');
            set(hrftoolfig,'userdata',rftooluserdatastruct);
            guidata(hrftoolfig,handles);
            selNode=getLastChild(huiroot);
            drawnow;
            huitree.setSelectedNode(selNode);

        else
            nodes=huitree.getSelectedNodes;
            if numel(nodes)>0
                set_enable(handles,nodes(1));
            end
        end
    catch ImportDataException
        errordlg(ImportDataException.message,'Error importing data from file');
        nodes=huitree.getSelectedNodes;
        if numel(nodes)>0
            set_enable(handles,nodes(1));
        end
    end
    unfreeze(handles);
end

function importfromws_filemenu_Callback(hObject,eventdata,handles)

    freeze(handles);

    rfwsvar=evalin('base','whos');
    listrfvar={};
    cnt=0;
    for i=1:numel(rfwsvar)
        if(length(rfwsvar(i).class)>=5)&&(strcmp(rfwsvar(i).class(1,1:5),'rfckt'))
            cnt=cnt+1;
            listrfvar{cnt}=rfwsvar(i).name;
        end
    end

    huitree=handles.uitree;
    huiroot=handles.uiroot;

    if~isempty(listrfvar)

        hrftoolfig=handles.rftoolfig;
        try
            [himportwin,handles]=importwin(hrftoolfig,handles,listrfvar);
            drawnow;

            objname=handles.createobjstr;
            hobject=copy(evalin('base',objname));
            objectToImport=evalin('base',objname);





            nodes=huitree.getSelectedNodes;
            if~getAllowsChildren(nodes(1))&&~isRoot(nodes(1))
                startNode=getParent(nodes(1));
            else
                startNode=nodes(1);
            end
            importobjectintotree(hobject,handles,startNode);
            huitree.setSelectedNode(startNode);

            handles=guidata(handles.rftoolfig);





            hrftoolfig=handles.rftoolfig;
            rftooluserdatastruct=get(hrftoolfig,'userdata');
            rftooluserdatastruct.isModified=true;
            set(hrftoolfig,'Name','RF Design and Analysis*');
            set(hrftoolfig,'userdata',rftooluserdatastruct);
            guidata(hrftoolfig,handles);
            drawnow;
            if isRoot(startNode)
                huitree.setSelectedNode(getLastChild(huiroot));
            else
                set_enable(handles,startNode);
                plotpushb_Callback(handles.rftoolfig,1,handles);
            end
        catch ImportFromWSException
            if strcmpi(ImportFromWSException.identifier,'rf:rftool:TwoPortOnly')
                errordlg(ImportFromWSException.message,'Error importing RF component');
            end

            nodes=huitree.getSelectedNodes;
            if numel(nodes)>0
                set_enable(handles,nodes(1));
            end
        end
    else
        errordlg('No rfckt objects found in workspace.','Error importing RF component');
    end
    unfreeze(handles);
end


function importobjectintotree(hobject,handles,startNode)

    huiroot=handles.uiroot;
    if nargin<3
        startNode=huiroot;
    end
    huitree=handles.uitree;
    hrftoolfig=handles.rftoolfig;
    hobjname=handles.createobjstr;

    blueprint=extractbuild({},getLevel(startNode),hobject,get(hobject,'Name'));

    numsubnodes=length(blueprint);
    level=zeros(1,numsubnodes);
    for idx=1:numsubnodes
        level(idx)=blueprint{idx}{1};
    end
    motion=[0,diff(level)];


    selNode=startNode;
    comptype=get(hobject,'Name');
    comptype=strrep(comptype,'-',' ');

    if(strcmp(comptype,'Cascaded Network')||...
        strcmp(comptype,'Series Connected Network')||...
        strcmp(comptype,'Parallel Connected Network')||...
        strcmp(comptype,'Hybrid Connected Network')||...
        strcmp(comptype,'Hybrid G Connected Network'))
        compdata={'Ckts',{}};
    else
        obj_strt=set(hobject);
        obj_props=fieldnames(obj_strt);
        numProps=length(obj_props);
        compdata=cell(numProps,2);
        for idx2=1:length(obj_props)
            obj_values=get(hobject,obj_props{idx2});
            obj_props{idx2}=char(param_name_map(obj_props{idx2},1));
            compdata(idx2,:)={obj_props{idx2},obj_values};
        end
    end

    hobjname=makenameunique(hobjname,huitree);

    handles.new_data{1}=hobjname;
    handles.new_data{2}=comptype;
    handles.new_data{3}=compdata;

    object=addobject(selNode,handles);



    if~isrefbased(object)&&~isempty(hobject.AnalyzedResult)
        setrfdata(object,hobject.AnalyzedResult);
        newNode=getLastChild(selNode);
        nodedata=getappdata(handle(newNode),'UserData');
        nodedata.analyzed=true;
        setappdata(handle(newNode),'UserData',nodedata);
    end

    if isRoot(selNode)
        idx=length(handles.ckts)+1;
        handles.ckts{idx}.object=object;
        handles.ckts{idx}.name=hobjname;

        if(~isempty(hobject.AnalyzedResult))
            handles.freq=hobject.AnalyzedResult.Freq;
            set(handles.freqedt,'string',num2str(handles.freq(:)','%0.3e '));
            handles.Z0=hobject.AnalyzedResult.Z0;
            set(handles.charimpedt,'string',num2str(handles.Z0));
        end
    else
        selObjNode=handle(selNode.getUserObject);
        numCkts=length(selObjNode.Ckts);
        selObjNode.Ckts{numCkts+1}=object;
        handles=UpdateAncestors(selNode,1,handles);
        handles=ClearAncestorPlots(selNode,handles);
    end

    selNode=getLastChild(selNode);
    handles.new_data={};
    guidata(hrftoolfig,handles);

    handles=guidata(hrftoolfig);


    for idx=1:numsubnodes

        comptype=blueprint{idx}{2};
        comptype=strrep(comptype,'-',' ');
        compname=makenameunique(comptype,huitree);
        compdata=blueprint{idx}{3};
        handles.new_data{1}=compname;
        handles.new_data{2}=comptype;
        handles.new_data{3}=compdata;

        if motion(idx)>0
            selNode=getLastChild(selNode);
        elseif motion(idx)<0
            for backuptree=1:abs(motion(idx))
                selNode=getParent(selNode);
            end
        end

        object=addobject(selNode,handles);



        if~isempty(blueprint{idx}{4})&&~isrefbased(object)
            setrfdata(object,blueprint{idx}{4});
            newNode=getLastChild(selNode);
            nodedata=getappdata(handle(newNode),'UserData');
            nodedata.analyzed=true;
            setappdata(handle(newNode),'UserData',nodedata);
        end

        selObjNode=handle(selNode.getUserObject);
        numCkts=length(selObjNode.Ckts);
        selObjNode.Ckts{numCkts+1}=object;
        handles.new_data={};

        handles=UpdateAncestors(selNode,1,handles);

        huitree.expand(selNode);

    end












    guidata(hrftoolfig,handles);


end

function blist=extractbuild(blist,level,object,objtype)

    if any(strcmp(fieldnames(object),'Ckts'))

        for idx1=1:length(object.Ckts)
            comptype=get(object.Ckts{idx1},'Name');

            if(strcmp(comptype,'Cascaded Network')||...
                strcmp(comptype,'Series Connected Network')||...
                strcmp(comptype,'Parallel Connected Network')||...
                strcmp(comptype,'Hybrid Connected Network')||...
                strcmp(comptype,'Hybrid G Connected Network'))
                compdata={'Ckts',''};
            else
                obj_strt=set(object.Ckts{idx1});
                obj_props=fieldnames(obj_strt);
                numProps=length(obj_props);
                compdata=cell(numProps,2);
                for idx2=1:length(obj_props)
                    obj_values=get(object.Ckts{idx1},obj_props{idx2});



                    compdata(idx2,:)={char(param_name_map(obj_props(idx2),1)),...
                    obj_values};
                end

            end
            comprfdata=[];
            if~isempty(object.Ckts{idx1}.AnalyzedResult)
                comprfdata=handle(object.Ckts{idx1}.AnalyzedResult);
            end

            newlevel=level+1;
            blist{length(blist)+1}={newlevel,comptype,compdata,comprfdata};
            blist=extractbuild(blist,newlevel,object.Ckts{idx1},comptype);
        end
    end
end


function export_filemenu_Callback(hObject,eventdata,handles)

    huitree=handles.uitree;
    root=huitree.getRoot;

    nodes=huitree.getSelectedNodes;
    selNode=nodes(1);

    if(strcmp(selNode.getName,root.getName))
        errordlg('Cannot export the session node. Select another node.');
    else

        hrftoolfig=handles.rftoolfig;
        hexportwin=exportwin(hrftoolfig);
    end
end


function close_filemenu_Callback(hObject,eventdata,handles)


    rftool('rftoolfig_CloseRequestFcn',gcf,[],guidata(gcf));
end

function rftbx_helpmenu_Callback(hObject,eventdata,handles)

    doc('rf');
end

function rfdemos_helpmenu_Callback(hObject,eventdata,handles)

    demo('toolbox','rf');
end

function aboutrftbx_helpmenu_Callback(hObject,eventdata,handles)

    aboutrf;
end


function plotpushb_Callback(hObject,eventdata,handles)









    huitree=handles.uitree;
    huiroot=handles.uiroot;
    nodes=huitree.getSelectedNodes;
    obj=handles.dummy;
    if~isempty(nodes)
        selNode=handle(nodes(1));
        nodeData=getappdata(selNode,'UserData');

        if~isRoot(selNode)&&nodeData.analyzed&&eventdata==1
            obj=handle(get(selNode,'Value'));
        end
    end

    if(get(handles.plotpushb,'value'))

        set(handles.rfdatdisptxt,'Visible','off')



        handles.Tab.setVisible(0);

        set(handles.rfdatplotfrm3,'Visible','on')
        set(handles.rfdatplotfrm,'Visible','on')
        set(handles.rfdatplotfrm2,'Visible','on')

        rfax=handles.RFDataPlot;
        plot(rfax,NaN,NaN);
        yzval=handles.plotoptions.smithyztypemenu.value;
        oldflag=obj.AnalyzedResult.NeedReset;
        obj.AnalyzedResult.NeedReset=false;
        reveal_figure_handle(handles);
        axes(rfax);
        if yzval==1
            hsmith=smith(obj,'S11','S12','S21','S22','y');
        elseif yzval==2
            hsmith=smith(obj,'S11','S12','S21','S22','z');
        elseif yzval==3
            hsmith=smith(obj,'S11','S12','S21','S22','yz');
        else
            hsmith=smith(obj,'S11','S12','S21','S22','zy');
        end
        legend('hide')
        obj.AnalyzedResult.NeedReset=oldflag;

        set(hsmith(1),'linestyle','-','linewidth',2);
        set(hsmith(2),'linestyle',':','linewidth',2);
        set(hsmith(3),'linestyle','-.','linewidth',2);
        set(hsmith(4),'linestyle','--','linewidth',2);
        set(get(hsmith(1),'Parent'),'HandleVisibility','callback');
        handles.hsmith=hsmith;
        hdcm=datacursormode;
        set(hdcm,'SnapToDataVertex','on');
        datacursormode(gcf,'on');
        if get(handles.smithchart_s11,'Value')
            set(handles.hsmith(1),'Visible','on');
        else
            set(handles.hsmith(1),'Visible','off');
        end
        if get(handles.smithchart_s12,'Value')
            set(handles.hsmith(2),'Visible','on');
        else
            set(handles.hsmith(2),'Visible','off');
        end
        if get(handles.smithchart_s21,'Value')
            set(handles.hsmith(3),'Visible','on');
        else
            set(handles.hsmith(3),'Visible','off');
        end
        if get(handles.smithchart_s22,'Value')
            set(handles.hsmith(4),'Visible','on');
        else
            set(handles.hsmith(4),'Visible','off');
        end



        xyax=handles.XYDataPlot;
        axes(xyax);
        plot(xyax,NaN,NaN,'Visible','off');
        mpval=handles.plotoptions.xymagphsmenu.value;
        llval=handles.plotoptions.xylinlogdegradmenu.value;
        reveal_figure_handle(handles);
        axes(xyax);
        if mpval==1
            if llval==1
                hxy=plot(obj,'S11','S12','S21','S22','mag');
            else
                hxy=plot(obj,'S11','S12','S21','S22','dB');
            end
        elseif mpval==2
            if llval==1
                hxy=plot(obj,'S11','S12','S21','S22','angle (degrees)');
            else
                hxy=plot(obj,'S11','S12','S21','S22','angle (radians)');
            end
        elseif mpval==3
            hxy=plot(obj,'S11','S12','S21','S22','real');
        else
            hxy=plot(obj,'S11','S12','S21','S22','imag');
        end
        legend('hide')
        set(hxy(1),'linestyle','-','linewidth',2);
        set(hxy(2),'linestyle',':','linewidth',2);
        set(hxy(3),'linestyle','-.','linewidth',2);
        set(hxy(4),'linestyle','--','linewidth',2);
        set(get(hxy(1),'Parent'),'HandleVisibility','callback');
        handles.hxy=hxy;
        hdcm=datacursormode;
        set(hdcm,'SnapToDataVertex','on');
        datacursormode(gcf,'on');
        if handles.plotoptions.ylinlogmenu.value==2
            set(get(hxy(1),'Parent'),'XScale','log')
        else
            set(get(hxy(1),'Parent'),'XScale','linear')
        end

        xdata=get(hxy(1),'Xdata');
        if length(xdata)>1
            set(xyax,'Xlim',[xdata(1),xdata(end)]);
        end

        if get(handles.xyplot_s11,'Value')
            set(handles.hxy(1),'Visible','on');
        else
            set(handles.hxy(1),'Visible','off');
        end
        if get(handles.xyplot_s12,'Value')
            set(handles.hxy(2),'Visible','on');
        else
            set(handles.hxy(2),'Visible','off');
        end
        if get(handles.xyplot_s21,'Value')
            set(handles.hxy(3),'Visible','on');
        else
            set(handles.hxy(3),'Visible','off');
        end
        if get(handles.xyplot_s22,'Value')
            set(handles.hxy(4),'Visible','on');
        else
            set(handles.hxy(4),'Visible','off');
        end


        plrax=handles.PolarDataPlot;
        axes(plrax);
        plot(plrax,NaN,NaN,'Visible','off');
        reveal_figure_handle(handles);
        axes(plrax);
        hpolar=polar(obj,'S11','S12','S21','S22');
        legend('hide')
        set(hpolar(1),'linestyle','-','linewidth',2);
        set(hpolar(2),'linestyle',':','linewidth',2);
        set(hpolar(3),'linestyle','-.','linewidth',2);
        set(hpolar(4),'linestyle','--','linewidth',2);
        set(get(hpolar(1),'Parent'),'HandleVisibility','callback');
        handles.hpolar=hpolar;
        hdcm=datacursormode;
        set(hdcm,'SnapToDataVertex','on');
        datacursormode(gcf,'on');
        if get(handles.polarplot_s11,'Value')
            set(handles.hpolar(1),'Visible','on');
        else
            set(handles.hpolar(1),'Visible','off');
        end
        if get(handles.polarplot_s12,'Value')
            set(handles.hpolar(2),'Visible','on');
        else
            set(handles.hpolar(2),'Visible','off');
        end
        if get(handles.polarplot_s21,'Value')
            set(handles.hpolar(3),'Visible','on');
        else
            set(handles.hpolar(3),'Visible','off');
        end
        if get(handles.polarplot_s22,'Value')
            set(handles.hpolar(4),'Visible','on');
        else
            set(handles.hpolar(4),'Visible','off');
        end


    else
        set(handles.rfdatplotfrm3,'Visible','off')
        set(handles.rfdatplotfrm,'Visible','off')
        set(handles.rfdatplotfrm2,'Visible','off')




        handles.Tab.setVisible(1);

        set(handles.rfdatdisptxt,'Visible','on')
        displaySParams(obj,handles);
    end


    hide_figure_handle(handles);
end

function figh=set_figure_tag(figtagstr)
    figh=findobj(0,'Type','Figure','Tag',figtagstr);
    if(ishghandle(figh))
        figure(figh);
    else
        figh=figure;
        set(figh,'Tag',figtagstr);
    end
end



function rftoolfig_ResizeFcn(hObject,eventdata,handles)

    if~isempty(handles)&&isfield(handles,'Tab')
        try
            entireFigPosition=get(handles.rftoolfig,'Position');

            currPanelPosition=get(handles.rfdatdisptxt,'Position');
            newPos=currPanelPosition.*entireFigPosition([3,4,3,4]);
            subPanelPosition=get(handles.RFDataTable,'position');
            newPos=[newPos(1:2),0,0]+subPanelPosition.*newPos([3,4,3,4]);
            hTab=handles.Tab;



            hTab.setPosition(newPos);


            hTab.setColumnWidth((newPos(3)-40)/9);







            if(get(handles.plotpushb,'value'))
                hTab.setVisible(0);
            else
                hTab.setVisible(1);
            end

            currPanelPosition=get(handles.rfcomlistfrm,'Position');
            newPos=currPanelPosition.*entireFigPosition([3,4,3,4]);
            subPanelPosition=get(handles.RFCompTree,'position');
            newPos=[newPos(1:2),0,0]+subPanelPosition.*newPos([3,4,3,4]);
            huitree=handles.uitree;
            huitree.setPosition(newPos);

            currPanelPosition=get(handles.compparamfrm,'Position');
            newPos=currPanelPosition.*entireFigPosition([3,4,3,4]);
            subPanelPosition=get(handles.RFCompParams,'position');
            newPos=[newPos(1:2),0,0]+subPanelPosition.*newPos([3,4,3,4]);
            hTab1=handles.Tab1;



            hTab1.setPosition(newPos);


            hTab1.setColumnWidth(newPos(3)/2.2);

        catch
        end
    end
end

function RFToolHelpMenu_Callback(hObject,eventdata,handles)
    doc('rftool');
end

function compname=makenameunique(compname,huitree)
    hcurrnode=handle(get(huitree,'root'));
    more=1;
    usednumstr=[];
    while more==1
        currname=get(hcurrnode,'Name');
        if(length(currname)>=length(compname)&&...
            strcmp(compname,currname(1:length(compname))))
            usednumstr=[usednumstr,' ',currname(length(compname)+1:end)];
        end
        hnextnode=handle(get(hcurrnode,'nextnode'));
        if~isempty(hnextnode)
            hcurrnode=hnextnode;
        else
            more=0;
        end
    end

    if isempty(usednumstr)
        numstr='';
    else
        testnum=1;
        while strfind(usednumstr,num2str(testnum))
            testnum=testnum+1;
        end
        numstr=num2str(testnum);
    end
    compname=[compname,numstr];
end


function object=addobject(hnode,handles)

    hcompname=handles.new_data{1};
    hcomptype=handles.new_data{2};
    data=handles.new_data{3};
    object=ckt_name_map(hcomptype);

    if~isempty(object)

        isNtwk='false';

        settable_props=set(object);


        name=data(:,1);
        val=data(:,2);
        numParam=size(val,1);
        try
            for paramCnt=1:numParam

                prop=char(param_name_map(name(paramCnt),0));

                if isfield(settable_props,prop)


                    if~isequal(val{paramCnt,:},'no change')

                        if ispropertyrfobject(prop)
                            if isa(val{paramCnt,:},'rfdata.rfdata')

                                set(object,prop,copy(val{paramCnt,:}));
                            else
                                set(object,prop,val{paramCnt,:});
                            end
                        else
                            set(object,prop,val{paramCnt,:});
                        end
                    end

                end

            end
        catch addOBJException
            rethrow(addOBJException);
        end

    else

        object=network_name_map(hcomptype);
        isNtwk='true';

    end

    huitree=handles.uitree;
    huiroot=handles.uiroot;

    objname=makenameunique(hcompname,huitree);
    orig_state=warning('off','MATLAB:uitreenode:DeprecatedFunction');
    newNode=uitreenode('v0',object,hcompname,[],true);
    warning(orig_state);

    if isa(object,'rfckt.datafile')&&~strcmp(object.File,object.AnalyzedResult.Reference.File)
        read(object,object.File);
    end
    if object.nPort~=2
        error(message('rf:rftool:TwoPortOnly'))
    end

    nodedata=getappdata(handle(newNode),'UserData');
    if isrefbased(object)&&~isempty(object.AnalyzedResult)...
        &&~isempty(object.AnalyzedResult.Reference)...
        &&~isempty(object.AnalyzedResult.Reference.NetworkData)...
        &&~isempty(object.AnalyzedResult.Reference.NetworkData.Freq)

        object=analyze(object,object.AnalyzedResult.Reference.NetworkData.Freq);
        nodedata.analyzed=true;
    else
        nodedata.analyzed=false;
    end
    setappdata(handle(newNode),'UserData',nodedata);

    huitree.add(hnode,newNode);
    if any(strcmp(fieldnames(object),'Ckts'))
        setLeafNode(newNode,false);
    end
    guidata(handles.rftoolfig,handles);
    huitree.nodeStructureChangeCompleted(hnode);

    selNode=getLastChild(hnode);

    selNode.setUserObject(object);


    selNode.getUserObject.acquireReference

end


function refreshTable(selNode,handles)



    hTab1=handles.Tab1;


    col_width=hTab1.getColumnWidth;

    selObjNode=handle(selNode.getUserObject);

    settable_props=set(handle(selObjNode));
    fn=fieldnames(settable_props);




    if~any(strcmp(fn,'Ckts'))
        nparams=length(fn);
        data=cell(nparams,2);
        for idx1=1:length(fn)
            param_value=get(handle(selObjNode),fn(idx1));
            param_string=[];

            if isnumeric(param_value{1})
                for idx2=1:length(param_value{1})
                    param_string=[param_string,num2str(param_value{1}(idx2)),' '];
                end
            elseif isa(param_value{1},'rfdata.rfdata')
                param_string=[class(param_value{1}),' object'];
            else
                param_string=param_value{1};
            end

            param_name=param_name_map(char(fn(idx1)),1);
            data(idx1,:)={char(param_name),param_string};
        end
    else
        data=cell(length(selObjNode.Ckts),2);

        for idx=1:size(data,1),
            data(idx,1)={get(handle(getChildAt(selNode,idx-1)),'Name')};
            data(idx,2)={selObjNode.Ckts{idx}.Name};
        end
    end



    hTab1.setData(data);


    hTab1.setColumnWidth(col_width);



    hTab1.setVisible(1);
end

function displaySParams(selNodeObj,handles)





    if get(handles.datapushb,'Value')

        huitree=handles.uitree;
        nodes=huitree.getSelectedNodes;
        if numel(nodes)>0
            selNode=handle(nodes(1));
            nodeData=getappdata(selNode,'UserData');
        else
            nodeData.analyzed=false;
        end

        hTab=handles.Tab;



        pos=hTab.getColumnWidth;





        hTab.setEditable(1,true);





        nRows=hTab.getNumRows;
        nCols=hTab.getNumColumns;



        if(~isempty(selNodeObj.AnalyzedResult)&&...
            isfield(nodeData,'analyzed')&&nodeData.analyzed)


            rfdat=get(selNodeObj,'AnalyzedResult');


            sparam=rfdat.S_Parameters;
            freq=rfdat.Freq;
            if~isempty(sparam)&&~isempty(freq)


                dc=cell(length(freq),nCols);
                tempParam=calculate(rfdat,'S11','dB');
                dbS11=tempParam{1};
                tempParam=calculate(rfdat,'S11','Angle');
                angS11=tempParam{1};
                tempParam=calculate(rfdat,'S12','dB');
                dbS12=tempParam{1};
                tempParam=calculate(rfdat,'S12','Angle');
                angS12=tempParam{1};
                tempParam=calculate(rfdat,'S21','dB');
                dbS21=tempParam{1};
                tempParam=calculate(rfdat,'S21','Angle');
                angS21=tempParam{1};
                tempParam=calculate(rfdat,'S22','dB');
                dbS22=tempParam{1};
                tempParam=calculate(rfdat,'S22','Angle');
                angS22=tempParam{1};
                for i1=1:numel(freq),
                    dc{i1,1}=sprintf('%1.4g',freq(i1));
                    dc{i1,2}=sprintf('%+5.3f',dbS11(i1));
                    dc{i1,3}=sprintf('%+5.3f',angS11(i1));
                    dc{i1,4}=sprintf('%+5.3f',dbS21(i1));
                    dc{i1,5}=sprintf('%+5.3f',angS21(i1));
                    dc{i1,6}=sprintf('%+5.3f',dbS12(i1));
                    dc{i1,7}=sprintf('%+5.3f',angS12(i1));
                    dc{i1,8}=sprintf('%+5.3f',dbS22(i1));
                    dc{i1,9}=sprintf('%+5.3f',angS22(i1));
                end

            end

        else
            dc={' ',' ',' ',' ',' ',' ',' ',' ',' '};
        end



        hTab.setData(dc);



        hTab.setColumnWidth(pos);




        hTab.setEditable(1,false);



    end

end

function exporttofile_filemenu_Callback(hObject,eventdata,handles)


    hrftoolfig=handles.rftoolfig;
    hrftool=guidata(hrftoolfig);
    nodes=hrftool.uitree.getSelectedNodes;
    selNode=nodes(1);
    root=handles.uiroot;

    if(strcmp(selNode.getName,root.getName))
        errordlg('Cannot export the session node. Select another node.');
        return;
    end

    cktobj=handle(getUserObject(selNode));
    if isempty(cktobj.AnalyzedResult)
        errordlg('The selected node must be analyzed before exporting to file.');
        return;
    end


    name=double(char(getName(selNode)));
    name(~isstrprop(name,'alphanum'))=95;
    name=name(1:min(length(name),28));
    name=['rft_',char(name),'.s2p'];

    [fname,pname]=uiputfile({'*.s2p';'*.y2p';'*.z2p';'*.h2p'},'Export to File',name);
    if~isequal(fname,0)

        filename=[pname,fname];

        try
            eval(['write(cktobj.AnalyzedResult,''',[pname,fname],''');']);
        catch saveException

            if strcmp(saveException.identifier,'MATLAB:save:permissionDenied')
                errordlg('Unable to save session: permission denied');
            else
                errordlg(saveException.message);
            end
            return
        end

    end
end

function newsess_filemenu_Callback(hObject,eventdata,handles)

    hrftoolfig=handles.rftoolfig;
    huitree=handles.uitree;
    huiroot=handles.uiroot;


    rftooluserdatastruct=get(hrftoolfig,'userdata');
    if(rftooluserdatastruct.isModified&&getChildCount(huiroot))

        saveResponse=questdlg('Do you want to save the current session?','Save Current Session');

        switch saveResponse,
        case 'Yes',
            rftool('savesessas_filemenu_Callback',gcbo,[],guidata(gcbo));
        case 'No',
        case 'Cancel',
            return;
        end

    end


    huiroot=handles.uiroot;
    huitree=handles.uitree;
    set(huiroot,'Name','untitled session');
    set(handles.compnameedt,'String','untitled session                               ');




    huitree.setSelectedNode(huiroot);

    rftooluserdatastruct.isFirstSave=true;
    rftooluserdatastruct.isModified=false;
    set(hrftoolfig,'Name','RF Design and Analysis');
    set(hrftoolfig,'userdata',rftooluserdatastruct);

    numCkts=length(handles.ckts);
    for idx=numCkts:-1:1
        handles.ckts{idx}=[];
    end
    handles.ckts={};

    numChildren=getChildCount(huiroot);
    for idx=numChildren:-1:1
        childNode=huiroot.getChildAt(idx-1);

        huitree.remove(huiroot,childNode);
        huitree.nodesWereRemoved(huiroot,[],childNode);
    end
    huitree.reloadNode(huiroot);
    huitree.setSelectedNode(huiroot);

    guidata(handles.rftoolfig,handles);
    drawnow;
end












function polarplot_s11_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hpolar=findobj(rftooldata.PolarDataPlot,'Type','Line');
    idx=strmatch('S_{11}',get(hpolar,'DisplayName'));
    rftooldata.hpolar(1)=hpolar(idx);
    if get(hObject,'Value')
        set(rftooldata.hpolar(1),'Visible','on');
    else
        set(rftooldata.hpolar(1),'Visible','off');
    end


end

function polarplot_s12_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hpolar=findobj(rftooldata.PolarDataPlot,'Type','Line');
    idx=strmatch('S_{12}',get(hpolar,'DisplayName'));
    rftooldata.hpolar(2)=hpolar(idx);
    if get(hObject,'Value')
        set(rftooldata.hpolar(2),'Visible','on');
    else
        set(rftooldata.hpolar(2),'Visible','off');
    end


end

function polarplot_s21_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hpolar=findobj(rftooldata.PolarDataPlot,'Type','Line');
    idx=strmatch('S_{21}',get(hpolar,'DisplayName'));
    rftooldata.hpolar(3)=hpolar(idx);
    if get(hObject,'Value')
        set(rftooldata.hpolar(3),'Visible','on');
    else
        set(rftooldata.hpolar(3),'Visible','off');
    end


end

function polarplot_s22_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hpolar=findobj(rftooldata.PolarDataPlot,'Type','Line');
    idx=strmatch('S_{22}',get(hpolar,'DisplayName'));
    rftooldata.hpolar(4)=hpolar(idx);
    if get(hObject,'Value')
        set(rftooldata.hpolar(4),'Visible','on');
    else
        set(rftooldata.hpolar(4),'Visible','off');
    end


end

function xyplot_s11_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hxy=findobj(rftooldata.XYDataPlot,'Type','Line');
    idx=strmatch('S_{11}',get(hxy,'DisplayName'));
    rftooldata.hxy(1)=hxy(idx);
    if get(hObject,'Value')
        set(rftooldata.hxy(1),'Visible','on');
    else
        set(rftooldata.hxy(1),'Visible','off');
    end


end

function xyplot_s12_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hxy=findobj(rftooldata.XYDataPlot,'Type','Line');
    idx=strmatch('S_{12}',get(hxy,'DisplayName'));
    rftooldata.hxy(2)=hxy(idx);
    if get(hObject,'Value')
        set(rftooldata.hxy(2),'Visible','on');
    else
        set(rftooldata.hxy(2),'Visible','off');
    end


end

function xyplot_s21_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hxy=findobj(rftooldata.XYDataPlot,'Type','Line');
    idx=strmatch('S_{21}',get(hxy,'DisplayName'));
    rftooldata.hxy(3)=hxy(idx);
    if get(hObject,'Value')
        set(rftooldata.hxy(3),'Visible','on');
    else
        set(rftooldata.hxy(3),'Visible','off');
    end


end

function xyplot_s22_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hxy=findobj(rftooldata.XYDataPlot,'Type','Line');
    idx=strmatch('S_{22}',get(hxy,'DisplayName'));
    rftooldata.hxy(4)=hxy(idx);
    if get(hObject,'Value')
        set(rftooldata.hxy(4),'Visible','on');
    else
        set(rftooldata.hxy(4),'Visible','off');
    end


end

function xymagphsmenu_Callback(hObject,eventdata,handles)
    peers=get(get(hObject,'Parent'),'Children');
    hlldr=peers(strcmp(get(peers,'Tag'),'xylinlogdegradmenu'));
    hlldrstroptions={{'Linear','Log (dB)'},{'Degrees','Radians'}...
    ,{'Linear','Linear'},{'Linear','Linear'}};
    set(hlldr,'String',hlldrstroptions{get(hObject,'Value')});
    if(get(hObject,'Value')<3)
        set(hlldr,'Enable','On');
        set_current_data(hlldr,handles);
    else
        set(hlldr,'Enable','Off');
        set_current_data(hlldr,handles);
    end
    set_current_data(hObject,handles);
end

function xymagphsmenu_CreateFcn(hObject,eventdata,handles)

    set(hObject,'BackgroundColor','white');



end

function xylinlogdegradmenu_Callback(hObject,eventdata,handles)
    set_current_data(hObject,handles);
end

function ylinlogmenu_Callback(hObject,eventdata,handles)
    set_current_data(hObject,handles);
end

function xylinlogdegradmenu_CreateFcn(hObject,eventdata,handles)

    set(hObject,'BackgroundColor','white');



end

function ylinlogmenu_CreateFcn(hObject,eventdata,handles)

    set(hObject,'BackgroundColor','white');



end

function smithchart_s11_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hsmith=findobj(rftooldata.RFDataPlot,'Type','Line');
    idx=strmatch('S_{11}',get(hsmith,'DisplayName'));
    rftooldata.hsmith(1)=hsmith(idx);
    if get(hObject,'Value')
        set(rftooldata.hsmith(1),'Visible','on');
    else
        set(rftooldata.hsmith(1),'Visible','off');
    end


end

function smithchart_s12_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hsmith=findobj(rftooldata.RFDataPlot,'Type','Line');
    idx=strmatch('S_{12}',get(hsmith,'DisplayName'));
    rftooldata.hsmith(2)=hsmith(idx);
    if get(hObject,'Value')
        set(rftooldata.hsmith(2),'Visible','on');
    else
        set(rftooldata.hsmith(2),'Visible','off');
    end


end

function smithchart_s21_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hsmith=findobj(rftooldata.RFDataPlot,'Type','Line');
    idx=strmatch('S_{21}',get(hsmith,'DisplayName'));
    rftooldata.hsmith(3)=hsmith(idx);
    if get(hObject,'Value')
        set(rftooldata.hsmith(3),'Visible','on');
    else
        set(rftooldata.hsmith(3),'Visible','off');
    end


end

function smithchart_s22_Callback(hObject,eventdata,handles)
    rftooldata=guidata(handles.rftoolfig);







    hsmith=findobj(rftooldata.RFDataPlot,'Type','Line');
    idx=strmatch('S_{22}',get(hsmith,'DisplayName'));
    rftooldata.hsmith(4)=hsmith(idx);
    if get(hObject,'Value')
        set(rftooldata.hsmith(4),'Visible','on');
    else
        set(rftooldata.hsmith(4),'Visible','off');
    end


end

function smithyztypemenu_Callback(hObject,eventdata,handles)
    set_current_data(hObject,handles);
end

function smithyztypemenu_CreateFcn(hObject,eventdata,handles)

    set(hObject,'BackgroundColor','white');



end

function set_current_data(hObject,handles)

    hrftoolfig=handles.rftoolfig;
    rftooldata=guidata(hrftoolfig);
    plotoptions=rftooldata.plotoptions;

    plotoptions.smithyztypemenu.enable=get(handles.smithyztypemenu,'Enable');
    plotoptions.smithyztypemenu.value=get(handles.smithyztypemenu,'Value');
    plotoptions.xymagphsmenu.enable=get(handles.xymagphsmenu,'Enable');
    plotoptions.xymagphsmenu.value=get(handles.xymagphsmenu,'Value');
    plotoptions.xylinlogdegradmenu.enable=get(handles.xylinlogdegradmenu,'Enable');
    plotoptions.xylinlogdegradmenu.value=get(handles.xylinlogdegradmenu,'Value');
    plotoptions.ylinlogmenu.enable=get(handles.ylinlogmenu,'Enable');
    plotoptions.ylinlogmenu.value=get(handles.ylinlogmenu,'Value');


    rftooldata.plotoptions=plotoptions;
    guidata(hrftoolfig,rftooldata);



    plotpushb_Callback(hrftoolfig,1,rftooldata);

end

function plotManualLegend(hObject,eventdata,handles)



    colorder=get(0,'DefaultAxesColorOrder');

    hplot=plot(hObject,...
    [0.12,0.27],[0.5,0.5],...
    [0.35,0.49],[0.5,0.5],...
    [0.58,0.73],[0.5,0.5],...
    [0.81,0.96],[0.5,0.5]);
    set(hplot(1),'color',colorder(1,:),'linestyle','-','linewidth',2);
    set(hplot(2),'color',colorder(2,:),'linestyle',':','linewidth',2);
    set(hplot(3),'color',colorder(3,:),'linestyle','-.','linewidth',2);
    set(hplot(4),'color',colorder(4,:),'linestyle','--','linewidth',2);

    hax=get(hplot(1),'Parent');
    defUIbkgrndcolor=get(0,'defaultUicontrolBackgroundColor');
    set(hax,...
    'XColor',defUIbkgrndcolor,...
    'YColor',defUIbkgrndcolor,...
    'XTick',[],...
    'YTick',[],...
    'Color',defUIbkgrndcolor,...
    'Box','Off');
end



function h1=rftool_LayoutFcn(policy)


    persistent hsingleton;
    if strcmpi(policy,'reuse')&ishghandle(hsingleton)
        h1=hsingleton;
        return;
    end

    appdata=[];
    appdata.GUIDEOptions=struct(...
    'active_h',[],...
    'taginfo',struct(...
    'figure',2,...
    'frame',18,...
    'text',45,...
    'pushbutton',46,...
    'edit',20,...
    'popupmenu',5,...
    'listbox',9,...
    'axes',4,...
    'uipanel',10,...
    'togglebutton',2),...
    'override',0,...
    'release',13,...
    'resize','simple',...
    'accessibility','callback',...
    'matlabfunction',1,...
    'callbacks',1,...
    'singleton',1,...
    'syscolorfig',1,...
    'blocking',0,...
    'lastSavedFile','rftool.m');
    appdata.lastValidTag='rftoolfig';

    colorder=get(0,'DefaultAxesColorOrder');

    screen_size=get(0,'ScreenSize');
    temp_pos=zeros(1,4);
    temp_pos(4)=0.62*screen_size(4);
    temp_pos(3)=temp_pos(4)*1.5;
    temp_pos(1)=screen_size(1)+screen_size(3)-1.03*temp_pos(3);
    temp_pos(2)=screen_size(2)+screen_size(4)-1.24*temp_pos(4);
    h1=figure(...
    'CloseRequestFcn','rftool(''rftoolfig_CloseRequestFcn'',gcf,[],guidata(gcf))',...
    'Color',[0.831372549019608,0.815686274509804,0.784313725490196],...
    'Colormap',[0,0,0.5625;0,0,0.625;0,0,0.6875;0,0,0.75;0,0,0.8125;0,0,0.875;0,0,0.9375;0,0,1;0,0.0625,1;0,0.125,1;0,0.1875,1;0,0.25,1;0,0.3125,1;0,0.375,1;0,0.4375,1;0,0.5,1;0,0.5625,1;0,0.625,1;0,0.6875,1;0,0.75,1;0,0.8125,1;0,0.875,1;0,0.9375,1;0,1,1;0.0625,1,1;0.125,1,0.9375;0.1875,1,0.875;0.25,1,0.8125;0.3125,1,0.75;0.375,1,0.6875;0.4375,1,0.625;0.5,1,0.5625;0.5625,1,0.5;0.625,1,0.4375;0.6875,1,0.375;0.75,1,0.3125;0.8125,1,0.25;0.875,1,0.1875;0.9375,1,0.125;1,1,0.0625;1,1,0;1,0.9375,0;1,0.875,0;1,0.8125,0;1,0.75,0;1,0.6875,0;1,0.625,0;1,0.5625,0;1,0.5,0;1,0.4375,0;1,0.375,0;1,0.3125,0;1,0.25,0;1,0.1875,0;1,0.125,0;1,0.0625,0;1,0,0;0.9375,0,0;0.875,0,0;0.8125,0,0;0.75,0,0;0.6875,0,0;0.625,0,0;0.5625,0,0],...
    'DockControls','off',...
    'IntegerHandle','off',...
    'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
    'MenuBar','none',...
    'Name','RF Design and Analysis',...
    'NumberTitle','off',...
    'PaperPosition',get(0,'defaultfigurePaperPosition'),...
    'Position',temp_pos,...
    'Renderer',get(0,'defaultfigureRenderer'),...
    'RendererMode','manual',...
    'ResizeFcn','rftool(''rftoolfig_ResizeFcn'',gcbo,[],guidata(gcbo))',...
    'HandleVisibility','callback',...
    'Tag','rftoolfig',...
    'UserData',[],...
    'Behavior',get(0,'defaultfigureBehavior'),...
    'Visible','off',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    h3=uimenu(...
    'Parent',h1,...
    'Accelerator','F',...
    'Label','File',...
    'Tag','file_menu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h4=uimenu(...
    'Parent',h3,...
    'Callback','rftool(''newsess_filemenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','New Session',...
    'Tag','newsess_filemenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h5=uimenu(...
    'Parent',h3,...
    'Callback','rftool(''opensess_filemenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','Open Session',...
    'Tag','opensess_filemenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h6=uimenu(...
    'Parent',h3,...
    'Callback','rftool(''importfromfile_filemenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','Import From File',...
    'Tag','importfromfile_filemenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h7=uimenu(...
    'Parent',h3,...
    'Callback','rftool(''importfromws_filemenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','Import From Workspace',...
    'Tag','importfromws_filemenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h8=uimenu(...
    'Parent',h3,...
    'Callback','rftool(''savesess_filemenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','Save Session',...
    'Separator','on',...
    'Tag','savesess_filemenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h9=uimenu(...
    'Parent',h3,...
    'Callback','rftool(''savesessas_filemenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','Save Session As',...
    'Tag','savesessas_filemenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h10=uimenu(...
    'Parent',h3,...
    'Callback','rftool(''exporttofile_filemenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','Export To File',...
    'Tag','exporttofile_filemenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h11=uimenu(...
    'Parent',h3,...
    'Callback','rftool(''export_filemenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','Export To Workspace',...
    'Tag','export_filemenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h12=uimenu(...
    'Parent',h3,...
    'Callback','rftool(''close_filemenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','Close',...
    'Separator','on',...
    'Tag','close_filemenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    appdata=[];
    appdata.lastValidTag='rfdatdisptxt';

    h13=uipanel(...
    'Parent',h1,...
    'Title','RF Data Display',...
    'Position',[0.01,0.02,0.98,0.52],...
    'Tag','rfdatdisptxt',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'Visible','off',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='RFDataTable';

    h14=uipanel(...
    'Parent',h13,...
    'Title','',...
    'Position',[0.01,0.02,0.98,0.93],...
    'Tag','RFDataTable',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'Visible','off',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='compparamfrm';

    h15=uipanel(...
    'Parent',h1,...
    'Title','Component Parameters',...
    'Position',[0.4,0.65,0.59,0.34],...
    'Tag','compparamfrm',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='RFCompParams';

    h16=uipanel(...
    'Parent',h15,...
    'Title','',...
    'Position',[0.03,0.07,0.79,0.66],...
    'Tag','RFCompParams',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'Visible','off',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='insertpushb';

    h17=uicontrol(...
    'Parent',h15,...
    'Units','normalized',...
    'Callback','rftool(''insertpushb_Callback'',gcbo,[],guidata(gcbo))',...
    'Position',[0.84,0.61,0.11,0.1],...
    'String','Insert',...
    'TooltipString','Insert component',...
    'Tag','insertpushb',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='uppushb';

    h18=uicontrol(...
    'Parent',h15,...
    'Units','normalized',...
    'Callback','rftool(''uppushb_Callback'',gcbo,[],guidata(gcbo))',...
    'Position',[0.84,0.46,0.11,0.1],...
    'String','Up',...
    'TooltipString','Move selected component up',...
    'Tag','uppushb',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='downpushb';

    h19=uicontrol(...
    'Parent',h15,...
    'Units','normalized',...
    'Callback','rftool(''downpushb_Callback'',gcbo,[],guidata(gcbo))',...
    'Position',[0.84,0.31,0.11,0.1],...
    'String','Down',...
    'TooltipString','Move selected component down',...
    'Tag','downpushb',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='applypushb';

    h2=uicontrol(...
    'Parent',h15,...
    'Units','normalized',...
    'Callback','rftool(''applypushb_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Position',[0.84,0.08,0.11,0.1],...
    'String','Apply',...
    'TooltipString','Apply change to parameter or name',...
    'Tag','applypushb',...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='comptypetxt';

    h20=uicontrol(...
    'Parent',h15,...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[0.51,0.87,0.06,0.10],...
    'String','Type: ',...
    'Style','text',...
    'Tag','comptypetxt',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='comptypeedt';

    h21=uicontrol(...
    'Parent',h15,...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[0.60,0.90,0.25+0.1,0.07],...
    'String','RF Tool Session',...
    'Style','text',...
    'CreateFcn',{@local_CreateFcn,'rftool(''comptypeedt_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
    'Tag','comptypeedt');

    appdata=[];
    appdata.lastValidTag='compnameedt';

    h22=uicontrol(...
    'Parent',h15,...
    'Units','normalized',...
    'BackgroundColor',[1,1,1],...
    'HorizontalAlignment','left',...
    'Position',[0.12,0.87,0.37,0.10],...
    'String','Component1',...
    'Style','edit',...
    'CreateFcn',{@local_CreateFcn,'rftool(''compnameedt_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
    'Tag','compnameedt');

    appdata=[];
    appdata.lastValidTag='compnametxt';

    h23=uicontrol(...
    'Parent',h15,...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[0.04,0.90,0.07,0.06],...
    'String','Name: ',...
    'Style','text',...
    'Tag','compnametxt',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='rfcomlistfrm';

    h24=uipanel(...
    'Parent',h1,...
    'Title','RF Component List',...
    'Position',[0.01,0.65,0.38,0.34],...
    'Tag','rfcomlistfrm',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='deletepushb';

    h25=uicontrol(...
    'Parent',h24,...
    'Units','normalized',...
    'Callback','rftool(''deletepushb_Callback'',gcbo,[],guidata(gcbo))',...
    'Position',[0.49,0.043,0.18,0.1],...
    'String','Delete',...
    'TooltipString','Delete selected item',...
    'Tag','deletepushb',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='createpushb';

    h26=uicontrol(...
    'Parent',h24,...
    'Units','normalized',...
    'Callback','rftool(''createpushb_Callback'',gcbo,[],guidata(gcbo))',...
    'Position',[0.26,0.043,0.18,0.1],...
    'String','Add',...
    'TooltipString','Create new component',...
    'Tag','createpushb',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='RFCompTree';

    h27=uipanel(...
    'Parent',h24,...
    'Title','',...
    'Position',[0.06,0.17,0.87,0.72],...
    'Tag','RFCompTree',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'Visible','off',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    h28=matlab.ui.internal.createWinMenu(h1);
    set(h28,'Behavior',get(0,'defaultuimenuBehavior'));

    h29=uimenu(...
    'Parent',h1,...
    'Label','Help',...
    'Tag','help_menu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h30=uimenu(...
    'Parent',h29,...
    'Callback','rftool(''RFToolHelpMenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','RF Tool Help',...
    'Tag','RFToolHelpMenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h31=uimenu(...
    'Parent',h29,...
    'Callback','rftool(''rftbx_helpmenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','RF Toolbox Help',...
    'Tag','rftbx_helpmenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h32=uimenu(...
    'Parent',h29,...
    'Callback','rftool(''rfdemos_helpmenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','RF Demos',...
    'Separator','on',...
    'Tag','rfdemos_helpmenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    h33=uimenu(...
    'Parent',h29,...
    'Callback','rftool(''aboutrftbx_helpmenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Label','About RF Toolbox',...
    'Separator','on',...
    'Tag','aboutrftbx_helpmenu',...
    'Behavior',get(0,'defaultuimenuBehavior'));

    appdata=[];
    appdata.lastValidTag='analysisfrm';

    h34=uipanel(...
    'Parent',h1,...
    'Title','Analysis',...
    'Position',[0.01,0.01,0.98,0.63],...
    'Tag','analysisfrm',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='freqedt';

    h35=uicontrol(...
    'Parent',h34,...
    'Units','normalized',...
    'BackgroundColor',[1,1,1],...
    'Callback','rftool(''freqedt_Callback'',gcbo,[],guidata(gcbo))',...
    'HorizontalAlignment','left',...
    'Position',[0.09+0.02,0.93,0.25-0.02,0.05],...
    'String','[1e8:5e6:2e9]',...
    'Style','edit',...
    'CreateFcn',{@local_CreateFcn,'rftool(''freqedt_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
    'Tag','freqedt');

    appdata=[];
    appdata.lastValidTag='charimpedt';

    h36=uicontrol(...
    'Parent',h34,...
    'Units','normalized',...
    'BackgroundColor',[1,1,1],...
    'Callback','rftool(''charimpedt_Callback'',gcbo,[],guidata(gcbo))',...
    'HorizontalAlignment','left',...
    'Position',[0.51+0.04,0.93,0.08,0.05],...
    'String','50',...
    'Style','edit',...
    'CreateFcn',{@local_CreateFcn,'rftool(''charimpedt_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
    'Tag','charimpedt');

    appdata=[];
    appdata.lastValidTag='charimptxt';

    h37=uicontrol(...
    'Parent',h34,...
    'Units','normalized',...
    'CData',[],...
    'HorizontalAlignment','right',...
    'Position',[0.35,0.925,0.15+0.02,0.05],...
    'String',' Reference impedance: ',...
    'Style','text',...
    'Tag','charimptxt',...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='freqtxt';

    h38=uicontrol(...
    'Parent',h34,...
    'Units','normalized',...
    'CData',[],...
    'HorizontalAlignment','right',...
    'Position',[0.01,0.925,0.07+0.02,0.05],...
    'String',' Frequency: ',...
    'Style','text',...
    'Tag','freqtxt',...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='analyzepushb';

    h39=uicontrol(...
    'Parent',h34,...
    'Units','normalized',...
    'Callback','rftool(''analyzepushb_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Position',[0.66+0.04,0.93,0.10,0.05],...
    'String','Analyze',...
    'TooltipString','Analyze selected item',...
    'Tag','analyzepushb',...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='radiobuttonpanel';

    h40=uibuttongroup(...
    'Parent',h34,...
    'Units','normalized',...
    'BorderType','none',...
    'Position',[.80,.90,.19,.09],...
    'Tag','radiobuttonpanel',...
    'SelectionChangeFcn','rftool(''plotpushb_Callback'',gcbo,1,guidata(gcbo))',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='plotpushb';

    h41=uicontrol(...
    'Parent',h40,...
    'Units','normalized',...
    'Enable','off',...
    'CData',[],...
    'Position',[0.5,0.01,0.44,0.44],...
    'String',{'Plots'},...
    'Style','radiobutton',...
    'Value',1,...
    'Tag','plotpushb');

    appdata=[];
    appdata.lastValidTag='datapushb';

    h42=uicontrol(...
    'Parent',h40,...
    'Units','normalized',...
    'Enable','off',...
    'CData',[],...
    'Position',[0.5,0.51,0.44,0.44],...
    'String',{'Data'},...
    'Style','radiobutton',...
    'Value',0,...
    'Tag','datapushb');

    h43=uicontrol(...
    'Parent',h40,...
    'Units','normalized',...
    'Enable','on',...
    'HorizontalAlignment','right',...
    'Position',[0.01,0.31,0.44,0.44],...
    'String','View: ',...
    'Style','text',...
    'Tag','dataviewtext',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    h61=uipanel(...
    'Parent',h34,...
    'Title','Smith Chart',...
    'Position',[0.01,0.01,0.32,0.88],...
    'Tag','rfdatplotfrm',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    h62=axes(...
    'Parent',h61,...
    'Units','normalized',...
    'Position',[0.125,0.175,0.75,0.75],...
    'Tag','RFDataPlot',...
    'Visible','off',...
    'HandleVisibility','callback',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    h62a=axes(...
    'Parent',h61,...
    'Units','normalized',...
    'Position',[0.0,0.01,1,0.05],...
    'Tag','SmithChartLegend',...
    'Visible','off',...
    'CreateFcn',{@local_CreateFcn,'rftool(''plotManualLegend'',gcbo,[],guidata(gcbo))',appdata});

    appdata=[];
    appdata.lastValidTag='smithchart_s11';

    h63=uicontrol(...
    'Parent',h61,...
    'Units','normalized',...
    'Callback','rftool(''smithchart_s11_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.05,0.05,0.15,0.05],...
    'String','S11',...
    'ForegroundColor',colorder(1,:),...
    'Style','checkbox',...
    'Tag','smithchart_s11',...
    'Value',1,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='smithchart_s12';

    h64=uicontrol(...
    'Parent',h61,...
    'Units','normalized',...
    'Callback','rftool(''smithchart_s12_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.28,0.05,0.15,0.05],...
    'String','S12',...
    'ForegroundColor',colorder(2,:),...
    'Style','checkbox',...
    'Tag','smithchart_s12',...
    'Value',0,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='smithchart_s21';

    h65=uicontrol(...
    'Parent',h61,...
    'Units','normalized',...
    'Callback','rftool(''smithchart_s21_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.51,0.05,0.15,0.05],...
    'String','S21',...
    'ForegroundColor',colorder(3,:),...
    'Style','checkbox',...
    'Tag','smithchart_s21',...
    'Value',0,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='smithchart_s22';

    h66=uicontrol(...
    'Parent',h61,...
    'Units','normalized',...
    'Callback','rftool(''smithchart_s22_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.74,0.05,0.15,0.05],...
    'String','S22',...
    'ForegroundColor',colorder(4,:),...
    'Style','checkbox',...
    'Tag','smithchart_s22',...
    'Value',1,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='smithyztypemenu';

    h68=uicontrol(...
    'Parent',h61,...
    'Units','normalized',...
    'BackgroundColor',[1,1,1],...
    'Callback','rftool(''smithyztypemenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Enable','on',...
    'Position',[0.03,0.94,0.3,0.05],...
    'String',{'Y Chart';'Z Chart';'YZ Chart';'ZY Chart'},...
    'Style','popupmenu',...
    'Value',2,...
    'CreateFcn',{@local_CreateFcn,'rftool(''smithyztypemenu_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
    'Tag','smithyztypemenu');

    h71=uipanel(...
    'Parent',h34,...
    'Title','XY Plot',...
    'Position',[0.34,0.01,0.32,0.88],...
    'Tag','rfdatplotfrm2',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    h72=axes(...
    'Parent',h71,...
    'Units','normalized',...
    'Position',[0.2,0.25,0.75,0.45],...
    'HandleVisibility','callback',...
    'Tag','XYDataPlot',...
    'Visible','off',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    h72a=axes(...
    'Parent',h71,...
    'Units','normalized',...
    'Position',[0.0,0.01,1,0.05],...
    'Tag','XYLegend',...
    'Visible','off',...
    'CreateFcn',{@local_CreateFcn,'rftool(''plotManualLegend'',gcbo,[],guidata(gcbo))',appdata});


    appdata=[];
    appdata.lastValidTag='xyplot_s11';

    h73=uicontrol(...
    'Parent',h71,...
    'Units','normalized',...
    'Callback','rftool(''xyplot_s11_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.05,0.05,0.15,0.05],...
    'String','S11',...
    'ForegroundColor',colorder(1,:),...
    'Style','checkbox',...
    'Tag','xyplot_s11',...
    'Value',0,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='xyplot_s12';

    h74=uicontrol(...
    'Parent',h71,...
    'Units','normalized',...
    'Callback','rftool(''xyplot_s12_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.28,0.05,0.15,0.05],...
    'String','S12',...
    'ForegroundColor',colorder(2,:),...
    'Style','checkbox',...
    'Tag','xyplot_s12',...
    'Value',0,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='xyplot_s21';

    h75=uicontrol(...
    'Parent',h71,...
    'Units','normalized',...
    'Callback','rftool(''xyplot_s21_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.51,0.05,0.15,0.05],...
    'String','S21',...
    'ForegroundColor',colorder(3,:),...
    'Style','checkbox',...
    'Tag','xyplot_s21',...
    'Value',1,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='xyplot_s22';

    h76=uicontrol(...
    'Parent',h71,...
    'Units','normalized',...
    'Callback','rftool(''xyplot_s22_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.74,0.05,0.15,0.05],...
    'String','S22',...
    'ForegroundColor',colorder(4,:),...
    'Style','checkbox',...
    'Tag','xyplot_s22',...
    'Value',0,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='xymagphsmenu';

    h77=uicontrol(...
    'Parent',h71,...
    'Units','normalized',...
    'BackgroundColor',[1,1,1],...
    'Callback','rftool(''xymagphsmenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Enable','on',...
    'Position',[0.63,0.94,0.3+0.05,0.05],...
    'String',{'Magnitude';'Phase';'Real';'Imaginary'},...
    'Style','popupmenu',...
    'Value',1,...
    'CreateFcn',{@local_CreateFcn,'rftool(''xymagphsmenu_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
    'Tag','xymagphsmenu');

    appdata=[];
    appdata.lastValidTag='xylinlogdegradmenu';

    h78=uicontrol(...
    'Parent',h71,...
    'Units','normalized',...
    'BackgroundColor',[1,1,1],...
    'Callback','rftool(''xylinlogdegradmenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Enable','on',...
    'Position',[0.28,0.94,0.3,0.05],...
    'String',{'Linear';'Log (dB)'},...
    'Style','popupmenu',...
    'Value',2,...
    'CreateFcn',{@local_CreateFcn,'rftool(''xylinlogdegradmenu_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
    'Tag','xylinlogdegradmenu');
    appdata=[];
    appdata.lastValidTag='yaxistxt';

    h781=uicontrol(...
    'Parent',h71,...
    'Units','normalized',...
    'CData',[],...
    'HorizontalAlignment','left',...
    'Position',[0.01,0.93,0.25,0.05],...
    'String',' Y options: ',...
    'Style','text',...
    'Tag','yaxistxt',...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});


    appdata=[];
    appdata.lastValidTag='ylinlogmenu';

    h79=uicontrol(...
    'Parent',h71,...
    'Units','normalized',...
    'BackgroundColor',[1,1,1],...
    'Callback','rftool(''ylinlogmenu_Callback'',gcbo,[],guidata(gcbo))',...
    'Enable','on',...
    'Position',[0.28,0.84,0.3,0.05],...
    'String',{'Linear';'Log'},...
    'Style','popupmenu',...
    'Value',1,...
    'CreateFcn',{@local_CreateFcn,'rftool(''ylinlogmenu_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
    'Tag','ylinlogmenu');

    appdata=[];
    appdata.lastValidTag='xaxistxt';

    h791=uicontrol(...
    'Parent',h71,...
    'Units','normalized',...
    'CData',[],...
    'HorizontalAlignment','left',...
    'Position',[0.01,0.83,0.25,0.05],...
    'String',' X options: ',...
    'Style','text',...
    'Tag','xaxistxt',...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});


    h81=uipanel(...
    'Parent',h34,...
    'Title','Polar Plot',...
    'Position',[0.67,0.01,0.32,0.88],...
    'Tag','rfdatplotfrm3',...
    'Behavior',get(0,'defaultuipanelBehavior'),...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    h82=axes(...
    'Parent',h81,...
    'Units','normalized',...
    'Position',[0.125,0.175,0.75,0.75],...
    'HandleVisibility','callback',...
    'Tag','PolarDataPlot',...
    'Visible','off',...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    h82a=axes(...
    'Parent',h81,...
    'Units','normalized',...
    'Position',[0.0,0.01,1,0.05],...
    'Tag','PolarLegend',...
    'Visible','off',...
    'CreateFcn',{@local_CreateFcn,'rftool(''plotManualLegend'',gcbo,[],guidata(gcbo))',appdata});

    appdata=[];
    appdata.lastValidTag='polarplot_s11';

    h83=uicontrol(...
    'Parent',h81,...
    'Units','normalized',...
    'Callback','rftool(''polarplot_s11_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.05,0.05,0.15,0.05],...
    'String','S11',...
    'ForegroundColor',colorder(1,:),...
    'Style','checkbox',...
    'Tag','polarplot_s11',...
    'Value',0,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='polarplot_s12';

    h84=uicontrol(...
    'Parent',h81,...
    'Units','normalized',...
    'Callback','rftool(''polarplot_s12_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.28,0.05,0.15,0.05],...
    'String','S12',...
    'ForegroundColor',colorder(2,:),...
    'Style','checkbox',...
    'Tag','polarplot_s12',...
    'Value',1,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='polarplot_s21';

    h85=uicontrol(...
    'Parent',h81,...
    'Units','normalized',...
    'Callback','rftool(''polarplot_s21_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.51,0.05,0.15,0.05],...
    'String','S21',...
    'ForegroundColor',colorder(3,:),...
    'Style','checkbox',...
    'Tag','polarplot_s21',...
    'Value',0,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});

    appdata=[];
    appdata.lastValidTag='polarplot_s22';

    h86=uicontrol(...
    'Parent',h81,...
    'Units','normalized',...
    'Callback','rftool(''polarplot_s22_Callback'',gcbo,[],guidata(gcbo))',...
    'CData',[],...
    'Enable','on',...
    'Position',[0.74,0.05,0.15,0.05],...
    'String','S22',...
    'ForegroundColor',colorder(4,:),...
    'Style','checkbox',...
    'Tag','polarplot_s22',...
    'Value',0,...
    'UserData',[],...
    'CreateFcn',{@local_CreateFcn,'',appdata});


    hsingleton=h1;

end

function local_CreateFcn(hObject,eventdata,createfcn,appdata)

    if~isempty(appdata)
        names=fieldnames(appdata);
        for i=1:length(names)
            name=char(names(i));
            setappdata(hObject,name,getfield(appdata,name));
        end
    end

    if~isempty(createfcn)
        eval(createfcn);
    end

end

function varargout=gui_mainfcn(gui_State,varargin)

    gui_StateFields={'gui_Name'
'gui_Singleton'
'gui_OpeningFcn'
'gui_OutputFcn'
'gui_LayoutFcn'
    'gui_Callback'};
    gui_Mfile='';
    for i=1:length(gui_StateFields)
        if~isfield(gui_State,gui_StateFields{i})
            error(message('rf:rftool:NoField',gui_StateFields{i},gui_Mfile));
        elseif isequal(gui_StateFields{i},'gui_Name')
            gui_Mfile=[gui_State.(gui_StateFields{i}),'.m'];
        end
    end

    numargin=length(varargin);

    if numargin==0


        gui_Create=1;
    elseif length(varargin{1})==1&&ishghandle(varargin{1})&&varargin{1}==gcbo

        vin{1}=gui_State.gui_Name;
        vin{2}=[get(varargin{1}.Peer,'Tag'),'_',varargin{end}];
        vin{3}=varargin{1};
        vin{4}=varargin{end-1};
        vin{5}=guidata(varargin{1}.Peer);
        feval(vin{:});
        return;
    elseif ischar(varargin{1})&&numargin>1&&length(varargin{2})==1&&...
        (ishghandle(varargin{2})||isa(varargin{2},'handle'))

        gui_Create=0;
    else


        gui_Create=1;
    end

    if gui_Create==0
        varargin{1}=gui_State.gui_Callback;
        if nargout
            [varargout{1:nargout}]=feval(varargin{:});
        else
            feval(varargin{:});
        end
    else
        if gui_State.gui_Singleton
            gui_SingletonOpt='reuse';
        else
            gui_SingletonOpt='new';
        end





        if~isempty(gui_State.gui_LayoutFcn)
            gui_hFigure=feval(gui_State.gui_LayoutFcn,gui_SingletonOpt);


            movegui(gui_hFigure,'onscreen')
        else
            gui_hFigure=local_openfig(gui_State.gui_Name,gui_SingletonOpt);


            if isappdata(gui_hFigure,'InGUIInitialization')
                delete(gui_hFigure);
                gui_hFigure=local_openfig(gui_State.gui_Name,gui_SingletonOpt);
            end
        end


        setappdata(gui_hFigure,'InGUIInitialization',1);


        gui_Options=getappdata(gui_hFigure,'GUIDEOptions');

        if~isappdata(gui_hFigure,'GUIOnScreen')

            if gui_Options.syscolorfig
                set(gui_hFigure,'Color',get(0,'DefaultUicontrolBackgroundColor'));
            end


            guidata(gui_hFigure,guihandles(gui_hFigure));
            drawnow;
        end



        gui_MakeVisible=1;
        for ind=1:2:length(varargin)
            if length(varargin)==ind
                break;
            end
            len1=min(length('visible'),length(varargin{ind}));
            len2=min(length('off'),length(varargin{ind+1}));
            if ischar(varargin{ind})&&ischar(varargin{ind+1})&&...
                strncmpi(varargin{ind},'visible',len1)&&len2>1
                if strncmpi(varargin{ind+1},'off',len2)
                    gui_MakeVisible=0;
                elseif strncmpi(varargin{ind+1},'on',len2)
                    gui_MakeVisible=1;
                end
            end
        end


        for index=1:2:length(varargin)
            if length(varargin)==index
                break;
            end
            try set(gui_hFigure,varargin{index},varargin{index+1}),catchbreak,end
        end



        gui_HandleVisibility=get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility,'callback')
            set(gui_hFigure,'HandleVisibility','on');
        end

        feval(gui_State.gui_OpeningFcn,gui_hFigure,[],guidata(gui_hFigure),varargin{:});

        if ishghandle(gui_hFigure)

            set(gui_hFigure,'HandleVisibility',gui_HandleVisibility);


            if gui_MakeVisible
                set(gui_hFigure,'Visible','on')
                if gui_Options.singleton
                    setappdata(gui_hFigure,'GUIOnScreen',1);
                end
            end


            rmappdata(gui_hFigure,'InGUIInitialization');
        end



        if ishghandle(gui_hFigure)
            gui_HandleVisibility=get(gui_hFigure,'HandleVisibility');
            if strcmp(gui_HandleVisibility,'callback')
                set(gui_hFigure,'HandleVisibility','on');
            end
            gui_Handles=guidata(gui_hFigure);
        else
            gui_Handles=[];
        end

        if nargout
            [varargout{1:nargout}]=feval(gui_State.gui_OutputFcn,gui_hFigure,[],gui_Handles);
        else
            feval(gui_State.gui_OutputFcn,gui_hFigure,[],gui_Handles);
        end

        if ishghandle(gui_hFigure)
            set(gui_hFigure,'HandleVisibility',gui_HandleVisibility);
        end
    end
end
function gui_hFigure=local_openfig(name,singleton)



    try
        gui_hFigure=openfig(name,singleton,'auto');
    catch



        gui_OldDefaultVisible=get(0,'defaultFigureVisible');
        set(0,'defaultFigureVisible','off');
        gui_hFigure=openfig(name,singleton);
        set(0,'defaultFigureVisible',gui_OldDefaultVisible);
    end
end

function handles=UpdateAncestors(selNode,cutOffLevel,handles)






    if selNode.getLevel>cutOffLevel

        path=selNode.getPath;

        if cutOffLevel==1

            startLevel=length(path);
        else

            startLevel=length(path)-1;
        end

        for p_idx=startLevel:-1:3
            child_idx=path(p_idx-1).getIndex(path(p_idx));
            parentNodeObj=handle(path(p_idx-1).getUserObject);
            childNodeObj=handle(path(p_idx).getUserObject);
            parentNodeObj.Ckts{child_idx+1}=childNodeObj;
        end

        topLevelNode=path(p_idx-1);
        topLevelNode_idx=getIndex(handles.uiroot,topLevelNode);
        handles.ckts{topLevelNode_idx+1}.object=handle(topLevelNode.getUserObject);
        handles.ckts{topLevelNode_idx+1}.name=char(topLevelNode.getName);
    end
end


function handles=ClearAncestorPlots(selNode,handles)



    path=selNode.getPath;
    for p_idx=2:length(path)
        nodeData=getappdata(handle(path(p_idx)),'UserData');
        nodeData.analyzed=false;
        setappdata(handle(path(p_idx)),'UserData',nodeData);
    end
end


function state=freeze(handles)



    state={handles.analyzepushb,'off';...
    handles.deletepushb,'off';...
    handles.downpushb,'off';...
    handles.uppushb,'off';...
    handles.insertpushb,'off';...
    handles.datapushb,'off';...
    handles.plotpushb,'off'};

    plot_state={handles.createpushb;...
    handles.applypushb;...
    handles.polarplot_s22;...
    handles.polarplot_s21;...
    handles.polarplot_s12;...
    handles.polarplot_s11;...
    handles.xyplot_s22;...
    handles.xyplot_s21;...
    handles.xyplot_s12;...
    handles.xyplot_s11;...
    handles.xylinlogdegradmenu;...
    handles.xymagphsmenu;...
    handles.ylinlogmenu;...
    handles.smithyztypemenu;...
    handles.smithchart_s22;...
    handles.smithchart_s21;...
    handles.smithchart_s12;...
    handles.smithchart_s11;...
    handles.file_menu};

    for k=1:size(state,1)

        set(state{k,1},'Enable','off');
    end
    for k=1:length(plot_state)
        set(plot_state{k},'Enable','off');
    end
end


function unfreeze(handles)



    plot_state={handles.createpushb;...
    handles.applypushb;...
    handles.polarplot_s22;...
    handles.polarplot_s21;...
    handles.polarplot_s12;...
    handles.polarplot_s11;...
    handles.xyplot_s22;...
    handles.xyplot_s21;...
    handles.xyplot_s12;...
    handles.xyplot_s11;...
    handles.xylinlogdegradmenu;...
    handles.xymagphsmenu;...
    handles.ylinlogmenu;...
    handles.smithyztypemenu;...
    handles.smithchart_s22;...
    handles.smithchart_s21;...
    handles.smithchart_s12;...
    handles.smithchart_s11;...
    handles.file_menu};

    for k=1:length(plot_state)
        set(plot_state{k},'Enable','on');
    end

    if(get(handles.xymagphsmenu,'Value')>2)
        set(handles.xylinlogdegradmenu,'Enable','off')
    end

end


function reveal_figure_handle(handles)


    set(handles.rftoolfig,'HandleVisibility','on');




end


function hide_figure_handle(handles)


    set(handles.rftoolfig,'HandleVisibility','callback');




end


function val=ispropertyrfobject(a_string)



    a_cell={'NetworkData';'Network Data';'NoiseData';'Noise Data';...
    'NonlinearData';'Nonlinear Data'};
    if any(strcmpi(a_string,a_cell))
        val=true;
    else
        val=false;
    end

end


function out=str2property(propname,curr_val,a_str)



    out='no change';


    if ischar(a_str)
        a_str=strtrim(a_str);
    end


    if ispropertyrfobject(propname)


        if~isrfdatastr(a_str)
            if isempty(a_str)
                a_str='[]';
            end
            temp_val=evalin('base',a_str);
            if isa(temp_val,'rfdata.rfdata')

                out=copy(temp_val);
            else
                out=temp_val;
            end
        end
    elseif isnumeric(curr_val)




        a_str=['[',a_str,']'];
        temp_val=evalin('base',a_str);
        out=temp_val;
    elseif ischar(curr_val)
        out=a_str;
    end

end


function out=cell2proppair(prop_cell,ckttype)


    out=cell(size(prop_cell));

    object=ckt_name_map(ckttype);
    if~isempty(object)
        out(:,1)=prop_cell(:,1);
        for idx=1:size(prop_cell,1)
            propname=char(param_name_map(prop_cell{idx,1},0));
            curr_val=get(object,propname);
            out{idx,2}=str2property(propname,curr_val,prop_cell{idx,2});
        end
    end

end


function[handles,plotFlag]=set_enable(handles,selNode)


    nodeName=char(selNode.getName);
    nodeObj=getUserObject(selNode);

    huitree=handles.uitree;
    huiroot=handles.uiroot;
    hTab1=handles.Tab1;


    col_width=hTab1.getColumnWidth;


    if strcmp(nodeName,'default')
        nodeName='\default';
    end

    plotFlag=0;

    if~isRoot(selNode)


        selObj=handle(nodeObj);
        settable_props=set(selObj);
        fn=fieldnames(settable_props);
        selNodeType=selObj.Name;

        set(handles.compnameedt,'String',nodeName);
        set(handles.comptypeedt,'String',selNodeType);


        if~any(strcmp(fn,'Ckts'))


            set(handles.insertpushb,'Enable','off');
            set(handles.uppushb,'Enable','off');
            set(handles.downpushb,'Enable','off');

            refreshTable(selNode,handles)





            hTab1.setEditable(2,true);

            set(handles.analyzepushb,'Enable','on');

        else


            set(handles.insertpushb,'Enable','on');

            selObj=handle(nodeObj);
            if~isempty(selObj.Ckts)

                refreshTable(selNode,handles)






                hTab1.setEditable(2,false);

                if(length(selObj.Ckts)>1)

                    set(handles.uppushb,'Enable','on');
                    set(handles.downpushb,'Enable','on');
                else

                    set(handles.uppushb,'Enable','off');
                    set(handles.downpushb,'Enable','off');
                end
                set(handles.analyzepushb,'Enable','on');

            else


                set(handles.uppushb,'Enable','off');
                set(handles.downpushb,'Enable','off');

                set(handles.analyzepushb,'Enable','Off');



                hTab1.setVisible(0);

            end
        end

        nodeData=getappdata(handle(selNode),'UserData');
        if~isRoot(selNode)&&nodeData.analyzed
            plotFlag=1;
            set(handles.datapushb,'Enable','on');
            set(handles.plotpushb,'Enable','on');
        else
            set(handles.datapushb,'Enable','off');
            set(handles.plotpushb,'Enable','off');
        end
        set(handles.deletepushb,'Enable','on');
        set(handles.freqedt,'Enable','on');
        set(handles.charimpedt,'Enable','on');

        rfdat=get(selObj,'AnalyzedResult');
        if~isempty(rfdat)
            freq=rfdat.Freq;
        else
            freq=[];
        end
        if~isempty(freq)
            freq=freq(:);

            if(length(freq)>1)&isequal(freq(:)',[freq(1):(freq(2)-freq(1)):freq(end)])
                f1=num2str(freq(1),' %1.4g');
                f2=num2str(freq(end),' %1.4g');
                df=num2str(freq(2)-freq(1),' %1.4g');
                set(handles.freqedt,'string',[f1,':',df,':',f2]);
            elseif(length(freq)>1)&(freq(1)>0)&...
                isequal(freq(:)',logspace(log10(freq(1)),log10(freq(end)),length(freq)))
                f1=num2str(log10(freq(1)),' %1.4g');
                f2=num2str(log10(freq(end)),' %1.4g');
                nf=num2str(length(freq),' %1.4g');
                set(handles.freqedt,'string',['logspace(',f1,',',f2,',',nf,')']);
            else
                set(handles.freqedt,'string',num2str(freq',' %1.4g'));
            end

            zo=rfdat.Z0;
            if~isempty(zo)
                set(handles.charimpedt,'string',num2str(zo));
            end




        end


    else

        selNodeType='RF Tool Session';
        selObj=handles.dummy;
        displaySParams(selObj,handles);



        hTab1.setVisible(0);


        set(handles.insertpushb,'Enable','off');
        set(handles.uppushb,'Enable','off');
        set(handles.downpushb,'Enable','off');


        set(handles.deletepushb,'Enable','off');
        set(handles.analyzepushb,'Enable','Off');
        set(handles.freqedt,'Enable','off');
        set(handles.charimpedt,'Enable','off');
        set(handles.datapushb,'Enable','off');
        set(handles.plotpushb,'Enable','off');
        set(handles.compnameedt,'String',nodeName);
        set(handles.comptypeedt,'String',selNodeType);
        set(handles.applypushb,'Enable','on');
    end

end


function y=isrfdatastr(a_str)


    y=strcmpi(a_str,'rfdata.network object')||...
    strcmpi(a_str,'rfdata.noise object')||...
    strcmpi(a_str,'rfdata.nf object')||...
    strcmpi(a_str,'rfdata.ip3 object')||...
    strcmpi(a_str,'rfdata.power object')||...
    strcmpi(a_str,'rfdata.p2d object');

end


function y=isrefbased(object)


    y=isa(object,'rfckt.passive');

end


