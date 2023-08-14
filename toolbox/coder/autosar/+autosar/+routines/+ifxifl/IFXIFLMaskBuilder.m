classdef IFXIFLMaskBuilder<handle





    properties(Constant,Access=private)
        UpdateCallbackStr='autosar.routines.RoutineBlock.updateMaskCallback(gcb);';
    end

    properties(Access=private)
        BlkH;
        InitializationCommands='';
    end

    methods(Access=public)
        function self=IFXIFLMaskBuilder(blkH)
            self.BlkH=blkH;
        end

        function setBlkMaskTitle(~,maskObj)
            blkMaskTitle=maskObj.getDialogControl('DescGroupVar');
            blkMaskTitle.Prompt=maskObj.Type;
        end

        function setHelpTarget(~,maskObj,helpIdentifier)
            maskObj.Help=['helpview([docroot ''/autosar/helptargets.map''], ''',helpIdentifier,''')'];
        end

        function createRoutineImplParameter(~,maskObj,routineImplStr)
            maskObj.addParameter('Type','edit',...
            'Name','RoutineImpl',...
            'Prompt','Routine Implementation',...
            'Value',routineImplStr,...
            'Tunable','off',...
            'Evaluate','on',...
            'Visible','off',...
            'Hidden','off',...
            'Callback','autosar.routines.RoutineCallbacks.clearErrors(gcb)');
        end

        function createMaskHeader(self,maskObj,validRoutines)




            header=maskObj.getDialogControl('DescGroupVar');

            header.addDialogControl('panel','HeaderPanel');
            headerPanel=maskObj.getDialogControl('HeaderPanel');

            [targetRoutineMaskItem,targetRoutineLibDC]=self.addParameter(...
            maskObj,...
            'TargetRoutineLibrary',...
            'radiobutton',...
            {'IFX (fixed-point)';'IFL (floating-point)'},...
            'Prompt','Targeted Routine Library:',...
            'Container','HeaderPanel',...
            'Callback','autosar.routines.RoutineCallbacks.setDefaultDataTypes(gcb);');
            targetRoutineLibDC.Orientation='horizontal';
            targetRoutineLibDC.Tooltip='';
            targetRoutineMaskItem.Value='IFL (floating-point)';

            HeaderText1=headerPanel.addDialogControl('text','HeaderText1');
            HeaderText1.Prompt='Targeted Routine:';
            HeaderText1.WordWrap='off';
            HeaderText1.HorizontalStretch='off';
            HeaderText1.Tooltip='';

            HeaderText2=headerPanel.addDialogControl('text','TargetedRoutineText');
            HeaderText2.Prompt='No Valid Routine';
            HeaderText2.Row='current';
            HeaderText2.WordWrap='off';
            HeaderText2.HorizontalStretch='off';
            HeaderText2.Tooltip='';

            HeaderText3=headerPanel.addDialogControl('text','HeaderText3');
            HeaderText3.Prompt=' ';
            HeaderText3.Row='current';
            HeaderText3.WordWrap='off';
            HeaderText3.HorizontalStretch='on';
            HeaderText3.Tooltip='';

            self.addParameter(...
            maskObj,...
            'TargetedRoutine',...
            'popup',...
            [validRoutines,'No Valid Routine'],...
            'Container','HeaderPanel',...
            'Visible','off');
        end

        function createMaskTabs(self,maskObj,hideDTTab)


            if nargin<3
                hideDTTab=false;
            end

            tabCont=maskObj.addDialogControl('tabcontainer','TabContainer');

            tabCont.addDialogControl('tab','Tab1');
            self.setDialogControlSetting(maskObj,'Tab1','Prompt','Table Specification');

            tabCont.addDialogControl('tab','Tab2');
            self.setDialogControlSetting(maskObj,'Tab2','Prompt','Algorithm');

            if~hideDTTab
                tabCont.addDialogControl('tab','Tab3');
                self.setDialogControlSetting(maskObj,'Tab3','Prompt','Data Types');
            end
        end

        function createTableSpecification(self,maskObj,tabName,dataSpecName,tableObjectName,tableDataName)


            callbacks=[...
            'autosar.routines.RoutineCallbacks.updateIndexSearchOptions(gcb,''',dataSpecName,''');',...
            'autosar.routines.RoutineCallbacks.updateDataTypeOptions(gcb,''',dataSpecName,''');',...
            'autosar.routines.RoutineCallbacks.setDefaultDataTypes(gcb);',...
            'autosar.routines.RoutineCallbacks.updateBreakpointOptions(gcb,''',dataSpecName,''');'];
            self.promoteParameter(...
            maskObj,tabName,dataSpecName,...
            'Prompt','Data Specification:',...
            'PromptLocation','left',...
            'Callback',callbacks);

            self.promoteParameter(...
            maskObj,tabName,tableObjectName,...
            'Prompt','Name:',...
            'PromptLocation','left');

            self.promoteParameter(...
            maskObj,tabName,tableDataName,...
            'Prompt','Table Data:',...
            'PromptLocation','left');
        end

        function createLookupTableEditButton(~,maskObj,tabName)


            tab=maskObj.getDialogControl(tabName);
            tab.addDialogControl('panel','EditPanel');
            editPanel=maskObj.getDialogControl('EditPanel');

            editButton=editPanel.addDialogControl('pushbutton','EditButton');
            editButton.Prompt='Edit table and breakpoints...';
            editButton.Row='current';
            editButton.HorizontalStretch='off';
            editButton.Tooltip='';
            editButton.Callback='sltbledit(''create'', gcb)';

            buttonSpacer=editPanel.addDialogControl('text','ButtonSpacer');
            buttonSpacer.Prompt=' ';
            buttonSpacer.Row='current';
            buttonSpacer.WordWrap='off';
            buttonSpacer.HorizontalStretch='on';
            buttonSpacer.Tooltip='';
        end

        function createPrelookupBreakpointSpecification(self,maskObj,tabName)



            breakpointsData1Name='BreakpointsData';
            breakpointsObject='BreakpointObject';

            callbacks=['autosar.routines.RoutineCallbacks.showParamIfParameterHasValue(gcb,''',breakpointsData1Name,''',''BPSpecification'',''Explicit values'');'...
            ,'autosar.routines.RoutineCallbacks.showParamIfParameterHasValue(gcb,''',breakpointsObject,''',''BPSpecification'',''Breakpoint object'');'...
            ,'autosar.routines.RoutineCallbacks.enableParamIfParameterHasValue(gcb,''',breakpointsData1Name,''',''BPSpecification'',''Explicit values'');'...
            ,'autosar.routines.RoutineCallbacks.enableParamIfParameterHasValue(gcb,''',breakpointsObject,''',''BPSpecification'',''Breakpoint object'');'...
            ,'autosar.routines.RoutineCallbacks.setDefaultDataTypes(gcb);'];
            self.addLimitedParameter(...
            maskObj,...
            'BPSpecification',...
            'BreakpointsSpecification',...
            {'Explicit values','Breakpoint object'},...
            'Container',tabName,...
            'Prompt','Breakpoints Specification:',...
            'PromptLocation','left',...
            'Callback',callbacks);

            self.promoteParameter(...
            maskObj,tabName,breakpointsData1Name,...
            'Prompt','Breakpoints:',...
            'PromptLocation','left');

            self.promoteParameter(...
            maskObj,tabName,breakpointsObject,...
            'Prompt','Name:',...
            'PromptLocation','left');
        end

        function createBreakpointSpecification(self,maskObj,tabName,dimensionality,dataSpecName)



            assert(dimensionality>0,'dimensionality should be greater than 0');
            assert(dimensionality<=2,'dimensionality should be no greater than 2');

            tab=maskObj.getDialogControl(tabName);


            breakpointsSpecName='BreakpointsSpecification';


            breakpointsData1Name='BreakpointsForDimension1';
            breakpointsFirst1Name='BreakpointsForDimension1FirstPoint';
            breakpointsSpacing1Name='BreakpointsForDimension1Spacing';


            breakpointsData2Name='BreakpointsForDimension2';
            breakpointsFirst2Name='BreakpointsForDimension2FirstPoint';
            breakpointsSpacing2Name='BreakpointsForDimension2Spacing';

            callback=['autosar.routines.RoutineCallbacks.updateIndexSearchOptions(gcb,''',dataSpecName,''');',...
            'autosar.routines.RoutineCallbacks.updateDataTypeOptions(gcb,''',dataSpecName,''');'];
            if dimensionality==2
                callback=[callback,'autosar.routines.RoutineCallbacks.updateBreakpointOptions(gcb,''',dataSpecName,''');'];
            end

            self.promoteParameter(...
            maskObj,tabName,breakpointsSpecName,...
            'Prompt','Breakpoints Specification:',...
            'PromptLocation','left',...
            'Callback',callback);

            if dimensionality==1
                self.promoteParameter(...
                maskObj,tabName,breakpointsData1Name,...
                'Prompt','Breakpoints:',...
                'PromptLocation','left');

                self.promoteParameter(...
                maskObj,tabName,breakpointsFirst1Name,...
                'Prompt','First point:',...
                'PromptLocation','top',...
                'Row','new');

                self.promoteParameter(...
                maskObj,tabName,breakpointsSpacing1Name,...
                'Prompt','Spacing:',...
                'PromptLocation','top',...
                'Row','current');
            else
                self.promoteParameter(...
                maskObj,tabName,breakpointsData1Name,...
                'Prompt','Breakpoints 1:',...
                'PromptLocation','left');

                self.promoteParameter(...
                maskObj,tabName,breakpointsData2Name,...
                'Prompt','Breakpoints 2:',...
                'PromptLocation','left');

                bpTextPanel1=tab.addDialogControl('panel','TextGroup1');
                bpText1=bpTextPanel1.addDialogControl('text','Text1');
                bpText1.Prompt=' ';
                bpText2=bpTextPanel1.addDialogControl('text','Text2');
                bpText2.Prompt='Breakpoints 1:';

                self.promoteParameter(...
                maskObj,tabName,breakpointsFirst1Name,...
                'Prompt','First point:',...
                'PromptLocation','top',...
                'Row','current');

                self.promoteParameter(...
                maskObj,tabName,breakpointsSpacing1Name,...
                'Prompt','Spacing:',...
                'PromptLocation','top',...
                'Row','current');

                bpTextPanel2=tab.addDialogControl('panel','TextGroup2');
                bpText3=bpTextPanel2.addDialogControl('text','Text3');
                bpText3.Prompt='Breakpoints 2:';
                bpText3.Row='new';

                self.promoteParameter(...
                maskObj,tabName,breakpointsFirst2Name,...
                'Row','current');

                self.promoteParameter(...
                maskObj,tabName,breakpointsSpacing2Name,...
                'Row','current');
            end
        end

        function createIndexSearchSpecification(self,maskObj,tabName,searchOptions)


            assert(numel(searchOptions)>1,'Expected more than one option');

            tab=maskObj.getDialogControl(tabName);
            tab.addDialogControl(...
            'Type','group',...
            'Name','IndexSearchGroup',...
            'Prompt','Index search settings');

            callbacks=[...
            'autosar.routines.RoutineCallbacks.disableParamIfParameterHasValue(gcb,''BeginIndexSearchUsingPreviousIndexResult'',''IndexSearchMode'',''Evenly spaced points'');',...
            'autosar.routines.RoutineCallbacks.hideParamIfParameterHasValue(gcb,''BeginIndexSearchUsingPreviousIndexResult'',''IndexSearchMode'',''Evenly spaced points'');',...
            ];
            self.addLimitedParameter(...
            maskObj,...
            'IndexSearchMode',...
            'IndexSearchMethod',...
            searchOptions,...
            'Container','IndexSearchGroup',...
            'Prompt','Index Search Method:',...
            'PromptLocation','left',...
            'Callback',callbacks);

            self.promoteParameter(...
            maskObj,'IndexSearchGroup','BeginIndexSearchUsingPreviousIndexResult',...
            'Prompt','Begin index search using previous index result');
        end

        function createInterpolationSpecification(self,maskObj,tabName,interpOptions)


            if numel(interpOptions)>0
                self.addLimitedParameter(...
                maskObj,...
                'InterpMode',...
                'InterpMethod',...
                interpOptions,...
                'Container',tabName,...
                'Prompt','Interpolation Method:',...
                'PromptLocation','left');
            end

            self.addLimitedParameter(...
            maskObj,...
            'RndMode',...
            'RndMeth',...
            {'Round','Zero'},...
            'Container',tabName,...
            'Prompt','Integer Rounding Method:',...
            'PromptLocation','left');
        end

        function createLookupDataTypeSpecification(self,maskObj,tabName)



            callbackStr='autosar.routines.RoutineCallbacks.setDefaultDataTypes(gcb);';

            self.promoteParameter(...
            maskObj,tabName,'TableDataTypeStr',...
            'Prompt','Table data:',...
            'PromptLocation','left',...
            'Callback',callbackStr);

            self.addInitializationCallback(callbackStr);
        end

        function createBreakpointDataTypeSpecification(self,maskObj,tabName,dimensions,isPrelookup)



            if nargin<5
                isPrelookup=false;
            end


            hideParameterStr={'Visible','off','Hidden','on'};




            if dimensions==1
                if isPrelookup
                    dataTypeStr='BreakpointDataTypeStr';
                    self.promoteParameter(...
                    maskObj,tabName,dataTypeStr,...
                    'Prompt','Breakpoints:',...
                    'PromptLocation','left');
                else
                    dataTypeStr='BreakpointsForDimension1DataTypeStr';
                    self.promoteParameter(...
                    maskObj,tabName,dataTypeStr,...
                    'Prompt','Breakpoints:',...
                    hideParameterStr{:});
                end

            else

                assert(dimensions==2,'Dimensionality cannot be higher than 2');
                self.promoteParameter(...
                maskObj,tabName,'BreakpointsForDimension1DataTypeStr',...
                'Prompt','Breakpoints 1:',...
                hideParameterStr{:});

                self.promoteParameter(...
                maskObj,tabName,'BreakpointsForDimension2DataTypeStr',...
                'Prompt','Breakpoints 2:',...
                hideParameterStr{:});
            end
        end

        function createLookupTableWidget(self,maskObj,dimensions)


            lookupWidget=maskObj.addDialogControl('lookuptablecontrol','LookupWidget');

            if dimensions==1
                breakpoints(1)=Simulink.dialog.LookupTableControl.Breakpoint;
                breakpoints(1).Name='BreakpointsForDimension1';
                breakpoints(1).FieldName='Breakpoints';
            else
                breakpoints(1)=Simulink.dialog.LookupTableControl.Breakpoint;
                breakpoints(1).Name='BreakpointsForDimension1';
                breakpoints(1).FieldName='Breakpoints 1';

                breakpoints(2)=Simulink.dialog.LookupTableControl.Breakpoint;
                breakpoints(2).Name='BreakpointsForDimension2';
                breakpoints(2).FieldName='Breakpoints 2';
            end

            lookupWidget.Table.Name='Table';
            lookupWidget.LookupTableObject='LookupTableObject';
            lookupWidget.DataSpecification='DataSpecification';
            lookupWidget.Breakpoints=breakpoints;


            callbackStr='autosar.routines.RoutineCallbacks.hideDCIfParameterHasValue(gcb,"LookupWidget","BreakpointsSpecification","Even spacing");';
            self.addInitializationCallback(callbackStr);
        end

        function createPortConstraints(self,maskObj,portIdentifiers)
            self.createPortIdentifiers(maskObj);
            self.createTypePortConstraints(maskObj);

            for ii=1:numel(portIdentifiers)
                maskObj.addPortConstraintAssociation('constraint_ifl_warn',portIdentifiers{ii});
                maskObj.addPortConstraintAssociation('constraint_ifl_err',portIdentifiers{ii});
                maskObj.addPortConstraintAssociation('constraint_ifx_warn',portIdentifiers{ii});
                maskObj.addPortConstraintAssociation('constraint_ifx_err',portIdentifiers{ii});
            end
        end

        function applyMaskInitialization(self,maskObj)


            maskObj.Initialization=[self.InitializationCommands,maskObj.Initialization];
        end
    end

    methods(Access=private)
        function[maskItem,dialogControl]=addParameter(self,maskObj,name,type,typeOptions,varargin)
            p=inputParser;
            addRequired(p,'MaskObj');
            addRequired(p,'Name');
            addRequired(p,'Type');
            addRequired(p,'TypeOptions');
            addParameter(p,'Prompt','');
            addParameter(p,'Container','');
            addParameter(p,'Callback','');
            addParameter(p,'Hidden','off');
            addParameter(p,'Visible','on');
            addParameter(p,'PromptLocation','top');
            addParameter(p,'Row','new');

            parse(p,maskObj,name,type,typeOptions,varargin{:});

            if strcmp(p.Results.Type,'promote')
                p.Results.MaskObj.addParameter(...
                'Type',p.Results.Type,...
                'Container',p.Results.Container,...
                'TypeOptions',p.Results.TypeOptions);
                maskItem=maskObj.getParameter(p.Results.Name);
                if~isempty(p.Results.Prompt)
                    maskItem.Prompt=p.Results.Prompt;
                end
            else
                p.Results.MaskObj.addParameter(...
                'Type',p.Results.Type,...
                'Name',p.Results.Name,...
                'Prompt',p.Results.Prompt,...
                'Container',p.Results.Container,...
                'TypeOptions',p.Results.TypeOptions);
                maskItem=maskObj.getParameter(p.Results.Name);
            end

            maskItem.Hidden=p.Results.Hidden;
            maskItem.Visible=p.Results.Visible;
            dialogControl=maskItem.DialogControl;
            if isprop(dialogControl,'PromptLocation')
                dialogControl.PromptLocation=p.Results.PromptLocation;
            end
            dialogControl.Row=p.Results.Row;
            maskItem.Callback=[p.Results.Callback,self.UpdateCallbackStr];
        end

        function[maskItem,dialogControl]=promoteParameter(self,maskObj,containerName,parameterName,varargin)
            assert(~isempty(parameterName),'Parameter name cannot be empty');

            extraArgs={'Container',containerName};
            extraArgs=[extraArgs,varargin];

            [maskItem,dialogControl]=self.addParameter(...
            maskObj,...
            parameterName,...
            'promote',...
            {parameterName},...
            extraArgs{:});
        end

        function[maskItem,dialogControl]=addLimitedParameter(self,maskObj,name,rootName,validOptions,varargin)
            callbackIdx=find(cellfun(@(x)strcmp(x,'Callback'),varargin));
            if~isempty(callbackIdx)
                callbackStr=varargin{callbackIdx+1};
                varargin(callbackIdx:callbackIdx+1)=[];
            else
                callbackStr='';
            end

            callback=sprintf('%sautosar.routines.RoutineCallbacks.propagateParam(gcb,''%s'',''%s'');',callbackStr,name,rootName);
            [maskItem,dialogControl]=self.addParameter(...
            maskObj,...
            name,...
            'popup',...
            validOptions,...
            'Callback',callback,...
            varargin{:});

            self.addInitializationCallback(callback);


            autosar.routines.RoutineCallbacks.propagateParam(self.BlkH,name,rootName);
        end

        function setDialogControlSetting(~,maskObj,dialogControlName,setting,prompt)
            dialogControl=maskObj.getDialogControl(dialogControlName);
            assert(~isempty(dialogControl),'Invalid dialog control name');
            dialogControl.(setting)=prompt;
        end

        function addInitializationCallback(self,callbackStr)
            self.InitializationCommands=[self.InitializationCommands,callbackStr];
        end

        function createPortIdentifiers(self,maskObj)

            ph=get_param(self.BlkH,'PortHandles');

            for ii=1:numel(ph.Inport)
                portNumber=num2str(get(ph.Inport(ii),'PortNumber'));
                pi=Simulink.Mask.PortIdentifier;
                pi.Name=sprintf('input_%s',portNumber);
                pi.Identifier=portNumber;
                pi.Type='Input';
                maskObj.addPortIdentifier(pi);
            end

            for ii=1:numel(ph.Outport)
                portNumber=num2str(get(ph.Outport(ii),'PortNumber'));
                pi=Simulink.Mask.PortIdentifier;
                pi.Name=sprintf('output_%s',portNumber);
                pi.Identifier=portNumber;
                pi.Type='Output';
                maskObj.addPortIdentifier(pi);
            end
        end

        function createTypePortConstraints(self,maskObj)


            self.addParameter(maskObj,...
            'DiagMode',...
            'radiobutton',...
            {'Error';'Warning'},...
            'Visible','off',...
            'Hidden','on');



            ifl_pc=maskObj.addPortConstraint('Name','constraint_ifl_err');
            ifl_pc.Rule.DataType={'single'};
            ifl_pc.DiagnosticLevel='error';
            ifl_pc.DiagnosticMessage='autosarstandard:routines:InvalidRoutineSignal';
            ifl_pc.addParameterCondition('Name','TargetRoutineLibrary','Values',{'IFL (floating-point)'});
            ifl_pc.addParameterCondition('Name','DiagMode','Values',{'Error'});


            ifl_pc2=maskObj.addPortConstraint('Name','constraint_ifl_warn');
            ifl_pc2.Rule.DataType={'single'};
            ifl_pc2.DiagnosticLevel='warning';
            ifl_pc2.DiagnosticMessage='autosarstandard:routines:InvalidRoutineSignal';
            ifl_pc2.addParameterCondition('Name','TargetRoutineLibrary','Values',{'IFL (floating-point)'});
            ifl_pc2.addParameterCondition('Name','DiagMode','Values',{'Warning'});


            ifx_pc=maskObj.addPortConstraint('Name','constraint_ifx_err');
            ifx_pc.Rule.DataType={'int8','uint8','int16','uint16','fixedpoint'};
            ifx_pc.Rule.FixedPointConstraint(1).WordLength='[8 16]';
            ifx_pc.DiagnosticLevel='error';
            ifx_pc.DiagnosticMessage='autosarstandard:routines:InvalidRoutineSignal';
            ifx_pc.addParameterCondition('Name','TargetRoutineLibrary','Values',{'IFX (fixed-point)'});
            ifx_pc.addParameterCondition('Name','DiagMode','Values',{'Error'});


            ifx_pc2=maskObj.addPortConstraint('Name','constraint_ifx_warn');
            ifx_pc2.Rule.DataType={'int8','uint8','int16','uint16','fixedpoint'};
            ifx_pc2.Rule.FixedPointConstraint(1).WordLength='[8 16]';
            ifx_pc2.DiagnosticLevel='warning';
            ifx_pc2.DiagnosticMessage='autosarstandard:routines:InvalidRoutineSignal';
            ifx_pc2.addParameterCondition('Name','TargetRoutineLibrary','Values',{'IFX (fixed-point)'});
            ifx_pc2.addParameterCondition('Name','DiagMode','Values',{'Warning'});
        end
    end
end







