



classdef Properties_SLDD<dds.internal.ui.app.base.OptionBase
    methods
        function obj=Properties_SLDD(env)





            id='Properties_SLDD';
            obj@dds.internal.ui.app.base.OptionBase(id,env);

            obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardSLDDFile');

            obj.DepInfo=struct('Option','Properties_Dictionary','Value',true);
            obj.Indent=1;

            obj.Type='file';
            obj.Value={};
            obj.Value.file=[];
            obj.Value.folder='';
            if~isempty(env.DDConn)
                [obj.Value.folder,fname,ext]=fileparts(env.DDConn.filepath);



                if~endsWith(obj.Value.folder,filesep)
                    obj.Value.folder=[obj.Value.folder,filesep];
                end
                obj.Value.file=[fname,ext];
            end
            obj.Value.browse='dataDictionarySelect';
            obj.Answer='';
        end

        function ret=onNext(obj)


            ret=0;
            if isempty(obj.Value.file)

                return
            end
            files=fullfile(obj.Value.folder,obj.Value.file);
            if isempty(files)
                ret=-1;
                errordlg(DAStudio.message('dds:toolstrip:uiWizardSlddEmptyError'),...
                obj.Env.Gui.Title,'replace');
                return
            end
            obj.Env.start_spin();
            c=onCleanup(@()obj.Env.stop_spin());
            try
                ddConn=Simulink.data.dictionary.open(files);
            catch ex

                ret=-1;
                errordlg(ex.message,...
                obj.Env.Gui.Title,'replace');
                return
            end
            obj.Env.DDConn=ddConn;
            obj.Env.ImportProperties=false;
        end

    end
end


