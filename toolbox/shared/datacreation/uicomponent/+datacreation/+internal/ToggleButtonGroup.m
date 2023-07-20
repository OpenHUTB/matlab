classdef(Hidden)ToggleButtonGroup<matlab.ui.componentcontainer.ComponentContainer

















    properties(Hidden,Transient)

Plugins
    end


    properties(Access=private,Transient,NonCopyable)

        Grid matlab.ui.container.GridLayout

    end


    properties(Hidden,Transient,NonCopyable)
TypeOfDataButtonGroup
TaskButtons
    end


    properties

        Value=datacreation.plugin.NumericalPlugin.LiveTaskKeyValue
    end


    events(HasCallbackProperty,NotifyAccess=protected)

ValueChanged

    end

    methods

        function delete(obj)

            delete@matlab.ui.componentcontainer.ComponentContainer(obj);
        end


        function set.Value(obj,inVal)
            aFactory=datacreation.internal.Factory.getInstance();
            plugins=aFactory.getAllContributors();
            if~any(strcmp({plugins(:).LiveTaskKeyValue},inVal)==1)
                error(message('datacreation:datacreation:toggleValueSetError'));
            end

            obj.Value=inVal;
        end


        function setEnable(obj,inVal)
            obj.TypeOfDataButtonGroup.Enable=inVal;
        end
    end


    methods(Access='protected')


        function setup(obj)
            w=90;
            h=80;
            obj.Grid=uigridlayout(obj,[1,1],'ColumnWidth',{'fit'},...
            'RowHeight',{h},'Padding',0);
            obj.TypeOfDataButtonGroup=uibuttongroup(obj.Grid);
            obj.TypeOfDataButtonGroup.BorderType='none';
            obj.TypeOfDataButtonGroup.SelectionChangedFcn=@obj.onToggleChange;



            aFactory=datacreation.internal.Factory.getInstance();


            aFactory.updateFactoryRegistry();


            obj.Plugins=aFactory.getAllContributors();

            buttonTexts=cell(1,length(obj.Plugins));
            buttonIcons=cell(1,length(obj.Plugins));
            for kButton=1:length(obj.Plugins)

                buttonTexts{kButton}=obj.Plugins(kButton).LiveTaskKey;
                buttonIcons{kButton}=obj.Plugins(kButton).Icon;
            end


            buttonTags=buttonTexts;

            for k=1:length(obj.Plugins)
                obj.TaskButtons(k)=uitogglebutton(obj.TypeOfDataButtonGroup,'Position',[(k-1)*w+1,1,w-2,h-2],...
                'IconAlignment','top','UserData',k,...
                'Text',buttonTexts{k},'Tag',buttonTags{k},...
                'Icon',buttonIcons{k});
            end

            obj.Grid.ColumnWidth={length(obj.Plugins)*w};
        end


        function update(obj)
            if isempty(obj.Value)
                return;
            end

            idx=find(strcmp({obj.Plugins(:).LiveTaskKeyValue},obj.Value)==1);
            set(obj.TaskButtons(idx),'Value',true);

        end


        function onToggleChange(obj,~,data)

            idx=find(strcmp({obj.Plugins(:).LiveTaskKey},data.NewValue.Text)==1);



            obj.Value=obj.Plugins(idx).LiveTaskKeyValue;


            notify(obj,'ValueChanged');
        end
    end
end

