function out=gethyperlink(block,varargin)











    h=get_param(block,'Object');

    useJavaScript=false;
    out='';
    if nargin>2
        if~strcmp(varargin{1},'JavaScript')
            return;
        end
        if strcmp(varargin{2},'on')
            useJavaScript=true;
        end
    end

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    try
        ssH=getSourceSubsystemHandle(bdroot(block));
        if~isempty(ssH)

            if~ischar(block)
                block=getfullname(block);
            end
            [~,block]=strtok(block,'/');
            ssBlkName=strrep(get_param(ssH,'Name'),'/','//');
            len=length(ssBlkName);
            if~strncmp(block,['/',ssBlkName,'/'],len+2)

                out=['<i>',rtwhtmlescape(h.getRTWName),'</i>'];
                return
            end
            block=[getfullname(ssH),block(len+2:end)];
        end

        if ischar(block)
            out=h.getHyperlink('BlockPath',block,varargin{:});
        else
            out=h.getHyperlink(varargin{:});
        end
    catch me
        throw(me);
    end


