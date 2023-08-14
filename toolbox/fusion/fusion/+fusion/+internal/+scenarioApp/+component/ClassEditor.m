classdef ClassEditor<fusion.internal.scenarioApp.component.PropertyPanel

    properties
        SetAsPreference=true
        CurrentEntry=1
    end

    properties(Hidden)
ClassInfo
OldSetAsPreference
    end

    properties

hClassList
hSetAsPreference
hRestoreFactory
hOk
hDelete
hAdd
hCopy
    end

    methods

        function this=ClassEditor(varargin)
            this@fusion.internal.scenarioApp.component.PropertyPanel(varargin{:})
        end

        function open(this)
            fig=this.Figure;
            updateLayout(this);
            update(this.Layout,'force');
            update(this);
            this.OldSetAsPreference=this.SetAsPreference;

            oldPos=fig.Position;
            newPos=this.Application.getPositionAroundCenter(oldPos(3:4));
            fig.Position=newPos;
            figure(fig);
        end

        function close(this,isCancel)
            if nargin<2
                isCancel=true;
            end
            fig=this.Figure;
            if ishghandle(fig)
                fig.Visible='off';
            end
            refresh(this);
            if isCancel
                this.SetAsPreference=this.OldSetAsPreference;
            end
        end

        function updateLayout(this)


            updatePropertyPanelLayout(this);
        end

        function b=isDocked(~)
            b=false;
        end

    end

    methods(Access=protected)
        function b=validate(this)
            info=this.ClassInfo;
            b=~any(arrayfun(@(c)isempty(c.id),info));
        end
    end

    methods(Access=protected)
        function updateClassList(this)

            allInfo=this.ClassInfo;
            list=cell(1,numel(allInfo));
            for indx=1:numel(allInfo)
                id=allInfo(indx).id;
                name=allInfo(indx).name;
                if isempty(id)
                    list{indx}=sprintf('<html><font color="red"><b>!!</b></font>: %s</html>',name);
                else
                    list{indx}=sprintf('%d: %s',id,name);
                end
            end

            entry=this.CurrentEntry;
            if entry>numel(allInfo)
                entry=numel(allInfo);
                this.CurrentEntry=entry;
            end
            set(this.hClassList,...
            'String',list,...
            'Value',entry);
        end

        function varargout=updateClassInfoFromMap(this,map)
            ids=keys(map);
            for indx=1:numel(ids)
                idInfo=map(ids{indx});
                idInfo.id=ids{indx};
                info(indx)=idInfo;%#ok<AGROW>
            end

            if nargout==0
                this.ClassInfo=info;
            else
                varargout={info};
            end
        end
    end

    methods(Access=protected)
        function fig=createFigure(this)
            fig=createFigure@matlabshared.application.Component(this,...
            'Tag',this.getTag,...
            'WindowStyle','modal',...
            'CloseRequestFcn',@this.closeRequestFcn);
            position=this.Application.getPositionAroundCenter([700,600]);
            fig.Position=position;
            hApp=this.Application;

            propertyPanel=createPropertyPanel(this,fig);

            topButtonPanel=createButtonPanel(this,fig);

            restoreButton=uicontrol(fig,...
            'Tag','classRestore',...
            'style','pushbutton',...
            'String',getString(message(strcat(this.ResourceCatalog,'EditorRestoreDefaultClasses'))),...
            'Callback',hApp.initCallback(@this.restoreToFactoryCallback));

            list=uicontrol(fig,...
            'Tag',[this.getTag,'List'],...
            'Style','listbox',...
            'Callback',hApp.initCallback(@this.listCallback),...
            'String',{' '});

            createCheckbox(this,fig,'SetAsPreference');

            okButton=uicontrol(fig,...
            'Tag','classOkBtn',...
            'Style','pushbutton',...
            'String',getString(message('MATLAB:uistring:popupdialogs:OK')),...
            'Callback',hApp.initCallback(@this.okCallback));

            cancelButton=uicontrol(fig,...
            'Tag','classCancelBtn',...
            'Style','pushbutton',...
            'String',getString(message('Spcuilib:application:Cancel')),...
            'Callback',hApp.initCallback(@this.cancelCallback));


            figureLayout=matlabshared.application.layout.GridBagLayout(fig,...
            'HorizontalGap',3,...
            'VerticalGap',3,...
            'HorizontalWeights',[0,0,2,2,0,0],...
            'VerticalWeights',[0,1,0]);

            buttonWidth=figureLayout.getMinimumWidth([okButton,cancelButton])+figureLayout.ButtonPadding;

            row=1;
            add(figureLayout,topButtonPanel,row,[1,3],...
            'Anchor','West',...
            'MinimumWidth',3*(22+figureLayout.ButtonPadding));
            add(figureLayout,restoreButton,row,[4,6],...
            'Anchor','East',...
            'MinimumWidth',figureLayout.getMinimumWidth(restoreButton)+figureLayout.ButtonPadding);
            row=row+1;
            add(figureLayout,list,row,[1,3],...
            'Fill','Both',...
            'MinimumWidth',100);
            add(figureLayout,propertyPanel,row,[4,6],...
            'LeftInset',-5,...
            'BottomInset',-1,...
            'Fill','Both');
            row=row+1;
            add(figureLayout,this.hSetAsPreference,row,[1,4],...
            'Fill','Horizontal',...
            'Anchor','West');
            add(figureLayout,okButton,row,5,...
            'MinimumWidth',buttonWidth);
            add(figureLayout,cancelButton,row,6,...
            'MinimumWidth',buttonWidth);

            this.Layout=figureLayout;
            this.hClassList=list;
            this.hRestoreFactory=restoreButton;
            this.hOk=okButton;
        end

        function buttonPanel=createButtonPanel(this,parent)

            buttonPanel=uipanel(parent,...
            'BorderType','none','Tag','ButtonPanel');

            buttonSize=22;
            icons=getIcon(this.Application);

            addButton=uicontrol(buttonPanel,...
            'Tag','classAdd',...
            'style','pushbutton',...
            'CData',icons.add16,...
            'Position',[1,1,buttonSize,buttonSize],...
            'TooltipString',getString(message(strcat(this.ResourceCatalog,'EditorAddClassDescription'))),...
            'callback',@this.addCallback);

            deleteButton=uicontrol(buttonPanel,...
            'Tag','classDeleteBtn',...
            'style','pushbutton',...
            'CData',icons.delete16,...
            'Position',[buttonSize+5,1,buttonSize,buttonSize],...
            'TooltipString',getString(message(strcat(this.ResourceCatalog,'EditorDeleteClassDescription'))),...
            'callback',@this.deleteCallback);

            copyButton=uicontrol(buttonPanel,...
            'Tag','classCopyBtn',...
            'style','pushbutton',...
            'CData',icons.copy16,...
            'Position',[2*buttonSize+9,1,buttonSize,buttonSize],...
            'TooltipString',getString(message(strcat(this.ResourceCatalog,'EditorCopyClassDescription'))),...
            'callback',@this.copyCallback);


            this.hAdd=addButton;
            this.hDelete=deleteButton;
            this.hCopy=copyButton;
        end

    end

    methods(Abstract,Access=protected)

        createPropertyPanel(this,fig)
        updatePropertyPanel(this,info,enable)
        updatePropertyPanelLayout(this)
    end

    methods(Abstract)

        addCallback(this,src,evt)
        deleteCallback(this,src,evt)
    end

    methods(Hidden)
        function name=getName(this)
            name=getString(message(strcat(this.ResourceCatalog,this.getTag)));
        end

        function listCallback(this,~,~)
            this.CurrentEntry=this.hClassList.Value;
            update(this);
        end

        function nameCallback(this,hName,~)
            newName=hName.String;
            if isempty(newName)
                update(this);
                return;
            end
            this.ClassInfo(this.CurrentEntry).name=newName;

            updateClassList(this);
        end

        function cancelCallback(this,~,~)
            close(this,true);
        end

        function closeRequestFcn(this,~,~)
            close(this,true);
        end
    end

end