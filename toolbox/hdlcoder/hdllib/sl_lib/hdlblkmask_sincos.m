%

% Copyright 2016 Mathworks, Inc.
function hdlblkmask_sincos(curr_blk_name, ~, OutputFormula, NumDataPoints,...
    TableDataTypeStr,SimulateLUTROMDelay)

% suppress fix point precision loss
Simulink.suppressDiagnostic(curr_blk_name, 'SimulinkFixedPoint:util:fxpParameterPrecisionLoss');
% turn off warning reg precision loss
oldsQuery = warning('query','SimulinkFixedPoint:util:fxpParameterPrecisionLoss');
warning('off','SimulinkFixedPoint:util:fxpParameterPrecisionLoss');
warCleanup = onCleanup(@() warning(oldsQuery.state,...
    'SimulinkFixedPoint:util:fxpParameterPrecisionLoss'));
iport1 = 'u/1';
oport1 = 'x/1';
oport2 = 'y';
oport2_full = [curr_blk_name,'/',oport2];
oport2 = [oport2,'/1'];


% Lookup
switch( OutputFormula )
    case {1,'sin(2*pi*u)'}
        new_name = 'sine hdl';
        refblk = 'Sine HDL Optimized';
    case {2,'cos(2*pi*u)'}
        new_name = 'cosine hdl';
        refblk = 'Cosine HDL Optimized';
    case {3,'exp(2*pi*u)'}
        new_name = 'exp hdl';
        refblk = 'Exp HDL Optimized';
    case {4,'sin(2*pi*u) and cos(2*pi*u)'}
        new_name = 'sincos hdl';
        refblk = 'SinCos HDL Optimized';
    otherwise
        error( ['Unexpected formula => ',OutputFormula] )
end

% find the input and output ports
ins=find_system(curr_blk_name,'FollowLinks','On','LookUnderMasks','On',...
    'SearchDepth',1,'BlockType','Inport');
if isempty(ins)
    delete(warCleanup);
    return
end
outs=find_system(curr_blk_name,'FollowLinks','On','LookUnderMasks','On',...
    'SearchDepth',1,'BlockType','Outport');
blks=find_system(curr_blk_name,'FollowLinks','On','LookUnderMasks','On',...
    'SearchDepth',1,'Regexp','On','BlockType','SubSystem');
blks=setdiff(blks,curr_blk_name);

assert(~isempty(blks),...
    'Previous block not found; this is a serious inconsistency in the block; Check your SL installation');

% delete non-port blocks
blk_only = strsplit( blks{1}, '/');
blk_only = blk_only{end};

if strcmpi(blk_only,new_name)
    update_block_params([curr_blk_name,'/',blk_only], NumDataPoints,...
        TableDataTypeStr, SimulateLUTROMDelay);
    % same block found in subsystem as mask parameter.  nothing to do.
    delete(warCleanup);
    return;
end

% delete the lines input to block
delete_line(curr_blk_name,iport1,[blk_only,'/1']);

% delete the lines output from the block
delete_line(curr_blk_name,[blk_only,'/1'],oport1);

if length(outs) == 2
    delete_line(curr_blk_name,[blk_only,'/2'],oport2)
    delete_block( outs(2) );
end


if ~isempty(blks)
    delete_block( blks );
end
oport2_exists = false;

% Build
full_newblkname = [curr_blk_name,'/',new_name];

add_block(['hdlsllib_helper/',refblk],full_newblkname,'Position',[295 59 445 171]);

add_line(curr_blk_name,iport1,[new_name,'/1']);

add_line(curr_blk_name,[new_name,'/1'],oport1);

switch( OutputFormula )
    case {4,'sin(2*pi*u) and cos(2*pi*u)'}
        oport2_exists = true;
end

if oport2_exists
    add_block( 'built-in/Outport', oport2_full,'Position',[750 153 780 167]);
    add_line(curr_blk_name,[new_name,'/2'],oport2);
end

update_block_params(full_newblkname, NumDataPoints, TableDataTypeStr,...
    SimulateLUTROMDelay);

% Copy Mask Description from upstream block to self.
set_param(curr_blk_name,'MaskDisplay',...
    get_param(full_newblkname,'MaskDisplay'));
delete(warCleanup);
end

function update_block_params(full_newblkname, NumDataPoints,...
    TableDataTypeStr, SimulateLUTROMDelay)
%% transfer block params onto the new block
% make them all strings.
%
% Go through a struct to copy Mask parameters
maskvalues = get_param(full_newblkname,'MaskValues');
masknames = get_param(full_newblkname,'MaskNames');
params = {};
for itr = 1:length(masknames)
    params{end+1} = masknames{itr}; %#ok<*AGROW>
    params{end+1} = maskvalues{itr};
end
maskval = struct(params{:});
maskval.NumDataPoints = num2str(NumDataPoints);
if ( isa(TableDataTypeStr,'Simulink.NumericType') )
    maskval.TableDataTypeStr = TableDataTypeStr.tostring();
else
    maskval.TableDataTypeStr = TableDataTypeStr;
end
if ( SimulateLUTROMDelay )
    maskval.SimulateLUTROMDelay = 'On';
else
    maskval.SimulateLUTROMDelay = 'Off';
end

% copy update mask parameters onto the actual block
try
    set_param(full_newblkname, 'MaskValues',...
        {maskval.NumDataPoints; maskval.TableDataTypeStr; maskval.SimulateLUTROMDelay});
catch mEx
    disp(mEx)
end
end
