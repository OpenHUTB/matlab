function openBirdsEyeScope(modelName,varargin)
    beScope=Simulink.scopes.BirdsEyeUtil.getBirdsEyeScope(modelName,true);
    if nargin<2||(nargin>=2&&varargin{1})
        hWebWindow=beScope.WebWindow;
        isObjectValid=isa(hWebWindow,'matlab.internal.webwindow')&&isvalid(hWebWindow);
        notifyLaunching=~(isObjectValid&&hWebWindow.isWindowValid);
        if notifyLaunching
            set_param(modelName,'StatusString',DAStudio.message('driving:birdseyescope:StartingBirdsEyeScope'));
            try
                beScope.openVisual();
            catch E
                set_param(modelName,'StatusString','');
                rethrow(E);
            end
            set_param(modelName,'StatusString','');
        else
            beScope.openVisual();
        end
    end
end

