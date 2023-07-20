classdef UIFigureImportDialogView<ee.internal.app.common.ui.ImportDialogView




    properties(SetAccess=private)
simlogVariablePicked
    end

    properties(Access=private)

Parent


        DialogHeight=120


HeaderLabel


MATLABWorkspace


        DialogTitle=getString(message('physmod:ee:harmonicAnalyzer:ImportDialogTitle'))



        HeaderString=getString(message('physmod:ee:harmonicAnalyzer:ImportDialogDescription'))


        AcceptButtonText=getString(message('physmod:ee:harmonicAnalyzer:ImportDialogOKButtonText'))

MainLayout
    end

    properties
InputsDropdown
OKButtonHandle
CancelButtonHandle
RefreshButtonHandle
    end

    methods
        function app=UIFigureImportDialogView()
            app.MATLABWorkspace=ee.internal.app.common.model.MATLABWorkspace;
            app.open();
        end

        function open(app)

            app.createComponents();
            app.updateWithWorkspaceVariables();


            movegui(app.Parent,'center');


            app.Parent.Visible=true;
            drawnow();
        end

        function delete(app)
            delete(app.Parent);
        end
    end

    methods(Access=private)
        function createComponents(app)
            app.Parent=uifigure("Position",[100,100,500,app.DialogHeight],...
            "Visible",false,...
            "CloseRequestFcn",@app.handleCancelClicked,...
            "Name",app.DialogTitle,...
            "Tag","IMPORTDIALOGFIGURE",...
            "WindowStyle","modal");

            app.MainLayout=uigridlayout(app.Parent,...
            "RowHeight",{'fit','fit','fit','fit','fit','fit'},...
            "ColumnWidth",{'1x'});

            app.createHeaderSection();
            app.createDropdownSection();
            app.createButtonSection();
        end

        function createHeaderSection(app)
            layout=uigridlayout(app.MainLayout,...
            "Padding",0,...
            "RowHeight",{'fit'},...
            "ColumnWidth",{'fit'});

            uilabel(layout,"Text",app.HeaderString,...
            "Tag","IMPORTDIALOG_HEADERLABEL");
        end

        function createDropdownSection(app)
            layout=uigridlayout(app.MainLayout,...
            "Padding",0,...
            "RowHeight",{'fit','fit'},...
            "ColumnWidth",{'fit','0.7x','fit'});

            uilabel(layout,...
            "Text",getString(message('physmod:ee:harmonicAnalyzer:ImportDialogInputsLabelText')));
            app.InputsDropdown=uidropdown(layout,...
            "Tooltip",getString(message('physmod:ee:harmonicAnalyzer:ImportDialogInputsDescription')),...
            "Tag","IMPORTDIALOG_INPUTSDROPDOWN");
        end

        function createButtonSection(app)
            layout=uigridlayout(app.MainLayout,...
            "Padding",0,...
            "RowHeight",{'fit'},...
            "ColumnWidth",{'1x','0.5x','0.5x','0.5x'});


            app.RefreshButtonHandle=uibutton(layout,...
            "Text",getString(message('physmod:ee:harmonicAnalyzer:ImportDialogRefreshButtonText')),...
            "ButtonPushedFcn",@app.handleRefreshClicked,...
            "Tag","IMPORTDIALOG_REFRESHBUTTON");
            app.RefreshButtonHandle.Layout.Column=2;


            app.OKButtonHandle=uibutton(layout,"Text",app.AcceptButtonText,...
            "ButtonPushedFcn",@app.handleOKClicked,...
            "Tag","IMPORTDIALOG_OKBUTTON");
            app.OKButtonHandle.Layout.Column=3;


            app.CancelButtonHandle=uibutton(layout,"Text",getString(message('physmod:ee:harmonicAnalyzer:ImportDialogCancelButtonText')),...
            "ButtonPushedFcn",@app.handleCancelClicked,...
            "Tag","IMPORTDIALOG_CANCELBUTTON");
            app.CancelButtonHandle.Layout.Column=4;
        end

        function updateWithWorkspaceVariables(app)
            variables=app.MATLABWorkspace.whos();
            validVariables=cell(1,length(variables));
            if~isempty(variables)
                for variableIdx=1:length(variables)
                    classType=variables(variableIdx).class;
                    switch classType
                    case 'simscape.logging.Node'
                        validVariables{variableIdx}=variables(variableIdx).name;
                    case 'Simulink.SimulationOutput'
                        simOutputContents=who(evalin(...
                        'base',variables(variableIdx).name));
                        for contentIdx=1:length(simOutputContents)
                            variableToCheck=...
                            get(evalin('base',variables(variableIdx).name),simOutputContents{contentIdx});
                            if isa(variableToCheck,'simscape.logging.Node')
                                validVariables{variableIdx}=...
                                strcat(variables(variableIdx).name,'.',simOutputContents{contentIdx});
                            end
                        end
                    end
                end
                variableNames=validVariables(~cellfun(@isempty,validVariables));
            end
            variableExistVector=cellfun(@isempty,validVariables);
            if all(variableExistVector)




                item={getString(message('physmod:ee:harmonicAnalyzer:ImportDialogNoValidVariables'))};

                app.InputsDropdown.Items=item;
                errordlg(getString(message('physmod:ee:harmonicAnalyzer:NoSimlogVariableDetected')))
            else



                app.InputsDropdown.Items=variableNames;

            end
        end

        function handleRefreshClicked(app,~,~)
            app.updateWithWorkspaceVariables();
        end

        function handleOKClicked(app,~,~)
            if~strcmp(app.InputsDropdown.Value,...
                getString(message('physmod:ee:harmonicAnalyzer:ImportDialogNoValidVariables')))

                eventData=ee.internal.app.common.model.EventData(app.InputsDropdown.Value);
                app.notify("ImportDialogDataImported",eventData);


                delete(app.Parent);
            else
                errordlg(getString(message('physmod:ee:harmonicAnalyzer:NoSimlogVariableDetected')))
            end
        end

        function handleCancelClicked(app,~,~)
            app.notify("ImportDialogCancelled");
            delete(app.Parent);
        end
    end
end