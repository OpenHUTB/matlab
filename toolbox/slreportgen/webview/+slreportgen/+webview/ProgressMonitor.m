classdef ProgressMonitor < handle









properties ( Constant )
ErrorMessagePriority = 1;
WarningMessagePriority = 2;
ImportantMessagePriority = 3;
StandardMessagePriority = 4;
LowLevelMessagePriority = 5;
end 

properties ( SetAccess = private )
Value = 0;
MinValue = 0;
MaxValue = 0;

Message = '';
MessagePriority = [  ];

Parent = [  ];
Children = [  ];
Weights = [  ];
end 

properties ( Access = private )
IsCanceled logical = false;
IsDone logical = false;

LastCalculatedValue;
LastCalculatedPercent;
end 

methods 
function this = ProgressMonitor( minValue, maxValue )
R36
minValue = 0;
maxValue = 0;
end 
this.Value = minValue;
this.MinValue = minValue;
this.MaxValue = maxValue;
end 

function done( this )
if ~this.IsDone
this.setValue( this.MaxValue );
this.IsDone = true;


children = this.Children;
for i = 1:numel( children )
children( i ).done(  );
end 
end 
end 

function cancel( this )
if ~this.IsCanceled
this.IsCanceled = true;


children = this.Children;
for i = 1:numel( children )
children( i ).cancel(  );
end 


root = getRoot( this );
cancel( root );
end 
end 

function tf = isCanceled( this )

tf = this.IsCanceled;
end 

function tf = isDone( this )

tf = this.IsDone;
end 

function setMessage( this, message, priority )
R36
this
message
priority = slreportgen.webview.ProgressMonitor.StandardMessagePriority
end 

if isa( message, 'message' )
this.Message = getString( message );
else 
this.Message = message;
end 
this.MessagePriority = priority;

parent = this.Parent;
if ~isempty( this.Parent )
parent.setMessage( message, priority )
end 
this.update(  );
end 

function setValue( this, value )
assert( ( value >= this.MinValue ) && ( value <= this.MaxValue ) );
this.Value = value;
this.update(  );
end 

function setMinValue( this, minValue )
assert( this.MaxValue >= minValue );
this.MinValue = minValue;
this.LastCalculatedValue =  - 1;
this.update(  );
end 

function setMaxValue( this, maxValue )
assert( maxValue >= this.MinValue );
this.MaxValue = maxValue;
this.LastCalculatedValue =  - 1;
this.update(  );
end 

function out = getPercent( this )
if isequaln( this.Value, this.LastCalculatedValue )
percent = this.LastCalculatedPercent;
else 

percent = double( this.Value - this.MinValue ) / double( this.MaxValue - this.MinValue );
this.LastCalculatedPercent = percent;
this.LastCalculatedValue = this.Value;
end 


n = length( this.Children );
if ( n == 0 )
out = percent;
else 
weight = 1;
childPercents = NaN( 1, n );
for i = 1:n
child = this.Children( i );
childPercents( i ) = getPercent( child );
end 


percents = [ percent, childPercents ];
weights = [ weight;this.Weights ];


isNanIdx = isnan( percents );
percents( isNanIdx ) = [  ];
weights( isNanIdx ) = [  ];

if isempty( percents )
out = NaN;
else 
out = percents * ( weights / sum( weights ) );
end 
end 
end 

function addChild( this, child, weight )
if ( nargin < 3 )
weight = 1;
end 

child.Parent = this;
this.Children = [ this.Children, child ];
this.Weights = [ this.Weights;weight ];
update( this );
end 
end 

methods ( Access = protected )
function update( this )
parent = this.Parent;
if ~isempty( parent )
update( parent );
end 
end 

function root = getRoot( this )
root = this;
parent = this.Parent;
while ~isempty( parent )
root = parent;
parent = parent.Parent;
end 
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQ7qhKN.p.
% Please follow local copyright laws when handling this file.

