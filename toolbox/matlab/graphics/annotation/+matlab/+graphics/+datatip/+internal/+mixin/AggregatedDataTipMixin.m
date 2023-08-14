classdef AggregatedDataTipMixin<matlab.graphics.datatip.internal.mixin.DataTipMixin













    properties(Access=protected,Dependent)
DataTipMethods
    end

    properties(Transient,NonCopyable,Access=protected)
        isAggregated(1,1)logical=true
    end

    properties(AffectsObject,Access=private)


        DataTipConfiguration_I string=string.empty(0,2)
    end

    methods(Abstract,Access=protected)
        getAllDataTipMethods(obj)
    end

    methods
        function method=get.DataTipMethods(obj)
            dtConfig=obj.getDataTipConfiguration();
            if~isempty(dtConfig)
                dtConfig=dtConfig(:,2)';
            end
            method=dtConfig;
        end
    end

    methods(Hidden)
        function var=getDataTipVariables(obj)
            dtConfig=obj.getDataTipConfiguration();
            if~isempty(dtConfig)
                dtConfig=dtConfig(:,1)';
            end
            var=dtConfig;
        end
    end

    methods(Access=protected)



        function showContextMenu(obj,evd)

            if evd.Button==3
                if isempty(obj.ContextMenu)
                    obj.initializeContextMenu();
                end
                hMenu=obj.ContextMenu;


                if obj.isAggregated
                    obj.addAggregatedTableOptions(hMenu.Children(2));
                else
                    obj.addTableOptions(hMenu.Children(2));
                end


                hFig=ancestor(obj,'figure','node');

                figPoint=hFig.CurrentPoint;
                figPoint=hgconvertunits(hFig,[figPoint,0,0],hFig.Units,'pixels',hFig);
                figPoint=figPoint(1:2);
                hMenu.Position=figPoint;
                hMenu.Visible='on';
            end
        end

        function dtConfig=getDataTipConfiguration(obj)
            dtConfig=obj.DataTipConfiguration_I;
        end

        function setDataTipConfiguration(obj,dtConf)
            sizeDtConfig=size(dtConf);
            if sizeDtConfig(2)==1
                dtConf(:,1)=dtConf;
                dtConf(:,2)=repmat("none",sizeDtConfig(1),1);
            end
            dtConf(:,2)=lower(dtConf(:,2));
            obj.DataTipConfiguration_I=dtConf;
            obj.DataTipConfigurationMode='manual';
            obj.updateDialogIfNeeded();
        end

        function initializeDataTipConfiguration(obj)
            if strcmp(obj.DataTipConfigurationMode,'auto')
                obj.DataTipConfiguration_I=obj.getDefaultDataTipConfiguration();
                obj.updateDialogIfNeeded();
            end
        end



        function addAggregatedTableOptions(obj,parentMenu)
            delete(parentMenu.Children);


            [selectedVariables,selectedMethods,...
            unSelectedVariables,...
            defaultAggregationMethods,...
            dimensionName,...
            numericVarNames]=obj.getOptionsToShow();



            sVars=unique(selectedVariables,'stable');

            for i=1:min(10,numel(sVars))
                varInd=ismember(selectedVariables,sVars(i));
                checkedMthd=selectedMethods(varInd);


                u=uimenu(parentMenu,'Text',addUTF8Checkmark(obj,sVars(i)),...
                'Tag',sVars(i),...
                'MenuSelectedFcn',@(e,d)updateDataTipConfiguration(obj,d));
                if any(ismember(sVars(i),numericVarNames))
                    if strcmp(sVars(i),dimensionName)
                        uimenu(u,'Text',obj.getStringFromMessageCatalog('Count'),...
                        'Tag','count',...
                        'Checked','on',...
                        'MenuSelectedFcn',@(e,d)obj.updateDataTipConfiguration(d));
                    else
                        for num=1:numel(defaultAggregationMethods)
                            u1=uimenu(u,'Text',obj.getStringFromMessageCatalog(defaultAggregationMethods{num}),...
                            'Tag',defaultAggregationMethods{num},...
                            'MenuSelectedFcn',@(e,d)obj.updateDataTipConfiguration(d));

                            if any(ismember(checkedMthd,defaultAggregationMethods{num}))
                                set(u1,'Checked','on');
                            end
                        end
                    end
                    u.MenuSelectedFcn=[];
                end
            end
            if isempty(i)
                i=1;
            end
            for j=1:min((obj.MAX_OPTIONS-i+1),numel(unSelectedVariables))


                u=uimenu(parentMenu,'Text',unSelectedVariables{j},...
                'Tag',unSelectedVariables{j});
                if j==1
                    u.Separator='on';
                end

                if any(ismember(unSelectedVariables{j},numericVarNames))
                    if strcmp(dimensionName,unSelectedVariables{j})
                        uimenu(u,'Text',obj.getStringFromMessageCatalog('Count'),...
                        'Tag','Count',...
                        'MenuSelectedFcn',@(e,d)obj.updateDataTipConfiguration(d));
                    else
                        for num=1:numel(defaultAggregationMethods)
                            uimenu(u,'Text',obj.getStringFromMessageCatalog(defaultAggregationMethods{num}),...
                            'Tag',defaultAggregationMethods{num},...
                            'MenuSelectedFcn',@(e,d)obj.updateDataTipConfiguration(d));
                        end
                    end
                else
                    u.MenuSelectedFcn=@(e,d)obj.updateDataTipConfiguration(d);
                end
            end


            uimenu(parentMenu,'Text',getString(message('MATLAB:graphics:datatip:MoreOption')),...
            'Tag','MoreOption',...
            'ForegroundColor','blue',...
            'Separator','on',...
            'MenuSelectedFcn',@(e,d)openAggregatedDialogToEdit(obj));
        end

        function updatedText=addUTF8Checkmark(~,text)
            updatedText=[char(hex2dec('2713')),'  ',char(text)];
        end



        function updateDataTipConfiguration(obj,eventobj)


            obj.DataTipConfigurationMode='manual';
            selectedOption=eventobj.Source;
            dtConfig=obj.DataTipConfiguration_I;
            if strcmp(selectedOption.Parent.Tag,'ModifyDataTipOption')&&...
                selectedOption.Parent.Parent==obj.ContextMenu
                selectedVar=selectedOption.Tag;
                selectedMethod='none';
            else
                selectedVar=selectedOption.Parent.Tag;
                selectedMethod=selectedOption.Tag;
            end

            if~contains(selectedOption.Text,char(hex2dec('2713')))&&strcmpi(selectedOption.Checked,'off')
                dtConfig(end+1,:)=[selectedVar,string(selectedMethod)];
            else
                varInd=find(ismember(obj.DataTipConfiguration_I(:,1),selectedVar));
                varOption=find(ismember(obj.DataTipConfiguration_I(:,2),selectedMethod));
                dtConfig(intersect(varInd,varOption),:)=[];
            end
            obj.setDataTipConfiguration(dtConfig);
        end


        function openAggregatedDialogToEdit(obj)
            if isempty(obj.DataTipsDialog)||~isvalid(obj.DataTipsDialog)
                obj.DataTipsDialog=matlab.graphics.datatip.internal.mixin.dialogs.AggregatedDataTipsDialog(obj);
            end
            obj.DataTipsDialog.bringToFront();
        end
    end

    methods(Static,Hidden)
        function translatedString=getStringFromMessageCatalog(textString)

            switch(lower(textString))
            case 'min'
                translatedString=getString(message('MATLAB:graphics:datatip:MinOption'));
            case 'max'
                translatedString=getString(message('MATLAB:graphics:datatip:MaxOption'));
            case 'mean'
                translatedString=getString(message('MATLAB:graphics:datatip:MeanOption'));
            case 'count'
                translatedString=getString(message('MATLAB:graphics:datatip:CountOption'));
            case 'median'
                translatedString=getString(message('MATLAB:graphics:datatip:MedianOption'));
            case 'sum'
                translatedString=getString(message('MATLAB:graphics:datatip:SumOption'));
            case 'modifyoption'
                translatedString=getString(message('MATLAB:graphics:datatip:ModifyOption'));
            case 'resetoption'
                translatedString=getString(message('MATLAB:graphics:datatip:ResetOption'));
            case 'moreoption'
                translatedString=getString(message('MATLAB:graphics:datatip:MoreOption'));
            otherwise
                translatedString=textString;
            end
        end
    end


    methods(Access={?matlab.graphics.datatip.internal.mixin.dialogs.AggregatedDataTipsDialog,...
        ?matlab.graphics.datatip.internal.mixin.dialogs.DataTipsDialog})

        function[selectedVariables,selectedMethods,...
            unSelectedVariables,defaultAggregationMethods,...
            dimensionName,...
            numericVarNames,availableOptions]=getOptionsToShow(obj)
            numericTableVars=obj.SourceTable(:,vartype('numeric'));
            defaultConfig=obj.getDefaultDataTipConfiguration();
            defaultVars=defaultConfig(:,1)';
            dtConfig=obj.getDataTipConfiguration();
            selectedVariables=string.empty(0,1);
            selectedMethods=string.empty(0,1);
            if~isempty(dtConfig)
                selectedVariables=dtConfig(:,1)';
                selectedMethods=dtConfig(:,2)';
            end
            numericVarNames=[string(numericTableVars.Properties.VariableNames),numericTableVars.Properties.DimensionNames{1}];

            availableOptions=unique(horzcat(numericVarNames,defaultVars),'stable');
            dimensionName=numericTableVars.Properties.DimensionNames{1};
            defaultAggregationMethods=obj.getAllDataTipMethods();
            unSelectedVariables=setdiff(availableOptions,selectedVariables);
        end
    end

    methods(Access=?tDataTip)
        function hDialog=getAggregatedDataTipDialog(obj)
            hDialog=obj.DataTipsDialog;
        end
    end
end