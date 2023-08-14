






classdef CredentialsDialog<handle

    properties

Parent


        Figure matlab.ui.Figure


        Layout matlab.ui.container.GridLayout


        Tokens matlab.ui.control.EditField


        Status matlab.ui.control.Label


        Save matlab.ui.control.CheckBox


        IsSubmitRequest logical=false


        IsParentSpecified logical=false


        OkBtn matlab.ui.control.Button
    end

    methods

        function this=CredentialsDialog(parent)


            this.IsParentSpecified=nargin==1&&ishghandle(parent);

            if this.IsParentSpecified
                this.Parent=parent;
                this.Figure=ancestor(this.Parent,'figure');
                this.createInputs();
            else
                this.Parent=this.createFigure();
                this.Figure=this.Parent;


                this.createInputs();
                this.attachNavigation();

                movegui(this.Figure,'center');
            end
        end

        function delete(this)

            if this.IsParentSpecified
                if ishghandle(this.Parent)
                    delete(this.Parent.Children);
                end
            elseif ishghandle(this.Figure)
                delete(this.Figure);
            end
        end

        function credentials=requestCredentials(this)



            this.IsSubmitRequest=false;


            uiwait(this.Figure);


            credentials=struct;
            for idx=1:numel(this.Tokens)
                token=this.Tokens(idx);
                credentials.(token.UserData)=token.Value;
            end
        end

        function tf=areFieldsEmpty(this)

            for idx=1:numel(this.Tokens)
                if isempty(this.Tokens(idx).Value)
                    tf=true;
                    return
                end
            end
            tf=false;
        end

        function fig=createFigure(this)


            dialogWidth=375;
            dialogHeight=300;

            fig=uifigure(...
            'Name',getString(message('driving:heremaps:DialogTitleText')),...
            'Visible','off',...
            'HandleVisibility','off',...
            'NumberTitle','off',...
            'WindowKeyReleaseFcn',@(~,event)this.keyPressCallback(event),...
            'CloseRequestFcn',@(~,~)this.cancelCallback(),...
            'Tag','hereHDLMCredentialsDialog');
            fig.InnerPosition(3:4)=[dialogWidth,dialogHeight];
        end

        function createInputs(this)


            fieldHeight=25;

            m=driving.internal.heremaps.DataServiceManager.getInstance();
            tokens=m.DataService.CredentialsTokens;

            rows=repmat({fieldHeight,'fit'},1,numel(tokens));

            this.Layout=uigridlayout(this.Parent,...
            'RowHeight',[{fieldHeight},{'fit'},rows(:)',{'fit'},{'1x'}],...
            'ColumnWidth',{'1x'},...
            'Padding',[20,20,20,20]);

            hDesc=uilabel(this.Layout,...
            'Text',getString(message("driving:heremaps:Dialog"+m.DataServiceName+"DescText")),...
            'VerticalAlignment','top',...
            'FontWeight','bold');
            hDesc.Layout.Row=1;

            currRow=2;
            for idx=1:numel(tokens)
                str=tokens{idx};


                hDesc=uilabel(this.Layout,...
                'Text',getString(message("driving:heremaps:Dialog"+str+"EditText")));
                hDesc.Layout.Row=currRow;

                this.Tokens(idx)=uieditfield(this.Layout,'text',...
                'Tag',['hereHDLM',str,'EditField'],...
                'UserData',str);
                this.Tokens(idx).Layout.Row=currRow+1;
                currRow=currRow+2;
            end
            this.Tokens=reshape(this.Tokens,size(tokens));


            this.Save=uicheckbox(this.Layout,...
            'Text',getString(message('driving:heremaps:DialogSaveText')),...
            'Value',false,...
            'Tag','hereHDLMSaveCheckBox');
            this.Save.Layout.Row=currRow;
            currRow=currRow+1;


            this.Status=uilabel(this.Layout,...
            'Text','',...
            'Tag','hereHDLMStatusLabel');
            this.Status.Layout.Row=currRow;
        end

        function attachNavigation(this)


            btnHeight=25;
            btnWidth=75;


            this.Layout.RowHeight=[this.Layout.RowHeight,btnHeight];

            g=uigridlayout(this.Layout,...
            'RowHeight',{'fit'},...
            'ColumnWidth',{'1x',btnWidth,btnWidth},...
            'Padding',[0,0,0,0]);
            g.Layout.Row=length(this.Layout.RowHeight);


            this.OkBtn=uibutton(g,...
            'Text',getString(message('driving:heremaps:DialogOkBtnText')),...
            'ButtonPushedFcn',@(~,~)this.okCallback(),...
            'Tag','hereHDLMOkButton');
            this.OkBtn.Layout.Column=2;

            hCancelBtn=uibutton(g,...
            'Text',getString(message('driving:heremaps:DialogCancelBtnText')),...
            'ButtonPushedFcn',@(~,~)this.cancelCallback(),...
            'Tag','hereHDLMCancelButton');
            hCancelBtn.Layout.Column=3;
        end

        function okCallback(this)

            this.IsSubmitRequest=true;
            uiresume(this.Figure);
        end

        function cancelCallback(this)

            uiresume(this.Figure);
        end

        function keyPressCallback(this,event)

            switch event.Key
            case 'escape'
                this.cancelCallback();
            case 'return'
                this.okCallback();
            end
        end

        function setValidatingStatus(this)

            this.Status.FontColor='k';
            this.Status.Text=...
            getString(message('driving:heremaps:DialogValidatingStatusText'));
            this.OkBtn.Enable='off';
            drawnow;
        end

        function setInvalidStatus(this,msg)

            this.Status.FontColor='r';
            this.Status.Text=msg;
            this.OkBtn.Enable='on';
            drawnow;
        end

        function throwValidationErrors(this,err)

            if strcmpi(err.identifier,...
                'MATLAB:webservices:HTTP401StatusCodeError')
                m=driving.internal.heremaps.DataServiceManager.getInstance();
                this.setInvalidStatus(...
                getString(message("driving:heremaps:Invalid"+m.DataServiceName+"AppCredentials")));
            else
                this.setInvalidStatus(...
                getString(message('driving:heremaps:AppValidationFailure')));
                disp(err.message);
            end

        end

    end

end
