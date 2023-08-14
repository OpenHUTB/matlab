




































function fc=createFloatingPointTargetConfig(varargin)

    if(nargin<1)
        error(message('hdlcommon:targetcodegen:ConfigObjUnknownLib'));
    else
        lib=varargin{1};
    end

    switch upper(lib)
    case{'NATIVEFLOATINGPOINT'}
        fc=hdlcoder.FloatingPointTargetConfig(varargin{:});
    case{'ALTERAFPFUNCTIONS','ALTFP','XILINXLOGICORE'}
        fc=hdlcoder.FloatingPointTargetConfig(varargin{:});
        table=fc.IPConfig.output();
        if(isempty(table))
            toolName=targetcodegen.targetCodeGenerationUtils.getToolName(lib);
            if~ischar(toolName)
                toolName=char(toolName(1));
            end
            error(message('hdlcommon:targetcodegen:ToolNotSet',lib,toolName));
        end
    otherwise
        error(message('hdlcommon:targetcodegen:ConfigObjUnknownLib'));
    end
end


