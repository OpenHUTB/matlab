

function[success,errormsg,ticks]=validateMinMaxTickIntervalFields(...
    minimumValue,maximumValue,tickInterval,dialog,isSlimDialog,varargin)


    ticks=[];

    scaleType='Linear';
    if(nargin>5)
        scaleType=varargin{1};
    end

    minimumValue=str2double(minimumValue);
    if utils.isValidFloatField(minimumValue)
        success=false;
        param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:Minimum'));
        errormsg=DAStudio.message('SimulinkHMI:dialogs:NonNumericParameter',param);
        if isSlimDialog
            dialog.setWidgetWithError('minimumValue',...
            DAStudio.UI.Util.Error('minimumValue','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

    maximumValue=str2double(maximumValue);
    if utils.isValidFloatField(maximumValue)
        success=false;
        param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:Maximum'));
        errormsg=DAStudio.message('SimulinkHMI:dialogs:NonNumericParameter',param);
        if isSlimDialog
            dialog.setWidgetWithError('maximumValue',...
            DAStudio.UI.Util.Error('maximumValue','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

    isTickIntervalAuto=false;
    if strcmpi(tickInterval,'auto')
        isTickIntervalAuto=true;
    end
    tickInterval=str2double(tickInterval);

    switch scaleType
    case{'Log'}
        [success,errormsg,ticks]=utils.validateForLogScale(...
        dialog,isSlimDialog,minimumValue,maximumValue,tickInterval,isTickIntervalAuto,scaleType);
    case{'Linear'}
        [success,errormsg,ticks]=utils.validateForNonLogScale(...
        dialog,isSlimDialog,minimumValue,maximumValue,tickInterval,isTickIntervalAuto,scaleType);
    end

    if success&&isSlimDialog
        dialog.clearWidgetWithError('minimumValue');
        dialog.clearWidgetWithError('maximumValue');
        dialog.clearWidgetWithError('tickInterval');
    end
end
