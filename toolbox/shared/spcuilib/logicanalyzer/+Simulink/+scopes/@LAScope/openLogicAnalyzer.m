function openLogicAnalyzer(modelName,varargin)




    laScope=Simulink.scopes.LAScope.getLogicAnalyzer(modelName);
    if nargin<2||(nargin>=2&&varargin{1})
        hWebWindow=laScope.WebWindow;
        isObjectValid=isa(hWebWindow,'matlab.internal.webwindow')&&isvalid(hWebWindow);
        notifyLaunching=~(isObjectValid&&hWebWindow.isWindowValid);
        if notifyLaunching
            set_param(modelName,'StatusString',DAStudio.message('Spcuilib:logicanalyzer:StartingLogicAnalyzer'));
            try
                laScope.open();
            catch E
                set_param(modelName,'StatusString','');
                rethrow(E);
            end
            set_param(modelName,'StatusString','');
        else
            laScope.open();
        end
    end
end

