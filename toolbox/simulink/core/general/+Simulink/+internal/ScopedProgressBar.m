




classdef(Hidden)ScopedProgressBar<handle

    properties(Access=private)
        progressBar=[]
    end

    methods
        function obj=ScopedProgressBar(title)
            try
                obj.progressBar=DAStudio.WaitBar;
                obj.progressBar.setWindowTitle(title);
                obj.progressBar.setLabelText(DAStudio.message('Simulink:tools:MAPleaseWait'));
                obj.progressBar.setCircularProgressBar(true);
                obj.progressBar.setCancelButtonText(DAStudio.message('Simulink:utility:CloseButton'));
                obj.progressBar.show();
            catch Mex %#ok<NASGU>
                obj.progressBar=[];
            end
        end

        function delete(obj)
            if~isempty(obj.progressBar)
                delete(obj.progressBar);
            end
        end
    end

end


