function cba_paste




    me=TflDesigner.getexplorer;
    if~isempty(me)&&~me.getRoot.iseditorbusy&&...
        strcmpi(me.getaction('EDIT_PASTE').Enabled,'on')==1&&...
        ~isempty(me.getRoot.uiclipboard)&&~isempty(me.getRoot.uiclipboard.contents)

        me.getRoot.iseditorbusy=true;
        curnode=me.getRoot.currenttreenode;

        if isempty(curnode)||~ishandle(curnode);
            return;
        end

        me.getaction('EDIT_PASTE').Enabled='off';

        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:PasteInProgressStatusMsg'));
        type=me.getRoot.uiclipboard.type;
        me.getRoot.iseditorbusy=false;

        if isa(curnode,'TflDesigner.root')
            if strcmpi(type,'TflTable')==1
                pastenodes(me);
                me.imme.expandTreeNode(curnode);
            end
        elseif isa(curnode,'TflDesigner.element')
            if strcmpi(type,'TflEntry')==1
                pasteelements(me,curnode);
            end
        elseif isa(curnode,'TflDesigner.node')
            if strcmpi(type,'TflEntry')==1
                pasteelements(me,curnode);
            else
                pastenodes(me);
            end
        end

        me.getaction('EDIT_PASTE').Enabled='on';
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:PasteInProgressStatusMsg'));
    end

    function pasteelements(me,curnode)

        contents=me.getRoot.uiclipboard.contents;

        entry=contents{1}.object.getCopy;
        newChildren=curnode.addchild(entry,false);

        for i=2:length(contents)
            entry=contents{i}.object.getCopy;
            newChildren(end+1)=curnode.addchild(entry,false);%#ok
        end
        me.getRoot.firelistchanged;
        TflDesigner.setcurrentlistnode(newChildren);


        function pastenodes(me)

            contents=me.getRoot.uiclipboard.contents;

            if strcmp(class(contents),'TflDesigner.node')&&...
                strcmp(contents.Type,'TflTable')
                name=getTableName(me,contents);
                newTableObject=RTW.TflTable;
                newTableObject.Name=name;
                newTableObject.setReservedIdentifiers(contents.object.getReservedIdentifiers);
                newTableObject.StringResolutionMap=contents.object.StringResolutionMap;

                curnode=me.getRoot.insertnode(newTableObject);
                children=contents.children;
                if~isempty(children)
                    entry=children(1).object.getCopy;
                    newChildren=curnode.addchild(entry,false);

                    for i=2:length(children)
                        entry=children(i).object.getCopy;
                        newChildren(end+1)=curnode.addchild(entry,false);%#ok
                    end
                end

                me.getRoot.firehierarchychanged;
                TflDesigner.setcurrenttreenode(curnode);
            end


            function nameStr=getTableName(me,contents)

                [~,tName]=fileparts(contents.Name);
                nameStr=tName;
                if isempty(me.getRoot.children)
                    return;
                end

                if~isempty(me.getRoot.children)
                    exactOrigNameMatch=false;
                    for i=1:length(me.getRoot.children)
                        [~,name]=fileparts(me.getRoot.children(i).Name);
                        if strcmp(name,tName)
                            exactOrigNameMatch=true;
                        end
                    end

                    if exactOrigNameMatch
                        found=false;
                        ind=[];
                        for i=1:length(me.getRoot.children)
                            [~,name]=fileparts(me.getRoot.children(i).Name);
                            if strfind(name,tName)
                                if length(name)>6&&...
                                    strcmp(name(1:4),...
                                    DAStudio.message('RTW:tfldesigner:CopyText'))
                                    if~isempty(ind)
                                        index=num2str(ind);
                                    else
                                        index=name(6:strfind(name,'_of')-1);
                                    end
                                    if strcmp(name,['Copy_',index,'_of_',tName])
                                        ind=str2double(index)+1;
                                        found=true;
                                    end
                                end
                            end
                        end
                        if~found
                            nameStr=['Copy_',num2str(1),'_of_',tName];
                        else
                            nameStr=['Copy_',num2str(ind),'_of_',tName];
                        end
                    end
                end




