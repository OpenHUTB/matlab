function writeAllScripts(this,varargin)




    if this.GenerateCompileDoFile
        this.writeCompileDoFile;
    end

    if this.GenerateSimDoFile
        if nargin>=3
            epl=varargin{1};
            epl_ref=varargin{2};
        else
            [epl,epl_ref]=this.getPortList;
        end
        this.writeSimDoFile(epl,epl_ref);
    end

    if this.GenerateSimProjectFile
        this.writeSimProjFile;
    end

    if this.GenerateSynthesisFile
        if(nargin==4)
            synthtool=varargin{3};
        else
            synthtool=this.HdlSynthTool;
        end



        filtercoder_mode=~strcmpi(hdlcodegenmode(),'slcoder');
        if(this.IsTopModel||filtercoder_mode)
            this.writeSynthesisFile(synthtool);
        end
    end

    if this.GenerateMapFile
        this.writeMapFile;
    end
end
