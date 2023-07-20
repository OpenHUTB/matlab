function launchTrimTool(modelToAnalyze,varargin)
















    narginchk(1,2);
    showdialog=0;
    if nargin>1
        showdialog=varargin{1};
    end


    if~bdIsLoaded(modelToAnalyze)
        open_system(modelToAnalyze);
    end

    set_param(modelToAnalyze,'LoadExternalInput','off');
    set_param(modelToAnalyze,'LoadInitialState','off');

    openTrimDlg(modelToAnalyze);

    if showdialog
        d=dialog('Visible','off','WindowStyle','normal','Units','points','Position',[1,1,307.5,120],'Name',...
        getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:TrimToolTitle')),'tag','TrimToolDialog');
        movegui(d,'center');d.Visible='on';
        uicontrol('Parent',d,'Units','points','Position',[116.25,11.25,75,22.5],'String',...
        'Ok','tag','dialogOk',...
        'Callback',@ok_callback);
        uicontrol('Parent',d,'Style','text','Units','points','Position',[15,37.5,277.5,75],...
        'String',getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:TrimToolInstructions')));
    end

    function ok_callback(source,event)%#ok<INUSD>
        delete(d);
        return;
    end

end
