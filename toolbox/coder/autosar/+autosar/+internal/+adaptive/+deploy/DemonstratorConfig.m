classdef DemonstratorConfig<handle





    properties(SetObservable=true,Access=public)
        Host{matlab.internal.validation.mustBeASCIICharRowVector(Host,'Host')}='';
        YoctoDir{matlab.internal.validation.mustBeASCIICharRowVector(YoctoDir,'YoctoDir')}='';
        Image{matlab.internal.validation.mustBeASCIICharRowVector(Image,'Image')}='core-image-apd-devel';
        CloseAction='';
        SshUsername{matlab.internal.validation.mustBeASCIICharRowVector(SshUsername,'SshUsername')}=char.empty;
        SshPassword{matlab.internal.validation.mustBeASCIICharRowVector(SshPassword,'SshPassword')}=char.empty;
    end

    methods(Access=public)
        function dialogclosed(obj,closeaction)
            obj.CloseAction=closeaction;
        end

        function dlgstruct=getDialogSchema(~)




            addressEdit.Name='Demonstrator IP Address: ';
            addressEdit.Type='edit';
            addressEdit.Tag='DemonstratorIPAddress_edit';
            addressEdit.ObjectProperty='Host';

            yoctoRootDir.Name='Yocto Root Directory: ';
            yoctoRootDir.Type='edit';
            yoctoRootDir.Tag='YoctoRootDir_edit';
            yoctoRootDir.ObjectProperty='YoctoDir';

            target.Name='Target: ';
            target.Type='edit';
            target.Tag='Target_edit';
            target.ObjectProperty='Image';

            dlgstruct.Items={addressEdit,yoctoRootDir,target};
            dlgstruct.DialogTitle='Configure Deployment';
            dlgstruct.DialogTag='DemonstratorConfigDialog';
            dlgstruct.StandaloneButtonSet={'Ok','Cancel'};
            dlgstruct.ShowGrid=false;
            dlgstruct.DefaultOk=true;
            dlgstruct.CloseMethodArgs={'%closeaction'};
            dlgstruct.CloseMethodArgsDT={'string'};
            dlgstruct.CloseMethod='dialogclosed';
            dlgstruct.Sticky=true;
        end

        function save(obj)

            config.SshUsername=obj.SshUsername;
            config.Host=obj.Host;
            config.YoctoDir=obj.YoctoDir;
            config.Image=obj.Image;
            save('demonstratorconfig','config');
        end

        function result=validate(obj)


            result=~isempty(obj.Host)&&...
            ~isempty(obj.YoctoDir)&&...
            ~isempty(obj.Image);
        end

        function result=sshValidate(obj)

            result=~isempty(obj.SshUsername)&&...
            ~isempty(obj.SshPassword);
            if~result
                return;
            end
        end
    end

    methods(Access=public,Static=true)
        function obj=load()
            obj=autosar.internal.adaptive.deploy.DemonstratorConfig;
            if exist('demonstratorconfig.mat','file')==2
                loadObj=load('demonstratorconfig','config');
                config=loadObj.config;
                obj.SshUsername=config.SshUsername;
                obj.Host=config.Host;
                obj.YoctoDir=config.YoctoDir;
                obj.Image=config.Image;
            end
        end

        function src=launchUI(varargin)

            if nargin<1
                src=autosar.internal.adaptive.deploy.DemonstratorConfig;
            else
                src=varargin{1};
            end
            src.CloseAction='';
            while(isempty(src.CloseAction))
                pause(.1)
            end
        end
    end
    methods
        function set.SshPassword(obj,value)
            obj.SshPassword=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.SshUsername(obj,value)
            obj.SshUsername=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.Image(obj,value)
            obj.Image=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.YoctoDir(obj,value)
            obj.YoctoDir=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.Host(obj,value)
            obj.Host=matlab.internal.validation.makeCharRowVector(value);
        end
    end
end


