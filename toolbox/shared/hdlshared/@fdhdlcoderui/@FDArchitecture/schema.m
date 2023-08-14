function schema
%SCHEMA   Define the FDArchitecture class.

%   Author(s): J. Sun
%   Copyright 2008-2018 The MathWorks, Inc.
%     

% store persistent variables
mlock;
pk = findpackage('hdlcoderui');
parentcls = findclass(pk, 'abstracthdlcomps');
pk = findpackage('fdhdlcoderui');
c  = schema.class(pk, 'FDArchitecture',parentcls);

if isempty(findtype('FDHDLCArchitectureType')),
    schema.EnumType('FDHDLCArchitectureType', {'Fully parallel', 'Fully serial','Partly serial','Cascade serial','Distributed arithmetic (DA)'}, [1 2 3 4 5]);
end

if isempty(findtype('CoefficientSourceUIType')),
    schema.EnumType('CoefficientSourceUIType', {'Internal', 'Processor interface'});
end


if isempty(findtype('RAMUIType'))
    schema.EnumType('RAMUIType',{'Registers','Single port RAMs','Dual port RAMs'});
end

p = schema.prop(c, 'Architecture', 'FDHDLCArchitectureType');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'CoefficientMemory', 'RAMUIType');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'ArchitectureEntries', 'mxArray');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

% keep it local and copy to cli at apply time
p = schema.prop(c, 'AddPipelineRegisters', 'bool');
p.AccessFlags.Serialize = 'off';
set(p, 'FactoryValue', false, 'Visible', 'off');

p = schema.prop(c, 'CoefficientSource', 'CoefficientSourceUIType');
p.AccessFlags.Serialize = 'off';
set(p, 'Visible', 'off');

p = schema.prop(c, 'GenerateHDLTestbench', 'bool');
p.AccessFlags.Serialize = 'off';
set(p, 'Visible', 'off');

p = schema.prop(c, 'FoldingFactor', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p, 'Visible', 'off');

p = schema.prop(c, 'FoldingFactorEntry', 'mxArray');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'Multipliers', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'MultipliersEntry', 'mxArray');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'SerialPartition', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'SerialPartitionEntry', 'mxArray');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'FPFoldingFactor', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p, 'Visible', 'off');

p = schema.prop(c, 'FPMultipliers', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'FPSerialPartition', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'FSFoldingFactor', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p, 'Visible', 'off');

p = schema.prop(c, 'FSMultipliers', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'FSSerialPartition', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'CascadeSerialPartition', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

if isempty(findtype('FDHDLPartitionType')),
    schema.EnumType('FDHDLPartitionType', {'Folding factor', 'Multipliers', 'Serial partition'});
end
p = schema.prop(c, 'PartitionModeEntry', 'FDHDLPartitionType');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c, 'DALUTPartition', 'ustring');
p.AccessFlags.Serialize = 'off';
set(p, 'FactoryValue', '-1', 'Visible', 'off');

p = schema.prop(c, 'hdlfilt', 'handle');
p.AccessFlags.Serialize = 'off';
set(p,'Visible', 'off');

p = schema.prop(c,'filterObj','MATLAB array'); 
p.AccessFlags.Serialize = 'off';
set(p, 'Visible', 'off');%, 'SetFunction', @setFilter);

if isempty(findtype('HDLFinalAddersUIType'))
    schema.EnumType('HDLFinalAddersUIType',{'Linear', 'Tree'});
end
p = schema.prop(c, 'FIRAdderStyle', 'HDLFinalAddersUIType');
set(p, 'Visible', 'off');

% Added for support new DA feature
p = schema.prop(c, 'SpecifyFoldingFactor', 'ustring');
set(p, 'FactoryValue', 'Folding factor', 'Visible', 'off');

p = schema.prop(c, 'DAFoldingFactorValue', 'ustring');
set(p, 'Visible', 'off');

p = schema.prop(c, 'DARadixValue', 'ustring');
set(p, 'Visible', 'off');

p = schema.prop(c, 'FoldingFactorEntries', 'mxArray');
set(p, 'FactoryValue', { }, 'Visible', 'off');


p = schema.prop(c, 'DARadixEntries', 'mxArray');
set(p, 'FactoryValue', { }, 'Visible', 'off');


p = schema.prop(c, 'SpecifyLUT', 'ustring');
set(p, 'FactoryValue', 'Address width', 'Visible', 'off');

p = schema.prop(c, 'LUTInputsValue', 'ustring');
set(p, 'Visible', 'off');

p = schema.prop(c, 'LUTPartitionValue', 'ustring');
set(p, 'Visible', 'off');

p = schema.prop(c, 'LUTInputsEntries', 'mxArray');
set(p, 'FactoryValue', { }, 'Visible', 'off');

p = schema.prop(c, 'LUTPartitionEntries', 'mxArray');
set(p, 'FactoryValue', { }, 'Visible', 'off');

p = schema.prop(c, 'DALUTSize', 'int');
set(p, 'FactoryValue', 0, 'Visible', 'off');

% The handle holding the web dialog for partition information
p = schema.prop(c,'webdlgHandle','mxArray'); 
p.AccessFlags.Serialize = 'off';
set(p, 'FactoryValue', [], 'Visible', 'off');

p = schema.prop(c,'reportHandle','mxArray'); 
p.AccessFlags.Serialize = 'off';
set(p, 'FactoryValue', [], 'Visible', 'off');

%
% Methods
%

m = schema.method(c, 'setobject');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'MATLAB array',  'handle'};
s.OutputTypes = {'bool', 'string'};

m = schema.method(c, 'getTabDialogSchema');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'handle', 'string'};
s.OutputTypes = {'mxArray'};

m = schema.method(c, 'getparam');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle' 'handle'};

m = schema.method(c, 'dialogCallback');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'handle', 'handle', 'string'};
s.OutputTypes = {'bool', 'string'};

m = schema.method(c, 'selectComboboxEntry');
s = m.Signature;
s.varargin = 'off';
s.InputTypes = {'handle', 'handle', 'mxArray', 'string', 'mxArray'};

m = schema.method(c, 'selectComboboxEntryCoeffMult');
s = m.Signature;
s.varargin = 'on';
s.InputTypes = {'handle', 'handle', 'mxArray', 'string', 'mxArray', 'handle'};

% [EOF]
