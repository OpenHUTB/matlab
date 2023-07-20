classdef ModelDDLinksAdapter<handle


    properties
ButtonPanel
Model
MyModelLink
IsTopModel


ReferencedModels
ReferencedModelClosure
DictionaryList
UserData
    end
    properties(Constant,Hidden)
        m_propertyNames={...
        'Model';...
        'UseDictionary';...
        'DataDictionary'};
        m_designDataValues={...
        'Base WS';...
        'DataDictionary';...
        'None'};
    end

    methods



        function thisObj=ModelDDLinksAdapter(buttonPanel,model,isTop,modelMap,overrideDataDict)
            thisObj.ButtonPanel=buttonPanel;
            thisObj.Model=model;
            thisObj.IsTopModel=isTop;
            thisObj.DictionaryList={};

            load_system(model);
            if isempty(overrideDataDict)
                dataDictionary=get_param(model,'DataDictionary');
            else
                dataDictionary=overrideDataDict;
            end
            if isempty(dataDictionary)
                designData='0';



                dataDictionary='';
            else
                designData='1';

            end
            if isTop
                h=waitbar(0,'Finding Referenced Models');
                hCleanup=onCleanup(@()close(h));
            end




            if modelMap.isKey(model)
                thisMdlLink=modelMap(model);
            else
                thisMdlLink=Simulink.dd.ModelDDLink(...
                buttonPanel,model,designData,dataDictionary);
                modelMap(model)=thisMdlLink;
            end
            thisObj.MyModelLink=thisMdlLink;



            closureMap=containers.Map;
            closureMap(model)=thisMdlLink;




            mdlrefList=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);
            len=length(mdlrefList);
            for i=1:len
                if isTop
                    waitbar(i/len);
                end

                nextSys=mdlrefList{i};
                if~isequal(nextSys,model)
                    refMdl=Simulink.dd.ModelDDLinksAdapter(...
                    buttonPanel,mdlrefList{i},false,modelMap,'');


                    refMdlChildren=refMdl.getChildren();
                    for r=1:length(refMdlChildren)
                        refMdlClosureMdlLink=refMdlChildren(r);
                        if~closureMap.isKey(refMdlClosureMdlLink.Model)
                            closureMap(refMdlClosureMdlLink.Model)=refMdlClosureMdlLink;
                        end
                    end
                    thisObj.ReferencedModels=cat(2,thisObj.ReferencedModels,refMdl);
                end
            end


            refmdls=closureMap.values;
            for r=1:length(refmdls)
                thisObj.ReferencedModelClosure=...
                cat(2,thisObj.ReferencedModelClosure,refmdls{r});
            end
        end

        function initialize(thisObj)
            if thisObj.IsTopModel
                am=DAStudio.ActionManager;
                me=thisObj.UserData.me;
                menu=am.createPopupMenu(me);


                tmpaction=am.createAction(me,'text','Select All');
                tmpaction.callback=['Simulink.dd.cb_treechanged(',num2str(tmpaction.id),', true)'];
                schema.prop(tmpaction,'callbackData','mxArray');
                tmpaction.callbackData.rootAdapter=thisObj;
                menu.addMenuItem(tmpaction);

                tmpaction2=am.createAction(me,'text','Unselect All');
                tmpaction2.callback=['Simulink.dd.cb_treechanged(',num2str(tmpaction2.id),', false)'];
                schema.prop(tmpaction2,'callbackData','mxArray');
                tmpaction2.callbackData.rootAdapter=thisObj;
                menu.addMenuItem(tmpaction2);

                menu.addSeparator;

                tmpaction3=am.createAction(me,'text','Link selected models');
                tmpaction3.callback=['Simulink.dd.linkSelected(',num2str(tmpaction3.id),',''selected'')'];
                schema.prop(tmpaction3,'callbackData','mxArray');
                tmpaction3.callbackData.rootAdapter=thisObj;
                menu.addMenuItem(tmpaction3);

                thisObj.UserData.listmenu=menu;

                menu2=am.createPopupMenu(me);
                tmpaction2_1=am.createAction(me,'text','Link referenced models');
                tmpaction2_1.callback=['Simulink.dd.linkSelected(',num2str(tmpaction2_1.id),',''referenced'')'];
                schema.prop(tmpaction2_1,'callbackData','mxArray');
                tmpaction2_1.callbackData.rootAdapter=thisObj;
                menu2.addMenuItem(tmpaction2_1);
                thisObj.UserData.treemenu=menu2;

            end
        end

        function menu=getListMenu(thisObj)
            menu=thisObj.UserData.listmenu;
        end

        function menu=getContextMenu(h,selectedHandles)
            me=h.ButtonPanel.rootAdapter.UserData.me;
            treeNodeDict=h.MyModelLink.DataDictionary;
            treeNodeModel=h.MyModelLink.Model;
            menu=h.ButtonPanel.rootAdapter.UserData.treemenu;
            items=menu.getChildren();
            if isempty(treeNodeDict)
                items(1).text=['Link all referenced models to same dictionary as ','''',treeNodeModel,''''];
                items(1).enabled='off';
            else
                items(1).text=['Link all referenced models to same dictionary as ','''',treeNodeModel,'''',' (',treeNodeDict,')'];
                items(1).enabled='on';
            end
        end

        function list=getAllDictionaryNames(thisObj)
            temp=thisObj.DictionaryList;
            len=length(thisObj.ReferencedModelClosure);
            for i=1:len
                if~isempty(thisObj.ReferencedModelClosure(i).DataDictionary)
                    temp{end+1}=thisObj.ReferencedModelClosure(i).DataDictionary;
                end
            end

            thisObj.DictionaryList=unique(temp);
            list=['<none>',thisObj.DictionaryList,'Browse...','New...'];
        end

        function assignDictionaryBtn(thisObj,dictName,mode)
            me=thisObj.UserData.me;


            if isequal(mode,'selected')
                selectedList=me.getListSelection();
                selectedList=[selectedList{:}]';
                if~isempty(selectedList)
                    len=length(selectedList);
                    for i=1:len
                        setPropValue(selectedList(i),'DataDictionary',dictName)
                    end
                end
            elseif isequal(mode,'referenced')
                treeNode=me.getTreeSelection();
                if~isempty(treeNode)
                    ddLinksAdapter=treeNode;
                    ddLinksAdapter.assignDictionaryToChildren(dictName);
                end
            end
        end

        function assignDictionaryToChildren(thisObj,dictName)
            len=length(thisObj.ReferencedModelClosure);
            for i=1:len
                setPropValue(thisObj.ReferencedModelClosure(i),'DataDictionary',dictName)
            end
        end

        function applyChanges(thisObj)
            h=waitbar(0,'Applying Changes');
            hCleanup=onCleanup(@()close(h));
            len=length(thisObj.ReferencedModelClosure);
            for i=1:len
                waitbar(i/len);
                thisObj.ReferencedModelClosure(i).applyChanges();
            end
        end

        function close(thisObj)
            if thisObj.IsTopModel
                delete(thisObj.UserData.me);
            end
        end





        function isHier=isHierarchical(thisObj)
            isHier=true;
        end

        function children=getChildren(thisObj)
            children=thisObj.ReferencedModelClosure;
        end

        function children=getHierarchicalChildren(thisObj)
            children=thisObj.ReferencedModels;
        end

        function dlgstruct=getDialogSchema(~,~)
            dlgstruct=[];
        end


























































        function label=getDisplayLabel(thisObj)
            label=thisObj.MyModelLink.Model;
        end
        function fileName=getDisplayIcon(thisObj)
            if thisObj.IsTopModel
                fileName=fullfile('toolbox','shared','dastudio','resources','simulink_model.png');
            else
                fileName=fullfile('toolbox','shared','dastudio','resources','simulink_model_reference.png');
            end
        end

    end
end

