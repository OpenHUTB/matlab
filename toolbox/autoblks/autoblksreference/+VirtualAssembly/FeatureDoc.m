classdef FeatureDoc<matlab.mixin.SetGet&matlab.mixin.Heterogeneous





    properties
HAppContainer
Parent

        FeatureName(1,:)char='';

FeatureVar

FeatureData

        FigSource=[];

        ConstrainedFeaturesDoc=[];

NumofFig
EngRzResult
CallBackDoc
MotRzResult
MotCallBackDoc
    end

    properties(Access=private)

FeatureImage

VariantLabel

FeatureLabel

TableLabel
FeatureVariantGridLayout
FeatureGridLayout
TabGridLayout
DesFigGroup
DesFigGridLayout
TableLyt
TableTitleLyt
TableTitle
ParaDefaultBtn
VehDataTab
Tabgp
CbTab
MotCbTab

FeatureUITable

FeatureDropDown

        Data=[];
        EngineResizedFlag=false;
    end

    events
FeatureDropDownValueChanged
FeatureDataValueChanged
ParameterDefaultBtnPushed
EngineResized
MotorResized
LoadEngine


    end

    methods
        function obj=FeatureDoc(varargin)

            if~isempty(varargin)
                if isscalar(varargin{1})&&isgraphics(varargin{1})

                    varargin=[{'Parent'},varargin];
                end

                set(obj,varargin{:});
            end

            if isempty(obj.Parent)
                obj.Parent=gcf;
            end

            if~isempty(obj.FeatureVar)
                obj.FeatureName=obj.FeatureVar.FeatureName;
            end

            obj.setupDocLyt();

        end
    end


    methods
        function setNewFeatureDoc(obj,var)
            obj.FeatureName=obj.FeatureVar.FeatureName;
            obj.FeatureLabel.Text=[obj.FeatureName,':'];


            component=VirtualAssembly.NameFilter(obj.FeatureName);
            if isfield(obj.ConstrainedFeaturesDoc,component)
                obj.FeatureDropDown.Items=obj.ConstrainedFeaturesDoc.(component).Options;
                if isempty(var)
                    obj.setFeatureDropDown(obj.ConstrainedFeaturesDoc.(component).Value);
                else
                    obj.setFeatureDropDown(var);
                end
            else
                obj.FeatureDropDown.Items=obj.FeatureVar.FeatureVariants;
                if isempty(var)
                    obj.setFeatureDropDown(obj.FeatureVar.FeatureVariants(1));
                else
                    obj.setFeatureDropDown(var);
                end
            end

            if~isempty(obj.FigSource)
                setFig(obj);
            end

            if~isempty(obj.FeatureData)
                setTableData(obj,obj.FeatureDropDown.Value);
            end
        end

        function update(obj,value)
            setFeatureDropDown(obj,value);
            setTableData(obj,value);
            setFig(obj);
        end

        function value=getFeatureVariant(obj)
            value=obj.FeatureDropDown.Value;
        end

        function setFeatureVariant(obj,value)
            obj.FeatureDropDown.Value=value;
            obj.createDropDownEvent(value);
        end

        function updateFeatureDataByName(obj,Name,Value,VariantName)
            if strcmp(VariantName,obj.FeatureDropDown.Value)
                index=strcmp(obj.FeatureUITable.Data(:,1),Name);
                obj.FeatureUITable.Data{index,4}=Value;
            end
            drawnow();
        end

        function updateData(obj)
            for i=1:size(obj.FeatureUITable.Data,1)
                dataname=obj.FeatureUITable.Data{i,1};
                dictionaryObj=Simulink.data.dictionary.open('VirtualVehicleTemplate.sldd');
                dDataSectObj=getSection(dictionaryObj,'Design Data');
                dObj=getEntry(dDataSectObj,dataname);
                entryval=getValue(dObj);
                v=entryval.Value;
                if size(v,2)>1
                    val=mat2str(entryval.Value);
                else
                    val=num2str(entryval.Value);
                end
                obj.FeatureUITable.Data{i,4}=val;
                createTableEvent(obj,i,val);
            end
            drawnow();
        end

        function enableFeatureDropDown(obj,status)
            obj.FeatureDropDown.Enable=status;
        end


    end

    methods(Access=private)

        function setupDocLyt(obj)
            if obj.NumofFig==0
                Rowheight={'0.3x','1x'};
            else
                Rowheight={'1x','2x','2x'};
            end



            obj.TabGridLayout=uigridlayout(obj.Parent,...
            'ColumnWidth',{'1x'},...
            'RowHeight',Rowheight,...
            'Padding',[10,0,10,0],...
            'BackgroundColor',[1,1,1]);



            obj.FeatureGridLayout=uigridlayout(obj.TabGridLayout,...
            'ColumnWidth',{'0.25x','1x'},...
            'RowHeight',{'1x'},...
            'Padding',[0,0,0,10],...
            'BackgroundColor',[1,1,1]);
            obj.FeatureGridLayout.Layout.Row=1;
            obj.FeatureGridLayout.Layout.Column=1;


            obj.FeatureImage=uiimage(obj.FeatureGridLayout);
            obj.FeatureImage.Layout.Row=1;
            obj.FeatureImage.Layout.Column=1;


            obj.FeatureVariantGridLayout=uigridlayout(obj.FeatureGridLayout,...
            'ColumnWidth',{'fit','1x'},...
            'RowHeight',{'fit','1x','1x'},...
            'RowSpacing',1,...
            'BackgroundColor',[1,1,1]);
            obj.FeatureVariantGridLayout.Layout.Row=1;
            obj.FeatureVariantGridLayout.Layout.Column=2;


            obj.FeatureLabel=uilabel(obj.FeatureVariantGridLayout,...
            'HorizontalAlignment','left');
            obj.FeatureLabel.FontWeight='bold';
            obj.FeatureLabel.Layout.Row=1;
            obj.FeatureLabel.Layout.Column=1;


            obj.FeatureDropDown=uidropdown(obj.FeatureVariantGridLayout,...
            'BackgroundColor',[1,1,1],...
            'ValueChangedFcn',@obj.DropDownValueChanged);

            obj.FeatureDropDown.Layout.Row=1;
            obj.FeatureDropDown.Layout.Column=2;
            obj.FeatureDropDown.Tag=obj.FeatureName;



            obj.VariantLabel=uilabel(obj.FeatureVariantGridLayout,...
            'WordWrap','on',...
            'FontColor',[0.5,0.5,0.5]);
            obj.VariantLabel.Layout.Row=2;
            obj.VariantLabel.Layout.Column=2;
            obj.VariantLabel.Text='';

            if obj.NumofFig>0
                Columnwidth=cell(1,obj.NumofFig);
                Columnwidth(:)={'1x'};
                obj.DesFigGridLayout=uigridlayout(obj.TabGridLayout,...
                'ColumnWidth',Columnwidth,...
                'RowHeight',{'1x'},...
                'Padding',[0,0,0,10],...
                'BackgroundColor',[1,1,1]);
                obj.DesFigGridLayout.Layout.Row=2;
                obj.DesFigGridLayout.Layout.Column=1;

                obj.DesFigGroup=cell(obj.NumofFig,1);

                for i=1:obj.NumofFig
                    obj.DesFigGroup{i}=uiimage(obj.DesFigGridLayout);
                    obj.DesFigGroup{i}.Layout.Row=1;
                    obj.DesFigGroup{i}.Layout.Column=i;
                end
            end

        end

        function setFeatureDropDown(obj,value)

            index=find(strcmp(obj.FeatureDropDown.Items,value));
            if~isempty(index)
                obj.FeatureDropDown.Value=value;
            else
                index=1;
            end

            if~isempty(obj.FeatureVar.FeatureVariantsDes)
                if length(obj.FeatureVar.FeatureVariantsDes)>=index
                    obj.VariantLabel.Text=obj.FeatureVar.FeatureVariantsDes(index);
                else
                    obj.VariantLabel.Text=obj.FeatureVar.FeatureVariantsDes(1);
                end
            end

            len=length(obj.FeatureVar.FeatureIcons);

            if len>=index&&~isempty(obj.FeatureVar.FeatureIcons)&&~isempty(obj.FeatureVar.FeatureIcons{index})
                obj.FeatureImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images',obj.FeatureVar.FeatureIcons{index});
            elseif~isempty(obj.FeatureVar.FeatureIcons)&&~isempty(obj.FeatureVar.FeatureIcons{1})
                obj.FeatureImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images',obj.FeatureVar.FeatureIcons{1});
            end
            len1=length(obj.FeatureVar.FeatureOptionImages);

            if len1>=index&&~isempty(obj.FeatureVar.FeatureOptionImages)&&~isempty(obj.FeatureVar.FeatureOptionImages{index})
                obj.FigSource={fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images',obj.FeatureVar.FeatureOptionImages{index})};
            end

        end

        function setFig(obj)
            for i=1:obj.NumofFig
                obj.DesFigGroup{i}.ImageSource=obj.FigSource{i};
            end
        end

        function DropDownValueChanged(obj,~,evt)
            createDropDownEvent(obj,evt.Value);
        end

        function createDropDownEvent(obj,value)

            dd=struct('BlockName',obj.FeatureName,...
            'Value',value,...
            'Source',obj);
            data=VirtualAssembly.VirtualAssemblyEventData(dd);
            notify(obj,'FeatureDropDownValueChanged',data);

            if~isempty(obj.CbTab)
                if strcmp(obj.FeatureName,'Engine')&&(strcmp(value,'CI Engine')||strcmp(value,'CI Mapped Engine')||strcmp(value,'Simple Engine (CI)'))
                    type=1;
                else
                    type=0;
                end

                if obj.CallBackDoc.EngType~=type
                    obj.CallBackDoc.EngTypeChanged(type);
                end

            end
        end

        function ParaDefaultBtnPushed(obj,~,~)
            obj.FeatureUITable.Data(:,4)=obj.Data(:,4);

            value=struct('BlockName',obj.FeatureName,...
            'Source',obj);
            data=VirtualAssembly.VirtualAssemblyEventData(value);
            notify(obj,'ParameterDefaultBtnPushed',data);
        end


        function createTable(obj)


            obj.Tabgp=uitabgroup(obj.TabGridLayout);

            if obj.NumofFig==0
                row=2;
            else
                row=3;
            end
            obj.Tabgp.Layout.Row=row;
            obj.Tabgp.Layout.Column=1;


            obj.VehDataTab=uitab(obj.Tabgp,...
            'Title','Parameters',...
            'Tag','Parameters');

            obj.TableLyt=uigridlayout(obj.VehDataTab,...
            'ColumnWidth',{'1x'},...
            'RowHeight',{'fit','fit'},...
            'Padding',[10,0,10,0],...
            'BackgroundColor',[1,1,1],...
            'RowSpacing',5,...
            'Scrollable','on');

            obj.TableTitleLyt=uigridlayout(obj.TableLyt,...
            'ColumnWidth',{'1x','0.05x'},...
            'RowHeight',{'fit'},...
            'Padding',[1,1,1,1],...
            'BackgroundColor',[1,1,1]);
            obj.TableTitleLyt.Layout.Row=1;
            obj.TableTitleLyt.Layout.Column=1;

            obj.ParaDefaultBtn=uibutton(obj.TableTitleLyt);
            obj.ParaDefaultBtn.Text='';
            obj.ParaDefaultBtn.Tooltip='Default Parameters';
            obj.ParaDefaultBtn.BackgroundColor=[1,1,1];
            obj.ParaDefaultBtn.Icon=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','showpara.png');
            obj.ParaDefaultBtn.Layout.Row=1;
            obj.ParaDefaultBtn.Layout.Column=2;
            obj.ParaDefaultBtn.ButtonPushedFcn=@obj.ParaDefaultBtnPushed;

            obj.FeatureUITable=uitable(obj.TableLyt);
            obj.FeatureUITable.ColumnName={'Parameter Name';'Description';'Unit';'Value'};
            obj.FeatureUITable.ColumnEditable=[false,false,false,true,false];
            obj.FeatureUITable.ColumnWidth={'2x','4x','1x','2x'};
            obj.FeatureUITable.Layout.Row=2;
            obj.FeatureUITable.Layout.Column=1;
            obj.FeatureUITable.CellSelectionCallback=@obj.TableCellPush;
            obj.FeatureUITable.CellEditCallback=@obj.TableCellEdit;
            drawnow();
        end

        function setTableData(obj,value)


            if strcmp(value,'')
                index=1;
            else
                index=find(strcmp(obj.FeatureVar.FeatureVariants,value));
            end

            if length(obj.FeatureData)>=index
                tData=obj.retriveData(obj.FeatureData{index});
            end

            if~isempty(tData)

                if isempty(obj.FeatureUITable)
                    obj.createTable();
                end

                obj.Tabgp.Visible='on';
                obj.FeatureUITable.Parent=obj.TableLyt;
                obj.FeatureUITable.Data=tData(:,1:4);
                obj.setTableEdit(tData(:,5));
                obj.setPlotMap(tData(:,6));
                obj.Data=tData;
                if~strcmp(obj.FeatureName,'Vehicle Architecture')
                    obj.FeatureUITable.Visible=true;
                    obj.Tabgp.Visible=true;
                else
                    obj.FeatureUITable.Visible=false;
                    obj.Tabgp.Visible=false;
                end
            else
                obj.Tabgp.Visible='off';
            end

            if strcmp(obj.FeatureName,'Engine')
                obj.CreateCbTab();
            elseif strcmp(obj.FeatureName,'Electric Machine (Motor)')||strcmp(obj.FeatureName,'Electric Machine (Generator)')
                obj.CreateMotCbTab();
            end

        end

        function Data=retriveData(~,FeatureData)
            n=length(FeatureData);
            Data=cell(n,8);
            for i=1:n
                Data(i,:)=FeatureData{i}.tocelldata();
            end

        end

        function TableCellPush(obj,~,evt)
            if~isempty(evt.Indices)&&evt.Indices(1,2)==5
                if~isempty(obj.Data{evt.Indices(1,1),6})
                    if~isempty(evt.Source.DisplayData{evt.Indices(1,1),5})
                        obj.plotMap(evt.Indices(1,1));
                    end
                end
            end

        end

        function TableCellEdit(obj,~,evt)
            name=obj.FeatureUITable.Data{evt.Indices(1),1};
            if evt.Indices(2)==4&&strcmp(obj.Data{evt.Indices(1),5},'Y')

                olddata=str2num(evt.PreviousData);
                newdata=str2num(evt.NewData);

                if(isempty(newdata)&&isempty(olddata))||(~isempty(newdata)&&~isempty(olddata)&&~any(isnan(newdata),'all')&&~any(isnan(olddata),'all'))
                    createTableEvent(obj,evt.Indices(1),evt.NewData);
                    obj.FeatureUITable.Data{evt.Indices(1),evt.Indices(2)}=evt.NewData;
                elseif isempty(newdata)&&~isempty(olddata)
                    errordlg(getString(message('autoblks_reference:autoerrVirtualAssembly:numericalDataType',name)));
                    obj.FeatureUITable.Data{evt.Indices(1),evt.Indices(2)}=evt.PreviousData;
                elseif~isempty(newdata)&&isempty(olddata)
                    errordlg(getString(message('autoblks_reference:autoerrVirtualAssembly:charDataType',name)));
                    obj.FeatureUITable.Data{evt.Indices(1),evt.Indices(2)}=evt.PreviousData;
                end
            else
                obj.FeatureUITable.Data{evt.Indices(1),evt.Indices(2)}=evt.PreviousData;
            end
        end

        function createTableEvent(obj,row,value)
            if isempty(obj.Data{row,8})
                var=obj.Data{row,1};
            else
                var=obj.Data{row,8};
            end
            value=struct('VariableName',var,...
            'Value',value,...
            'Source',obj.Data{row,7},...
            'Parameter',obj.Data{row,1},...
            'VariantName',obj.FeatureDropDown.Value,...
            'FeatureName',obj.FeatureName);
            data=VirtualAssembly.VirtualAssemblyEventData(value);
            notify(obj,'FeatureDataValueChanged',data);
        end

        function setTableEdit(obj,paramEdit)
            s=uistyle('FontColor',[0.5,0.5,0.5]);
            for i=1:length(paramEdit)
                if~strcmp(paramEdit{i},'Y')
                    addStyle(obj.FeatureUITable,s,'cell',[i,4]);
                end
            end
        end

        function setPlotMap(obj,paramPlot)
            index=find(contains(paramPlot,'Y'));
            if~isempty(index)
                obj.FeatureUITable.ColumnName{5}='Plot';
                obj.FeatureUITable.ColumnFormat{5}='char';
                for i=1:length(index)
                    obj.FeatureUITable.Data{index(i),5}='Plot Map';
                end
            end
        end

        function plotMap(obj,row)


            cord=extractBetween(obj.Data{row,6},'(',')');
            cordn=split(cord,',');
            numberofcordn=length(cordn);
            if numberofcordn>1
                cordx=cordn{1};
                cordy=cordn{2};
                ncordx=strcmp(obj.Data(:,1),cordx);
                ncordy=strcmp(obj.Data(:,1),cordy);
                xx=obj.Data{ncordx,4};
                yy=obj.Data{ncordy,4};
                zz=obj.FeatureUITable.Data{row,4};
                h=figure('Visible','off');
                [X,Y]=ndgrid(str2num(xx),str2num(yy));
                surf(X,Y,str2num(zz));
                xlabel(cordx,'Interpreter','none');
                ylabel(cordy,'Interpreter','none');
                zlabel(obj.Data{row,1},'Interpreter','none');
                title(obj.Data{row,2},'Interpreter','none');
                h.Visible='on';
            else
                cordx=cordn{1};
                ncordx=strcmp(obj.Data(:,1),cordx);
                xx=obj.Data{ncordx,4};
                yy=obj.FeatureUITable.Data{row,4};
                h=figure('Visible','off');
                plot(str2num(xx),str2num(yy));
                xlabel(cordx,'Interpreter','none');
                ylabel(obj.Data{row,2},'Interpreter','none');
                title(obj.Data{row,2},'Interpreter','none');
                h.Visible='on';
            end

            obj.FeatureUITable.Selection=[];
        end

        function CreateCbTab(obj,~,~)
            value=obj.FeatureDropDown.Value;

            if strcmp(obj.FeatureName,'Engine')&&(strcmp(value,'CI Engine')||strcmp(value,'CI Mapped Engine')||strcmp(value,'Simple Engine (CI)'))
                type=1;
            else
                type=0;
            end

            if isfield(obj.EngRzResult,'EngRzIn')
                rin=obj.EngRzResult.EngRzIn;
            else
                rin=[];
            end
            if isfield(obj.EngRzResult,'EngRzOut')
                rout=obj.EngRzResult.EngRzOut;
            else
                rout=[];
            end

            if isfield(obj.EngRzResult,'EngineResizedFlag')
                obj.EngineResizedFlag=obj.EngRzResult.EngineResizedFlag;
            else
                obj.EngineResizedFlag=false;
            end

            if strcmp(obj.Tabgp.Visible,'on')&&length(obj.Tabgp.Children)==1
                obj.CbTab=uitab(obj.Tabgp,...
                'Title','Engine Resize',...
                'Tag','Engine Resize');

                obj.CallBackDoc=VirtualAssembly.VehCalibraDoc(...
                'HAppContainer',obj.HAppContainer,...
                'Parent',obj.CbTab,...
                'EngRzIn',rin,...
                'EngRzOut',rout,...
                'EngType',type,...
                'Resizedflag',obj.EngineResizedFlag);

                addlistener(obj.CallBackDoc,'EngineResized',@(src,event)EngineResizedFcn(obj,src,event));

            end
            obj.Tabgp.SelectedTab=obj.CbTab;

        end


        function CreateMotCbTab(obj,~,~)
            if length(obj.Tabgp.Children)==1
                obj.MotCbTab=uitab(obj.Tabgp,...
                'Title','Motor Resize',...
                'Tag','Motor Resize');
                if~isfield(obj.MotRzResult,'BlockParams')
                    p=obj.FeatureUITable.Data(:,4);
                    obj.MotRzResult.BlockParams=p;
                end
                obj.MotCallBackDoc=VirtualAssembly.MotCalibraDoc(...
                'HAppContainer',obj.HAppContainer,...
                'Parent',obj.MotCbTab,...
                'BlockParams',obj.MotRzResult.BlockParams,...
                'BlockName',obj.FeatureName);

                addlistener(obj.MotCallBackDoc,'MotorResized',@(src,evnt)MotorResizedFcn(obj,src,evnt));
            end
            obj.Tabgp.SelectedTab=obj.MotCbTab;


        end


        function EngineResizedFcn(obj,~,~)
            obj.EngineResizedFlag=true;






            obj.updateData();



        end

        function LoadEngineFcn(obj,~,~)


            notify(obj,'LoadEngine');


        end

        function LoadMotorFcn(obj,~,~)

            notify(obj,'LoadMotor');


        end

        function[doc,fig]=addDocumentFigures(obj,name)


            docOptions.Title=name;
            docOptions.DocumentGroupTag='Configuration';

            doc=matlab.ui.internal.FigureDocument(docOptions);
            doc.Closable=false;
            doc.Figure.AutoResizeChildren='on';
            doc.Tag=obj.FeatureName;

            fig=doc.Figure;
            fig.Tag=name;
            fig.AutoResizeChildren='on';
            fig.Interruptible='off';
            fig.BusyAction='cancel';
        end


        function MotorResizedFcn(obj,~,~)
            dd=obj.MotCallBackDoc.BlockParams;

            for i=1:length(dd)
                setTableCellData(obj,i,dd{i});
            end

        end

        function setTableCellData(obj,row,data)
            olddata=obj.FeatureUITable.Data{row,4};
            try
                obj.FeatureUITable.Data{row,4}=data;
                createTableEvent(obj,row,data);
            catch
                obj.FeatureUITable.Data{row,4}=olddata;
            end
        end

        function RunMotorResizeFcn(obj,~,event)
            sts=event.NewData.Status;
            value=struct('Status',sts);
            data=VirtualAssembly.VirtualAssemblyEventData(value);
            notify(obj,'RunMotorResize',data);

        end

    end
end