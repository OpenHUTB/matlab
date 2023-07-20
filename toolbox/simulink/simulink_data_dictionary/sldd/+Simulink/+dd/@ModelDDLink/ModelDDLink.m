classdef ModelDDLink<handle

    properties
ButtonPanel
Model
UseDictionary
DataDictionary
Dirty
    end
    properties(Constant,Hidden)
        m_propertyNames={...
        'Model';...
        'DataDictionary'};

        m_designDataValues={...
        'Base WS';...
        'DataDictionary';...
        'None'};
    end

    methods
        function obj=ModelDDLink(buttonPanel,model,designData,dataDict)
            obj.ButtonPanel=buttonPanel;
            obj.Model=model;
            obj.UseDictionary=designData;
            obj.DataDictionary=dataDict;
            obj.Dirty=false;
        end


        function applyChanges(thisObj)
            if thisObj.Dirty
                load_system(thisObj.Model);
                if~isequal(thisObj.UseDictionary,'1')
                    set_param(thisObj.Model,'DataDictionary','');
                else
                    set_param(thisObj.Model,'DataDictionary',thisObj.DataDictionary);
                    if isempty(thisObj.DataDictionary)
                        thisObj.UseDictionary='0';
                        ed=DAStudio.EventDispatcher;
                        ed.broadcastEvent('PropertyChangedEvent');
                    end
                end
                thisObj.Dirty=false;
            end
        end





        function dlgstruct=getDialogSchema(obj,objName)
            dlgstruct=[];
        end

        function isValid=isValidProperty(~,propName)
            isValid=any(strcmp(propName,...
            Simulink.dd.ModelDDLink.m_propertyNames));

        end
        function isReadonly=isReadonlyProperty(thisObj,propName)
            isReadonly=strcmpi(propName,'Model');



        end
        function isEditable=isEditableProperty(thisObj,propName)
            isEditable=~isReadonlyProperty(thisObj,propName);
        end
        function out=getPossibleProperties(~)
            out=Simulink.dd.ModelDDLink.m_propertyNames;

        end
        function out=getPreferredProperties(~)
            out=Simulink.dd.ModelDDLink.m_propertyNames;

        end
        function propDataType=getPropDataType(~,propName)
            if strcmpi(propName,'UseDictionary')

                propDataType='bool';
            else
                propDataType='combobox';
            end
        end











        function allowedValues=getPropAllowedValues(thisObj,propName)
            allowedValues={};
            if strcmpi(propName,'DataDictionary')

                allowedValues=thisObj.ButtonPanel.rootAdapter.getAllDictionaryNames();
            end
        end
        function propValue=getPropValue(thisObj,propName)
            propValue='';
            if isValidProperty(thisObj,propName)
                propValue=thisObj.(propName);
                if isequal(propName,'DataDictionary')&&...
                    isempty(propValue)
                    propValue='<none>';
                end
            end
        end
        function setPropValue(thisObj,propName,propValue)
            if isValidProperty(thisObj,propName)
                thisObj.Dirty=true;
                if strcmpi(propName,'DataDictionary')
                    propValue=strtrim(propValue);
                    if(isequal(propValue,'Browse...')||...
                        isequal(propValue,'New...'))
                        filename=thisObj.getDifferentDict(propValue);
                        if isempty(filename)
                            return;
                        else
                            propValue=filename;
                        end
                    elseif isequal(propValue,'<none>')
                        propValue='';
                    end
                    if~isempty(propValue)
                        [~,~,ext]=fileparts(propValue);
                        if(isempty(ext))
                            propValue=[propValue,'.sldd'];
                        end
                    end
                end
                thisObj.(propName)=propValue;
                if strcmpi(propName,'UseDictionary')&&...
                    strcmpi(propValue,'0')
                    thisObj.DataDictionary='';
                end
                if strcmpi(propName,'DataDictionary')
                    if isempty(propValue)
                        thisObj.UseDictionary='0';
                        thisObj.DataDictionary='';
                    else
                        thisObj.UseDictionary='1';
                    end
                end
                ed=DAStudio.EventDispatcher;
                ed.broadcastEvent('PropertyChangedEvent');
                thisObj.ButtonPanel.setDirty();
            end
        end
        function menu=getContextMenu(h,selectedHandles)
            me=h.ButtonPanel.rootAdapter.UserData.me;
            treeNode=me.getTreeSelection();
            treeNodeDict=treeNode.MyModelLink.DataDictionary;
            treeNodeModel=treeNode.MyModelLink.Model;

            menu=h.ButtonPanel.rootAdapter.getListMenu();
            items=menu.getChildren();
            if isempty(treeNodeDict)

                items(3).text=['Link selected models to same dictionary as ','''',treeNodeModel,''''];
                items(3).enabled='off';
            else
                items(3).text=['Link selected models to same dictionary as ','''',treeNodeModel,'''',' (',treeNodeDict,')'];
                items(3).enabled='on';
            end
        end























































        function label=getDisplayLabel(thisObj)
            label=thisObj.Model;
        end
        function fileName=getDisplayIcon(thisObj)
            if isequal(thisObj,thisObj.ButtonPanel.rootAdapter.MyModelLink)
                fileName=fullfile('toolbox','shared','dastudio','resources','simulink_model.png');
            else
                fileName=fullfile('toolbox','shared','dastudio','resources','simulink_model_reference.png');
            end
        end
        function filename=getDifferentDict(thisObj,option)
            filename='';
            filter={'*.sldd','Data Dictionary files (*.sldd)';...
            '*.*','All Files (*.*)'};
            if isequal(option,'Browse...')
                [filename,pathname]=uigetfile(filter,...
                'Select a Data Dictionary');
                if isequal(filename,0)
                    filename='';
                end
            elseif isequal(option,'New...')
                [filename,pathname,filterIndex]=uiputfile(filter,...
                'Create a new Data Dictionary');
                if~isequal(filename,0)
                    path=fullfile(pathname,filename);
                    Simulink.dd.create(path);
                else
                    filename='';
                end
            end
        end

    end
end

