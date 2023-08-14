





























































classdef FloatingPointTargetConfig<handle&fpconfig.DeepCopiable&fpconfig.ReadableMScriptsSerializable

    properties(SetObservable)
Library
LibrarySettings
IPConfig
    end

    properties(Dependent,Hidden=true)
LibraryInt
    end

    properties(Access=private,Constant=true)
        LibraryVals={'ALTERAFPFUNCTIONS','ALTFP','XILINXLOGICORE','NativeFloatingPoint'};
    end

    properties(Access=public,Hidden=true)
m_strategy
    end

    methods
        function obj=FloatingPointTargetConfig(varargin)

            if(nargin==1&&isa(varargin{1},'fpconfig.ConstructArgs'))
                fpconfig.DeepCopiable.initWithPV(obj,varargin{:});
                return;
            end

            if(nargin<1)
                return;
            else
                lib=varargin{1};
            end

            if(nargin>1)
                moreArgs=varargin(2:end);
            else
                moreArgs={};
            end

            obj.Library=lib;
            switch obj.LibraryInt
            case 1
                obj.m_strategy=fpconfig.FrequencyDrivenStrategy;
            case 2
                obj.m_strategy=fpconfig.LatencyDrivenStrategy;
            case 3
                obj.m_strategy=fpconfig.LatencyDrivenStrategy;
            case 4
                obj.m_strategy=fpconfig.NFPLatencyDrivenStrategy;
            otherwise
                assert(false);
            end
            ipconfigPVIdx=find(strcmpi(moreArgs,'IPConfig'));
            if(~isempty(ipconfigPVIdx)&&ipconfigPVIdx<length(moreArgs))
                ipconfigSettings=moreArgs{ipconfigPVIdx+1};
                moreArgs=[moreArgs(1:ipconfigPVIdx-1),moreArgs(ipconfigPVIdx+2:end)];
            else
                ipconfigSettings={};
            end

            obj.IPConfig=hdlcoder.FloatingPointTargetConfig.IPConfig(obj.m_strategy,lib);
            obj.IPConfig.customize(ipconfigSettings);
            obj.LibrarySettings=obj.m_strategy.createModeSettings(moreArgs{:});
        end

        function set.Library(obj,val)
            if(~isequal(val,obj.Library)&&~isempty(obj.Library))
                error(message('hdlcommon:targetcodegen:ConfigObjCannotChangeLib'));
            end
            obj.Library=obj.LibraryVals{strcmpi(val,obj.LibraryVals)};
        end

        function val=get.LibraryInt(obj)
            val=find(strcmpi(obj.Library,obj.LibraryVals));
        end
    end

    methods(Access=public,Hidden=true)
        function obj=copy(this)
            obj=this.deepCopy();
        end

        function savedObj=saveobj(this)
            savedObj.mcode=this.serializeToMCode();
        end

        function mcode=serialize(this)
            mcode=this.serializeToMCode();
        end

        function scripts=serializeOutMScripts(this)
            libSettingStr=this.LibrarySettings.serializeOutMScripts();
            ipConfigStr=this.IPConfig.serializeOutMScripts();
            nfpLib=strcmpi(this.Library,'NATIVEFLOATINGPOINT');
            if nfpLib
                if isempty(libSettingStr)&&strcmpi(ipConfigStr,'{}')
                    scripts=sprintf('hdlcoder.createFloatingPointTargetConfig(''%s'')',this.Library);
                else
                    scripts=sprintf('hdlcoder.createFloatingPointTargetConfig(''%s'' ...\n',this.Library);
                    if(~strcmpi(ipConfigStr,'{}'))
                        if(~isempty(libSettingStr))
                            scripts=sprintf('%s, %s ...\n',scripts,libSettingStr);
                        end
                        scripts=sprintf('%s, ''IPConfig'', ...\n%s) ...\n',scripts,ipConfigStr);
                    else
                        scripts=sprintf('%s, %s) ...\n',scripts,libSettingStr);
                    end
                end
                return;
            end

            scripts=sprintf('hdlcoder.createFloatingPointTargetConfig(''%s'' ...\n',this.Library);
            if(~isempty(libSettingStr))
                scripts=sprintf('%s, %s ...\n',scripts,libSettingStr);
            end

            if(~isempty(ipConfigStr))
                scripts=sprintf('%s, ''IPConfig'', ...\n%s) ...\n',scripts,ipConfigStr);
            end
        end
    end

    methods(Access=public,Hidden=true)
        function str=toString(this)
            str=class(this);
        end

        function str=char(this)
            str=this.toString();
        end
    end

    methods(Static=true)
        function obj=loadobj(savedObj)
            obj=eval(savedObj.mcode);
        end
    end
end




