classdef SLPluginTransaction < handle
















properties 
slTxn
txnEvent
mf0Mdl
end 
methods 
function obj = SLPluginTransaction( bdNameOrHdl, eventMeta, pluginName )
R36
bdNameOrHdl
eventMeta mf.zero.meta.Class
pluginName = 'sysarch_app_plugin'
end 

bdHdl = get_param( bdNameOrHdl, 'handle' );


obj.mf0Mdl = systemcomposer.sync.transaction.model.TransactionInfo.createTransactionInfoModel;
txnInfo = systemcomposer.sync.transaction.model.TransactionInfo.getTransactionInfo( obj.mf0Mdl );
obj.txnEvent = txnInfo.addNewEvent( eventMeta );


pluginMgr = Simulink.PluginMgr;
commitOnSave = false;
obj.slTxn = pluginMgr.beginTransaction( bdHdl, pluginName, obj.mf0Mdl, commitOnSave );






obj.slTxn.setTransactionContextInfo( obj.mf0Mdl );
end 

function addEventData( obj, varargin )
for idx = 1:2:length( varargin )
obj.txnEvent.( varargin{ idx } ) = varargin{ idx + 1 };
end 
end 

function delete( obj )
assert( isempty( obj.slTxn ),  ...
'Attempt to delete transaction object without committing it' );
end 

function commitTransaction( obj )
obj.addEventData( 'p_IsProcessed', true );
obj.slTxn.commitTransaction(  );
obj.slTxn = [  ];
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpOxFTtG.p.
% Please follow local copyright laws when handling this file.

