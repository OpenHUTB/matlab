classdef RTBParamsDialog < handle

properties ( Transient )
ParentObj;
ParentDlg;
end 

methods 
function this = RTBParamsDialog( parentObj, dlg )
this.ParentObj = parentObj;
this.ParentDlg = dlg;
end 

function schema = getDialogSchema( this )

dataInteg.Type = 'checkbox';
dataInteg.Tag = 'ensureDataIntegrity';
dataInteg.Name = DAStudio.message( 'Simulink:blkprm_prompts:RateTransDataIntegrity' );
dataInteg.Value = this.ParentObj.Adaptation.getConversionOptionValue( 'Integrity' );
dataInteg.Source = this;
dataInteg.ObjectMethod = 'handleEnsureIntegrityChange';
dataInteg.MethodArgs = { '%value' };
dataInteg.ArgDataTypes = { 'mxArray' };
dataInteg.Mode = true;
dataInteg.DialogRefresh = true;
dataInteg.RowSpan = [ 1, 1 ];
dataInteg.ColSpan = [ 1, 1 ];
dataInteg.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeAbstractTooltip' );

deterministic.Type = 'checkbox';
deterministic.Tag = 'ensureDeterministic';
deterministic.Name = DAStudio.message( 'Simulink:blkprm_prompts:RateTransDeterministic' );
deterministic.Value = this.ParentObj.Adaptation.getConversionOptionValue( 'Deterministic' );
deterministic.Source = this;
deterministic.ObjectMethod = 'handleEnsureDeterministicChange';
deterministic.MethodArgs = { '%value' };
deterministic.ArgDataTypes = { 'mxArray' };
deterministic.Mode = true;
deterministic.DialogRefresh = true;
deterministic.RowSpan = [ 2, 2 ];
deterministic.ColSpan = [ 1, 1 ];
deterministic.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeAbstractTooltip' );

ic.Type = 'edit';
ic.Tag = 'initialValue';
ic.Name = DAStudio.message( 'Simulink:blkprm_prompts:AllBlksInitConds' );
ic.NameLocation = 1;
ic.Source = this;
ic.Value = this.ParentObj.Adaptation.getConversionOptionValue( 'InitialConditions' );
ic.ObjectMethod = 'handleInitialConditionsChange';
ic.MethodArgs = { '%value' };
ic.ArgDataTypes = { 'char' };
ic.Graphical = true;
ic.Mode = true;
ic.DialogRefresh = true;
ic.RowSpan = [ 3, 3 ];
ic.ColSpan = [ 1, 1 ];
ic.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ProfileNameTooltip' );

group.Type = 'group';
group.Name = 'Configure Rate Transition';
group.Items = { dataInteg, deterministic, ic };
group.LayoutGrid = [ 3, 1 ];

schema.DialogTitle = '';
schema.Items = { group };
schema.DialogTag = 'systemcomposer_adapter_rtb_params';
schema.Source = this;
schema.Transient = true;
schema.DialogStyle = 'frameless';
schema.ExplicitShow = true;
schema.StandaloneButtonSet = { '' };
schema.CloseMethod = 'onClose';
schema.CloseMethodArgs = { '%dialog' };
schema.CloseMethodArgsDT = { 'handle' };

end 

function setPositionBasedOn( this, prmsDlg, tag )


buttonPos = this.ParentDlg.getWidgetPosition( tag );
defaultPos = prmsDlg.position;
offset = buttonPos( 3:4 ) / 2;


dlgPos = [ buttonPos( 1:2 ) + offset, defaultPos( 3 ), defaultPos( 4 ) ];



screen = get( 0, 'screensize' );

if dlgPos( 1 ) + dlgPos( 3 ) > screen( 3 )

dlgPos( 1 ) = buttonPos( 1 ) - dlgPos( 3 ) + offset( 1 );
end 

if dlgPos( 2 ) + dlgPos( 4 ) > screen( 4 )

dlgPos( 2 ) = buttonPos( 2 ) - dlgPos( 4 ) + offset( 2 );
end 

prmsDlg.position = dlgPos;
end 

function handleEnsureIntegrityChange( this, val )
if ~isequal( this.ParentObj.Adaptation.getConversionOptionValue( 'Integrity' ), val )

this.ParentObj.Adaptation.setConversionOptionValue( 'Integrity', val );
this.ParentObj.setDirty( this.ParentDlg );
end 
end 

function handleEnsureDeterministicChange( this, val )
if ~isequal( this.ParentObj.Adaptation.getConversionOptionValue( 'Deterministic' ), val )

this.ParentObj.Adaptation.setConversionOptionValue( 'Deterministic', val );
this.ParentObj.setDirty( this.ParentDlg );
end 
end 

function handleInitialConditionsChange( this, val )
if ~isequal( this.ParentObj.Adaptation.getConversionOptionValue( 'InitialConditions' ), val )

this.ParentObj.Adaptation.setConversionOptionValue( 'InitialConditions', val );
this.ParentObj.setDirty( this.ParentDlg );
end 
end 

function onClose( this, dlg )




this.handleEnsureIntegrityChange( dlg.getWidgetValue( 'ensureDataIntegrity' ) );
this.handleEnsureDeterministicChange( dlg.getWidgetValue( 'ensureDeterministic' ) );
this.handleInitialConditionsChange( dlg.getWidgetValue( 'initialValue' ) );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpBihodD.p.
% Please follow local copyright laws when handling this file.

