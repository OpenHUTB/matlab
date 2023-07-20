classdef CustomAutomationFunctionSettingsDialog<handle





    properties

Dlg


DlgSize


DlgTitle



TextArea
EditBox
BrowseButton
InfoText
InfoButton
OkButton
CancelButton


        IsCanceled=true



FunctionHandle



FunctionString
    end

    properties(Access=protected)
        ButtonSize=[60,25];
        ButtonHalfSpace=10;
    end

    methods
        function this=CustomAutomationFunctionSettingsDialog(fcnString)
            this.DlgSize=[500,260];
            this.FunctionString=fcnString;
        end



        function createDialog(this)


            this.DlgSize=[520,260];

            dlgTitle=vision.getMessage('vision:labeler:FunctionalAlgSettingsTitle');

            dlgPosition=[1,1,this.DlgSize];
            this.Dlg=dialog(...
            'Name',dlgTitle,...
            'Position',dlgPosition,...
            'KeyPressFcn',@this.onKeyPress,...
            'Visible','off',...
            'Tag','CustomAutomationFucntionSettingsDialog');




            leftMargin=16;
            rightMargin=16;
            componentWidth=this.DlgSize(1)-leftMargin-rightMargin;



            editPos=[leftMargin,60,componentWidth-this.ButtonSize(1)-2,25];
            this.EditBox=uicontrol('Parent',this.Dlg,...
            'String',this.FunctionString,...
            'Style','edit',...
            'Position',editPos,...
            'HorizontalAlignment','left',...
            'Tag','EditBox');


            browsePosition=[editPos(1:2)+[editPos(3)+2,0],this.ButtonSize];
            this.BrowseButton=uicontrol('Parent',this.Dlg,...
            'Style','pushbutton',...
            'String',vision.getMessage('vision:labeler:Browse'),...
            'Tag','BrowseButton',...
            'Callback',@(~,~)onBrowse(this),...
            'Position',browsePosition);


            vertDistFromEditBox=40;
            buttonPos=[leftMargin,editPos(2)+editPos(4)+vertDistFromEditBox,16,16];
            buttonTextColor=repelem(160/255,1,3);
            infoButtonFilePath=fullfile(toolboxdir('vision'),'vision',...
            '+vision','+internal','+calibration','+tool','info_button_16.png');

            infoButtonCData=imread(infoButtonFilePath);

            this.InfoButton=uicontrol('Parent',this.Dlg,...
            'Style','pushbutton',...
            'CData',infoButtonCData,...
            'ForegroundColor',buttonTextColor,...
            'Callback',@(~,~)openTemplate(this),...
            'Position',buttonPos,...
            'Tag','InfoButton');

            infoPos=[leftMargin+16+2,buttonPos(2)-(25-16)-1,componentWidth-18,25];
            infoMsg=vision.getMessage('vision:labeler:FunctionalAlgInfoText');

            this.InfoText=uicontrol('Parent',this.Dlg,...
            'Style','text',...
            'String',infoMsg,...
            'HorizontalAlignment','left',...
            'Position',infoPos,...
            'Tag','InfoText');


            this.TextArea=uicontrol(this.Dlg,...
            'Style','text',...
            'Position',[leftMargin,infoPos(2)+infoPos(4),componentWidth,80],...
            'String',vision.getMessage('vision:labeler:FunctionalAlgSettingsText'),...
            'HorizontalAlignment','left');

            addOK(this);
            addCancel(this);



            movegui(this.Dlg,'center');
            this.Dlg.Visible='on';

            uiwait(this.Dlg);
        end


        function wait(this)

            uiwait(this.Dlg);
        end
    end

    methods(Access=protected)
        function onOK(this,~,~)



            functionStr=string(this.EditBox.String);
            functionStr=strtrim(functionStr);
            if~isempty(functionStr)&&strlength(functionStr)>0

                try
                    isFunctionHandle=startsWith(functionStr,"@");
                    if~isFunctionHandle

                        [folder,name,~]=fileparts(functionStr);

                        if strlength(folder)==0






                            location=iWhichFile(name);

                            if isempty(location)
                                errordlg(...
                                vision.getMessage('vision:labeler:FunctionalAlgNotFound',name),...
                                vision.getMessage('vision:labeler:AlgorithmNotFoundTitle'),...
                                'modal');
                                return




                            end
                        else


                            errordlg(...
                            vision.getMessage('vision:labeler:FunctionalAlgInvalidFunction'),...
                            vision.getMessage('vision:labeler:FunctionalAlgInvalidFunctionTitle'),...
                            'modal');
                            return
                        end

                    end

                    this.FunctionString=functionStr;
                    this.FunctionHandle=str2func(functionStr);



                catch


                    this.FunctionString="";
                    this.FunctionHandle=[];

                    errordlg(...
                    vision.getMessage('vision:labeler:FunctionalAlgInvalidFunction'),...
                    vision.getMessage('vision:labeler:FunctionalAlgInvalidFunctionTitle'),...
                    'modal');
                end

                if ishandle(this.Dlg)
                    close(this.Dlg)
                end
                this.IsCanceled=false;
            else
                errordlg(...
                vision.getMessage('vision:labeler:FunctionalAlgNotSpecifiedOnOK'),...
                vision.getMessage('vision:labeler:FunctionalAlgInvalidFunctionTitle'),...
                'modal');
            end

        end

        function onBrowse(this)

            filter=["*.m","*.mlx"];
            [file,folder]=uigetfile(filter,...
            vision.getMessage('vision:labeler:FunctionalAlgBrowseTitle'),...
            'MultiSelect','off');

            isFileSelected=~isequal(file,0);

            if isFileSelected



                [~,name,~]=fileparts(file);
                location=iWhichFile(name);

                if isempty(location)
                    wasCanceled=addPathOrChangeDirectoryDialog(this,folder,name);




                    if~wasCanceled
                        this.EditBox.String=name;
                    end
                else


                    this.EditBox.String=name;
                end
            end

        end


        function onCancel(this,~,~)
            close(this);
            this.IsCanceled=true;
        end


        function close(this,~,~)

            if ishandle(this.Dlg)
                close(this.Dlg);
            end
        end


        function delete(this)

            close(this);
        end


        function addOK(this)
            x=this.DlgSize(1)/2-this.ButtonSize(1)-this.ButtonHalfSpace;
            this.OkButton=uicontrol('Parent',this.Dlg,'Callback',@this.onOK,...
            'Position',[x,10,this.ButtonSize],...
            'FontUnits','normalized','FontSize',0.6,'String',...
            getString(message('MATLAB:uistring:popupdialogs:OK')));
        end


        function addCancel(this)
            x=this.DlgSize(1)/2+this.ButtonHalfSpace;
            this.CancelButton=uicontrol('Parent',this.Dlg,...
            'Callback',@this.onCancel,...
            'Position',[x,10,this.ButtonSize],...
            'FontUnits','normalized','FontSize',0.6,'String',...
            getString(message('MATLAB:uistring:popupdialogs:Cancel')));
        end


        function onKeyPress(this,~,evd)
            switch(evd.Key)
            case{'return','space'}
                onOK(this);
            case{'escape'}
                onCancel(this);
            end
        end


        function hasCanceled=addPathOrChangeDirectoryDialog(~,folder,fcn)
            cancelButton=vision.getMessage('vision:uitools:Cancel');
            addToPathButton=vision.getMessage('vision:labeler:addToPath');
            cdButton=vision.getMessage('vision:labeler:cdFolder');

            msg=vision.getMessage(...
            'vision:labeler:notOnPathQuestionAlgImport',fcn,folder);
            dlgTitle=getString(message('vision:labeler:notOnPathTitle'));

            buttonName=questdlg(msg,dlgTitle,...
            cdButton,addToPathButton,cancelButton,cdButton);

            hasCanceled=false;
            switch buttonName
            case cdButton
                cd(folder);
            case addToPathButton
                addpath(folder);
            otherwise
                hasCanceled=true;
            end

        end


        function openTemplate(this)


            filename='CustomAutomationFunctionExample';
            example=fullfile(toolboxdir('vision'),'vision','+vision',...
            '+internal',[filename,'.m']);
            fid=fopen(example);
            contents=fread(fid,'*char');
            fclose(fid);


            close(this);
            this.IsCanceled=true;


            editorDoc=matlab.desktop.editor.newDocument(contents');

            editorDoc.Text=contents;
            editorDoc.smartIndentContents;
            editorDoc.goToLine(1);


            editorDoc.makeActive

        end
    end

end


function location=iWhichFile(name)


    isExistingFile=isequal(exist(name,'file'),2);
    if isExistingFile
        location=which(name,'-all');




        vidx=strcmp('variable',location);
        location(vidx)=[];



        location=location{1};
    else
        location=[];
    end
end