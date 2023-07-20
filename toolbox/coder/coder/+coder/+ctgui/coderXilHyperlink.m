



function coderXilHyperlink(targetMode,appId,targetCommandIndex,varargin)




    assert(ischar(targetMode)&&isnumeric(appId)&&isnumeric(targetCommandIndex),'Unexpected argument(s)');

    if strcmp(targetMode,'run')&&any(regexp(targets_hyperlink_manager('get',targetCommandIndex),'^clear[\s]+.+','once'))

        com.mathworks.toolbox.coder.app.MatlabJavaNotifier.publish(appId,'XIL_TERMINATED_FROM_HYPERLINK')
    else

        targets_hyperlink_manager(targetMode,targetCommandIndex,varargin{:});
    end
end