classdef CommandStrProvider<Simulink.typeeditor.utils.CommandStrProvider






    properties(Access=private)
        Studio sl.interface.dictionaryApp.StudioApp;
    end

    methods(Access=public)
        function this=CommandStrProvider(studio)
            this=this@Simulink.typeeditor.utils.CommandStrProvider();
            this.CommandPackage='sl.interface.dictionaryApp.actions';
            this.Studio=studio;
        end

        function commandStr=getCommandStr(this,commandType)

            baseCommandStr=...
            getCommandStr@Simulink.typeeditor.utils.CommandStrProvider(...
            this,commandType);

            dictPath=this.Studio.getInterfaceDictObj().filepath;
            commandStr=[baseCommandStr,'(''',dictPath,''')'];
        end
    end
end
