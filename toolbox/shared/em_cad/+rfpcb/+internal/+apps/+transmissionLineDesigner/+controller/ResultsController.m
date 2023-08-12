classdef ResultsController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller






methods 

function obj = ResultsController( Model, App )



R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% ResultsController is created.' )

registerListeners( obj );
end 


function update( obj )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.ResultsController{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.controller.ResultsController;
end 
if ~obj.App.AppContainer.Visible
addGroup2Container( obj.App, 'Group', 'AnalysisGroup' );
addComponent2Container( obj.App, 'Component', 'ResultsDocument' );
obj.App.AppContainer.Visible = true;

createUIComponents( obj.App.ResultsDocument );
end 
end 
end 

methods ( Access = private )

function registerListeners( obj )


obj.App.ResultsDocument.AutoCalculateCheckbox.ValueChangedFcn = @( src, evt )autoCalculateCallback( obj, src, evt );
obj.App.ResultsDocument.CalculateResultsButton.ButtonPushedFcn = @( src, evt )calculateResultsCallback( obj, src, evt );
obj.App.ResultsDocument.ViewModelButton.ButtonPushedFcn = @( src, evt )viewModelCallback( obj, src, evt );
end 


function autoCalculateCallback( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.ResultsController;
src( 1, 1 )matlab.ui.control.CheckBox = [  ];
evt = [  ];%#ok<INUSA>
end 

obj.Model.Results.IsAutoCalculate = src.Value;
obj.App.ResultsDocument.CalculateResultsButton.Enable = ~src.Value;
end 


function calculateResultsCallback( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.ResultsController;
src( 1, 1 )matlab.ui.control.Button = [  ];
evt = [  ];%#ok<INUSA>
end 

compute( obj.Model.Results );
src.Enable = "off";
end 


function viewModelCallback( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.ResultsController;%#ok<INUSA>
src( 1, 1 )matlab.ui.control.Button = [  ];%#ok<INUSA>
evt = [  ];%#ok<INUSA>
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpqYC6TZ.p.
% Please follow local copyright laws when handling this file.

