


classdef DeepCopiable<handle

    methods(Hidden=true,Static=true)
        function this=initWithPV(this,construcArgs)
            args=construcArgs.getArgs();
            props=fpconfig.DeepCopiable.getWritableProperties(this);
            p=inputParser;
            for i=1:length(props)
                prop=props{i};
                p.addParameter(prop,[],@(x)(assert(~isempty(x))));
            end
            p.parse(args{:});
            for i=1:length(props)
                prop=props{i};
                this.(prop)=fpconfig.DeepCopiable.assign(p.Results.(prop));
            end
        end
    end

    methods(Access=protected)
        function obj=deepCopy(this)
            mcode=this.serializeToMCode();
            obj=eval(mcode);
        end
    end

    methods(Access=public,Hidden=true)
        function mcode=serializeToMCode(this)
            mcode=sprintf('%s(fpconfig.ConstructArgs(',class(this));
            props=fpconfig.DeepCopiable.getWritableProperties(this);
            for i=1:length(props)
                prop=props{i};
                val=this.(prop);
                valStr=fpconfig.DeepCopiable.getString(val);
                if(i==1)
                    mcode=sprintf('%s''%s'', %s',mcode,prop,valStr);
                else
                    mcode=sprintf('%s, ''%s'', %s',mcode,prop,valStr);
                end
            end
            mcode=sprintf('%s))',mcode);
        end
    end

    methods(Static=true)
        function out=assign(in)
            if(~isa(in,'fpconfig.DeepCopiable'))
                if(~isa(in,'handle'))
                    out=in;
                else
                    assert(false);
                end
            else
                out=in.deepCopy();
            end
        end

        function valStr=getString(val)
            if(~isa(val,'fpconfig.DeepCopiable'))
                if(iscell(val))
                    valStr='';
                    for i=1:length(val)
                        if(i==1)
                            patten='%s%s';
                        else
                            patten='%s, %s';
                        end
                        valStr=sprintf(patten,valStr,fpconfig.DeepCopiable.getString(val{i}));
                    end
                    valStr=sprintf('{%s}',valStr);
                elseif(~isscalar(val)&&~ischar(val))
                    valStr='';
                    for i=1:length(val)
                        if(i==1)
                            patten='%s%s';
                        else
                            patten='%s, %s';
                        end
                        valStr=sprintf(patten,fpconfig.DeepCopiable.getString(val(i)));
                    end
                    valStr=sprintf('[%s]',valStr);
                else
                    try
                        if(ischar(val))
                            valStr=sprintf('''%s''',val);
                        elseif(isnumeric(val))
                            valStr=num2str(val);
                        elseif(islogical(val))
                            if(val)
                                valStr='true';
                            else
                                valStr='false';
                            end
                        else
                            valStr=char(val);
                        end
                    catch me
                        valStr='';
                    end
                end
            else
                valStr=val.serializeToMCode();
            end
        end

        function props=getWritableProperties(c)
            mc=meta.class.fromName(class(c));
            mp=mc.PropertyList;
            props={};
            for i=1:length(mp)
                if(~mp(i).Constant&&~mp(i).Transient&&~mp(i).Dependent)
                    props{end+1}=mp(i).Name;%#ok<AGROW>
                end
            end
        end
    end
end


