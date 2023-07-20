function this=EditorPrefs(bdhandle)


























    persistent root_instance

    if nargin<1||isequal(bdhandle,0)

        if~isa(root_instance,'Simulink.EditorPrefs'),
            this=Simulink.EditorPrefs;
            root_instance=this;
        else
            this=root_instance;
        end
    else

        this=Simulink.EditorPrefs;
        this.SimulinkHandle=bdhandle;
    end

