classdef NewSession<handle



    properties
        SessionPopUp matlab.ui.Figure
        SessionPopUpCanClose(1,1)logical{mustBeNumericOrLogical}=true
        gridOverall(1,1)matlab.ui.container.GridLayout
        SourcePanel(1,1)matlab.ui.container.Panel
        gridoverallSourceZ(1,1)matlab.ui.container.GridLayout
        gridSourceZ(1,1)matlab.ui.container.GridLayout
        plotgridSourceZ(1,1)matlab.ui.container.GridLayout

        LoadPanel(1,1)matlab.ui.container.Panel
        gridoverallLoadZ(1,1)matlab.ui.container.GridLayout
        gridLoadZ(1,1)matlab.ui.container.GridLayout
        plotgridLoadZ(1,1)matlab.ui.container.GridLayout

        SourceZLabel(1,1)matlab.ui.control.Label
        SourceZLabel1(1,1)matlab.ui.control.Label
        SourceZType(1,1)matlab.ui.control.DropDown
        SourceZTypeEdit(1,1)matlab.ui.control.EditField
        SourceZFileBrowseBtn(1,1)matlab.ui.control.Button
        SourceZObjDrop(1,1)matlab.ui.control.DropDown
        SourceZSpars sparameters

        LoadZLabel(1,1)matlab.ui.control.Label
        LoadZLabel1(1,1)matlab.ui.control.Label
        LoadZType(1,1)matlab.ui.control.DropDown
        LoadZTypeEdit(1,1)matlab.ui.control.EditField
        LoadZFileBrowseBtn(1,1)matlab.ui.control.Button
        LoadZObjDrop(1,1)matlab.ui.control.DropDown
        LoadZSpars sparameters

        ConstraintsPanel(1,1)matlab.ui.container.GridLayout
        CenterFrequencyEdit(1,1)matlab.ui.control.NumericEditField
        CenterFrequencyLabel(1,1)matlab.ui.control.Label

        BandWidthEdit(1,1)matlab.ui.control.NumericEditField
        BandWidthLabel(1,1)matlab.ui.control.Label

        ResponsePanel(1,1)matlab.ui.container.GridLayout
        ResponsePanelStart(1,1)matlab.ui.control.Button
        ResponsePanelCancel(1,1)matlab.ui.control.Button
    end

    properties(Dependent)
        FileNameZS{mustBeFile}
        FileNameZL{mustBeFile}
    end

    properties(Constant)
        title=getString(message('rf:matchingnetworkgenerator:NSTitle'))
        items={'Touchstone File','Scalar Complex Impedance',...
        'S-, Y-, or Z-parameter Object','Circuit Object',...
        'Antenna Toolbox Object','Anonymous Function'}
    end

    events
SBarUpdate
ImpUpdate
    end

    methods
        function set.FileNameZS(this,str)
            this.SourceZTypeEdit.Value=str;
        end

        function set.FileNameZL(this,str)
            this.LoadZTypeEdit.Value=str;
        end

        function browseAction(this,~,event)
            touchstoneFiles=...
            'All Touchstone files (*.s1p,*.y1p,*.z1p,*.h1p,*.g1p)';

            this.SessionPopUp.WindowStyle='normal';
            [filename,pathname]=uigetfile(...
            {'*.s1p','S-parameter files (*.s1p)';...
            '*.s1p;*.y1p;*.z1p;*.h1p;*.g1p',touchstoneFiles;...
            '*.*','All files (*.*)'},...
            'Select 1-port Touchstone file',pwd);
            this.SessionPopUp.WindowStyle='modal';

            wasCanceled=isequal(filename,0)||isequal(pathname,0);
            if wasCanceled
                return;
            end

            switch event.Source.Tag
            case 'BrowseZS'
                this.FileNameZS=[pathname,filename];
                target="SourceZ";
            case 'BrowseZL'
                this.FileNameZL=[pathname,filename];
                target="LoadZ";
            end
            plot(this,sparameters([pathname,filename]),target)
        end

        function plot(this,sparam,tempstr)
            target="gridoverall"+tempstr;
            tempstrp="plotgrid"+tempstr;
            this.(tempstrp)=uigridlayout(this.(target),...
            'Visible','off','ColumnWidth',{'1x'},'RowHeight',300,...
            'Padding',[0,0,0,0]);
            this.(tempstrp).Layout.Row=2;
            this.(tempstrp).Layout.Column=1;
            ax=uiaxes(this.(tempstrp));
            plot(ax,sparam.Frequencies,20*log10(abs(rfparam(sparam,1,1))))
            ylabel(ax,'Magnitude (dB)')
            xlabel(ax,'Frequency, Hz')
            grid(ax,'on');
            legend(ax,'dB(S)')
            this.(tempstrp).Visible='on';
            this.(tempstr+"Spars")=sparam;
        end

        function this=NewSession()
            title=this.title;
            items=this.items;
            if~builtin('license','test','Antenna_Toolbox')
                items(strcmp(items,'Antenna Toolbox Object'))=[];
            end
            this.SessionPopUp=uifigure('Visible','off','Name',title,...
            'WindowStyle','modal');
            this.SessionPopUp.Position(4)=1.1*this.SessionPopUp.Position(4);

            this.gridOverall=uigridlayout(this.SessionPopUp,...
            'RowHeight',{'fit','fit','fit','fit'},...
            'ColumnWidth',{'1x'},'Scrollable','on');

            Zterminal=["Source","Load"];
            Zitem=[items(2),items(1)];
            ZitemValue=["Impedance (Ohms)","File Name"];
            for index=1:numel(Zterminal)
                set=Zterminal(index);
                labelZ=regexprep(set,'[a-z]','');
                tempstr=set+"Panel";
                this.(tempstr)=uipanel(...
                'Parent',this.gridOverall,...
                'Title',"Set "+set+" Impedance (Z"+lower(labelZ)+")");
                this.(tempstr).Layout.Row=index;
                this.(tempstr).Layout.Column=1;

                tempstrg="gridoverall"+set+"Z";
                this.(tempstrg)=uigridlayout(this.(tempstr),...
                'RowHeight',{'1x','fit'},...
                'ColumnWidth',{'1x'});

                tempstrp="grid"+set+"Z";
                this.(tempstrp)=uigridlayout(this.(tempstrg),...
                'RowHeight',{30,30},...
                'ColumnWidth',{140,'1x',70});
                this.(tempstrp).Layout.Row=1;
                this.(tempstrp).Layout.Column=1;

                tempstr=set+"ZLabel1";
                this.(tempstr)=uilabel(this.(tempstrp),...
                'Text',"Z"+lower(labelZ)+" "+set);
                this.(tempstr).Layout.Row=1;
                this.(tempstr).Layout.Column=1;

                tempstr=set+"ZType";
                this.(tempstr)=uidropdown(this.(tempstrp),...
                'Items',items,...
                'Value',Zitem{index},...
                'ValueChangedFcn',@(~,~)ZPanelUpdate(this,set));
                this.(tempstr).Layout.Row=1;
                this.(tempstr).Layout.Column=2;

                tempstr=set+"ZLabel";
                this.(tempstr)=uilabel(this.(tempstrp),'Text',ZitemValue(index));
                this.(tempstr).Layout.Row=2;
                this.(tempstr).Layout.Column=1;

                tempstr=set+"ZObjDrop";
                this.(tempstr)=uidropdown(this.(tempstrp),...
                'Items',{''},'Visible',0,...
                'ValueChangedFcn',@(~,~)ZPanelUpdate(this,set));
                this.(tempstr).Layout.Row=2;
                this.(tempstr).Layout.Column=2;

                tempstr=set+"ZFileBrowseBtn";
                this.(tempstr)=uibutton(this.(tempstrp),...
                'Text','Browse',...
                'Tag',"BrowseZ"+labelZ,...
                'Visible',strcmp(set,"Load"),...
                'ButtonPushedFcn',@(h,e)browseAction(this,h,e),...
                'Tooltip',getString(message('rf:matchingnetworkgenerator:BrowseFile')));
                this.(tempstr).Layout.Row=2;
                this.(tempstr).Layout.Column=3;
            end

            this.SourceZType.Tooltip=getString(message('rf:matchingnetworkgenerator:ScalarImp'));
            this.SourceZTypeEdit=uieditfield(this.gridSourceZ,'text',...
            'Value','50',...
            'Tooltip',getString(message('rf:matchingnetworkgenerator:ScalarImp')));
            this.SourceZTypeEdit.Layout.Row=2;
            this.SourceZTypeEdit.Layout.Column=2;

            this.LoadZType.Tooltip=getString(message('rf:matchingnetworkgenerator:EnterFile'));
            this.LoadZTypeEdit=uieditfield(this.gridLoadZ,'text',...
            'Value','dipole_example.s1p',...
            'Tooltip',getString(message('rf:matchingnetworkgenerator:EnterFile')));
            this.LoadZTypeEdit.Layout.Row=2;
            this.LoadZTypeEdit.Layout.Column=2;
            this.LoadZSpars=sparameters('dipole_example.s1p');

            this.ConstraintsPanel=uigridlayout('Parent',...
            this.gridOverall,'RowHeight',{30,30},'ColumnWidth',{150,'1x',70});
            this.ConstraintsPanel.Layout.Row=3;
            this.ConstraintsPanel.Layout.Column=1;

            this.CenterFrequencyLabel=...
            uilabel(this.ConstraintsPanel,'Text','Center Frequency');
            this.CenterFrequencyLabel.Layout.Row=1;
            this.CenterFrequencyEdit=...
            uieditfield(this.ConstraintsPanel,'numeric',...
            'Value',1.5e9,'Limits',[0,Inf],...
            'LowerLimitInclusive','off','UpperLimitInclusive','off',...
            'ValueChangedFcn',@(~,~)bwtooltipUpdate(this),...
            'Tag','centerfrequency','ValueDisplayFormat','%11.4g Hz');
            this.CenterFrequencyEdit.Layout.Row=1;
            this.BandWidthLabel=...
            uilabel(this.ConstraintsPanel,'Text','Bandwidth');
            this.BandWidthLabel.Layout.Row=2;
            this.BandWidthLabel.Layout.Column=1;
            this.BandWidthEdit=...
            uieditfield(this.ConstraintsPanel,'numeric',...
            'Value',750e6,'Limits',[0,Inf],...
            'LowerLimitInclusive','off','UpperLimitInclusive','off',...
            'ValueChangedFcn',@(~,~)bwtooltipUpdate(this),...
            'Tag','bandwidth','ValueDisplayFormat','%11.4g Hz');
            this.BandWidthEdit.Tooltip=...
            join(["Used to compute loaded quality factor, Q = ",this.CenterFrequencyEdit.Value/this.BandWidthEdit.Value]);

            this.BandWidthEdit.Layout.Row=2;
            this.BandWidthEdit.Layout.Column=2;

            this.ResponsePanel=uigridlayout('Parent',this.gridOverall,...
            'RowHeight',{'fit',30},...
            'ColumnWidth',{'2x','1x','1x'});
            this.ResponsePanel.Layout.Row=4;
            this.ResponsePanel.Layout.Column=1;

            this.ResponsePanelStart=uibutton(this.ResponsePanel,...
            'Text','Start Session',...
            'ButtonPushedFcn',@(h,e)setImpedances(this,h,e),...
            'Tooltip',getString(message('rf:matchingnetworkgenerator:StartSession')));
            this.ResponsePanelStart.Layout.Row=2;
            this.ResponsePanelStart.Layout.Column=2;

            this.ResponsePanelCancel=uibutton(this.ResponsePanel,...
            'Text','Cancel',...
            'ButtonPushedFcn',@(~,~)closeNewSession(this),...
            'Tooltip',getString(message('rf:matchingnetworkgenerator:CancelSession')));
            this.ResponsePanelCancel.Layout.Row=2;
            this.ResponsePanelCancel.Layout.Column=3;

            this.SessionPopUp.Visible='on';
        end

        function closeNewSession(this)
            this.SessionPopUp.WindowStyle='normal';
            delete(this.SessionPopUp);
        end

        function ZPanelUpdate(this,ZTerminal)
            delete(this.("plotgrid"+ZTerminal+"Z"));
            switch this.(ZTerminal+"ZType").Value
            case 'Scalar Complex Impedance'
                this.(ZTerminal+"ZObjDrop").Visible='off';
                this.(ZTerminal+"ZLabel").Text='Impedance (Ohms)';
                this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                this.(ZTerminal+"ZTypeEdit").Editable='on';
                this.(ZTerminal+"ZTypeEdit").Visible='on';
                this.(ZTerminal+"ZTypeEdit").Value='50';
                this.(ZTerminal+"ZTypeEdit").Tooltip='';
                this.(ZTerminal+"ZType").Tooltip=getString(message('rf:matchingnetworkgenerator:ScalarImp'));
                this.(ZTerminal+"ZTypeEdit").Tooltip=getString(message('rf:matchingnetworkgenerator:ScalarImp'));
            case 'Touchstone File'
                this.(ZTerminal+"ZObjDrop").Visible='off';
                this.(ZTerminal+"ZLabel").Text='File Name';
                this.(ZTerminal+"ZFileBrowseBtn").Visible='on';
                this.(ZTerminal+"ZTypeEdit").Editable='on';
                this.(ZTerminal+"ZTypeEdit").Visible='on';
                this.(ZTerminal+"ZTypeEdit").Value='dipole_example.s1p';
                this.(ZTerminal+"ZType").Tooltip=getString(message('rf:matchingnetworkgenerator:EnterFile'));
                this.(ZTerminal+"ZTypeEdit").Tooltip=getString(message('rf:matchingnetworkgenerator:EnterFile'));
                this.(ZTerminal+"ZSpars")=sparameters('dipole_example.s1p');
            case 'S-, Y-, or Z-parameter Object'
                this.(ZTerminal+"ZLabel").Text='Variable Name';
                this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                s=evalin('base','whos');
                if isempty(s)
                    this.(ZTerminal+"ZObjDrop").Visible='off';
                    this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                    this.(ZTerminal+"ZTypeEdit").Value=getString(message('rf:matchingnetworkgenerator:NoVars'));
                    this.(ZTerminal+"ZTypeEdit").Editable='off';
                else
                    st=struct2table(s);
                    matches=regexp(st.class,'[syz]parameters');
                    if isempty(matches)||(size(matches,1)>1&&...
                        all(cellfun(@(x)isempty(x),matches)))
                        this.(ZTerminal+"ZObjDrop").Visible='off';
                        this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                        this.(ZTerminal+"ZTypeEdit").Value=getString(message('rf:matchingnetworkgenerator:NoVars'));
                        this.(ZTerminal+"ZTypeEdit").Editable='off';
                        this.(ZTerminal+"ZTypeEdit").Visible='on';
                    elseif size(matches,1)>1
                        matches=cellfun(@(x)~isempty(x),matches);
                        nametemp=st.name(matches);
                        matches2=cellfun(@(x)evalin('base',x).NumPorts==1,nametemp);
                        if all(~matches2)
                            this.(ZTerminal+"ZObjDrop").Visible='off';
                            this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                            this.(ZTerminal+"ZTypeEdit").Value=getString(message('rf:matchingnetworkgenerator:NoVars'));
                            this.(ZTerminal+"ZTypeEdit").Editable='off';
                            this.(ZTerminal+"ZTypeEdit").Visible='on';
                        else
                            this.(ZTerminal+"ZObjDrop").Items=nametemp(matches2);
                            this.(ZTerminal+"ZTypeEdit").Visible='off';
                            this.(ZTerminal+"ZObjDrop").Visible='on';
                        end
                    else
                        if evalin('base',st.name).NumPorts==1
                            this.(ZTerminal+"ZObjDrop").Items={st.name};
                            this.(ZTerminal+"ZTypeEdit").Visible='off';
                            this.(ZTerminal+"ZObjDrop").Visible='on';
                        else
                            this.(ZTerminal+"ZObjDrop").Visible='off';
                            this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                            this.(ZTerminal+"ZTypeEdit").Value=getString(message('rf:matchingnetworkgenerator:NoVars'));
                            this.(ZTerminal+"ZTypeEdit").Editable='off';
                            this.(ZTerminal+"ZTypeEdit").Visible='on';
                        end
                    end
                end
                this.(ZTerminal+"ZType").Tooltip=getString(message('rf:matchingnetworkgenerator:NetObj'));
                this.(ZTerminal+"ZTypeEdit").Tooltip='';
            case 'Circuit Object'
                this.(ZTerminal+"ZLabel").Text='Variable Name';
                this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                s=evalin('base','whos');
                if isempty(s)
                    this.(ZTerminal+"ZObjDrop").Visible='off';
                    this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                    this.(ZTerminal+"ZTypeEdit").Value=getString(message('rf:matchingnetworkgenerator:NoVars'));
                    this.(ZTerminal+"ZTypeEdit").Editable='off';
                else
                    st=struct2table(s);
                    matches=regexp(st.class,'circuit');
                    if isempty(matches)||(size(matches,1)>1&&...
                        all(cellfun(@(x)isempty(x),matches)))
                        this.(ZTerminal+"ZObjDrop").Visible='off';
                        this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                        this.(ZTerminal+"ZTypeEdit").Value=getString(message('rf:matchingnetworkgenerator:NoVars'));
                        this.(ZTerminal+"ZTypeEdit").Editable='off';
                        this.(ZTerminal+"ZTypeEdit").Visible='on';
                    elseif size(matches,1)>1
                        matches=cellfun(@(x)~isempty(x),matches);
                        nametemp=st.name(matches);
                        matches2=cellfun(@(x)evalin('base',x).NumPorts==1,nametemp);
                        if all(~matches2)
                            this.(ZTerminal+"ZObjDrop").Visible='off';
                            this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                            this.(ZTerminal+"ZTypeEdit").Value=getString(message('rf:matchingnetworkgenerator:NoVars'));
                            this.(ZTerminal+"ZTypeEdit").Editable='off';
                            this.(ZTerminal+"ZTypeEdit").Visible='on';
                        else
                            this.(ZTerminal+"ZObjDrop").Items=nametemp(matches2);
                            this.(ZTerminal+"ZTypeEdit").Visible='off';
                            this.(ZTerminal+"ZObjDrop").Visible='on';
                        end
                    else
                        if evalin('base',st.name).NumPorts==1
                            this.(ZTerminal+"ZObjDrop").Items={st.name};
                            this.(ZTerminal+"ZTypeEdit").Visible='off';
                            this.(ZTerminal+"ZObjDrop").Visible='on';
                        else
                            this.(ZTerminal+"ZObjDrop").Visible='off';
                            this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                            this.(ZTerminal+"ZTypeEdit").Value=getString(message('rf:matchingnetworkgenerator:NoVars'));
                            this.(ZTerminal+"ZTypeEdit").Editable='off';
                            this.(ZTerminal+"ZTypeEdit").Visible='on';
                        end
                    end
                end
                this.(ZTerminal+"ZType").Tooltip=getString(message('rf:matchingnetworkgenerator:CktObj'));
                this.(ZTerminal+"ZTypeEdit").Tooltip='';
            case 'Antenna Toolbox Object'
                this.(ZTerminal+"ZLabel").Text='Antenna Object';
                this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                s=evalin('base','whos');
                if isempty(s)
                    this.(ZTerminal+"ZObjDrop").Visible='off';
                    this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                    this.(ZTerminal+"ZTypeEdit").Value=getString(message('rf:matchingnetworkgenerator:NoVars'));
                    this.(ZTerminal+"ZTypeEdit").Editable='off';
                else
                    st=struct2table(s);
                    if size(st,1)==1
                        matches=isa(evalin('base',st.name),'em.Antenna');
                    else
                        matches=cellfun(@(x)isa(evalin('base',x),'em.Antenna'),st.name);
                    end
                    if~any(matches)
                        this.(ZTerminal+"ZObjDrop").Visible='off';
                        this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                        this.(ZTerminal+"ZTypeEdit").Value=getString(message('rf:matchingnetworkgenerator:NoVars'));
                        this.(ZTerminal+"ZTypeEdit").Editable='off';
                        this.(ZTerminal+"ZTypeEdit").Visible='on';
                    else
                        if length(matches)==1
                            this.(ZTerminal+"ZObjDrop").Items={st.name};
                        else
                            this.(ZTerminal+"ZObjDrop").Items=st.name(matches);
                        end
                        this.(ZTerminal+"ZTypeEdit").Visible='off';
                        this.(ZTerminal+"ZObjDrop").Visible='on';
                    end
                end
                this.(ZTerminal+"ZType").Tooltip=getString(message('rf:matchingnetworkgenerator:AntObj'));
                this.(ZTerminal+"ZTypeEdit").Tooltip='';
            case 'Anonymous Function'
                this.(ZTerminal+"ZObjDrop").Visible='off';
                this.(ZTerminal+"ZFileBrowseBtn").Visible='off';
                this.(ZTerminal+"ZLabel").Text='Anonymous Function';
                s=evalin('base','whos');
                if isempty(s)
                    this.(ZTerminal+"ZObjDrop").Visible='off';
                    this.(ZTerminal+"ZTypeEdit").Value='@(x) x.^2';
                    this.(ZTerminal+"ZTypeEdit").Editable='on';
                    this.(ZTerminal+"ZTypeEdit").Visible='on';
                else
                    st=struct2table(s);
                    if size(st,1)==1
                        matches=isa(evalin('base',st.name),'function_handle');
                    else
                        matches=cellfun(@(x)isa(evalin('base',x),'function_handle'),st.name);
                    end
                    if~any(matches)
                        this.(ZTerminal+"ZObjDrop").Visible='off';
                        this.(ZTerminal+"ZTypeEdit").Value='@(x) x.^2';
                        this.(ZTerminal+"ZTypeEdit").Editable='on';
                        this.(ZTerminal+"ZTypeEdit").Visible='on';
                    else
                        if length(matches)==1
                            this.(ZTerminal+"ZObjDrop").Items={st.name};
                        else
                            this.(ZTerminal+"ZObjDrop").Items=st.name(matches);
                        end
                        this.(ZTerminal+"ZTypeEdit").Visible='off';
                        this.(ZTerminal+"ZObjDrop").Visible='on';
                    end
                end
                this.(ZTerminal+"ZType").Tooltip=getString(message('rf:matchingnetworkgenerator:FuncHandle'));
                this.(ZTerminal+"ZTypeEdit").Tooltip=getString(message('rf:matchingnetworkgenerator:FuncHandle'));
            end

            if(strcmp(this.SourceZTypeEdit.Value,getString(message('rf:matchingnetworkgenerator:NoVars')))&&...
                isequal(this.SourceZTypeEdit.Visible,matlab.lang.OnOffSwitchState('on')))||...
                (strcmp(this.LoadZTypeEdit.Value,getString(message('rf:matchingnetworkgenerator:NoVars')))&&...
                isequal(this.LoadZTypeEdit.Visible,matlab.lang.OnOffSwitchState('on')))
                this.ResponsePanelStart.Enable='off';
                this.ResponsePanelStart.Tooltip=getString(message('rf:matchingnetworkgenerator:CantStartSession'));
            else
                this.ResponsePanelStart.Enable='on';
                this.ResponsePanelStart.Tooltip=getString(message('rf:matchingnetworkgenerator:StartSession'));
            end
        end

        function setImpedances(this,~,~)
            for ZTerminal=["Source","Load"]
                if strcmp(this.(ZTerminal+"ZType").Value,'Touchstone File')
                    value=this.(ZTerminal+"ZSpars");
                    [S,L]=bounds(value.Frequencies);
                    if~(this.CenterFrequencyEdit.Value>=S&&...
                        this.CenterFrequencyEdit.Value<=L)
                        [FV,~,FU]=engunits(this.CenterFrequencyEdit.Value);
                        [SV,~,SU]=engunits(S);
                        [LV,~,LU]=engunits(L);
                        uialert(this.SessionPopUp,...
                        getString(message('rf:matchingnetworkgenerator:CenterFreqBounds',...
                        lower(ZTerminal),...
                        FV+" "+FU+"Hz",SV+" "+SU+"Hz",LV+" "+LU+"Hz")),...
                        getString(message('rf:matchingnetworkgenerator:CenterFreqBoundsTitle')));
                        return
                    end
                elseif strcmp(this.(ZTerminal+"ZType").Value,'S-, Y-, or Z-parameter Object')
                    value=evalin('base',this.(ZTerminal+"ZObjDrop").Value);
                    [S,L]=bounds(value.Frequencies);
                    if~(this.CenterFrequencyEdit.Value>=S&&...
                        this.CenterFrequencyEdit.Value<=L)
                        [FV,~,FU]=engunits(this.CenterFrequencyEdit.Value);
                        [SV,~,SU]=engunits(S);
                        [LV,~,LU]=engunits(L);
                        uialert(this.SessionPopUp,...
                        getString(message('rf:matchingnetworkgenerator:CenterFreqBounds',...
                        lower(ZTerminal),...
                        FV+" "+FU+"Hz",SV+" "+SU+"Hz",LV+" "+LU+"Hz")),...
                        getString(message('rf:matchingnetworkgenerator:CenterFreqBoundsTitle')));
                        return
                    end
                end
            end
            try
                data.SourceZ=setImpedances_2(this,"Source");
            catch me
                CBK_setParameters(this,rf.internal.apps.matchnet.ArbitraryEventData(me.message))
                return
            end
            data.SourceZTag=this.SourceZObjDrop.Value;
            try
                data.LoadZ=setImpedances_2(this,"Load");
            catch me
                CBK_setParameters(this,rf.internal.apps.matchnet.ArbitraryEventData(me.message))
                return
            end
            data.LoadZTag=this.LoadZObjDrop.Value;
            data.CenterFrequency=this.CenterFrequencyEdit.Value;
            data.Q=this.CenterFrequencyEdit.Value/this.BandWidthEdit.Value;
            evtdata=rf.internal.apps.matchnet.ArbitraryEventData(data);
            this.notify('ImpUpdate',evtdata);
            if this.SessionPopUpCanClose
                this.notify('SBarUpdate',evtdata);
                closeNewSession(this)
            else
                this.SessionPopUpCanClose=true;
            end
        end

        function value=setImpedances_2(this,ZTerminal)
            switch this.(ZTerminal+"ZType").Value
            case 'Scalar Complex Impedance'
                value=str2num(this.(ZTerminal+"ZTypeEdit").Value);%#ok<ST2NM>
                validateattributes(value,{'double'},{'scalar'})
            case 'Touchstone File'
                value=this.(ZTerminal+"ZTypeEdit").Value;
            case{'S-, Y-, or Z-parameter Object','Antenna Toolbox Object','Circuit Object'}
                value=evalin('base',this.(ZTerminal+"ZObjDrop").Value);
            case 'Anonymous Function'
                if this.(ZTerminal+"ZTypeEdit").Visible
                    value=eval(this.(ZTerminal+"ZTypeEdit").Value);
                else
                    value=evalin('base',this.(ZTerminal+"ZObjDrop").Value);
                end
            end
        end

        function CBK_setParameters(this,message)
            uialert(this.SessionPopUp,message.data,'Error');
            this.SessionPopUpCanClose=false;
        end

        function bwtooltipUpdate(this)
            this.BandWidthEdit.Tooltip=...
            join(["Used to compute loaded quality factor, Q = ",this.CenterFrequencyEdit.Value/this.BandWidthEdit.Value]);
        end
    end
end
