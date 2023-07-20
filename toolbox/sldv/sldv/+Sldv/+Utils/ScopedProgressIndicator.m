




classdef ScopedProgressIndicator<handle



    properties(Access=private)
        progressBar=[]
    end

    methods
        function obj=ScopedProgressIndicator(title_id)
            try
                obj.progressBar=DAStudio.WaitBar;
                obj.progressBar.setWindowTitle(getString(message(title_id)));
                obj.progressBar.setLabelText(DAStudio.message('Simulink:tools:MAPleaseWait'));
                obj.progressBar.setCircularProgressBar(true);
                obj.progressBar.show();
            catch Mex %#ok<NASGU>
                obj.progressBar=[];
            end
        end

        function delete(obj)
            if~isempty(obj.progressBar)
                obj.progressBar=[];
            end
        end

        function updateTitle(obj,new_title)
            obj.progressBar.setLabelText(getString(message(new_title)));
        end
    end

end
