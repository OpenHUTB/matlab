classdef ConfigurationBase<handle

    properties
FileName
Location
    end

    properties(Dependent)
Layouts
Name
Locale
    end

    properties(Access=private)
MF0Config
MF0Model
    end


    properties(Constant,Hidden,Abstract)
AppId
WidgetTypes
WidgetReportTypes
DefaultConfigFileName
DefaultConfigLocation
    end

    methods

        function obj=ConfigurationBase(mf0config,mf0model)
            obj.MF0Config=mf0config;
            obj.MF0Model=mf0model;
            obj.MF0Config.AppId=obj.AppId;
        end

        function layouts=get.Layouts(this)
            layouts=metric.dashboard.Layout.empty(0,0);
            layoutArray=this.MF0Config.Layouts.toArray;
            for i=1:numel(layoutArray)
                layouts(i)=metric.dashboard.Layout(layoutArray(i),this);
            end
        end

        function out=addLayout(this,id)
            mf0Layout=metric.dashboard.Layout.create(mf.zero.getModel(this.MF0Config),id);
            try
                this.MF0Config.Layouts.add(mf0Layout);
            catch ME
                mf0Layout.destroy();
                if strcmp(ME.identifier,'mf0:messages:UniquenessConstraint')
                    error(message('dashboard:uidatamodel:ExistingLayout',id));
                else
                    rethrow(ME);
                end
            end
            out=metric.dashboard.Layout(mf0Layout,this);
        end

        function removeLayout(this,layout)
            if~isempty(this.MF0Config.Layouts.getByKey(layout.MF0Layout.Name))
                this.MF0Config.Layouts.remove(layout.MF0Layout);
                delete(layout);
            else
                error(message('dashboard:uidatamodel:NonExistingLayout'));
            end
        end


        function name=get.Name(this)
            name=this.MF0Config.Name;
        end

        function set.Name(this,name)
            metric.dashboard.Verify.ScalarCharOrString(name);
            this.MF0Config.Name=name;
        end



        function set.FileName(this,name)
            metric.dashboard.Verify.ScalarCharOrString(name);

            name=string(name);

            if~name.endsWith('.json','IgnoreCase',true)
                name=name+".json";
            end

            this.FileName=char(name);
        end



        function set.Location(this,loc)
            metric.dashboard.Verify.ScalarCharOrString(loc);
            this.Location=char(loc);
        end


        function out=getLayout(this,id)
            tmp=this.MF0Config.Layouts.getByKey(id);
            if isempty(tmp)
                out=metric.dashboard.Layout.empty(0,0);
            else
                out=metric.dashboard.Layout(tmp,this);
            end
        end


        function set.Locale(this,locale)
            if isempty(locale)
                this.MF0Config.Locale=locale;
                return
            end

            locale=matlab.internal.i18n.locale(locale);
            this.MF0Config.Locale=locale.Ctype;
        end

        function locale=get.Locale(this)
            locale=this.MF0Config.Locale;
        end


        function save(this,varargin)

            f=@(x)isstring(x)|ischar(x);

            p=inputParser;
            p.addParameter('FileName',this.FileName,f);
            p.addParameter('Location',this.Location,f);
            p.addParameter('Locale',this.Locale,f);


            p.addParameter('xx_AllowOverWriteDefault_xx',false,@islogical);
            p.parse(varargin{:});

            locale=p.Results.Locale;
            if~isempty(locale)
                locale=matlab.internal.i18n.locale(p.Results.Locale);
                locale=locale.Ctype;
            end


            this.verify();

            filename=string(p.Results.FileName);
            if~filename.endsWith('.json','IgnoreCase',true)
                filename=char(filename+".json");
            end

            location=p.Results.Location;

            if exist(fullfile(location,locale),'dir')~=7
                [status,msg]=mkdir(fullfile(location,locale));
                if status==0
                    error(message('dashboard:uidatamodel:CouldNotCreateFolder',...
                    fullfile(location,locale),msg));
                end
            end

            trgt=fullfile(location,locale,filename);

            if~p.Results.xx_AllowOverWriteDefault_xx&&(exist(trgt,'file')~=0)
                fid=fopen(trgt,'r');
                absTrgt=fopen(fid);
                fclose(fid);

                cmprfcn=@(x,y)strcmpi(x,y);
                if strcmp(computer('arch'),'glnxa64')
                    cmprfcn=@(x,y)strcmp(x,y);
                end

                shippingLocales=getShippingLocales(metaclass(this));
                wouldOverwriteDefault=cmprfcn(absTrgt,fullfile(...
                this.DefaultConfigLocation,...
                this.DefaultConfigFileName));
                for i=1:numel(shippingLocales)
                    wouldOverwriteDefault=wouldOverwriteDefault||...
                    cmprfcn(absTrgt,fullfile(...
                    this.DefaultConfigLocation,...
                    shippingLocales{i},this.DefaultConfigFileName));
                end
                if wouldOverwriteDefault
                    error(message('dashboard:uidatamodel:CantOverwriteDefault'));
                end

            end

            s=mf.zero.io.JSONSerializer;
            s.serializeToFile(this.MF0Config,trgt);
        end



        function verify(this)
            if numel(this.Layouts)==0
                error(message('dashboard:uidatamodel:NoLayouts'));
            end

            for i=1:numel(this.Layouts)
                this.Layouts(i).verify;
            end
        end

    end

    methods(Static,Access=protected)

        function config=newInternal(mc,varargin)
            f=@(x)isstring(x)|ischar(x);
            p=inputParser;
            p.addParameter('FileName','newConfiguration.json',f);
            p.addParameter('Location',pwd,f);
            p.addParameter('Locale','',f);
            p.addParameter('Name','Default',f);
            p.parse(varargin{:});

            mf0=mf.zero.Model;
            mf0config=dashboard.ui.Configuration(mf0);
            constr=str2func(mc.Name);
            config=constr(mf0config,mf0);
            config.FileName=p.Results.FileName;
            config.Location=p.Results.Location;
            config.Name=p.Results.Name;
            config.Locale=p.Results.Locale;
        end

        function config=openInternal(mc,varargin)

            if nargin==1
                dfltFcn=str2func(sprintf('%s.openDefaultConfiguration',mc.Name));
                config=dfltFcn();
                return
            end

            f=@(x)isstring(x)|ischar(x);
            p=inputParser;
            p.addParameter('FileName',f);
            p.addParameter('Location',pwd,f);
            p.addParameter('Locale','',f);
            p.parse(varargin{:});

            filename=string(p.Results.FileName);
            if~filename.endsWith('.json','IgnoreCase',true)
                filename=char(filename+".json");
            end


            locale=p.Results.Locale;
            if~isempty(locale)
                locale=matlab.internal.i18n.locale(locale);
                locale=locale.Ctype;
            else


                dl=matlab.internal.i18n.locale.default;
                if exist(fullfile(p.Results.Location,dl.Ctype,filename),'file')==2
                    locale=dl.Ctype;
                else
                    locale='en_US';
                end
            end

            if strcmp(locale,'en_US')
                locale='';
            end

            jp=mf.zero.io.JSONParser;
            mf0=mf.zero.Model;
            jp.Model=mf0;
            mf0config=jp.parseFile(fullfile(p.Results.Location,locale,filename));
            constr=str2func(mc.Name);
            config=constr(mf0config,mf0);
            config.FileName=filename;
            config.Location=p.Results.Location;
            config.Locale=locale;
        end

        function config=openDefaultConfigurationInternal(mc,varargin)

            f=@(x)isstring(x)|ischar(x);
            dl=matlab.internal.i18n.locale.default;

            p=inputParser;
            p.addParameter('Locale',dl.Ctype,f);
            p.parse(varargin{:});
            locale=matlab.internal.i18n.locale(p.Results.Locale);
            shippingLocales=getShippingLocales(mc);
            switch locale.Ctype
            case 'en_US'
                locale='';
            case shippingLocales
                locale=locale.Ctype;
            otherwise

                if nargin>1
                    error(message('dashboard:uidatamodel:NoDefaultConfigForLocale',...
                    locale.Ctype));
                end
                locale='';
            end

            openFcn=str2func(sprintf('%s.open',mc.Name));
            config=openFcn(...
            'FileName',mc.PropertyList({mc.PropertyList.Name}=="DefaultConfigFileName").DefaultValue,...
            'Location',mc.PropertyList({mc.PropertyList.Name}=="DefaultConfigLocation").DefaultValue,...
            'Locale',locale);
        end
    end

    methods(Static,Abstract)
        config=new(varargin)
        config=open(varargin)
        config=openDefaultConfiguration(varargin)
    end
end

function locales=getShippingLocales(mc)
    folder=mc.PropertyList({mc.PropertyList.Name}=="DefaultConfigLocation").DefaultValue;
    content=dir(folder);
    folders=content([content.isdir]);
    locales={};
    for i=1:numel(folders)
        try

            matlab.internal.i18n.locale(folders(i).name);
            locales{end+1}=folders(i).name;%#ok<AGROW>
        catch
        end
    end
end

