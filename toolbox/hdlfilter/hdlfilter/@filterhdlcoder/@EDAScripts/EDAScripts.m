function this=EDAScripts(varargin)





    if nargin==1
        tbfilenames=varargin{1};
    else
        tbfilenames={};
    end
    this=filterhdlcoder.EDAScripts;
    this.initParams(tbfilenames);
    updateEDAScriptSettings(this);

end


function updateEDAScriptSettings(this)%#ok

    toolSelection=this.HdlSynthTool;

    if~strcmpi(toolSelection,'none')

        defaults=this.initEDAScript(toolSelection);

        if isempty(this.SynthesisFilePostFix)
            this.SynthesisFilePostFix=defaults{2};
        end

        if isempty(this.HDLSynthInit)
            this.HDLSynthInit=defaults{4};
        end

        if isempty(this.HDLSynthCmd)
            this.HDLSynthCmd=defaults{6};
        end

        if isempty(this.HDLSynthTerm)
            this.HDLSynthTerm=defaults{8};
        end

    end

end

