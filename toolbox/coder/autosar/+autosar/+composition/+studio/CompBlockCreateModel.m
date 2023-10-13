classdef CompBlockCreateModel < handle

    properties ( Access = private )
        CompBlockH;
        ModelBlockH;
        TemplateInfos;
    end

    properties ( Hidden, Constant )
        CreateModelDialogTag = 'AutosarCreateModelDialogTag';
        ModelFileNameTag = 'ModelFileName';
        CreateSimulinkModelTitleID = 'autosarstandard:editor:CreateSimulinkModelTitle';
        TemplateComboTag = 'TemplateCombo';
        BehaviorTypeComboTag = 'behaviorTypeButton';
        BrowseButtonTag = 'browseButton';
    end

    properties ( SetAccess = immutable, GetAccess = private )
        CloseModelListener;
    end

    methods ( Static )
        function launchDialog( compBlkH )

            modelCreator = autosar.composition.studio.CompBlockCreateModel( compBlkH );
            dlg = DAStudio.Dialog( modelCreator );
            dlg.show(  );
        end

        function defaultMdlName = getDefaultMdlName( compBlkH )
            defaultMdlName = autosar.api.Utils.getUniqueModelName(  ...
                get_param( compBlkH, 'Name' ) );
        end
    end

    methods

        function this = CompBlockCreateModel( compBlkH )
            this.CompBlockH = get_param( compBlkH, 'Handle' );


            parentCompositionH = get_param( bdroot( compBlkH ), 'Handle' );
            this.CloseModelListener = Simulink.listener( parentCompositionH,  ...
                'CloseEvent', @CloseModelCB );
        end


        function schema = getDialogSchema( this )


            autosar.api.Utils.autosarlicensed( true );

            row = 1;
            col = 1;


            desc.Type = 'text';
            desc.Tag = 'textDesc';
            desc.RowSpan = [ row, row ];
            desc.ColSpan = [ col, col + 1 ];
            desc.Name = message( 'autosarstandard:editor:CreateSimulinkModelDescription' ).string;

            row = row + 1;
            behaviorCombo = this.getBehaviorTypeCombobox( row, col );

            row = row + 1;


            nameEdit.Type = 'edit';
            nameEdit.Tag = this.ModelFileNameTag;
            nameEdit.Name = message( 'autosarstandard:editor:ModelNamePrompt' ).string;
            nameEdit.NameLocation = 1;
            nameEdit.Source = this;
            nameEdit.Graphical = true;
            nameEdit.Mode = true;
            nameEdit.RowSpan = [ row, row ];
            nameEdit.ColSpan = [ col, col ];
            nameEdit.ToolTip = '';


            nameEdit.Value = autosar.composition.studio.CompBlockCreateModel.getDefaultMdlName( this.CompBlockH );


            browseButton.Type = 'pushbutton';
            browseButton.Tag = this.BrowseButtonTag;
            browseButton.Source = this;
            browseButton.ObjectMethod = 'handleClickBrowseButton';
            browseButton.MethodArgs = { '%dialog' };
            browseButton.ArgDataTypes = { 'handle' };
            browseButton.RowSpan = [ row, row ];
            browseButton.ColSpan = [ col + 1, col + 1 ];
            browseButton.Enabled = true;
            browseButton.ToolTip = '';
            browseButton.FilePath = '';
            browseButton.Name = message( 'SystemArchitecture:SaveAndLink:Browse' ).string;




            row = row + 1;

            templateCombo = this.getTemplateCombobox( row, col );

            group.Type = 'group';
            group.Name = '';
            group.Items = { desc, behaviorCombo, nameEdit, browseButton, templateCombo };
            group.LayoutGrid = [ 1, col + 1 ];

            group.RowSpan = [ 1, 1 ];
            group.ColSpan = [ 1, 2 ];

            panel.Type = 'panel';
            panel.Tag = 'main_panel';
            panel.Items = { group };
            panel.LayoutGrid = [ 5, 2 ];
            panel.RowStretch = [ 0, 0, 0, 1, 0 ];
            panel.ColStretch = [ 1, 0 ];

            schema.DialogTitle = message( this.CreateSimulinkModelTitleID ).string;
            schema.Items = { panel };
            schema.DialogTag = this.CreateModelDialogTag;
            schema.Source = this;
            schema.SmartApply = true;
            schema.PreApplyCallback = 'preApplyCB';
            schema.PreApplyArgs = { this, '%dialog' };
            schema.CloseCallback = 'closeCB';
            schema.CloseArgs = { this, '%dialog' };
            schema.StandaloneButtonSet = { 'Ok', 'Cancel' };
            schema.MinMaxButtons = true;
            schema.ShowGrid = 1;
            schema.DisableDialog = false;
            schema.Sticky = true;
        end

        function [ isValid, msg ] = preApplyCB( this, dlg )



            this.ModelBlockH = [  ];


            modelNameToCreate = dlg.getWidgetValue( this.ModelFileNameTag );


            templateWidgetValue = dlg.getWidgetValue( this.TemplateComboTag );
            if templateWidgetValue == 0
                template = '';
            else
                template = this.TemplateInfos{ templateWidgetValue }.FileName;
            end


            behaviorTypeWidgetValue = dlg.getWidgetValue( this.BehaviorTypeComboTag );
            if behaviorTypeWidgetValue == 0
                behaviorType = systemcomposer.internal.arch.internal.ComponentImplementation.ExportFunction;
            else
                assert( behaviorTypeWidgetValue == 1, 'Unexpected widget value for template behavior' );
                behaviorType = systemcomposer.internal.arch.internal.ComponentImplementation.RateBased;
            end

            [ isValid, ~, msg ] = this.convert( modelNameToCreate, behaviorType, template );
        end

        function [ isValid, msgId, msg ] = convert( this, modelNameToCreate, behaviorType, template )

            arguments
                this
                modelNameToCreate{ mustBeTextScalar, mustBeNonzeroLengthText };
                behaviorType( 1, 1 )systemcomposer.internal.arch.internal.ComponentImplementation =  ...
                    systemcomposer.internal.arch.internal.ComponentImplementation.RateBased;
                template{ mustBeTextScalar } = '';
            end

            isValid = true;
            msgId = '';
            msg = '';


            pb = Simulink.internal.ScopedProgressBar(  ...
                DAStudio.message( 'autosarstandard:editor:CreatingModelProgressMessage' ) );%#ok<NASGU>


            [ ~, nameNoExt, ~ ] = fileparts( modelNameToCreate );
            try

                autosar.api.Utils.autosarlicensed( true );

                componentObj = autosar.arch.Component.create( this.CompBlockH );
                isUIMode = true;

                guard = systemcomposer.internal.saveAndLink.ComponentSaveLinkViaUIGuard(  );
                componentObj.createModelImpl( modelNameToCreate, behaviorType, template, isUIMode );
                delete( guard );
            catch me
                bdclose( nameNoExt );
                isValid = false;
                msg = me.message;
                msgId = me.identifier;
                return ;
            end
        end


        function [ isValid, msg ] = closeCB( this, ~ )
            isValid = true;
            msg = '';



            if ~isempty( this.ModelBlockH ) && ishandle( this.ModelBlockH )
                autosar.composition.studio.CompBlockUtils.routeLinesForBlk( this.ModelBlockH );
            end
        end

        function handleClickBrowseButton( this, dlg )



            dlg.hide;

            newFileName =  ...
                autosar.composition.studio.CompBlockCreateModel.getDefaultMdlName(  ...
                this.CompBlockH );
            [ file, cPath ] = uiputfile( { '*.slx;*.mdl' },  ...
                message( 'SystemArchitecture:SaveAndLink:CreateSimulinkBehaviorName' ).string,  ...
                newFileName );


            dlg.show;

            if ~isequal( file, 0 ) && ~isequal( cPath, 0 )
                dlg.setWidgetValue( this.ModelFileNameTag, fullfile( cPath, file ) );
            end
        end
    end

    methods ( Access = private )
        function templateCombo = getTemplateCombobox( this, row, col )

            this.TemplateInfos = [  ];

            templateCombo.Type = 'combobox';
            templateCombo.Tag = this.TemplateComboTag;
            templateCombo.Name = message( 'SystemArchitecture:SaveAndLink:FromSimTemplate' ).string;
            templateCombo.ToolTip = DAStudio.message( 'SystemArchitecture:SaveAndLink:TemplateSimulinkBehaviorTooltip' );
            templateCombo.NameLocation = 2;



            [ names, infos ] = Simulink.findTemplates( '*', 'Type', 'Model', 'Group', 'My Templates' );
            if ~isempty( infos )

                idxs = cell2mat( cellfun( @( x )~isequal( x.Keywords, { 'Architecture' } ), infos, 'UniformOutput', false ) );
                this.TemplateInfos = infos( idxs );
                fileNames = names( idxs );
                [ ~, templateNames, ~ ] = cellfun( @fileparts, fileNames, 'UniformOutput', false );



                templateCombo.Values = 0:numel( templateNames );
                templateCombo.Entries = [ { message( 'SystemArchitecture:SaveAndLink:TemplateDefault' ).string }, templateNames ];
                templateCombo.Enabled = true;
            else

                templateCombo.Values = 0;
                templateCombo.Entries = { message( 'SystemArchitecture:SaveAndLink:TemplateDefault' ).string };
                templateCombo.Enabled = false;
            end

            templateCombo.Value = message( 'SystemArchitecture:SaveAndLink:TemplateDefault' ).string;
            templateCombo.Source = this;
            templateCombo.Graphical = true;
            templateCombo.RowSpan = [ row, row ];
            templateCombo.ColSpan = [ col, col + 1 ];
        end

        function behaviorCombo = getBehaviorTypeCombobox( this, row, col )

            behaviorCombo.Name = "Type";
            behaviorCombo.Type = 'combobox';
            behaviorCombo.OrientHorizontal = false;
            behaviorCombo.RowSpan = [ row, row ];
            behaviorCombo.ColSpan = [ col, col + 1 ];
            behaviorCombo.Tag = this.BehaviorTypeComboTag;
            behaviorCombo.Entries = {  ...
                message( 'SystemArchitecture:SaveAndLink:ExportFunctionModel' ).getString; ...
                message( 'SystemArchitecture:SaveAndLink:RateBasedModel' ).getString };
            isEnabled = slfeature( 'SoftwareModelingAutosar' ) > 0;

            if isEnabled
                implType =  ...
                    systemcomposer.internal.arch.internal.getDefaultSoftwareComponentImplementation(  ...
                    this.CompBlockH );
                if implType == systemcomposer.internal.arch.internal.ComponentImplementation.RateBased
                    behaviorCombo.Value = 1;
                end
            end
            behaviorCombo.Visible = slfeature( 'SoftwareModelingAutosar' ) > 0;
        end
    end

    methods ( Static, Access = private )

        function [ success, msgId, msg ] = runValidationChecks( m3iComp, compBlkH, mdlToCreate )
            success = true;
            msg = '';
            msgId = '';


            assert( isa( m3iComp, 'Simulink.metamodel.arplatform.component.AtomicComponent' ),  ...
                'Cannot create a model for non-atomic component %s', getfullname( compBlkH ) );


            mdlAlreadyLoaded = ~isempty( find_system( 'type', 'block_diagram', 'Name', mdlToCreate ) );
            if mdlAlreadyLoaded
                msgId = 'autosarstandard:editor:ModelAlreadyLoaded';
                msg = DAStudio.message( msgId, getfullname( compBlkH ), mdlToCreate );
                success = false;
                return ;
            end
        end
    end
end


function CloseModelCB( eventSrc, ~ )
root = DAStudio.ToolRoot;
arDialog = root.getOpenDialogs.find( 'dialogTag',  ...
    autosar.composition.studio.CompBlockCreateModel.CreateModelDialogTag );
for i = 1:length( arDialog )
    dlgSrc = arDialog.getDialogSource(  );
    modelH = get_param( bdroot( dlgSrc.CompBlockH ), 'Handle' );
    if modelH == eventSrc.Handle
        dlgSrc.delete;
        break ;
    end
end
end


