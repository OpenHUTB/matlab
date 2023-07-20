classdef ApplicationOptions<handle




    properties(Constant,Access=private)
        OptionsFileName="options.rsp"
        OptionsPartName="/misc/options.rsp";
    end

    properties(Access=private)
ApplicationBackend
    end

    methods(Access=private,Static)
        function result=rspencode(rspdata)




            validateattributes(rspdata,{'struct'},{'nonempty'});

            keys=fieldnames(rspdata);
            lines(length(keys))="";
            lineidx=1;
            for ii=1:length(keys)
                key=keys{ii};
                values=rspdata.(key);
                for jj=1:length(values)
                    value=values(jj);
                    lines(lineidx)=key+"="+value;
                    lineidx=lineidx+1;
                end
            end
            result=lines.join(newline);
        end

        function result=rspdecode(text)



            validateattributes(text,{'string'},{'nonempty'});
            result=struct();
            lines=text.splitlines();
            for ii=1:length(lines)
                line=lines(ii);
                key=line.extractBefore("=");
                value=line.extractAfter("=");

                dv=double(value);
                if~isnan(dv)
                    result.(key)=dv;
                elseif strcmp(value,"true")
                    result.(key)=true;
                elseif strcmp(value,"false")
                    result.(key)=false;
                else
                    result.(key)=value;
                end
            end
        end

        function result=updateStruct(old,new)


            result=old;
            keys=fieldnames(new);
            for ii=1:length(keys)
                key=keys{ii};
                result.(key)=new.(key);
            end
        end
    end

    methods(Access=public)
        function h=ApplicationOptions(application)

            h.ApplicationBackend=application;
        end

        function set(this,varargin)




            parser=inputParser();






            parser.FunctionName="ApplicationOptions.set";
            parser.addParameter("wait",false,@islogical);
            parser.addParameter("stoptime",1,@(x)validateattributes(x,{'numeric'},{'nonnegative','scalar'}));
            parser.addParameter("loglevel","info",@isstring);
            parser.addParameter("pollingThreshold",1e-4,@(x)validateattributes(x,{'numeric'},{'nonnegative','scalar'}));
            parser.addParameter("relativeTimer",false,@islogical);
            parser.addParameter("fileLogMaxRuns",1,@(x)validateattributes(x,{'numeric'},{'positive','integer','scalar'}));
            parser.addParameter("fileLogUseRAM",false,@islogical);
            parser.addParameter("overrideBaseRatePeriod",0.,@(x)validateattributes(x,{'numeric'},{'nonnegative','scalar'}));
            parser.addParameter("startupParameterSet","paramInfo",@isstring);
            parser.addParameter("autoSaveParameterSetOnStop",true,@islogical);
            parser.parse(varargin{:});

            parts=this.ApplicationBackend.list;
            if any(strcmp(this.OptionsPartName,parts))
                part=this.ApplicationBackend.extract(this.OptionsPartName);
                text=string(fileread(part{2}));
                oldoptions=this.rspdecode(text);
            else
                oldoptions=struct();
                part{1}=this.OptionsPartName;
                part{2}=fullfile(this.ApplicationBackend.getWorkingDir,this.OptionsFileName);
            end

            newoptions=rmfield(parser.Results,parser.UsingDefaults);
            if isempty(newoptions)||isempty(fields(newoptions))
                return;
            end
            newoptions=this.updateStruct(oldoptions,newoptions);


            newoptions.fileLogMaxRuns=int32(newoptions.fileLogMaxRuns);

            f=fopen(part{2},'w');
            fwrite(f,this.rspencode(newoptions));
            fclose(f);
            this.ApplicationBackend.add(part{1},part{2});
        end

        function val=get(this,varargin)




            p=inputParser();
            p.addOptional("optionName","default",@(x)assert(isstring(x)&&strlength(x)>0,"Expected non-empty string"));
            p.parse(varargin{:});

            parts=this.ApplicationBackend.list;
            assert(any(strcmp(this.OptionsPartName,parts)));

            part=this.ApplicationBackend.extract(this.OptionsPartName);
            text=string(fileread(part{2}));
            options=this.rspdecode(text);

            if nargin==1
                val=options;
            elseif isfield(options,p.Results.optionName)
                val=options.(p.Results.optionName);
            else
                id='slrealtime:settings:GetUnsetOption';
                msg=message(id,p.Results.optionName);
                ex=MException(id,msg.getString());
                throw(ex);
            end
        end
    end
end


